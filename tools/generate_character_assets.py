from __future__ import annotations

import json
import math
from pathlib import Path

from PIL import Image, ImageDraw


ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "assets" / "characters"
FRAME = 64
FRAMES = 6
DIRECTIONS = ["down", "up", "right", "left"]
ACTIONS = ["idle", "run", "slash"]


CHARACTERS = [
    {"id": "qinghe", "name": "青禾", "hat": "#31b7e9", "coat": "#0e6385", "skin": "#d88b5d", "hair": "#3c2925", "accent": "#fff4a8"},
    {"id": "chilian", "name": "赤镰", "hat": "#ef5b76", "coat": "#982d48", "skin": "#c97a55", "hair": "#2e2020", "accent": "#ffd0dd"},
    {"id": "wanxia", "name": "晚霞", "hat": "#e67e22", "coat": "#8d4b23", "skin": "#dc9a6d", "hair": "#442616", "accent": "#ffe0a3"},
    {"id": "mosui", "name": "墨穗", "hat": "#9b59b6", "coat": "#57306d", "skin": "#bd7f5d", "hair": "#17191f", "accent": "#e7d2ff"},
    {"id": "zhuye", "name": "竹叶", "hat": "#2ecc71", "coat": "#1f7d4a", "skin": "#d18c63", "hair": "#29311e", "accent": "#caffd8"},
    {"id": "shuangmai", "name": "霜麦", "hat": "#8ed6ff", "coat": "#356b8f", "skin": "#e0a078", "hair": "#f2efe4", "accent": "#eef9ff"},
    {"id": "jinli", "name": "金粒", "hat": "#f5c542", "coat": "#9b7724", "skin": "#c4825c", "hair": "#6b4224", "accent": "#fff1a8"},
    {"id": "lanting", "name": "兰庭", "hat": "#1abc9c", "coat": "#11695f", "skin": "#d7946d", "hair": "#223434", "accent": "#bcfff4"},
    {"id": "hongdou", "name": "红豆", "hat": "#e84393", "coat": "#8f2d61", "skin": "#cc825d", "hair": "#3b1e30", "accent": "#ffd3ea"},
    {"id": "heiyan", "name": "黑岩", "hat": "#607d8b", "coat": "#314750", "skin": "#a96f50", "hair": "#111111", "accent": "#d4e2e8"},
    {"id": "baimian", "name": "白面", "hat": "#f4ead7", "coat": "#9d8e73", "skin": "#df9a72", "hair": "#6a4a35", "accent": "#fffdf0"},
    {"id": "canglang", "name": "苍浪", "hat": "#3d8fbe", "coat": "#23566f", "skin": "#c58460", "hair": "#1d2a36", "accent": "#bdefff"},
]


def hex_color(value: str, alpha: int = 255) -> tuple[int, int, int, int]:
    value = value.lstrip("#")
    return tuple(int(value[i : i + 2], 16) for i in (0, 2, 4)) + (alpha,)


def rect(draw: ImageDraw.ImageDraw, xy: tuple[int, int, int, int], color: str | tuple[int, int, int, int]) -> None:
    draw.rectangle(xy, fill=hex_color(color) if isinstance(color, str) else color)


def ellipse(draw: ImageDraw.ImageDraw, xy: tuple[int, int, int, int], color: str | tuple[int, int, int, int]) -> None:
    draw.ellipse(xy, fill=hex_color(color) if isinstance(color, str) else color)


def line(draw: ImageDraw.ImageDraw, xy: list[tuple[int, int]], color: str | tuple[int, int, int, int], width: int = 1) -> None:
    draw.line(xy, fill=hex_color(color) if isinstance(color, str) else color, width=width)


