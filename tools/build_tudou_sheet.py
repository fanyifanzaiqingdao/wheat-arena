#!/usr/bin/env python3
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from build_character_sheet import build_character

if __name__ == "__main__":
    build_character("tudou", "土豆", insert_after=None)
