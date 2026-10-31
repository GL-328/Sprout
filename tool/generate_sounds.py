"""Generates Sprout's soft sound effects as WAV files. (Music: tool/generate_music.py.)

Everything is synthesised here, so the sounds are original and free to use.
Run from the repository root:  python3 tool/generate_sounds.py
"""
import math
import random
import struct
import wave

RATE = 22050
OUT = "assets/sounds"


def write(name, samples, rate=RATE):
    # A short fade at the very end, so nothing stops with a click.
    fade = min(len(samples) // 4, int(0.012 * rate))
    samples = list(samples)
    for i in range(fade):
        samples[-1 - i] *= i / fade
    peak = max(1e-9, max(abs(s) for s in samples))
    scale = 0.8 / peak
    with wave.open(f"{OUT}/{name}.wav", "wb") as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(rate)
        w.writeframes(b"".join(struct.pack("<h", int(max(-1, min(1, s * scale)) * 32767)) for s in samples))



def mix(*tracks):
    n = max(len(t) for t in tracks)
    return [sum(t[i] for t in tracks if i < len(t)) for i in range(n)]


def note(name):
    names = {"C": -9, "D": -7, "E": -5, "F": -4, "G": -2, "A": 0, "B": 2}
    return 440.0 * 2 ** ((names[name[0]] + 12 * (int(name[1]) - 4)) / 12)


def kalimba(freq, dur, start=0.0, total=None, rate=RATE):
    """A kalimba tine: a warm, round note with a soft metallic glint at the start."""
    n = int((total or dur + start) * rate)
    out = [0.0] * n
    s0 = int(start * rate)
    for i in range(int(dur * rate)):
        t = i / rate
        attack = min(1.0, t / 0.003)
        v = math.sin(2 * math.pi * freq * t) * math.exp(-5 * t)
        v += 0.18 * math.sin(2 * math.pi * freq * 5.95 * t) * math.exp(-40 * t)  # the glint
        v += 0.08 * math.sin(2 * math.pi * freq * 2 * t) * math.exp(-9 * t)
        if s0 + i < n:
            out[s0 + i] += v * attack
    return out


def marimba(freq, dur, start=0.0, total=None, rate=RATE):
    """A soft wooden bar."""
    n = int((total or dur + start) * rate)
    out = [0.0] * n
    s0 = int(start * rate)
    for i in range(int(dur * rate)):
        t = i / rate
        v = math.sin(2 * math.pi * freq * t) * math.exp(-9 * t) + 0.2 * math.sin(2 * math.pi * freq * 3.93 * t) * math.exp(-30 * t)
        if s0 + i < n:
            out[s0 + i] += v * min(1.0, t / 0.002)
    return out


def bubble(f0, f1, dur, start=0.0, total=None, decay=40, rate=RATE):
    """A round, bubbly pop: a quick upward sweep that fades fast."""
    n = int((total or dur + start) * rate)
    out = [0.0] * n
    s0 = int(start * rate)
    phase = 0.0
    for i in range(int(dur * rate)):
        t = i / rate
        f = f1 + (f0 - f1) * math.exp(-t * 60)
        phase += 2 * math.pi * f / rate
        if s0 + i < n:
            out[s0 + i] += math.sin(phase) * math.exp(-t * decay) * min(1.0, t / 0.0015)
    return out


def complete():
    """A happy pop, then two quick wooden notes going up."""
    return mix(bubble(380, 760, 0.12, 0.0, 0.6), marimba(note("E5"), 0.4, 0.06, 0.6), marimba(note("A5"), 0.45, 0.14, 0.6))


def seed():
    """A little kalimba run, for a new seed."""
    notes = ["C5", "E5", "G5", "C6"]
    return mix(*[kalimba(note(n), 0.9, i * 0.1, 1.2) for i, n in enumerate(notes)])


def coin():
    """Two short, bright clinks."""
    def clink(f, start):
        n = int(0.4 * RATE)
        out = [0.0] * n
        for i in range(int(0.25 * RATE)):
            t = i / RATE
            v = sum(a * math.sin(2 * math.pi * f * r * t) for r, a in ((1, 1), (2.76, 0.5), (5.4, 0.25))) * math.exp(-22 * t)
            j = int(start * RATE) + i
            if j < n:
                out[j] += v * min(1.0, t / 0.001)
        return out

    return mix(clink(2100, 0.0), clink(2650, 0.07))


def harvest():
    """A juicy plop, with a low wooden note under it."""
    return mix(bubble(220, 620, 0.18, 0.0, 0.4, decay=22), marimba(note("C5"), 0.3, 0.03, 0.4))


def plant():
    """A soft pat of soil, then a kalimba note as the seed settles in."""
    rnd = random.Random(6)
    n = int(0.5 * RATE)
    pat = []
    lp = 0.0
    for i in range(n):
        t = i / RATE
        lp += 0.2 * (rnd.uniform(-1, 1) - lp)
        pat.append((0.5 * lp + math.sin(2 * math.pi * (120 - 40 * t) * t)) * math.exp(-t * 25) * min(1, t / 0.003))
    return mix(pat, kalimba(note("G5"), 0.4, 0.1, 0.5))


def tap(variant=0):
    """A soft, bubbly button pop. Three slight variations keep taps from sounding samey."""
    lift = (0, 40, -30)[variant]
    return bubble(420 + lift, 900 + lift * 2, 0.07, decay=55)


def toggle():
    """A small, tactile click-clack for switches."""
    return mix(bubble(900, 1300, 0.03, 0.0, 0.1, decay=120), bubble(700, 1000, 0.03, 0.045, 0.1, decay=120))


def chirp():
    """Two little bird notes, for saying hello to a visitor."""
    out = [0.0] * int(0.3 * RATE)
    for c, start in enumerate([0.0, 0.13]):
        s0 = int(start * RATE)
        for i in range(int(0.09 * RATE)):
            t = i / RATE
            f = 2900 + 700 * math.sin(math.pi * t / 0.09) + c * 250
            out[s0 + i] += math.sin(2 * math.pi * f * t) * math.sin(math.pi * t / 0.09)
    return out


def mood():
    """Two warm kalimba notes."""
    return mix(kalimba(note("G4"), 0.6, 0.0, 0.7), kalimba(note("D5"), 0.55, 0.08, 0.7))


def compost():
    """A soft, earthy pat."""
    rnd = random.Random(2)
    n = int(0.25 * RATE)
    out = []
    lp = 0.0
    for i in range(n):
        t = i / RATE
        lp += 0.25 * (rnd.uniform(-1, 1) - lp)
        thud = math.sin(2 * math.pi * (140 - 60 * t) * t)
        out.append((0.6 * lp + thud) * math.exp(-t * 18) * min(1, t / 0.003))
    return out


if __name__ == "__main__":
    write("complete", complete())
    write("seed", seed())
    write("coin", coin())
    write("harvest", harvest())
    write("plant", plant())
    write("tap", tap(0))
    write("tap2", tap(1))
    write("tap3", tap(2))
    write("toggle", toggle())
    write("chirp", chirp())
    write("mood", mood())
    write("compost", compost())
    print("Sounds written to", OUT)
