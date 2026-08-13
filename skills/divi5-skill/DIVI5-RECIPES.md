# DIVI5-RECIPES — Render-Verified Component Library
V0.8.2 | Builder Version 5.10.0
Every recipe below shipped live on a Divi 5.10 site via Novamira Pro MCP abilities **with host WAF/ModSecurity enabled** — all attrs are in flat dotted-key form (WAF-safe; abilities auto-nest with a harmless warning). Replace `{{TOKENS}}` and go. Build order: design system → presets → structure top-down, one fully-formed `divi-add-module` call per module.

Tokens used throughout: `{{ACCENT}}` `{{ACCENT_SOFT}}` `{{DARK}}` `{{INK}}` `{{SURFACE_DARK}}` `{{BG}}` `{{BG_ALT}}` `{{PAPER}}` `{{MUTED}}` = `var(--gcid-…)` global color vars (create colors first, capture returned gcids). `{{SERIF}}`/`{{SANS}}` = font families. `{{IMG}}` = **real attachment URL from the media library** (never a constructed path).

---

## R1 — Design-system bootstrap (order matters)
1. `divi-create-global-color` per palette color → record each `var(--gcid-…)`.
2. `divi-update-global-colors` to re-point the 5 built-in named colors (primary/secondary/heading/body/background) — default module chrome inherits primary, so set it deliberately.
3. `divi-set-global-fonts` heading + body.
4. Presets (R2, R3, R5-group) BEFORE any page module.
Rebrand = trash old pages + re-point the 5 named colors. Leave dormant custom tokens; don't burn calls deleting them.

## R2 — Solid accent button (preset) ✅ the exact shipped preset
`divi-create-global-preset` module `divi/button`, then apply everywhere via `modulePreset`.
```json
{
 "button.decoration.background.desktop.value": {"color": "{{ACCENT}}"},
 "button.decoration.background.desktop.hover": {"color": "{{ACCENT_SOFT}}"},
 "button.decoration.border.desktop.value": {"radius": {"sync":"on","topLeft":"0px","topRight":"0px","bottomLeft":"0px","bottomRight":"0px"}, "styles": {"all": {"width":"0px"}}},
 "button.decoration.font.font.desktop.value": {"family":"{{SANS}}","size":"10px","letterSpacing":"2.2px","weight":"500","color":"{{DARK_TEXT}}"},
 "button.decoration.button.desktop.value": {"enable":"on","icon":{"enable":"on","onHover":"off"}},
 "module.decoration.spacing.desktop.value": {"padding": {"top":"19px","bottom":"19px","left":"30px","right":"30px"}}
}
```
Pitfalls pre-solved: `enable:"on"` gate (without it ALL styling ignored) · padding under `module.decoration.spacing` (`button.decoration.spacing` does not exist — silently ignored) · `icon.onHover:"off"` for always-visible arrow · radius 0 (default is rounded).

## R3 — Text-link / underline button (inline attrs on the module)
```json
{
 "button.innerContent.desktop.value": {"text":"{{LABEL}}","linkUrl":"{{URL}}"},
 "button.decoration.button.desktop.value": {"enable":"on"},
 "button.decoration.background.desktop.value": {"color":"rgba(255,255,255,0)"},
 "button.decoration.border.desktop.value": {"radius": {"sync":"on","topLeft":"0px","topRight":"0px","bottomLeft":"0px","bottomRight":"0px"}, "styles": {"top":{"width":"0px"},"left":{"width":"0px"},"right":{"width":"0px"},"bottom":{"width":"1px","style":"solid","color":"{{HAIRLINE}}"}}},
 "button.decoration.font.font.desktop.value": {"family":"{{SANS}}","size":"10px","letterSpacing":"2.2px","weight":"500","color":"{{INK}}"},
 "module.decoration.spacing.desktop.value": {"padding": {"top":"0px","bottom":"8px","left":"0px","right":"0px"}}
}
```
Every unspecified property inherits accent-colored default chrome → the full zero-out is mandatory.

