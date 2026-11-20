#!/usr/bin/env python3
"""Prepare the four Electronics pictures not already present in V2 assets."""
from __future__ import annotations

import hashlib
import io
import json
import urllib.request
from pathlib import Path

from PIL import Image, ImageDraw

ROOT = Path(__file__).resolve().parents[1]
IMAGES = ROOT / "assets" / "images"
MANIFEST = ROOT / "assets" / "data" / "image_manifest.json"
NOTO = "https://raw.githubusercontent.com/googlefonts/noto-emoji/main/2D/png/512"


def noto(name: str, codepoint: str) -> None:
    target = IMAGES / name
    url = f"{NOTO}/emoji_u{codepoint}.png"
    data = urllib.request.urlopen(url, timeout=30).read()
    source = Image.open(io.BytesIO(data)).convert("RGBA")
    canvas = Image.new("RGBA", (384, 384), "#FFF2F7")
    source.thumbnail((300, 300), Image.Resampling.LANCZOS)
    canvas.alpha_composite(source, ((384 - source.width) // 2, (384 - source.height) // 2))
    canvas.save(target, optimize=True)
    manifest = json.loads(MANIFEST.read_text(encoding="utf-8"))
    records = [record for record in manifest["notoEmoji"] if record["file"] != name]
    records.append({"file": name, "source": url, "sha256": hashlib.sha256(data).hexdigest()})
    manifest["notoEmoji"] = records
    MANIFEST.write_text(json.dumps(manifest, indent=2), encoding="utf-8")


def tablet() -> None:
    image = Image.new("RGBA", (384, 384), "#E9F5FF")
    draw = ImageDraw.Draw(image)
    draw.rounded_rectangle((82, 35, 302, 349), 30, fill="#2E3B62", outline="#17233F", width=8)
    draw.rounded_rectangle((102, 65, 282, 306), 12, fill="#8DDCF4")
    draw.ellipse((183, 320, 201, 338), fill="#FFF7E8")
    draw.ellipse((132, 113, 252, 233), fill="#FFF06B", outline="#FFB84D", width=6)
    draw.arc((150, 145, 234, 217), 15, 165, fill="#E66A8D", width=8)
    image.save(IMAGES / "original_tablet.png", optimize=True)


def aircon() -> None:
    image = Image.new("RGBA", (384, 384), "#FFF3DF")
    draw = ImageDraw.Draw(image)
    draw.rounded_rectangle((42, 100, 342, 238), 25, fill="#FFFFFF", outline="#91A6B7", width=7)
    draw.rounded_rectangle((68, 128, 316, 168), 10, fill="#E6F7FF")
    draw.line((72, 201, 312, 201), fill="#91A6B7", width=7)
    draw.ellipse((294, 116, 310, 132), fill="#64C879")
    for x in (125, 192, 259):
        draw.arc((x - 27, 250, x + 27, 326), 35, 145, fill="#58B7E8", width=8)
    image.save(IMAGES / "original_aircon.png", optimize=True)


def main() -> None:
    IMAGES.mkdir(parents=True, exist_ok=True)
    noto("school_computer.png", "1f4bb")
    noto("school_camera.png", "1f4f7")
    tablet()
    aircon()
    print("Prepared Electronics assets: computer, camera, tablet, aircon")


if __name__ == "__main__":
    main()
