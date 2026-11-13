"""Builds all LearnCard app icons from the chosen 2048px logo (variant 14)."""
import re
import sys
from pathlib import Path

import numpy as np
from PIL import Image, ImageDraw

SRC = Path(sys.argv[2]) if len(sys.argv) > 2 else Path(__file__).resolve().parents[1] / "docs/store_assets/logo_source_2048.jpg"
ROOT = Path(sys.argv[1])
BG = np.array([0x46, 0x70, 0x5A], np.float32)  # chosen background (#46705A)
OLD_BG = np.array([0x75, 0x92, 0x7E], np.float32)
WHITE = np.array([0xF8, 0xF6, 0xF0], np.float32)

src = Image.open(SRC).convert("RGB")
a = np.asarray(src).astype(np.float32)
hsv = np.asarray(src.convert("HSV")).astype(np.float32)
terra = (hsv[..., 0] < 30) & (hsv[..., 1] > 80)

# Coverage of the off-white artwork: 1 on white, 0 on the background.
t = ((a - WHITE) / (OLD_BG - WHITE)).mean(axis=2)
cover = np.clip(1 - t, 0, 1)
cover[terra] = 1

# Full-bleed square icon on the new background.
full = WHITE + (1 - cover[..., None]) * (BG - WHITE)
full = np.where(terra[..., None], a, full)
full_img = Image.fromarray(np.clip(full, 0, 255).round().astype(np.uint8))

# Transparent foreground (artwork only) for the Android adaptive icon.
fg = np.dstack([np.where(terra[..., None], a, WHITE), cover * 255])
fg_img = Image.fromarray(np.clip(fg, 0, 255).round().astype(np.uint8), "RGBA")
ys, xs = np.where(cover > 0.5)
cx, cy = (xs.min() + xs.max()) / 2, (ys.min() + ys.max()) / 2
half = max(xs.max() - xs.min(), ys.max() - ys.min()) / 2 * 1.04
fg_img = fg_img.crop((int(cx - half), int(cy - half), int(cx + half), int(cy + half)))


def save(img, path, size, mode="RGBA"):
    path = ROOT / path
    path.parent.mkdir(parents=True, exist_ok=True)
    img.resize((size, size), Image.LANCZOS).convert(mode).save(path)


def circle(img, size):
    im = img.resize((size, size), Image.LANCZOS).convert("RGBA")
    m = Image.new("L", (size * 4, size * 4), 0)
    ImageDraw.Draw(m).ellipse((0, 0, size * 4 - 1, size * 4 - 1), fill=255)
    im.putalpha(m.resize((size, size), Image.LANCZOS))
    return im


# Source assets kept in the repo.
save(full_img, "assets/icon/learncard_app_icon_1024.png", 1024, "RGB")
circle(full_img, 1024).save(ROOT / "assets/icon/learncard_app_icon_legacy_1024.png")
save(fg_img, "assets/icon/learncard_adaptive_foreground_1024.png", 1024)

# Android: legacy round launcher + adaptive foreground (108dp canvas, xml adds 25% inset so the ring sits inside the 72dp visible area).
res = "android/app/src/main/res"
for d, px in {"mdpi": 48, "hdpi": 72, "xhdpi": 96, "xxhdpi": 144, "xxxhdpi": 192}.items():
    circle(full_img, px).save(ROOT / f"{res}/mipmap-{d}/ic_launcher.png")
for d, px in {"mdpi": 108, "hdpi": 162, "xhdpi": 216, "xxhdpi": 324, "xxxhdpi": 432}.items():
    save(fg_img, f"{res}/drawable-{d}/ic_launcher_foreground.png", px)
colors = ROOT / f"{res}/values/colors.xml"
colors.write_text(re.sub(r"#[0-9A-Fa-f]{6}", "#46705A", colors.read_text()))

# iOS / macOS: opaque squares, the OS applies the mask.
for p in (ROOT / "ios/Runner/Assets.xcassets/AppIcon.appiconset").glob("Icon-App-*.png"):
    m = re.search(r"(\d+(?:\.\d+)?)x\1@(\d)x", p.name)
    save(full_img, p.relative_to(ROOT), round(float(m.group(1)) * int(m.group(2))), "RGB")
for p in (ROOT / "macos/Runner/Assets.xcassets/AppIcon.appiconset").glob("app_icon_*.png"):
    save(full_img, p.relative_to(ROOT), int(p.stem.split("_")[-1]), "RGB")

# Web.
save(full_img, "web/favicon.png", 32)
for n in (192, 512):
    circle(full_img, n).save(ROOT / f"web/icons/Icon-{n}.png")
    save(full_img, f"web/icons/Icon-maskable-{n}.png", n, "RGB")

# Play Store listing icon (512, 32-bit PNG, full square; Play rounds it).
save(full_img, "docs/store_assets/play_icon_512.png", 512)
print("ok", fg_img.size)
