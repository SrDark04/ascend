#!/usr/bin/env python3
"""Genera los assets de Ascend a partir de los originales de Resources/Images/.

Reproducible e idempotente: lee SOLO de Resources/Images/ (nunca los modifica)
y escribe en assets/ y tool/out/.

    python3 tool/prepare_assets.py

Requiere Python 3 + Pillow (sudo pacman -S python-pillow).

Salidas:
  assets/images/streak/nivel_1..6.png   insignias 768×768 con fondo transparente
  assets/icon/icon.png                  ícono legacy (prod), 1024×1024
  assets/icon/icon_dev.png              ícono legacy con banda «DEV»
  assets/icon/icon_foreground.png       primer plano del ícono adaptativo (prod)
  assets/icon/icon_foreground_dev.png   primer plano adaptativo con banda «DEV»
  assets/splash/splash.png              trébol para el splash (Android < 12)
  assets/splash/splash_android12.png    trébol para el splash de Android 12+
  tool/out/streak_contact_sheet.png     hoja de revisión de las insignias
  tool/out/icon_contact_sheet.png       hoja de revisión de íconos y splash
"""

from __future__ import annotations

import math
import statistics
import sys
from collections import deque
from pathlib import Path

from PIL import Image, ImageChops, ImageDraw, ImageFilter, ImageFont

ROOT = Path(__file__).resolve().parent.parent
SRC = ROOT / "Resources" / "Images"
ASSETS = ROOT / "assets"
OUT = ROOT / "tool" / "out"
FONT_BOLD = ASSETS / "fonts" / "BarlowCondensed" / "BarlowCondensed-Bold.ttf"

# ---------------------------------------------------------------------------
# Insignias de racha («niveles de ascenso»)
# ---------------------------------------------------------------------------

#: Cajas verificadas (izquierda, arriba, derecha, abajo) sobre el original
#: de 2400×1792. Excluyen el texto «FASE N».
STREAK_BOXES: dict[int, tuple[int, int, int, int]] = {
    1: (68, 80, 764, 772),
    2: (852, 80, 1592, 772),
    3: (1616, 80, 2356, 772),
    4: (52, 876, 776, 1640),
    5: (820, 876, 1584, 1640),
    6: (1608, 876, 2376, 1640),
}
STREAK_BG = (0x08, 0x0F, 0x17)  # azul-negro del fondo de la lámina
STREAK_TOLERANCE = 40  # distancia euclídea RGB máxima al fondo
STREAK_SIZE = 768  # lienzo cuadrado de salida (≥ la caja más grande)

# ---------------------------------------------------------------------------
# Ícono y splash
# ---------------------------------------------------------------------------

ICON_SIZE = 1024
#: Anillo que rodea al trébol en Icon.png, ajustado por mínimos cuadrados
#: (ver _fit_ring); el anillo no está perfectamente centrado en la imagen.
#: El recorte incluye el trazo del anillo y casi todas las estrellas.
ICON_CROP_RADIUS = 440
#: Zona segura del ícono adaptativo: círculo de 66 dp en una capa de 108 dp
#: (= 61 %). El recorte circular ocupa ese diámetro.
ADAPTIVE_SAFE_FRACTION = 66 / 108
#: Android 12+: ícono de 288 dp cuyo contenido visible es un círculo de
#: 192 dp (2/3). Dejamos un 4 % de margen dentro de ese círculo.
SPLASH12_SIZE = 1152
SPLASH12_FRACTION = (192 / 288) * 0.96
SPLASH_SIZE = 768

CRIMSON = (0xC1, 0x12, 0x1F, 255)  # AscendPalette.crimson (§7.2)
WHITE = (255, 255, 255, 255)


def _check_inputs() -> tuple[Path, Path]:
    icon = SRC / "Icon.png"
    sheet = SRC / "ImagenesDeRacha.jpg"
    for p in (icon, sheet, FONT_BOLD):
        if not p.exists():
            sys.exit(f"Falta el archivo de entrada: {p.relative_to(ROOT)}")
    return icon, sheet


# ---------------------------------------------------------------------------
# Insignias
# ---------------------------------------------------------------------------


