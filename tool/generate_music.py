"""Generates Sprout's gentle background music: one seamless loop per plot.

Everything is synthesised here (harp-like plucks, music-box bells, marimba,
soft pads, a light bass and a little reverb), so the music is original and free
to use. Needs numpy and ffmpeg. Run from the repository root:

    python3 tool/generate_music.py
"""
import os
import random
import subprocess
import tempfile
import wave

import numpy as np

RATE = 22050
OUT = "assets/music"
TAIL = 5.0  # seconds of ringing that wrap back to the start, so the loop has no seam

NOTE_INDEX = {"C": 0, "C#": 1, "Db": 1, "D": 2, "D#": 3, "Eb": 3, "E": 4, "F": 5, "F#": 6, "Gb": 6, "G": 7,
              "G#": 8, "Ab": 8, "A": 9, "A#": 10, "Bb": 10, "B": 11}


def midi(name):
    """'C4' -> 60, 'F#3' -> 54."""
    pitch, octave = name[:-1], int(name[-1])
    return 12 * (octave + 1) + NOTE_INDEX[pitch]


def hz(m):
    return 440.0 * 2 ** ((m - 69) / 12)


def env(n, attack, decay):
    t = np.arange(n) / RATE
    return np.minimum(1, t / max(attack, 1e-4)) * np.exp(-decay * t)


# --- Instruments --------------------------------------------------------------

def pluck(f, dur, bright=1.0):
    """A soft harp or guitar pluck: harmonics that fade faster the higher they are."""
    n = int(dur * RATE)
    t = np.arange(n) / RATE
    out = np.zeros(n)
    for k in range(1, 7):
        if f * k > RATE / 2.2:
            break
        out += (bright ** (k - 1)) / k ** 1.6 * np.sin(2 * np.pi * f * k * t) * np.exp(-t * (2.2 + 1.6 * k))
    return out * np.minimum(1, t / 0.004)


def bell(f, dur):
    """A music-box bell: a pure tone with a few gentle inharmonic partials."""
    n = int(dur * RATE)
    t = np.arange(n) / RATE
    out = np.sin(2 * np.pi * f * t) * np.exp(-t * 2.6)
    out += 0.3 * np.sin(2 * np.pi * f * 2.0 * t) * np.exp(-t * 5)
    out += 0.12 * np.sin(2 * np.pi * f * 3.01 * t) * np.exp(-t * 9)
    return out * np.minimum(1, t / 0.002)


def marimba(f, dur):
    n = int(dur * RATE)
    t = np.arange(n) / RATE
    out = np.sin(2 * np.pi * f * t) * np.exp(-t * 5.5) + 0.25 * np.sin(2 * np.pi * f * 3.93 * t) * np.exp(-t * 16)
    return out * np.minimum(1, t / 0.003)


def flute(f, dur):
    """A breathy, soft lead with a slow vibrato."""
    n = int(dur * RATE)
    t = np.arange(n) / RATE
    vib = 1 + 0.004 * np.sin(2 * np.pi * 5 * t) * np.minimum(1, t / 0.4)
    phase = 2 * np.pi * np.cumsum(f * vib) / RATE
    tone = np.sin(phase) + 0.15 * np.sin(2 * phase)
    shape = np.minimum(1, t / 0.12) * np.minimum(1, (dur - t) / 0.25).clip(0, 1)
    return tone * shape


def pad(freqs, dur):
    """A warm pad: each note is three slightly detuned sines, swelling in and out."""
    n = int(dur * RATE)
    t = np.arange(n) / RATE
    out = np.zeros(n)
    for f in freqs:
        for cents in (-6, 0, 6):
            g = f * 2 ** (cents / 1200)
            out += np.sin(2 * np.pi * g * t + random.random() * 6.28)
    shape = np.minimum(1, t / 1.4) * np.minimum(1, (dur - t) / 1.2).clip(0, 1)
    return out * shape / (3 * len(freqs))


def bass(f, dur):
    n = int(dur * RATE)
    t = np.arange(n) / RATE
    return (np.sin(2 * np.pi * f * t) + 0.2 * np.sin(4 * np.pi * f * t)) * env(n, 0.01, 2.2)


INSTRUMENTS = {"pluck": pluck, "bell": bell, "marimba": marimba, "flute": flute, "bass": bass}


# --- Effects ------------------------------------------------------------------

def _comb(x, delay, gain):
    y = x.copy()
    for start in range(delay, len(y), delay):
        end = min(start + delay, len(y))
        y[start:end] += gain * y[start - delay:end - delay]
    return y


def _allpass(x, delay, gain):
    y = np.zeros_like(x)
    y[:delay] = -gain * x[:delay]
    for start in range(delay, len(x), delay):
        end = min(start + delay, len(x))
        y[start:end] = -gain * x[start:end] + x[start - delay:end - delay] + gain * y[start - delay:end - delay]
    return y