## R4 — Hero: full-bleed bg + gradient scrim + vertically centered content
Section (split into 2 calls if WAF bounces: bg-color+image first, gradient via edit):
```json
{"module.decoration.background.desktop.value": {"color":"{{DARK}}","image":{"url":"{{IMG}}","size":"cover","position":"center"}}}
{"module.decoration.background.desktop.value": {"gradient": {"enabled":"on","overlaysImage":"on","type":"linear","direction":"90deg","stops":[{"position":0,"color":"rgba(12,11,10,0.92)"},{"position":42,"color":"rgba(12,11,10,0.62)"},{"position":78,"color":"rgba(12,11,10,0.18)"},{"position":100,"color":"rgba(12,11,10,0.45)"}]}}}
{"module.decoration.sizing.desktop.value": {"minHeight":"700px"},
 "module.decoration.layout.desktop.value": {"display":"flex","flexDirection":"column","justifyContent":"center"},
 "module.decoration.spacing.desktop.value": {"padding":{"top":"60px","bottom":"60px","left":"56px","right":"56px"}}}
```
Section is a flex COLUMN → vertical centering is `justifyContent` (not alignItems). `overlaysImage:"on"` puts the scrim above the photo. Row inside: `{"module.decoration.sizing.desktop.value": {"maxWidth":"1560px","width":"100%"}}`. Children: eyebrow text (11px letterspaced accent) → h1 heading ({{SERIF}} 300, 78px desktop/54 tablet/38 phone, lineHeight 1.06em) → lede (maxWidth 400px) → R2 button.

## R5 — Card row — cards as COLUMNS (⚠ corrected; beats groups-in-grid)
Groups tiling in a grid column caused stretch-distribution gaps and blocked overlay techniques. The clean structure: **one row, each card its own column.**
- Row: `{"module.decoration.layout.desktop.value": {"display":"flex","alignItems":"flex-start","columnGap":"22px"}, "module.decoration.layout.tablet.value": {"flexDirection":"column","rowGap":"22px"}}` — alignItems flex-start stops taller siblings (sidebar) stretching the cards.
- Columns: NO width fractions — even columns auto-distribute and can't gap-overflow. Card column attrs: white bg + 1px hairline border (+ accent hover border).
- Card children in flow: media group (R6) → price heading (serif 26, padding 22/22/0) → address text (13px, padding 9/22/0) → specs text (9px letterspaced, `border …styles.top` hairline, margins 18/22, padding 20/0/22).

## R6 — Overlay chip / badge — PURE FLOW, no positioning (⚠ corrected)
**The `position` style group does NOT emit CSS through the MCP abilities — any module, any parent.** Attrs store and the VB shows them, but no rules reach the frontend. Never build overlays on it. The verified pattern is flow-over-background:
```json
// the media area: a group with the PHOTO as background
{"module.decoration.background.desktop.value": {"image":{"url":"{{IMG}}","size":"cover","position":"center"}},
 "module.decoration.sizing.desktop.value": {"minHeight":"250px","width":"100%"},
 "module.decoration.layout.desktop.value": {"display":"flex","flexDirection":"column","alignItems":"flex-start"},
 "module.decoration.spacing.desktop.value": {"padding":{"top":"16px","left":"16px"}}}
// the chip: a plain in-flow text child — renders over the photo naturally
{"content.innerContent.desktop.value": "<p>{{LABEL}}</p>",
 "module.decoration.background.desktop.value": {"color":"rgba(18,17,15,0.72)"},
 "module.decoration.spacing.desktop.value": {"padding":{"top":"8px","bottom":"8px","left":"13px","right":"13px"}}}
```
`alignItems:flex-start` on the group shrinks the chip to its text. Same pattern at every scale: About-style overlay cards (column bg + in-flow group), footer quote cards (group bg + centered text). Zero positioning, VB-editable, responsive-safe. Trade-off: background images ship no `<img>`/alt — flag it if image SEO matters. True absolute positioning remains a manual Visual Builder step; note it in handoff.

