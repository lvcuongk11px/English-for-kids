#!/usr/bin/env python3
"""Build the JSON curriculum and normalized PNG artwork.

External pictograms are downloaded only from Google Noto Emoji's official
repository. Existing, verified PNG files are skipped. Colors and shapes are
drawn locally. Run from the project root: python scripts/prepare_images.py
"""

from __future__ import annotations

import hashlib
import io
import json
import math
import sys
import time
import urllib.error
import urllib.request
from pathlib import Path

try:
    from PIL import Image, ImageDraw
except ImportError as exc:
    raise SystemExit("Install Pillow first: python -m pip install Pillow") from exc

ROOT = Path(__file__).resolve().parents[1]
IMAGE_DIR = ROOT / "assets" / "images"
DATA_DIR = ROOT / "assets" / "data"
NOTO_BASE = "https://raw.githubusercontent.com/googlefonts/noto-emoji/main/2D/png/512"
CANVAS = 384

TOPICS = [
    {
        "id": "animals", "english": "Animals", "vietnamese": "Động vật", "accent": "FFF06B5B", "kind": "emoji",
        "items": [("cat", "cat", "Where is the cat?", "1f408"), ("dog", "dog", "Where is the dog?", "1f415"),
                  ("rabbit", "rabbit", "Where is the rabbit?", "1f407"), ("bird", "bird", "Where is the bird?", "1f426"),
                  ("fish", "fish", "Where is the fish?", "1f41f"), ("elephant", "elephant", "Where is the elephant?", "1f418"),
                  ("lion", "lion", "Where is the lion?", "1f981"), ("tiger", "tiger", "Where is the tiger?", "1f405"),
                  ("monkey", "monkey", "Where is the monkey?", "1f412"), ("horse", "horse", "Where is the horse?", "1f40e")],
    },
    {
        "id": "colors", "english": "Colors", "vietnamese": "Màu sắc", "accent": "FFFF9F43", "kind": "color",
        "items": [("red", "red", "Which one is red?", "E84141"), ("blue", "blue", "Which one is blue?", "3987E8"),
                  ("yellow", "yellow", "Which one is yellow?", "F7D838"), ("green", "green", "Which one is green?", "43B96B"),
                  ("orange", "orange", "Which one is orange?", "F28C35"), ("purple", "purple", "Which one is purple?", "8E5AD7"),
                  ("pink", "pink", "Which one is pink?", "F17FA5"), ("black", "black", "Which one is black?", "2D3340"),
                  ("white", "white", "Which one is white?", "F8F8F5"), ("brown", "brown", "Which one is brown?", "925C36")],
    },
    {
        "id": "shapes", "english": "Shapes", "vietnamese": "Hình dạng", "accent": "FF5CBAA8", "kind": "shape",
        "items": [("circle", "circle", "Where is the circle?", "circle"), ("square", "square", "Where is the square?", "square"),
                  ("triangle", "triangle", "Where is the triangle?", "triangle"), ("rectangle", "rectangle", "Where is the rectangle?", "rectangle"),
                  ("star", "star", "Where is the star?", "star"), ("heart", "heart", "Where is the heart?", "heart"),
                  ("oval", "oval", "Where is the oval?", "oval"), ("diamond", "diamond", "Where is the diamond?", "diamond"),
                  ("pentagon", "pentagon", "Where is the pentagon?", "pentagon"), ("hexagon", "hexagon", "Where is the hexagon?", "hexagon")],
    },
    {
        "id": "body_parts", "english": "Body Parts", "vietnamese": "Bộ phận cơ thể", "accent": "FF9B6DDE", "kind": "emoji",
        "items": [("eyes", "eyes", "Where are the eyes?", "1f440"), ("ears", "ears", "Where are the ears?", "1f442"),
                  ("nose", "nose", "Where is the nose?", "1f443"), ("mouth", "mouth", "Where is the mouth?", "1f444"),
                  ("hand", "hand", "Where is the hand?", "270b"), ("foot", "foot", "Where is the foot?", "1f9b6"),
                  ("arm", "arm", "Where is the arm?", "1f4aa"), ("leg", "leg", "Where is the leg?", "1f9b5"),
                  ("head", "head", "Where is the head?", "1f9d1"), ("tooth", "tooth", "Where is the tooth?", "1f9b7")],
    },
    {
        "id": "vehicles", "english": "Vehicles", "vietnamese": "Phương tiện", "accent": "FF438DDA", "kind": "emoji",
        "items": [("car", "car", "Where is the car?", "1f697"), ("bus", "bus", "Where is the bus?", "1f68c"),
                  ("bicycle", "bicycle", "Where is the bicycle?", "1f6b2"), ("train", "train", "Where is the train?", "1f686"),
                  ("airplane", "airplane", "Where is the airplane?", "2708"), ("boat", "boat", "Where is the boat?", "26f5"),
                  ("truck", "truck", "Where is the truck?", "1f69a"), ("motorcycle", "motorcycle", "Where is the motorcycle?", "1f3cd"),
                  ("helicopter", "helicopter", "Where is the helicopter?", "1f681"), ("scooter", "scooter", "Where is the scooter?", "1f6f4")],
    },
    {
        "id": "household", "english": "Household Items", "vietnamese": "Đồ dùng trong nhà", "accent": "FFE66A9D", "kind": "emoji",
        "items": [("clock", "clock", "Where is the clock?", "23f0"), ("lamp", "lamp", "Where is the lamp?", "1fa94"),
                  ("phone", "phone", "Where is the phone?", "1f4f1"), ("television", "television", "Where is the television?", "1f4fa"),
                  ("key", "key", "Where is the key?", "1f511"), ("cup", "cup", "Where is the cup?", "2615"),
                  ("plate", "plate", "Where is the plate?", "1f37d"), ("spoon", "spoon", "Where is the spoon?", "1f944"),
                  ("toothbrush", "toothbrush", "Where is the toothbrush?", "1faa5"), ("soap", "soap", "Where is the soap?", "1f9fc")],
    },
    {
        "id": "rooms", "english": "Rooms", "vietnamese": "Các phòng trong nhà", "accent": "FF5DB9D1", "kind": "emoji",
        "items": [("kitchen", "kitchen", "Which picture shows a kitchen?", "1f373"), ("bedroom", "bedroom", "Which picture shows a bedroom?", "1f6cf"),
                  ("bathroom", "bathroom", "Which picture shows a bathroom?", "1f6c1"), ("living_room", "living room", "Which picture shows a living room?", "1f6cb"),
                  ("dining_room", "dining room", "Which picture shows a dining room?", "1f37d"), ("study", "study", "Which picture shows a study?", "1f4da"),
                  ("laundry_room", "laundry room", "Which picture shows a laundry room?", "1f9fa"), ("garage", "garage", "Which picture shows a garage?", "1f3e0")],
    },
]

