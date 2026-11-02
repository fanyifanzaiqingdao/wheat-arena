#!/usr/bin/env python3
from __future__ import annotations

import json
import math
from pathlib import Path

from PIL import Image, ImageDraw

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "assets" / "characters"
FRAME = 64
FRAMES = 4
DIRECTIONS = ["down", "up", "right", "left"]
ACTIONS = ["idle", "run", "slash"]

CHARACTERS = [
    {
        "id": "huluobo",
        "name": "胡萝卜",
        "body": "#f47b28",
        "body_dark": "#b94d1d",
        "leaf": "#39b85a",
        "leaf_dark": "#1f7a37",
        "face": "#4b2418",
        "accent": "#ffe0a3",
        "shape": "carrot",
    },
    {
        "id": "kuihuazi",
        "name": "葵花籽",
        "body": "#5a3724",
        "body_dark": "#2f1b13",
        "leaf": "#f4c542",
        "leaf_dark": "#a66f1c",
        "face": "#f7df9a",
        "accent": "#fff1a8",
        "shape": "seed",
    },
    {
        "id": "dianfanbao",
        "name": "电饭煲",
        "body": "#e8edf0",
        "body_dark": "#88969e",
        "leaf": "#8ed6ff",
        "leaf_dark": "#3f7e99",
        "face": "#2a3b43",
        "accent": "#ff6f61",
        "shape": "rice_cooker",
    },
]


def rgba(hex_value: str, alpha: int = 255) -> tuple[int, int, int, int]:
    hex_value = hex_value.lstrip("#")
    return tuple(int(hex_value[i : i + 2], 16) for i in (0, 2, 4)) + (alpha,)


def rect(draw: ImageDraw.ImageDraw, box, color: str, alpha: int = 255) -> None:
    draw.rectangle(box, fill=rgba(color, alpha))


def ellipse(draw: ImageDraw.ImageDraw, box, color: str, alpha: int = 255) -> None:
    draw.ellipse(box, fill=rgba(color, alpha))


def line(draw: ImageDraw.ImageDraw, points, color: str, width: int = 1, alpha: int = 255) -> None:
    draw.line(points, fill=rgba(color, alpha), width=width)


def draw_body(draw: ImageDraw.ImageDraw, cx: int, y: int, spec: dict, direction: str, bob: int) -> None:
    shape = spec["shape"]
    if shape == "carrot":
        polygon = [(cx - 12, y + 3 + bob), (cx + 12, y + 3 + bob), (cx + 5, y + 30 + bob), (cx - 5, y + 30 + bob)]
        draw.polygon(polygon, fill=rgba(spec["body"]))
        line(draw, [(cx - 5, y + 11 + bob), (cx + 6, y + 9 + bob)], spec["body_dark"], 2)
        line(draw, [(cx - 4, y + 21 + bob), (cx + 4, y + 19 + bob)], spec["body_dark"], 2)
        rect(draw, (cx - 4, y - 7 + bob, cx + 4, y + 4 + bob), spec["leaf"])
        rect(draw, (cx - 11, y - 5 + bob, cx - 4, y + 2 + bob), spec["leaf_dark"])
        rect(draw, (cx + 4, y - 6 + bob, cx + 11, y + 2 + bob), spec["leaf_dark"])
    elif shape == "seed":
        ellipse(draw, (cx - 13, y + bob, cx + 13, y + 31 + bob), spec["body"])
        ellipse(draw, (cx - 7, y + 5 + bob, cx + 7, y + 24 + bob), spec["body_dark"])
        rect(draw, (cx - 16, y - 5 + bob, cx + 16, y + 2 + bob), spec["leaf"])
        rect(draw, (cx - 5, y - 12 + bob, cx + 5, y - 5 + bob), spec["leaf"])
    else:
        rect(draw, (cx - 16, y + 4 + bob, cx + 16, y + 28 + bob), spec["body"])
        rect(draw, (cx - 12, y + bob, cx + 12, y + 6 + bob), spec["body_dark"])
        rect(draw, (cx - 11, y + 10 + bob, cx + 11, y + 21 + bob), "#b9e4ef")
        rect(draw, (cx + 10, y + 11 + bob, cx + 14, y + 15 + bob), spec["accent"])
        rect(draw, (cx - 20, y + 9 + bob, cx - 16, y + 20 + bob), spec["body_dark"])
        rect(draw, (cx + 16, y + 9 + bob, cx + 20, y + 20 + bob), spec["body_dark"])
    if direction != "up":
        rect(draw, (cx - 5, y + 13 + bob, cx - 2, y + 16 + bob), spec["face"])
        rect(draw, (cx + 3, y + 13 + bob, cx + 6, y + 16 + bob), spec["face"])
        rect(draw, (cx - 3, y + 22 + bob, cx + 4, y + 24 + bob), spec["face"])


