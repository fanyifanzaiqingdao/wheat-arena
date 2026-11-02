#!/usr/bin/env python3
"""Build standardized 64x64 sprite sheets for Q-style characters."""

from __future__ import annotations

import argparse
import json
from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
FRAME = 64
FRAMES = 6
DIRECTIONS = ["down", "up", "right", "left"]
ACTIONS = ["idle", "run", "slash"]

SOURCE_NAMES = {
    "portrait_source.png": "portrait (1)",
    "poses_reference.png": "poses strip (2)",
    "idle_sheet_source.png": "idle grid (3)",
    "run_sheet_source.png": "run grid (4)",
    "slash_sheet_source.png": "slash grid (5)",
    "hit_down_sheet_source.png": "hit/down grid (6)",
}


def remove_background(image: Image.Image, threshold: int = 238) -> Image.Image:
    rgba = image.convert("RGBA")
    pixels = rgba.load()
    width, height = rgba.size
    for y in range(height):
        for x in range(width):
            r, g, b, a = pixels[x, y]
            if r >= threshold and g >= threshold and b >= threshold:
                pixels[x, y] = (r, g, b, 0)
    return rgba


def fit_frame(image: Image.Image, size: int = FRAME) -> Image.Image:
    rgba = remove_background(image)
    rgba.thumbnail((size - 8, size - 8), Image.Resampling.LANCZOS)
    canvas = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    offset_x = (size - rgba.width) // 2
    offset_y = size - rgba.height - 1
    canvas.paste(rgba, (offset_x, offset_y), rgba)
    return canvas


def slice_grid(path: Path, cols: int, rows: int) -> list[list[Image.Image]]:
    image = Image.open(path)
    cell_w = image.width // cols
    cell_h = image.height // rows
    grid: list[list[Image.Image]] = []
    for row in range(rows):
        row_frames: list[Image.Image] = []
        for col in range(cols):
            box = (col * cell_w, row * cell_h, (col + 1) * cell_w, (row + 1) * cell_h)
            row_frames.append(image.crop(box))
        grid.append(row_frames)
    return grid


def slice_strip(path: Path, count: int) -> list[Image.Image]:
    image = Image.open(path)
    cell_w = image.width // count
    frames: list[Image.Image] = []
    for index in range(count):
        box = (index * cell_w, 0, (index + 1) * cell_w, image.height)
        frames.append(image.crop(box))
    return frames


def pick_frames(cells: list[Image.Image], count: int = FRAMES) -> list[Image.Image]:
    if len(cells) >= count:
        return cells[:count]
    if not cells:
        blank = Image.new("RGBA", (FRAME, FRAME), (0, 0, 0, 0))
        return [blank.copy() for _ in range(count)]
    frames: list[Image.Image] = []
    for index in range(count):
        frames.append(cells[index % len(cells)])
    return frames


def paste_row(sheet: Image.Image, row_index: int, frames: list[Image.Image], flip: bool = False) -> None:
    for frame_index, frame in enumerate(frames):
        fitted = fit_frame(frame)
        if flip:
            fitted = fitted.transpose(Image.Transpose.FLIP_LEFT_RIGHT)
        sheet.paste(fitted, (frame_index * FRAME, row_index * FRAME), fitted)


def rename_chatgpt_sources(char_dir: Path) -> None:
    if all((char_dir / name).exists() for name in SOURCE_NAMES):
        return
    sources = sorted(char_dir.glob("ChatGPT Image*.png"))
    if len(sources) < 6:
        missing = [name for name in SOURCE_NAMES if not (char_dir / name).exists()]
        raise FileNotFoundError(f"Missing sources in {char_dir}: {missing}")
    for source, target in zip(sources, SOURCE_NAMES):
        destination = char_dir / target
        if destination.exists():
            continue
        source.rename(destination)


def build_portrait(char_dir: Path) -> None:
    source = Image.open(char_dir / "portrait_source.png")
    rgba = remove_background(source)
    rgba.thumbnail((512, 512), Image.Resampling.LANCZOS)
    canvas = Image.new("RGBA", (512, 512), (0, 0, 0, 0))
    offset_x = (512 - rgba.width) // 2
    offset_y = (512 - rgba.height) // 2
    canvas.paste(rgba, (offset_x, offset_y), rgba)
    canvas.save(char_dir / "portrait.png")