def _flood_background(img: Image.Image, target: tuple[int, int, int], tol: int) -> Image.Image:
    """Máscara L (255 = conservar) tras inundar desde las 4 esquinas.

    Solo se vuelven transparentes los píxeles parecidos a `target` que están
    CONECTADOS a una esquina; así las sombras internas oscuras de la
    insignia no se tocan (un reemplazo de color global sí las dañaría).
    """
    w, h = img.size
    px = img.load()
    tol2 = tol * tol
    tr, tg, tb = target
    seen = bytearray(w * h)
    mask = Image.new("L", (w, h), 255)
    mpx = mask.load()
    queue: deque[tuple[int, int]] = deque()
    for x, y in ((0, 0), (w - 1, 0), (0, h - 1), (w - 1, h - 1)):
        queue.append((x, y))
        seen[y * w + x] = 1
    while queue:
        x, y = queue.popleft()
        r, g, b = px[x, y][:3]
        if (r - tr) ** 2 + (g - tg) ** 2 + (b - tb) ** 2 > tol2:
            continue
        mpx[x, y] = 0
        for nx, ny in ((x + 1, y), (x - 1, y), (x, y + 1), (x, y - 1)):
            if 0 <= nx < w and 0 <= ny < h and not seen[ny * w + nx]:
                seen[ny * w + nx] = 1
                queue.append((nx, ny))
    return mask


def _soften_edge(mask: Image.Image) -> Image.Image:
    """Quita el halo y suaviza el borde, solo hacia dentro.

    El JPEG deja 1–2 px de transición oscura entre el aro blanco y el fondo
    que superan la tolerancia; sobre un fondo claro se ven como un halo gris.
    Se erosiona 1 px y luego se aplica un antialias (nunca añade opacidad).
    """
    eroded = mask.filter(ImageFilter.MinFilter(3))
    return ImageChops.darker(eroded, eroded.filter(ImageFilter.GaussianBlur(1.0)))


