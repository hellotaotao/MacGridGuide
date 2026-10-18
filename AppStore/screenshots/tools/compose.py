"""Composites the real overlay and settings window renders over the page backgrounds.

Usage: compose.py <work dir> <output dir>
"""
import sys
from PIL import Image

WORK, OUT = sys.argv[1], sys.argv[2]
MENU_BAR_PX = 48  # 24 pt menu bar at 2x; the overlay covers the visible frame below it


def shot(bg, overlay, name, window=None, window_center=None):
    base = Image.open(f"{WORK}/out/bg-{bg}.png").convert("RGBA")
    layer = Image.new("RGBA", base.size)
    if overlay:
        layer.paste(Image.open(f"{WORK}/out/{overlay}").convert("RGBA"), (0, MENU_BAR_PX))
    if window:
        win = Image.open(f"{WORK}/out/{window}").convert("RGBA")
        cx, cy = window_center
        base.alpha_composite(win, (cx - win.width // 2, cy - win.height // 2))
    # The overlay panel floats above normal windows, so it is drawn on top of everything.
    base.alpha_composite(layer)
    base.convert("RGB").save(f"{OUT}/{name}", optimize=True)
    print("saved", name, base.size)


shot("columns", "overlay-columns.png", "01-columns.png")
shot("dashboard", "overlay-8pt.png", "02-8pt-grid.png")
shot("article", "overlay-baseline.png", "03-baseline.png")
# Grid hidden: the overlay floats above normal windows and would cover the settings window.
shot("columns", None, "04-settings.png", window="settings-columns.png", window_center=(1440, 960))
