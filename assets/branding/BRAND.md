# TlsLib4Pascal — lightweight brand guide

## Primary mark

- **Default:** [`logo.svg`](logo.svg) — **secured link**: two **endpoint** nodes joined by a **connection**, with a **padlock** straddling the wire. Reads as a **protected TLS channel between two parties** — transport security, not a single algorithm.
- **Dark UI:** [`logo-dark.svg`](logo-dark.svg) — same layout with **brighter** endpoints and connection on a **near-black teal** badge, a **sky** padlock, and a **near-black** keyhole.

## Palette (default logo)

| Role | Hex | Notes |
|------|-----|--------|
| Badge top | `#0f4d6e` | Gradient start. |
| Badge bottom | `#082f45` | Gradient end. |
| Badge gradient axis | `(0,0)–(1,1)` | Diagonal. |
| Endpoints | `#3d8fb0` at 95% opacity | The two connected parties. |
| Connection (wire) | `#e8f4fc` | The link between them. |
| Padlock body | `#38bdf8` | Security over the channel. |
| Padlock shackle | `#e8f4fc` | — |
| Keyhole | `#082f45` | Cut into the padlock. |

Dark variant uses badge `#0a1624`–`#050c14`, connection `#cffafe`, endpoints `#155e75`, padlock body `#22d3ee`, shackle `#cffafe`, keyhole `#020617`.

**Banner background** (flat fill behind the logo for wide social and Open Graph PNGs [here](export/)): RGB **16, 77, 110** (`#104d6e`) — the same deep teal as `#0f4d6e` to the eye; +1 red avoids matching the badge-top pixel-for-pixel so the squircle edge survives. The **SVG** keeps gradient top `#0f4d6e`.

## Typography (pairing)

The logo has **no embedded wordmark**. When setting type next to the mark:

- Prefer **clean sans-serif** system or UI fonts (e.g. Segoe UI, Inter, Source Sans 3).
- **Do not** use Embarcadero's proprietary Delphi logotype fonts or official Delphi product logos alongside this mark in a way that suggests a product bundle.

## Clear space

Keep padding around the badge at least **1/4 of the mark's width** (e.g. ~32 px clear space on a 128 px square canvas). Do not crowd badges, buttons, or text against the curved corners.

## Minimum size

- **Favicon / IDE:** readable at **16×16** when exported to ICO; prefer **32×32** or larger for clarity.
- **README / docs:** **128–200 px** wide for the SVG or equivalent raster is typical.

## Correct use

- Scale **uniformly** (preserve aspect ratio).
- Place on **solid or subtly patterned** backgrounds with enough contrast (use [`logo-dark.svg`](logo-dark.svg) on dark pages).
- Prefer **SVG** for web; use **PNG** only where required (some social crawlers, legacy tools).

## Incorrect use

- Do not **stretch** or **skew** the badge.
- Do not **change hue** arbitrarily (keep the palette cohesive with the table above, or update this doc when rebranding).
- Do not **outline** with clashing neon colors for "effect."
- Do not **crop** the rounded square into a harsh rectangle that removes the corner radius entirely.
- Do not **add** third-party logos *inside* the badge.

## Wordmark

"TlsLib4Pascal" in plain text beside or below the mark is sufficient; no official custom logotype is required.