def build_streak_badges(sheet_path: Path) -> list[Image.Image]:
    sheet = Image.open(sheet_path).convert("RGB")
    if sheet.size != (2400, 1792):
        sys.exit(f"ImagenesDeRacha.jpg debe medir 2400×1792 y mide {sheet.size}")
    out_dir = ASSETS / "images" / "streak"
    out_dir.mkdir(parents=True, exist_ok=True)
    badges = []
    for level, box in STREAK_BOXES.items():
        crop = sheet.crop(box)
        w, h = crop.size
        if max(w, h) > STREAK_SIZE:
            sys.exit(f"La caja del nivel {level} ({w}×{h}) no cabe en {STREAK_SIZE}")
        # Centrar en un lienzo cuadrado relleno con el color de fondo, para
        # que el relleno por inundación también limpie el margen añadido.
        canvas = Image.new("RGB", (STREAK_SIZE, STREAK_SIZE), STREAK_BG)
        canvas.paste(crop, ((STREAK_SIZE - w) // 2, (STREAK_SIZE - h) // 2))
        mask = _soften_edge(_flood_background(canvas, STREAK_BG, STREAK_TOLERANCE))
        badge = canvas.convert("RGBA")
        badge.putalpha(mask)
        # Los píxeles totalmente transparentes se guardan negros: PNG más
        # pequeño y sin «halo» de color al escalar.
        badge = Image.composite(badge, Image.new("RGBA", badge.size, (0, 0, 0, 0)), mask.point(lambda a: 255 if a else 0))
        path = out_dir / f"nivel_{level}.png"
        badge.save(path, optimize=True)
        badges.append(badge)
        opaque = mask.histogram()[255] / (STREAK_SIZE**2)
        print(f"  nivel_{level}.png  caja {w}×{h}  opaco {opaque:.0%}  {path.stat().st_size / 1024:.0f} KB")
    return badges


# ---------------------------------------------------------------------------
# Ícono
# ---------------------------------------------------------------------------


def _fit_ring(icon: Image.Image) -> tuple[float, float, float]:
    """Ajusta el anillo fino que rodea al trébol (método de Kåsa)."""
    gray = icon.convert("L")
    pts = []
    for deg in range(0, 360, 2):
        a = math.radians(deg)
        for r in range(395, 470):
            x, y = int(512 + r * math.cos(a)), int(512 + r * math.sin(a))
            if gray.getpixel((x, y)) < 80:
                pts.append((x, y))
                break

    def fit(points):
        s = [[0.0] * 3 for _ in range(3)]
        t = [0.0] * 3
        for x, y in points:
            row, z = (2 * x, 2 * y, 1), x * x + y * y
            for i in range(3):
                t[i] += row[i] * z
                for j in range(3):
                    s[i][j] += row[i] * row[j]
        m = [s[i] + [t[i]] for i in range(3)]
        for i in range(3):
            p = max(range(i, 3), key=lambda k: abs(m[k][i]))
            m[i], m[p] = m[p], m[i]
            for k in range(3):
                if k != i:
                    f = m[k][i] / m[i][i]
                    m[k] = [a - f * b for a, b in zip(m[k], m[i])]
        a, b, c = (m[i][3] / m[i][i] for i in range(3))
        return a, b, math.sqrt(c + a * a + b * b)

    cx, cy, r = fit(pts)
    for _ in range(3):  # descartar estrellas y puntos que no son el anillo
        pts = [p for p in pts if abs(math.hypot(p[0] - cx, p[1] - cy) - r) < 5]
        cx, cy, r = fit(pts)
    return cx, cy, r


def _sample_paper(icon: Image.Image, cx: float, cy: float, ring_r: float) -> tuple[int, int, int]:
    """Mediana del papel claro dentro del anillo (sin tinta negra ni roja)."""
    samples = []
    for deg in range(0, 360, 2):
        a = math.radians(deg)
        for r in range(int(ring_r * 0.70), int(ring_r * 0.97), 4):
            p = icon.getpixel((int(cx + r * math.cos(a)), int(cy + r * math.sin(a))))
            if min(p) > 150 and max(p) - min(p) < 40:
                samples.append(p)
    return tuple(int(statistics.median(ch)) for ch in zip(*samples))


def _circle_crop(icon: Image.Image, cx: float, cy: float, radius: int, feather: float) -> Image.Image:
    """Recorte circular RGBA con borde suavizado (sin costura con el fondo)."""
    box = (round(cx - radius), round(cy - radius), round(cx + radius), round(cy + radius))
    crop = icon.crop(box).convert("RGBA")
    d = 2 * radius
    scale = 4  # supermuestreo para un borde limpio
    mask = Image.new("L", (d * scale, d * scale), 0)
    inset = feather * scale
    ImageDraw.Draw(mask).ellipse((inset, inset, d * scale - inset, d * scale - inset), fill=255)
    mask = mask.resize((d, d), Image.LANCZOS).filter(ImageFilter.GaussianBlur(feather / 2))
    crop.putalpha(mask)
    return crop


def _centered(layer: Image.Image, size: int, diameter: int) -> Image.Image:
    canvas = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    scaled = layer.resize((diameter, diameter), Image.LANCZOS)
    off = (size - diameter) // 2
    canvas.alpha_composite(scaled, (off, off))
    return canvas


def _dev_band(size: int, center: tuple[float, float], thickness: float) -> Image.Image:
    """Banda diagonal roja (↗) con el texto «DEV», centrada en `center`."""
    layer = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    px, py = center
    dx, dy = 1 / math.sqrt(2), -1 / math.sqrt(2)  # dirección de la banda
    nx, ny = -dy, dx  # normal
    length, half = size * 2, thickness / 2
    poly = [
        (px - dx * length - nx * half, py - dy * length - ny * half),
        (px + dx * length - nx * half, py + dy * length - ny * half),
        (px + dx * length + nx * half, py + dy * length + ny * half),
        (px - dx * length + nx * half, py - dy * length + ny * half),
    ]
    scale = 4
    big = Image.new("RGBA", (size * scale, size * scale), (0, 0, 0, 0))
    ImageDraw.Draw(big).polygon([(x * scale, y * scale) for x, y in poly], fill=CRIMSON)
    layer = big.resize((size, size), Image.LANCZOS)

    font = ImageFont.truetype(str(FONT_BOLD), int(thickness * 0.78))
    left, top, right, bottom = font.getbbox("DEV")
    text = Image.new("RGBA", (right - left + 8, bottom - top + 8), (0, 0, 0, 0))
    ImageDraw.Draw(text).text((4 - left, 4 - top), "DEV", font=font, fill=WHITE)
    text = text.rotate(45, resample=Image.BICUBIC, expand=True)
    layer.alpha_composite(text, (round(px - text.width / 2), round(py - text.height / 2)))
    return layer


def build_icons(icon_path: Path) -> dict[str, Image.Image]:
    icon = Image.open(icon_path).convert("RGB")
    if icon.size != (ICON_SIZE, ICON_SIZE):
        sys.exit(f"Icon.png debe medir 1024×1024 y mide {icon.size}")
    cx, cy, ring_r = _fit_ring(icon)
    paper = _sample_paper(icon, cx, cy, ring_r)
    print(f"  anillo: centro ({cx:.1f}, {cy:.1f}) radio {ring_r:.1f} px")
    print(f"  papel muestreado: #{paper[0]:02X}{paper[1]:02X}{paper[2]:02X} {paper}")

    icon_dir = ASSETS / "icon"
    splash_dir = ASSETS / "splash"
    icon_dir.mkdir(parents=True, exist_ok=True)
    splash_dir.mkdir(parents=True, exist_ok=True)

    legacy = icon.convert("RGBA")
    circle = _circle_crop(icon, cx, cy, ICON_CROP_RADIUS, feather=10)
    fg = _centered(circle, ICON_SIZE, round(ICON_SIZE * ADAPTIVE_SAFE_FRACTION))

    band_t = ICON_SIZE * 0.13
    # Legacy: banda en la esquina inferior derecha (bien visible).
    legacy_dev = legacy.copy()
    legacy_dev.alpha_composite(_dev_band(ICON_SIZE, (ICON_SIZE * 0.80, ICON_SIZE * 0.80), band_t))
    # Adaptativo: banda más cerca del centro, para que «DEV» quede dentro de
    # la zona segura sea cual sea la máscara del lanzador.
    fg_dev = fg.copy()
    fg_dev.alpha_composite(_dev_band(ICON_SIZE, (ICON_SIZE * 0.66, ICON_SIZE * 0.66), ICON_SIZE * 0.10))

    splash = _centered(circle, SPLASH_SIZE, SPLASH_SIZE)
    splash12 = _centered(circle, SPLASH12_SIZE, round(SPLASH12_SIZE * SPLASH12_FRACTION))

    outputs = {
        icon_dir / "icon.png": legacy.convert("RGB"),
        icon_dir / "icon_dev.png": legacy_dev.convert("RGB"),
        icon_dir / "icon_foreground.png": fg,
        icon_dir / "icon_foreground_dev.png": fg_dev,
        splash_dir / "splash.png": splash,
        splash_dir / "splash_android12.png": splash12,
    }
    for path, img in outputs.items():
        img.save(path, optimize=True)
        print(f"  {path.relative_to(ROOT)}  {img.size[0]}×{img.size[1]}  {path.stat().st_size / 1024:.0f} KB")
    return {"paper": paper, "fg": fg, "fg_dev": fg_dev, "legacy": legacy, "legacy_dev": legacy_dev, "splash12": splash12}


# ---------------------------------------------------------------------------
# Hojas de revisión
# ---------------------------------------------------------------------------


def _checker(size: int, cell: int = 24) -> Image.Image:
    img = Image.new("RGBA", (size, size), (200, 200, 200, 255))
    d = ImageDraw.Draw(img)
    for y in range(0, size, cell):
        for x in range(0, size, cell):
            if (x // cell + y // cell) % 2:
                d.rectangle((x, y, x + cell - 1, y + cell - 1), fill=(240, 240, 240, 255))
    return img


def contact_sheet_streak(badges: list[Image.Image]) -> None:
    """Cada insignia sobre negro tinta, hueso (claro), damero y magenta.

    El magenta delata cualquier resto de fondo o «fuga» del relleno.
    """
    cell = 256
    rows = [("tinta", (0x0B, 0x0B, 0x0D, 255)), ("hueso", (0xF7, 0xF5, 0xF2, 255)), ("damero", None), ("magenta", (255, 0, 255, 255))]
    label_w = 120
    sheet = Image.new("RGBA", (label_w + cell * len(badges), cell * len(rows)), (255, 255, 255, 255))
    draw = ImageDraw.Draw(sheet)
    font = ImageFont.truetype(str(FONT_BOLD), 30)
    for r, (name, color) in enumerate(rows):
        draw.text((10, r * cell + cell // 2 - 15), name, font=font, fill=(0, 0, 0, 255))
        for i, badge in enumerate(badges):
            bg = _checker(cell) if color is None else Image.new("RGBA", (cell, cell), color)
            bg.alpha_composite(badge.resize((cell, cell), Image.LANCZOS))
            sheet.paste(bg, (label_w + i * cell, r * cell))
    for i in range(len(badges)):
        draw.text((label_w + i * cell + 8, 4), f"Nivel {i + 1}", font=font, fill=(255, 0, 255, 255))
    OUT.mkdir(parents=True, exist_ok=True)
    sheet.convert("RGB").save(OUT / "streak_contact_sheet.png", optimize=True)


def contact_sheet_icons(icons: dict) -> None:
    """Íconos con máscaras típicas de lanzador (círculo y squircle) y splash."""
    cell = 300
    paper = icons["paper"] + (255,)
    tiles = []

    def adaptive(fg: Image.Image, shape: str) -> Image.Image:
        # La capa de 108 dp se recorta a 72 dp visibles (2/3 centrales).
        full = Image.new("RGBA", fg.size, paper)
        full.alpha_composite(fg)
        inner = round(fg.width * 72 / 108)
        off = (fg.width - inner) // 2
        vis = full.crop((off, off, off + inner, off + inner)).resize((cell, cell), Image.LANCZOS)
        mask = Image.new("L", (cell * 4, cell * 4), 0)
        md = ImageDraw.Draw(mask)
        if shape == "circle":
            md.ellipse((0, 0, cell * 4, cell * 4), fill=255)
        else:
            md.rounded_rectangle((0, 0, cell * 4, cell * 4), radius=cell * 4 * 0.3, fill=255)
        vis.putalpha(mask.resize((cell, cell), Image.LANCZOS))
        return vis

    tiles.append(("legacy", icons["legacy"].resize((cell, cell), Image.LANCZOS)))
    tiles.append(("legacy DEV", icons["legacy_dev"].resize((cell, cell), Image.LANCZOS)))
    tiles.append(("adapt. círculo", adaptive(icons["fg"], "circle")))
    tiles.append(("adapt. squircle", adaptive(icons["fg"], "squircle")))
    tiles.append(("DEV círculo", adaptive(icons["fg_dev"], "circle")))
    tiles.append(("DEV squircle", adaptive(icons["fg_dev"], "squircle")))
    splash = Image.new("RGBA", (cell, cell), (0x0B, 0x0B, 0x0D, 255))
    splash.alpha_composite(icons["splash12"].resize((cell, cell), Image.LANCZOS))
    tiles.append(("splash 12+", splash))

    font = ImageFont.truetype(str(FONT_BOLD), 28)
    sheet = Image.new("RGBA", ((cell + 20) * len(tiles) + 20, cell + 70), (0x5A, 0x5A, 0x62, 255))
    draw = ImageDraw.Draw(sheet)
    for i, (name, tile) in enumerate(tiles):
        x = 20 + i * (cell + 20)
        sheet.alpha_composite(tile, (x, 20))
        draw.text((x, cell + 28), name, font=font, fill=(255, 255, 255, 255))
    OUT.mkdir(parents=True, exist_ok=True)
    sheet.convert("RGB").save(OUT / "icon_contact_sheet.png", optimize=True)


def main() -> None:
    icon_path, sheet_path = _check_inputs()
    print("Insignias de racha:")
    badges = build_streak_badges(sheet_path)
    print("Ícono y splash:")
    icons = build_icons(icon_path)
    contact_sheet_streak(badges)
    contact_sheet_icons(icons)
    print(f"Hojas de revisión en {OUT.relative_to(ROOT)}/")


if __name__ == "__main__":
    main()