def draw_frame(draw: ImageDraw.ImageDraw, ox: int, oy: int, spec: dict, action: str, direction: str, frame: int) -> None:
    cx = ox + FRAME // 2
    cycle = math.sin(frame / FRAMES * math.tau)
    bob = -abs(round(cycle * 2)) if action == "run" else (-1 if frame == 1 else 0)
    step = round(cycle * 4) if action == "run" else 0
    ellipse(draw, (cx - 16, oy + 50, cx + 16, oy + 57), "#19382d", 95)
    draw_body(draw, cx, oy + 17, spec, direction, bob)
    rect(draw, (cx - 10 - step, oy + 45, cx - 4 - step, oy + 53), "#6c4934")
    rect(draw, (cx + 4 + step, oy + 45, cx + 10 + step, oy + 53), "#6c4934")
    angle = {"right": 0, "left": math.pi, "down": math.pi / 2, "up": -math.pi / 2}[direction]
    hand = (cx + (10 if direction != "left" else -10), oy + 35)
    if action == "slash":
        angle += (frame / max(1, FRAMES - 1) - 0.5) * 1.4
        reach = 19 + frame * 2
    else:
        reach = 13
    tip = (int(hand[0] + math.cos(angle) * reach), int(hand[1] + math.sin(angle) * reach))
    line(draw, [hand, tip], "#71472f", 3)
    line(draw, [tip, (int(tip[0] + math.cos(angle + 0.9) * 8), int(tip[1] + math.sin(angle + 0.9) * 8))], "#edf2d4", 3)
    if action == "slash" and frame in (1, 2):
        line(draw, [(tip[0] - 8, tip[1] + 2), (tip[0], tip[1] - 5), (tip[0] + 8, tip[1])], "#fff4a8", 2, 150)


def build_sheet(spec: dict, path: Path) -> None:
    sheet = Image.new("RGBA", (FRAME * 6, FRAME * len(ACTIONS) * len(DIRECTIONS)), (0, 0, 0, 0))
    draw = ImageDraw.Draw(sheet)
    for action_i, action in enumerate(ACTIONS):
        for dir_i, direction in enumerate(DIRECTIONS):
            row = action_i * len(DIRECTIONS) + dir_i
            for frame in range(6):
                draw_frame(draw, frame * FRAME, row * FRAME, spec, action, direction, frame % FRAMES)
    sheet.save(path)


def build_hit_sheet(spec: dict, path: Path) -> None:
    sheet = Image.new("RGBA", (FRAME * 6, FRAME * 2), (0, 0, 0, 0))
    draw = ImageDraw.Draw(sheet)
    for frame in range(6):
        draw_frame(draw, frame * FRAME - 2 + frame, 0, spec, "idle", "down", frame % FRAMES)
        draw_frame(draw, frame * FRAME, FRAME + 8, spec, "idle", "down", frame % FRAMES)
    sheet.save(path)


def build_portrait(spec: dict, path: Path) -> None:
    frame = Image.new("RGBA", (FRAME, FRAME), (0, 0, 0, 0))
    draw_frame(ImageDraw.Draw(frame), 0, 0, spec, "idle", "down", 0)
    scaled = frame.resize((FRAME * 6, FRAME * 6), Image.Resampling.NEAREST)
    image = Image.new("RGBA", (512, 512), (0, 0, 0, 0))
    image.alpha_composite(scaled, ((512 - scaled.width) // 2, 72))
    path.parent.mkdir(parents=True, exist_ok=True)
    image.save(path)


def entry(spec: dict) -> dict:
    base = f"res://assets/characters/{spec['id']}"
    return {
        "id": spec["id"],
        "name": spec["name"],
        "sheet": f"{base}/sheet.png",
        "portrait": f"{base}/portrait.png",
        "hit_sheet": f"{base}/hit_down_sheet.png",
        "poses": {
            "idle": {"frames": 4, "fps": 5},
            "run": {"frames": 4, "fps": 11},
            "slash": {"frames": 4, "fps": 14},
            "hit": {"frames": 4, "fps": 10},
            "down": {"frames": 4, "fps": 6},
        },
    }


def update_manifest() -> None:
    path = OUT / "manifest.json"
    manifest = json.loads(path.read_text(encoding="utf-8"))
    existing = [item for item in manifest.get("characters", []) if item.get("id") not in {c["id"] for c in CHARACTERS}]
    insert_at = 0
    for i, item in enumerate(existing):
        if item.get("id") == "mangguo":
            insert_at = i + 1
            break
    for spec in reversed(CHARACTERS):
        existing.insert(insert_at, entry(spec))
    manifest["characters"] = existing
    path.write_text(json.dumps(manifest, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")


def main() -> None:
    for spec in CHARACTERS:
        directory = OUT / spec["id"]
        directory.mkdir(parents=True, exist_ok=True)
        build_portrait(spec, directory / "portrait.png")
        build_sheet(spec, directory / "sheet.png")
        build_hit_sheet(spec, directory / "hit_down_sheet.png")
    update_manifest()
    print("Created food characters:", ", ".join(c["name"] for c in CHARACTERS))


if __name__ == "__main__":
    main()