## R7 — Split section: bg-image column | content | hairline stats
Section: bg `{{BG_ALT}}`, padding 0. Row: `maxWidth 100%`, padding 0. Columns `2_5 | 2_5 | 1_5`:
- Image half = **column BACKGROUND**, not an image module: `{"module.decoration.background.desktop.value": {"image":{"url":"{{IMG}}","size":"cover","position":"center"}}, "module.decoration.sizing.desktop.value": {"minHeight":"560px"}}` — image modules under-fill in flex columns (grid cells only). Overlay card = R6 group inside this column.
- Content column: own padding (92/76/92/40), eyebrow → h2 (46px, `<em>` for the italic line) → paragraph (maxWidth 440) → R3 link.
- Stats column: `border …styles.left` hairline + paddingLeft 40; repeat R8.

## R8 — Stat block (pair)
Heading `{{SERIF}} 300 40px lineHeight 1em` + label text `9px letterSpacing 2px {{MUTED}}` with `border …styles.top` hairline, `margin {top:12px,bottom:38px}`, `padding {top:14px}`.

## R9 — List rows w/ active state (neighborhood list)
Each row = one text module `<p>01&nbsp;&nbsp;&nbsp;&nbsp;{{LABEL}}</p>`, 12px letterSpacing 2.2px, padding 15/0, `border …styles.bottom` 1px. Active row: accent border color + `{{INK}}` text + `&rarr;`; inactive: hairline + `{{MUTED}}`.

## R10 — Quote block (testimonial)
Group: `border …styles.left` 1px rgba(paper,0.12), padding 6/34. Children: quote text (13px, lineHeight 1.9em, rgba(paper,0.78), `&ldquo;…&rdquo;`) + attribution (10px letterspaced {{MUTED}}, `&mdash; NAME`). Tile 3-up via R5 grid (columnGap 0).

## R11 — CTA band (bordered panel row)
Second row inside the dark section:
```json
{"module.decoration.background.desktop.value": {"color":"{{SURFACE_DARK}}"},
 "module.decoration.border.desktop.value": {"styles":{"all":{"width":"1px","style":"solid","color":"rgba({{ACCENT_RGB}},0.28)"}}},
 "module.decoration.sizing.desktop.value": {"maxWidth":"1440px","width":"100%"},
 "module.decoration.spacing.desktop.value": {"margin":{"top":"56px"},"padding":{"top":"44px","bottom":"44px","left":"48px","right":"48px"}}}
```
4 equal columns: serif h3 (`<em>` second line) | support text | contact lines (`&#9742;` / `&#9993;` glyphs) | R2 button. Put the page's `#contact` anchor here via `module.advanced.htmlAttributes.desktop.value {"id":"contact"}`.

## R12 — Header bar (TB header layout)
Section: dark bg, padding 22/56. Row: maxWidth 1560 + `display:flex`; the VB stores column widths as `module.advanced.columnStructure.desktop.value` on the ROW (e.g. `"1_2,1_2,1_4"`) alongside per-column `module.advanced.type`.
- Logo column: `{"module.decoration.layout.desktop.value": {"display":"flex","flexDirection":"row","alignItems":"center","columnGap":"16px"}}` → monogram heading + wordmark text with `border …styles.left` hairline divider + paddingLeft 16.
- Nav column: ONE text module of anchor links (`content.decoration.bodyFont.link.font…color` for link color; body font 11px letterspaced; textAlign center). One module beats seven.
- Button column: `{"module.decoration.layout.desktop.value": {"display":"flex","flexDirection":"row","justifyContent":"flex-end"}}` → ghost button (R3-style zero-out but 1px accent border all sides + translucent dark bg + 16/26 padding).

