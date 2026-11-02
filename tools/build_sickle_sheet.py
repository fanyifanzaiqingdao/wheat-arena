#!/usr/bin/env python3
"""Build sickle spin sprite sheet from a 2x4 source grid."""

from __future__ import annotations

from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
OUT_DIR = ROOT / "assets" / "weapons" / "sickle"
SOURCE = OUT_DIR / "sheet_source.png"
FRAME = 56
COLS = 4
ROWS = 2


def rename_chatgpt_source() -> None:
    if SOURCE.exists():
        return
    matches = sorted(OUT_DIR.glob("ChatGPT Image*.png"))
    if not matches:
        raise FileNotFoundError(f"Missing sickle source in {OUT_DIR}")
    matches[0].rename(SOURCE)


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
    rgba.thumbnail((size - 4, size - 4), Image.Resampling.LANCZOS)
    canvas = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    offset_x = (size - rgba.width) // 2
    offset_y = (size - rgba.height) // 2
    canvas.paste(rgba, (offset_x, offset_y), rgba)
    return canvas


def main() -> None:
    rename_chatgpt_source()
    image = Image.open(SOURCE)
    cell_w = image.width // COLS
    cell_h = image.height // ROWS
    sheet = Image.new("RGBA", (FRAME * COLS, FRAME * ROWS), (0, 0, 0, 0))
    frame_index = 0
    for row in range(ROWS):
        for col in range(COLS):
            box = (col * cell_w, row * cell_h, (col + 1) * cell_w, (row + 1) * cell_h)
            fitted = fit_frame(image.crop(box))
            sheet.paste(fitted, (col * FRAME, row * FRAME), fitted)
            frame_index += 1
    sheet.save(OUT_DIR / "sheet.png")
    print(f"Built sickle sheet: {OUT_DIR / 'sheet.png'} ({COLS * ROWS} frames)")


if __name__ == "__main__":
    main()
