# TlsLib4Pascal branding

This folder holds the **project logo** and derivative assets for README, social previews, and optional IDE package icons.

## Meaning

The mark is a **rounded badge** showing a **secured connection**: two **endpoint** nodes joined by a **link**, with a **padlock** straddling the wire. It suggests:

- **Transport security between two parties** — the TLS handshake and the encrypted channel it protects (a *library*, not one primitive).
- **Secure by default** — the padlock sits on the connection itself.
- **Clarity** — readable at small sizes (favicon / package icon).

It is **not** derived from Embarcadero, Delphi, or any other artwork. Do not combine it with third-party trademarks in a way that implies endorsement.

## Files

| File | Use |
|------|-----|
| [`logo.svg`](logo.svg) | **Source of truth** (light UI / default README on GitHub light theme). |
| [`logo-dark.svg`](logo-dark.svg) | Dark backgrounds (docs sites, dark-themed pages). |
| [`BRAND.md`](BRAND.md) | Colors, clear space, minimum size, do / don't. |
| [`export/`](export/) (`*.png`) | Raster exports (GitHub social 2:1, Open Graph, social header, square avatar). |
| [`icons/`](icons/) (`*.ico`) | Multi-resolution Windows icon for `.dproj` / `.lpi`. |

## License

The **library source code** is under the project [MIT License](../../LICENSE). The **logo files in this directory** are also released under the **MIT License** unless the repository maintainers specify otherwise in a future commit; you may use them to refer to TlsLib4Pascal. Do not use them to misrepresent authorship or to imply certification by the authors.

## Regenerating PNG and ICO

The `.svg` files are the source of truth; the raster and icon files are generated from [`logo.svg`](logo.svg). After changing the SVG, regenerate with one of:

- **Inkscape** (CLI): `inkscape logo.svg --export-type=png --export-width=512 -o export/logo-512.png` (repeat for the sizes [listed here](export/README.md)).
- **ImageMagick** 7+: `magick logo.svg -resize 512x512 export/logo-512.png`, and for the icon `magick logo.svg -define icon:auto-resize=16,32,48,256 icons/TlsLib4Pascal.ico`.