def reverb(x, wet=0.28):
    """A small Schroeder reverb, softened a little so it stays warm."""
    soft = np.convolve(x, np.ones(4) / 4, mode="same")
    combs = sum(_comb(soft, d, g) for d, g in ((558, 0.80), (594, 0.79), (639, 0.78), (678, 0.77))) / 4
    tail = _allpass(_allpass(combs, 278, 0.6), 112, 0.6)
    return x * (1 - wet) + tail * wet


# --- Songs --------------------------------------------------------------------

class Song:
    def __init__(self, bpm, beats_per_bar, bars):
        self.beat = 60 / bpm
        self.beats_per_bar = beats_per_bar
        self.length = bars * beats_per_bar * self.beat
        self.buf = np.zeros(int((self.length + TAIL) * RATE))

    def add(self, sound, at, gain):
        start = int(at * RATE)
        end = min(len(self.buf), start + len(sound))
        self.buf[start:end] += gain * sound[: end - start]

    def render(self):
        mixed = reverb(self.buf)
        n = int(self.length * RATE)
        out = mixed[:n].copy()
        tail = mixed[n:]
        out[: len(tail)] += tail  # whatever rings past the end wraps round to the start
        # A tiny fade right at the seam avoids any click.
        k = int(0.012 * RATE)
        ramp = 0.5 - 0.5 * np.cos(np.linspace(0, np.pi, k))
        out[:k] *= ramp
        out[-k:] *= ramp[::-1]
        return out / max(1e-9, np.abs(out).max()) * 0.8


def chord_notes(root, kind, octave):
    steps = {"maj": (0, 4, 7), "min": (0, 3, 7), "sus": (0, 5, 7), "maj7": (0, 4, 7, 11), "min7": (0, 3, 7, 10)}
    base = midi(f"{root}{octave}")
    return [base + s for s in steps[kind]]


def scale_notes(root, mode, low, high):
    modes = {
        "major": (0, 2, 4, 5, 7, 9, 11),
        "pentatonic": (0, 2, 4, 7, 9),
        "dorian": (0, 2, 3, 5, 7, 9, 10),
        "minor_pent": (0, 3, 5, 7, 10),
        "phrygian": (0, 1, 3, 5, 7, 8, 10),
        "lydian": (0, 2, 4, 6, 7, 9, 11),
    }
    r = NOTE_INDEX[root]
    return [m for m in range(low, high + 1) if (m - r) % 12 in modes[mode]]