def draw_character_frame(draw: ImageDraw.ImageDraw, ox: int, oy: int, spec: dict, action: str, direction: str, frame: int) -> None:
    t = frame / FRAMES
    cycle = math.sin(t * math.tau)
    step = int(round(cycle * 3))
    bob = -abs(int(round(math.sin(t * math.tau) * 2))) if action == "run" else 0
    if action == "idle":
        bob = -1 if frame in (1, 4) else 0
    slash = action == "slash"
    slash_sweep = (frame / (FRAMES - 1)) * 1.35 - 0.5

    cx = ox + FRAME // 2
    foot_y = oy + 50 + bob
    body_y = oy + 27 + bob
    head_y = oy + 16 + bob
    facing_x = 1 if direction == "right" else -1 if direction == "left" else 0

    shadow = (20, 50, 34, 92)
    ellipse(draw, (cx - 15, oy + 48, cx + 15, oy + 56), shadow)

    if direction in ("left", "right"):
        leg_shift = step if action == "run" else 0
        rect(draw, (cx - 8 - leg_shift, foot_y - 7, cx - 2 - leg_shift, foot_y + 2), "#67462f")
        rect(draw, (cx + 2 + leg_shift, foot_y - 7, cx + 8 + leg_shift, foot_y + 2), "#67462f")
        rect(draw, (cx - 8, body_y, cx + 8, body_y + 18), spec["coat"])
        rect(draw, (cx - 6, head_y, cx + 6, head_y + 12), spec["skin"])
        rect(draw, (cx - 7, head_y - 4, cx + 7, head_y + 1), spec["hair"])
        eye_x = cx + facing_x * 4
        rect(draw, (eye_x - 1, head_y + 5, eye_x + 1, head_y + 6), "#2a1d1b")
        rect(draw, (cx - 13, head_y - 5, cx + 13, head_y - 1), spec["hat"])
        rect(draw, (cx - 7, head_y - 10, cx + 7, head_y - 5), spec["hat"])
    else:
        leg_shift = step if action == "run" else 0
        rect(draw, (cx - 10, foot_y - 7 - leg_shift, cx - 3, foot_y + 2 - leg_shift), "#67462f")
        rect(draw, (cx + 3, foot_y - 7 + leg_shift, cx + 10, foot_y + 2 + leg_shift), "#67462f")
        rect(draw, (cx - 9, body_y, cx + 9, body_y + 18), spec["coat"])
        rect(draw, (cx - 8, head_y, cx + 8, head_y + 13), spec["skin"])
        if direction == "up":
            rect(draw, (cx - 9, head_y - 3, cx + 9, head_y + 6), spec["hair"])
        else:
            rect(draw, (cx - 5, head_y + 6, cx - 3, head_y + 7), "#2a1d1b")
            rect(draw, (cx + 3, head_y + 6, cx + 5, head_y + 7), "#2a1d1b")
        rect(draw, (cx - 13, head_y - 5, cx + 13, head_y - 1), spec["hat"])
        rect(draw, (cx - 7, head_y - 10, cx + 7, head_y - 5), spec["hat"])

    rect(draw, (cx - 4, body_y + 3, cx + 4, body_y + 13), spec["accent"])

    hand = (cx + facing_x * 10, body_y + 8)
    if direction == "down":
        hand = (cx + 10, body_y + 10)
    elif direction == "up":
        hand = (cx - 10, body_y + 7)
    if slash:
        base_angle = {"right": 0.0, "left": math.pi, "down": math.pi / 2, "up": -math.pi / 2}[direction]
        angle = base_angle + slash_sweep * (1 if direction in ("right", "up") else -1)
        reach = 18 + frame * 2
        tip = (int(hand[0] + math.cos(angle) * reach), int(hand[1] + math.sin(angle) * reach))
        line(draw, [hand, tip], "#71472f", 3)
        blade_angle = angle + 0.9
        blade_tip = (int(tip[0] + math.cos(blade_angle) * 8), int(tip[1] + math.sin(blade_angle) * 8))
        line(draw, [tip, blade_tip], "#edf2d4", 3)
        if frame in (2, 3, 4):
            arc_color = (255, 247, 176, 115)
            line(draw, [(tip[0] - 7, tip[1] + 3), (tip[0], tip[1] - 4), (tip[0] + 8, tip[1] - 1)], arc_color, 2)
    else:
        dir_angle = {"right": 0.0, "left": math.pi, "down": math.pi / 2, "up": -math.pi / 2}[direction]
        tip = (int(hand[0] + math.cos(dir_angle) * 14), int(hand[1] + math.sin(dir_angle) * 14))
        line(draw, [hand, tip], "#71472f", 2)
        line(draw, [tip, (tip[0] + facing_x * 5 if facing_x else tip[0] + 5, tip[1] - 5)], "#edf2d4", 2)


def draw_portrait(spec: dict) -> Image.Image:
    scale = 4
    img = Image.new("RGBA", (128, 128), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    ellipse(draw, (20, 98, 108, 118), (23, 58, 49, 120))
    rect(draw, (42, 62, 86, 112), spec["coat"])
    rect(draw, (48, 36, 80, 70), spec["skin"])
    rect(draw, (45, 30, 83, 43), spec["hair"])
    rect(draw, (34, 28, 94, 38), spec["hat"])
    rect(draw, (48, 13, 80, 28), spec["hat"])
    rect(draw, (54, 52, 58, 56), "#2a1d1b")
    rect(draw, (70, 52, 74, 56), "#2a1d1b")
    rect(draw, (58, 64, 70, 67), "#9b514b")
    rect(draw, (56, 78, 72, 104), spec["accent"])
    rect(draw, (26, 76, 42, 104), "#71472f")
    line(draw, [(31, 72), (84, 26)], "#71472f", 4)
    line(draw, [(84, 26), (98, 17)], "#edf2d4", 4)
    return img.resize((128 * scale, 128 * scale), Image.Resampling.NEAREST)


def generate() -> None:
    OUT.mkdir(parents=True, exist_ok=True)
    manifest = {"frame_size": FRAME, "frames": FRAMES, "directions": DIRECTIONS, "actions": ACTIONS, "characters": []}
    for spec in CHARACTERS:
        char_dir = OUT / spec["id"]
        char_dir.mkdir(parents=True, exist_ok=True)
        sheet = Image.new("RGBA", (FRAME * FRAMES, FRAME * len(ACTIONS) * len(DIRECTIONS)), (0, 0, 0, 0))
        draw = ImageDraw.Draw(sheet)
        for action_index, action in enumerate(ACTIONS):
            for direction_index, direction in enumerate(DIRECTIONS):
                row = action_index * len(DIRECTIONS) + direction_index
                for frame in range(FRAMES):
                    draw_character_frame(draw, frame * FRAME, row * FRAME, spec, action, direction, frame)
        sheet.save(char_dir / "sheet.png")
        draw_portrait(spec).save(char_dir / "portrait.png")
        manifest["characters"].append({
            "id": spec["id"],
            "name": spec["name"],
            "sheet": f"res://assets/characters/{spec['id']}/sheet.png",
            "portrait": f"res://assets/characters/{spec['id']}/portrait.png",
        })
    (OUT / "manifest.json").write_text(json.dumps(manifest, ensure_ascii=False, indent=2), encoding="utf-8")


if __name__ == "__main__":
    generate()