PASTELS = ["FDE8E3", "FFF3C4", "DDF4EA", "DDEEFF", "EEE4FA", "FFE5F0"]


def valid_png(path: Path) -> bool:
    try:
        with Image.open(path) as image:
            image.verify()
        return path.stat().st_size > 100
    except (OSError, FileNotFoundError):
        return False


def download(url: str, attempts: int = 4, timeout: int = 25) -> bytes:
    last_error: Exception | None = None
    for attempt in range(attempts):
        try:
            request = urllib.request.Request(url, headers={"User-Agent": "EnglishForKidsAssetBuilder/1.0"})
            with urllib.request.urlopen(request, timeout=timeout) as response:
                payload = response.read()
            with Image.open(io.BytesIO(payload)) as image:
                image.verify()
            return payload
        except (OSError, urllib.error.URLError) as error:
            last_error = error
            time.sleep(1.5 * (attempt + 1))
    raise RuntimeError(f"Could not download {url}: {last_error}")


def rounded_canvas(index: int) -> tuple[Image.Image, ImageDraw.ImageDraw]:
    image = Image.new("RGBA", (CANVAS, CANVAS), (255, 255, 255, 0))
    draw = ImageDraw.Draw(image)
    draw.rounded_rectangle((12, 12, CANVAS - 12, CANVAS - 12), radius=68, fill="#" + PASTELS[index % len(PASTELS)])
    draw.ellipse((42, 39, 110, 107), fill=(255, 255, 255, 105))
    draw.ellipse((280, 278, 350, 348), fill=(255, 255, 255, 90))
    return image, draw


