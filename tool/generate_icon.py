"""Draws the Sprout launcher icon into the Android mipmap folders.

Run from the repository root with Pillow installed:  python3 tool/generate_icon.py
"""
from PIL import Image, ImageDraw

SIZES = {"mdpi": 48, "hdpi": 72, "xhdpi": 96, "xxhdpi": 144, "xxxhdpi": 192}
S = 1024  # draw large, then scale down for smooth edges


def draw():
    img = Image.new("RGBA", (S, S), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    # Soft peach background circle with a cream inner glow.
    d.ellipse((24, 24, S - 24, S - 24), fill=(255, 226, 205, 255))
    d.ellipse((120, 120, S - 120, S - 120), fill=(255, 241, 226, 255))
    # Soil mound.
    d.pieslice((250, 640, 774, 900), 180, 360, fill=(184, 138, 99, 255))
    # Stem.
    d.line((512, 700, 512, 430), fill=(108, 176, 104, 255), width=46)
    # Two leaves.
    leaf = (127, 196, 139, 255)
    leaf_dark = (96, 168, 112, 255)
    left = Image.new("RGBA", (S, S), (0, 0, 0, 0))
    ImageDraw.Draw(left).ellipse((250, 330, 530, 480), fill=leaf_dark)
    left = left.rotate(28, center=(512, 440))
    right = Image.new("RGBA", (S, S), (0, 0, 0, 0))
    ImageDraw.Draw(right).ellipse((494, 270, 800, 430), fill=leaf)
    right = right.rotate(-24, center=(512, 400))
    img.alpha_composite(left)
    img.alpha_composite(right)
    # A little highlight.
    d = ImageDraw.Draw(img)
    d.ellipse((610, 300, 660, 330), fill=(196, 236, 196, 255))
    return img


if __name__ == "__main__":
    icon = draw()
    for folder, px in SIZES.items():
        icon.resize((px, px), Image.LANCZOS).save(f"android/app/src/main/res/mipmap-{folder}/ic_launcher.png")
    icon.resize((512, 512), Image.LANCZOS).save("assets/icon.png")
    print("Icon written")