def build_main_sheet(char_dir: Path) -> None:
    idle_grid = slice_grid(char_dir / "idle_sheet_source.png", 4, 3)
    run_grid = slice_grid(char_dir / "run_sheet_source.png", 4, 3)
    slash_grid = slice_grid(char_dir / "slash_sheet_source.png", 4, 3)

    sheet = Image.new("RGBA", (FRAME * FRAMES, FRAME * len(ACTIONS) * len(DIRECTIONS)), (0, 0, 0, 0))
    action_grids = {
        "idle": idle_grid,
        "run": run_grid,
        "slash": slash_grid,
    }

    for action_index, action in enumerate(ACTIONS):
        grid = action_grids[action]
        front_row = pick_frames(grid[0])
        back_row = pick_frames(grid[1])
        right_row = pick_frames(grid[2])
        direction_rows = [front_row, back_row, right_row, right_row]
        for direction_index, frames in enumerate(direction_rows):
            row_index = action_index * len(DIRECTIONS) + direction_index
            paste_row(sheet, row_index, frames, flip=direction_index == 3)

    sheet.save(char_dir / "sheet.png")


def build_pose_sheets(char_dir: Path) -> None:
    hit_down_grid = slice_grid(char_dir / "hit_down_sheet_source.png", 4, 2)
    hit_sheet = Image.new("RGBA", (FRAME * FRAMES, FRAME * 2), (0, 0, 0, 0))
    paste_row(hit_sheet, 0, pick_frames(hit_down_grid[0]))
    paste_row(hit_sheet, 1, pick_frames(hit_down_grid[1]))
    hit_sheet.save(char_dir / "hit_down_sheet.png")

    reference = slice_strip(char_dir / "poses_reference.png", 5)
    ref_sheet = Image.new("RGBA", (FRAME * len(reference), FRAME), (0, 0, 0, 0))
    for index, frame in enumerate(reference):
        fitted = fit_frame(frame)
        ref_sheet.paste(fitted, (index * FRAME, 0), fitted)
    ref_sheet.save(char_dir / "poses_reference_sheet.png")


def character_entry(character_id: str, display_name: str) -> dict:
    base = f"res://assets/characters/{character_id}"
    return {
        "id": character_id,
        "name": display_name,
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


def update_manifest(character_id: str, display_name: str, insert_after: str | None = None) -> None:
    manifest_path = ROOT / "assets" / "characters" / "manifest.json"
    manifest = json.loads(manifest_path.read_text(encoding="utf-8"))
    entry = character_entry(character_id, display_name)
    characters = manifest.get("characters", [])
    characters = [item for item in characters if item.get("id") != character_id]
    if insert_after:
        inserted = False
        for index, item in enumerate(characters):
            if item.get("id") == insert_after:
                characters.insert(index + 1, entry)
                inserted = True
                break
        if not inserted:
            characters.insert(0, entry)
    else:
        characters.append(entry)
    manifest["characters"] = characters
    manifest_path.write_text(json.dumps(manifest, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")


def build_character(character_id: str, display_name: str, insert_after: str | None = None) -> Path:
    char_dir = ROOT / "assets" / "characters" / character_id
    if not char_dir.exists():
        raise FileNotFoundError(f"Character directory not found: {char_dir}")
    rename_chatgpt_sources(char_dir)
    build_portrait(char_dir)
    build_main_sheet(char_dir)
    build_pose_sheets(char_dir)
    update_manifest(character_id, display_name, insert_after)
    return char_dir


def main() -> None:
    parser = argparse.ArgumentParser(description="Build character sprite sheets")
    parser.add_argument("character_id", help="Character folder/id, e.g. fanqie")
    parser.add_argument("display_name", help="Display name, e.g. 番茄")
    parser.add_argument("--after", dest="insert_after", default=None, help="Insert after this character id in manifest")
    args = parser.parse_args()
    char_dir = build_character(args.character_id, args.display_name, args.insert_after)
    print(f"Built character assets: {char_dir}")


if __name__ == "__main__":
    main()