## R13 — Footer grid + bg-image quote card + legal bar
Row 1: maxWidth 1560, 5 columns: brand (monogram heading, wordmark, tagline+social in one text w/ link color accent) | nav links text (`<strong>` label + `<br>`-separated anchors, lineHeight 2.2em) | resources same | contact text | quote card column → group: `{"module.decoration.background.desktop.value": {"image":{"url":"{{IMG}}","size":"cover","position":"center"}, "gradient":{"enabled":"on","overlaysImage":"on","type":"linear","direction":"180deg","stops":[{"position":0,"color":"rgba(18,17,15,0.5)"},{"position":100,"color":"rgba(18,17,15,0.5)"}]}}, "module.decoration.sizing.desktop.value": {"minHeight":"150px"}}` + centered italic serif text. (Two identical stops = a flat tint overlay.)
Row 2 (legal): `border …styles.top` hairline, one centered 10px text with copyright + policy links.

## R14 — Theme Builder template (the ONLY safe shape)
`divi-create-theme-builder-template` with **areas ["header","body","footer"], default:true** — header+footer-only templates DO NOT fall back to page content on 5.10 (body renders empty). Body layout = zero-padding section › full-width row › column › `post-content` (self-closing, no attrs). Rebuild without losing layouts: save each layout's **section subtree (address "0", never the whole post** — the `divi/placeholder` root is un-reinsertable) to the Library, recreate, re-apply.

## R15 — Timed popup (Library global)
Scratch page → section › row › column › group: `{"module.decoration.background.desktop.value": {"color":"{{SURFACE_DARK}}"}, "module.decoration.border.desktop.value": {"styles":{"all":{"width":"1px","style":"solid","color":"rgba({{ACCENT_RGB}},0.28)"}}}, "module.decoration.sizing.desktop.value": {"maxWidth":"460px"}, "module.decoration.spacing.desktop.value": {"padding":{"top":"48px","bottom":"48px","left":"48px","right":"48px"}}}` → monogram, serif heading, copy, R2 button. Then `divi-set-interactions` on the group: `[{"trigger":"onLoad","effect":"toggleVisibility","settings":{"timeDelay":4000}}]` → `divi-create-library-item` global:true → delete scratch. Canvas/click-trigger binding stays a VB step.

---
## Responsive doctrine (multi-breakpoint sites)
Values cascade DOWNWARD from desktop; setting `tablet` covers tablet + phoneWide + phone unless overridden. **Rows never auto-stack on any band** — set `layout.tablet.value {"flexDirection":"column","rowGap":…}` on EVERY multi-column row, page AND Theme Builder header/footer. When stacking, neutralize desktop-only side effects at the same band: vertical hairlines (`border.tablet…left.width "0px"`), oversized paddings, and `disabledOn` for desktop-only decorations. Scale display type per band (e.g. h1 78/54/38).

## Cache purge trilogy (Divi 5 + LiteSpeed)
A LiteSpeed purge is NOT enough: Divi's static CSS files in `wp-content/et-cache` keep their URLs across regenerations, so browsers keep serving pre-fix styles. Full clear = `litespeed_purge_all` + `ET_Core_PageResource::remove_static_resources('all','all')` + delete `et-cache` `*.css` on disk — then the user hard-refreshes or checks incognito. Stale et-cache is the #1 "my fix didn't apply" false alarm; verify fixes in the LIVE fetched CSS, with tight greps, before concluding a write failed.

## Library items are snapshots
They freeze content at save time — applying an item saved before a bug-fix resurrects the bug. After ANY fix to a component that lives in the Library, re-save it as a new version and update the site's on-site skill ID list.

## Cloning workflow (fastest full site, WAF-proof)
Sections from a shipped build live in the Library. New same-genre site: R1 design system (~12 calls) → `divi-apply-library-item` per section (~5) → targeted `divi-edit-module` for text/images/anchors (~15-25) → R14 template + re-apply header/footer items (~8). **~30-45 calls total vs ~200 composing fresh.**
