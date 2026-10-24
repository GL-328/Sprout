"""Generates Sprout's soft sound effects and ambient loop as WAV files.

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
    peak = max(1e-9, max(abs(s) for s in samples))
    scale = 0.8 / peak
    with wave.open(f"{OUT}/{name}.wav", "wb") as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(rate)
        w.writeframes(b"".join(struct.pack("<h", int(max(-1, min(1, s * scale)) * 32767)) for s in samples))


def bell(freq, dur, start=0.0, total=None, decay=6.0, rate=RATE):
    """A soft bell: a sine plus a quieter overtone with an exponential fade."""
    n = int((total or dur + start) * rate)
    out = [0.0] * n
    s0 = int(start * rate)
    for i in range(int(dur * rate)):
        t = i / rate
        attack = min(1.0, t / 0.008)
        env = attack * math.exp(-decay * t)
        v = math.sin(2 * math.pi * freq * t) + 0.25 * math.sin(2 * math.pi * freq * 2.01 * t)
        if s0 + i < n:
            out[s0 + i] += v * env
    return out


def mix(*tracks):
    n = max(len(t) for t in tracks)
    return [sum(t[i] for t in tracks if i < len(t)) for i in range(n)]


def note(name):
    names = {"C": -9, "D": -7, "E": -5, "F": -4, "G": -2, "A": 0, "B": 2}
    return 440.0 * 2 ** ((names[name[0]] + 12 * (int(name[1]) - 4)) / 12)


def complete():
    return mix(bell(note("E5"), 0.5, 0.0, 0.7), bell(note("A5"), 0.5, 0.09, 0.7))


def seed():
    notes = ["C5", "E5", "G5", "C6"]
    return mix(*[bell(note(n), 0.8, i * 0.11, 1.2, decay=4.5) for i, n in enumerate(notes)])


def coin():
    return mix(bell(1318.5, 0.35, 0.0, 0.45, decay=10), bell(1760.0, 0.3, 0.05, 0.45, decay=10))


def harvest():
    n = int(0.3 * RATE)
    out = []
    for i in range(n):
        t = i / RATE
        f = 520 + 380 * math.exp(-t * 30)
        out.append(math.sin(2 * math.pi * f * t) * math.exp(-t * 14) * min(1, t / 0.004))
    return out


def plant():
    n = int(0.45 * RATE)
    out = []
    phase = 0.0
    for i in range(n):
        t = i / RATE
        f = 220 + 260 * t / 0.45
        phase += 2 * math.pi * f / RATE
        out.append(math.sin(phase) * math.exp(-t * 6) * min(1, t / 0.01))
    return mix(out, bell(note("G5"), 0.3, 0.18, 0.45, decay=9))


def ambient(seconds=16):
    """Soft wind with a few distant birds. Loops seamlessly."""
    rnd = random.Random(4)
    n = seconds * RATE
    wind = []
    lp = 0.0
    lp2 = 0.0
    for i in range(n):
        lp += 0.02 * (rnd.uniform(-1, 1) - lp)
        lp2 += 0.05 * (lp - lp2)
        t = i / RATE
        gust = 0.55 + 0.45 * math.sin(2 * math.pi * t / seconds) * math.sin(2 * math.pi * 3 * t / seconds)
        wind.append(lp2 * gust * 6)
    birds = [0.0] * n
    for _ in range(7):
        start = rnd.uniform(0.5, seconds - 1.0)
        base = rnd.uniform(2600, 3600)
        for c in range(rnd.randint(2, 4)):
            s0 = int((start + c * 0.16) * RATE)
            for i in range(int(0.11 * RATE)):
                t = i / RATE
                f = base + 900 * math.sin(math.pi * t / 0.11)
                if s0 + i < n:
                    birds[s0 + i] += 0.12 * math.sin(2 * math.pi * f * t) * math.sin(math.pi * t / 0.11)
    out = mix(wind, birds)
    fade = int(0.5 * RATE)
    for i in range(fade):  # crossfade the ends so the loop is seamless
        a = i / fade
        out[i] = out[i] * a + out[n - fade + i] * (1 - a)
    return out[: n - fade]


if __name__ == "__main__":
    write("complete", complete())
    write("seed", seed())
    write("coin", coin())
    write("harvest", harvest())
    write("plant", plant())
    write("ambient", ambient())
    print("Sounds written to", OUT)