def compose(spec, seed):
    rnd = random.Random(seed)
    random.seed(seed)
    s = Song(spec["bpm"], spec["beats"], spec["bars"])
    chords = spec["chords"]
    bars_per_chord = spec["bars"] // len(chords)
    scale = scale_notes(spec["key"], spec["mode"], *spec["melody_range"])
    lead = INSTRUMENTS[spec["lead"]]
    arp = INSTRUMENTS[spec["arp"]]
    melody_at = len(scale) // 2
    for ci, (root, kind) in enumerate(chords):
        bar0 = ci * bars_per_chord
        t0 = bar0 * s.beats_per_bar * s.beat
        span = bars_per_chord * s.beats_per_bar * s.beat
        tones = chord_notes(root, kind, spec["chord_octave"])
        # Pad holds the chord.
        s.add(pad([hz(m) for m in tones], span + 1.0), t0, spec["pad"])
        # Bass on the first beat of each bar.
        for b in range(bars_per_chord):
            s.add(bass(hz(tones[0] - 12), s.beats_per_bar * s.beat * 1.2), t0 + b * s.beats_per_bar * s.beat, spec["bass"])
        # Arpeggio: a gentle pattern through the chord.
        steps = int(span / (s.beat * spec["arp_step"]))
        pattern = spec["arp_pattern"]
        for k in range(steps):
            idx = pattern[k % len(pattern)]
            if idx is None:
                continue
            m = tones[idx % len(tones)] + 12 * (idx // len(tones))
            s.add(arp(hz(m), 2.4), t0 + k * s.beat * spec["arp_step"], spec["arp_gain"] * (0.85 + 0.3 * rnd.random()))
        # Melody: a slow, gentle random walk, landing on chord tones.
        beat = 0.0
        while beat < bars_per_chord * s.beats_per_bar:
            length = rnd.choice(spec["rhythm"])
            if rnd.random() < spec["rest"]:
                beat += length
                continue
            melody_at = max(0, min(len(scale) - 1, melody_at + rnd.choice((-2, -1, -1, 0, 1, 1, 2))))
            m = scale[melody_at]
            if beat == 0:  # start each chord on one of its notes
                m = min(scale, key=lambda n: min(abs(n - (c + 12 * o)) for c in tones for o in (1, 2)))
                melody_at = scale.index(m)
            dur = length * s.beat * (1.6 if spec["lead"] == "flute" else 3)
            s.add(lead(hz(m), dur), t0 + beat * s.beat, spec["lead_gain"])
            beat += length
    return s.render()


SONGS = {
    "meadow": dict(bpm=84, beats=4, bars=8, key="C", mode="pentatonic", chords=[("C", "maj"), ("A", "min"), ("F", "maj"), ("G", "sus")],
                   chord_octave=4, melody_range=(midi("E5"), midi("E6")), lead="bell", lead_gain=0.22, arp="pluck",
                   arp_step=0.5, arp_pattern=[0, 2, 1, 3, 2, None, 1, None], arp_gain=0.32, pad=0.18, bass=0.28,
                   rhythm=[1, 1, 2, 2], rest=0.35),
    "forest": dict(bpm=68, beats=4, bars=8, key="D", mode="dorian", chords=[("D", "min7"), ("C", "maj"), ("G", "maj"), ("D", "min")],
                   chord_octave=3, melody_range=(midi("A4"), midi("A5")), lead="flute", lead_gain=0.16, arp="pluck",
                   arp_step=0.5, arp_pattern=[0, 2, 4, 2, 1, None, 3, None], arp_gain=0.36, pad=0.24, bass=0.3,
                   rhythm=[2, 2, 3, 1], rest=0.45),
    "orchard": dict(bpm=100, beats=3, bars=16, key="F", mode="major", chords=[("F", "maj"), ("D", "min"), ("A#", "maj"), ("C", "maj")],
                    chord_octave=4, melody_range=(midi("C5"), midi("C6")), lead="bell", lead_gain=0.24, arp="bell",
                    arp_step=1, arp_pattern=[None, 1, 2], arp_gain=0.16, pad=0.12, bass=0.3,
                    rhythm=[1, 1, 2, 3], rest=0.3),
    "wetland": dict(bpm=60, beats=4, bars=8, key="E", mode="minor_pent", chords=[("E", "min7"), ("C", "maj7"), ("G", "maj"), ("D", "sus")],
                    chord_octave=3, melody_range=(midi("E5"), midi("E6")), lead="bell", lead_gain=0.16, arp="pluck",
                    arp_step=1, arp_pattern=[0, None, 2, None, 3, None, None, 1], arp_gain=0.3, pad=0.3, bass=0.24,
                    rhythm=[2, 3, 4], rest=0.55),
    "desert": dict(bpm=72, beats=4, bars=8, key="E", mode="phrygian", chords=[("E", "min"), ("F", "maj"), ("E", "sus"), ("D", "min")],
                   chord_octave=3, melody_range=(midi("B4"), midi("B5")), lead="flute", lead_gain=0.15, arp="pluck",
                   arp_step=0.5, arp_pattern=[0, None, None, 2, None, 1, None, None], arp_gain=0.4, pad=0.14, bass=0.3,
                   rhythm=[1, 2, 2, 3], rest=0.5),
    "tropical": dict(bpm=100, beats=4, bars=16, key="G", mode="pentatonic", chords=[("G", "maj"), ("E", "min"), ("C", "maj"), ("D", "maj")],
                     chord_octave=4, melody_range=(midi("D5"), midi("D6")), lead="marimba", lead_gain=0.24, arp="marimba",
                     arp_step=0.5, arp_pattern=[0, None, 2, 1, None, 2, 3, None], arp_gain=0.28, pad=0.1, bass=0.32,
                     rhythm=[0.5, 1, 1, 1.5], rest=0.35),
    "alpine": dict(bpm=66, beats=4, bars=8, key="A", mode="lydian", chords=[("A", "maj7"), ("E", "maj"), ("F#", "min"), ("D", "maj7")],
                   chord_octave=4, melody_range=(midi("E5"), midi("E6")), lead="bell", lead_gain=0.2, arp="pluck",
                   arp_step=1, arp_pattern=[0, 2, 3, 1], arp_gain=0.24, pad=0.3, bass=0.2,
                   rhythm=[2, 2, 3], rest=0.45),
}


def write_ogg(name, samples):
    os.makedirs(OUT, exist_ok=True)
    with tempfile.TemporaryDirectory() as tmp:
        wav_path = os.path.join(tmp, f"{name}.wav")
        with wave.open(wav_path, "wb") as w:
            w.setnchannels(1)
            w.setsampwidth(2)
            w.setframerate(RATE)
            w.writeframes((np.clip(samples, -1, 1) * 32767).astype("<i2").tobytes())
        subprocess.run(
            ["ffmpeg", "-y", "-loglevel", "error", "-i", wav_path, "-c:a", "libvorbis", "-q:a", "3",
             "-map_metadata", "-1", "-fflags", "+bitexact", f"{OUT}/{name}.ogg"],
            check=True,
        )


if __name__ == "__main__":
    for i, (name, spec) in enumerate(SONGS.items()):
        write_ogg(name, compose(spec, seed=100 + i))
        print("wrote", f"{OUT}/{name}.ogg")