def make_emoji(path: Path, codepoint: str, index: int) -> None:
    if valid_png(path):
        return
    payload = download(f"{NOTO_BASE}/emoji_u{codepoint}.png")
    with Image.open(io.BytesIO(payload)) as source:
        emoji = source.convert("RGBA")
    emoji.thumbnail((276, 276), Image.Resampling.LANCZOS)
    image, _ = rounded_canvas(index)
    image.alpha_composite(emoji, ((CANVAS - emoji.width) // 2, (CANVAS - emoji.height) // 2))
    image.save(path, "PNG", optimize=True)


def make_color(path: Path, color: str, index: int) -> None:
    if valid_png(path):
        return
    image, draw = rounded_canvas(index)
    outline = "#CCD4DF" if color in {"F8F8F5", "F7D838"} else "#FFFFFF"
    draw.ellipse((78, 78, 306, 306), fill="#" + color, outline=outline, width=10)
    draw.ellipse((116, 102, 182, 150), fill=(255, 255, 255, 75))
    image.save(path, "PNG", optimize=True)


def polygon(cx: float, cy: float, radius: float, sides: int, rotation: float = -math.pi / 2) -> list[tuple[float, float]]:
    return [(cx + radius * math.cos(rotation + i * 2 * math.pi / sides), cy + radius * math.sin(rotation + i * 2 * math.pi / sides)) for i in range(sides)]


def make_shape(path: Path, shape: str, index: int) -> None:
    if valid_png(path):
        return
    image, draw = rounded_canvas(index)
    colors = ["#EF5D60", "#3A8DE2", "#F4C542", "#4DBB78", "#9B62DB", "#F37FAD", "#F18D38", "#52BFC0", "#6D78D8", "#E66D4B"]
    fill = colors[index % len(colors)]
    box = (87, 87, 297, 297)
    if shape == "circle": draw.ellipse(box, fill=fill)
    elif shape == "square": draw.rounded_rectangle(box, radius=10, fill=fill)
    elif shape == "triangle": draw.polygon(polygon(192, 203, 130, 3), fill=fill)
    elif shape == "rectangle": draw.rounded_rectangle((52, 115, 332, 269), radius=10, fill=fill)
    elif shape == "star":
        points = []
        for i in range(10):
            points.append((192 + (130 if i % 2 == 0 else 57) * math.cos(-math.pi / 2 + i * math.pi / 5), 192 + (130 if i % 2 == 0 else 57) * math.sin(-math.pi / 2 + i * math.pi / 5)))
        draw.polygon(points, fill=fill)
    elif shape == "heart":
        draw.ellipse((70, 83, 210, 223), fill=fill); draw.ellipse((174, 83, 314, 223), fill=fill); draw.polygon([(72, 159), (312, 159), (192, 316)], fill=fill)
    elif shape == "oval": draw.ellipse((61, 111, 323, 273), fill=fill)
    elif shape == "diamond": draw.polygon([(192, 50), (326, 192), (192, 334), (58, 192)], fill=fill)
    elif shape == "pentagon": draw.polygon(polygon(192, 199, 135, 5), fill=fill)
    elif shape == "hexagon": draw.polygon(polygon(192, 192, 137, 6), fill=fill)
    elif shape == "semicircle":
        draw.pieslice((58, 72, 326, 340), 180, 360, fill=fill)
    elif shape == "cross":
        draw.polygon([(145, 62), (239, 62), (239, 145), (322, 145), (322, 239), (239, 239), (239, 322), (145, 322), (145, 239), (62, 239), (62, 145), (145, 145)], fill=fill)
    image.save(path, "PNG", optimize=True)


def make_icon() -> None:
    icon = Image.new("RGBA", (1024, 1024), "#6657D9")
    draw = ImageDraw.Draw(icon)
    draw.rounded_rectangle((154, 150, 870, 850), radius=145, fill="#FFF7DF")
    draw.polygon([(512, 80), (560, 225), (715, 225), (590, 315), (638, 466), (512, 374), (386, 466), (434, 315), (309, 225), (464, 225)], fill="#FFCB4C")
    draw.rounded_rectangle((250, 470, 774, 745), radius=60, fill="#4BB7A7")
    draw.line((512, 492, 512, 718), fill="#FFF7DF", width=18)
    draw.arc((285, 510, 505, 730), 270, 90, fill="#FFF7DF", width=15)
    draw.arc((519, 510, 739, 730), 90, 270, fill="#FFF7DF", width=15)
    icon_path = IMAGE_DIR / "app_icon.png"
    icon.save(icon_path, "PNG", optimize=True)
    for folder, size in [("mipmap-mdpi", 48), ("mipmap-hdpi", 72), ("mipmap-xhdpi", 96), ("mipmap-xxhdpi", 144), ("mipmap-xxxhdpi", 192)]:
        target = ROOT / "android" / "app" / "src" / "main" / "res" / folder / "ic_launcher.png"
        target.parent.mkdir(parents=True, exist_ok=True)
        icon.resize((size, size), Image.Resampling.LANCZOS).convert("RGB").save(target, "PNG", optimize=True)


def main() -> None:
    IMAGE_DIR.mkdir(parents=True, exist_ok=True)
    DATA_DIR.mkdir(parents=True, exist_ok=True)
    output_topics = []
    credits = []
    counter = 0
    for topic in TOPICS:
        output_items = []
        for item_id, word, question, value in topic["items"]:
            path = IMAGE_DIR / f"{topic['id']}_{item_id}.png"
            if topic["kind"] == "emoji":
                make_emoji(path, value, counter)
                credits.append({"file": path.name, "source": f"{NOTO_BASE}/emoji_u{value}.png", "sha256": hashlib.sha256(path.read_bytes()).hexdigest()})
            elif topic["kind"] == "color": make_color(path, value, counter)
            else: make_shape(path, value, counter)
            output_items.append({
                "id": f"{topic['id']}_{item_id}", "word": word, "questionText": question,
                "imagePath": f"assets/images/{path.name}",
                "questionAudioPath": f"assets/audio/questions/{topic['id']}_{item_id}.wav",
            })
            counter += 1
        output_topics.append({
            "id": topic["id"], "englishName": topic["english"], "vietnameseName": topic["vietnamese"],
            "coverImagePath": output_items[0]["imagePath"], "accentColor": topic["accent"], "items": output_items,
        })
    (DATA_DIR / "topics.json").write_text(json.dumps({"topics": output_topics}, ensure_ascii=False, indent=2), encoding="utf-8")
    (DATA_DIR / "image_manifest.json").write_text(json.dumps({"notoEmoji": credits}, indent=2), encoding="utf-8")
    make_icon()
    print(f"Prepared {counter} vocabulary images, JSON data, and Android launcher icons.")


if __name__ == "__main__":
    main()
