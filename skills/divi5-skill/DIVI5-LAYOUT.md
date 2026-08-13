---
name: divi5-layout
description: Section, row, column, group and group-carousel structure — flexbox system, responsive stacking, nesting rules and parent-child reference for Divi 5 JSON generation.
author: Shashank Gupta @ divilove.com
---

# DIVI5 Skill — Layout Modules (Section, Row, Column, Group)
> **Part of the DIVI5 skill set. Attach when building page structure.**
> Skill files: BASE · LAYOUT (this) · STYLING · MODULES-CONTENT · MODULES-INTERACTIVE · MODULES-MEDIA · MODULES-DATA · MODULES-DYNAMIC · MODULES-WOOCOMMERCE · WORDPRESS · PATTERNS

---

## 1. `divi/section`

Top-level container. Every page needs at least one.

**Self-closing?** No.

**Section types** — `module.advanced.type.desktop.value`:
| Value | Description |
|-------|-------------|
| `"regular"` | Default section with rows/columns inside |
| `"fullwidth"` | Fullwidth section — contains fullwidth modules (e.g. `divi/fullwidth-header`) directly, no row/column wrapper needed |
| `"specialty"` | Specialty section with custom column layout |

```json
{
  "module": {
    "meta": {
      "adminLabel": {"desktop": {"value": "Hero Section"}}
    },
    "decoration": {
      "background": {
        "desktop": {"value": {"color": "#0f172a"}}
      },
      "spacing": {
        "desktop": {"value": {"padding": {"top": "80px", "bottom": "80px"}}}
      }
    }
  },
  "builderVersion": "5.10.0"
}
```

---

## 2. `divi/row`

Horizontal container inside a section. Defines column arrangement via the flex system.

**Self-closing?** No.

```json
{
  "module": {
    "advanced": {
      "flexColumnStructure": {
        "desktop": {"value": "equal-columns_3"}
      }
    },
    "decoration": {
      "layout": {
        "desktop": {"value": {"flexWrap": "nowrap"}},
        "phone": {"value": {"flexWrap": "wrap"}},
        "phoneWide": {"value": {"flexWrap": "wrap"}}
      },
      "sizing": {
        "desktop": {"value": {"maxWidth": "1280px"}}
      }
    }
  },
  "builderVersion": "5.10.0"
}
```

### `flexColumnStructure` Values

| Value | Columns |
|-------|---------|
| `"equal-columns_1"` | 1 column (full width) |
| `"equal-columns_2"` | 2 equal columns |
| `"equal-columns_3"` | 3 equal columns |
| `"equal-columns_4"` | 4 equal columns |

### How Row Flex Actually Works

**Divi applies `display: flex` automatically to rows** when `flexColumnStructure` is set. You do NOT set `display: flex` yourself. The `module.decoration.layout` on a row controls `flexWrap` and other flex properties — not `display`.

❌ Setting `display: flex` — ignored:
```json
"layout": {"desktop": {"value": {"display": "flex"}}}
```
✅ Correct: `flexColumnStructure` + `flexWrap`:
```json
"advanced": {"flexColumnStructure": {"desktop": {"value": "equal-columns_3"}}},
"decoration": {"layout": {"desktop": {"value": {"flexWrap": "nowrap"}}}}
```

### Hero Row (column-reverse on mobile)

```json
{
  "module": {
    "advanced": {
      "flexColumnStructure": {"desktop": {"value": "equal-columns_2"}}
    },
    "decoration": {
      "layout": {
        "desktop":   {"value": {"flexWrap": "nowrap", "alignItems": "center", "columnGap": "60px"}},
        "phone":     {"value": {"flexWrap": "wrap", "flexDirection": "column-reverse"}},
        "phoneWide": {"value": {"flexWrap": "wrap"}}
      },
      "sizing": {"desktop": {"value": {"maxWidth": "1280px"}}}
    }
  },
  "builderVersion": "5.10.0"
}
```

---

## 3. `divi/column`

A column inside a row. Contains content modules.

**Self-closing?** No.

```json
{
  "module": {
    "decoration": {
      "sizing": {
        "desktop":   {"value": {"flexType": "8_24"}},
        "phone":     {"value": {"flexType": "24_24"}},
        "phoneWide": {"value": {"flexType": "24_24"}}
      }
    }
  },
  "builderVersion": "5.10.0"
}
```

### `flexType` Cheat Sheet (column width as fraction of 24)

| flexType | Width | Use case |
|----------|-------|----------|
| `"24_24"` | 100% | Full width / single column |
| `"16_24"` | 66.7% | Two-thirds |
| `"12_24"` | 50% | Half |
| `"8_24"` | 33.3% | One-third |
| `"6_24"` | 25% | One-quarter |
| `"18_24"` | 75% | Three-quarters |
| `"4_24"` | 16.7% | Narrow sidebar |

### Column Width Alignment Rule

The sum of all column `flexType` values in a row should equal 24.

| Layout | Column flexTypes |
|--------|-----------------|
| 1 column | `24_24` |
| 2 equal | `12_24` + `12_24` |
| 3 equal | `8_24` × 3 |
| 4 equal | `6_24` × 4 |
| 2/3 + 1/3 | `16_24` + `8_24` |
| 3/4 + 1/4 | `18_24` + `6_24` |

### Centering content in a column (esp. block modules)

A column is a flex container (column direction). To horizontally center its children —
**including block modules like `divi/image` and `divi/button`** — set
`column.module.decoration.layout.desktop.value.alignItems = "center"`. `text-align:center`
only centers text inside text/heading modules; it does **not** move a block module, and
`module.advanced.alignment` does not emit a centering rule for `divi/image`. So: center text
with `textAlign`, but center an image/button by centering its **parent column** with
`alignItems:center`. (Render-confirmed 5.8.0.)

### Building site chrome — header/footer nav

When you build a header/footer as a Theme Builder layout, **`divi/menu` collapses to a
hamburger when it sits inside a column** (i.e. not a true full-width context), which looks
broken on desktop. For a small fixed nav, build the links as individual `divi/link` modules
(or styled inline `<a>` in a `divi/text` module) inside a column whose layout is a horizontal
flex row (`layout.desktop.value = {display:"flex", flexDirection:"row", columnGap:..., flexWrap:"wrap"}`).
They sit inline on desktop and wrap on mobile. Use `divi/menu` only where the nav is genuinely
full-width / you want the built-in responsive hamburger.

---

## 4. `divi/group`

A generic `div` wrapper for grouping modules inside a column. **Real-render confirmed.**

**Self-closing?** No.

All standard `module.decoration` properties work: `background`, `border` (including `radius`), `spacing.padding`, `layout` (flexDirection, alignItems, justifyContent).

**Styled card example (confirmed working):**
```json
{
  "module": {
    "decoration": {
      "background": {"desktop": {"value": {"color": "#FFFFFF"}}},
      "border": {"desktop": {"value": {
        "radius": {
          "topLeft": "12px", "topRight": "12px",
          "bottomLeft": "12px", "bottomRight": "12px", "sync": "on"
        },
        "styles": {"all": {"width": "1px", "color": "#e2e8f0", "style": "solid"}}
      }}},
      "spacing": {"desktop": {"value": {"padding": {
        "top": "32px", "bottom": "32px", "left": "32px", "right": "32px"
      }}}},
      "layout": {
        "desktop": {"value": {"flexDirection": "column", "alignItems": "flex-start"}}
      }
    }
  },
  "builderVersion": "5.10.0"
}
```

**Nested row inside group (confirmed):**
A `divi/row` can be placed directly inside a `divi/group`. This extends the hierarchy to:
`section → row → column → group → row → column → module`
The inner row behaves identically to a top-level row — `flexColumnStructure`, `flexWrap`, and responsive column widths all work.

---

## 5. `divi/group-carousel`

Carousel of `divi/group` slides. Each child `group` is one slide. **Real-render confirmed.**

**Self-closing?** No (contains `divi/group` children).

**Confirmed behavior:**
- Renders one slide at a time with navigation dots auto-generated
- Minimal attrs required — just `builderVersion`
- Each `group` child becomes a swipeable/clickable slide
- `group` children support full decoration (background, border, padding) per-slide

```json
{
  "builderVersion": "5.10.0"
}
```

```
group-carousel {"builderVersion": "5.10.0"}
  └── group (slide 1) — styled with decoration props
        └── modules...
  └── group (slide 2)
        └── modules...
  └── group (slide 3)
        └── modules...
```

**Full attrs reference (all confirmed working):**

```json
{
  "module": {
    "advanced": {
      "slidesToShow":    {"desktop": {"value": "3"}, "tablet": {"value": "2"}, "phone": {"value": "1"}},
      "slidesToScroll":  {"desktop": {"value": "1"}},
      "auto":            {"desktop": {"value": "on"}},
      "speed":           {"desktop": {"value": "3000ms"}},
      "transitionSpeed": {"desktop": {"value": "500ms"}},
      "pauseOnHover":    {"desktop": {"value": "on"}},
      "centerMode":      {"desktop": {"value": "on"}}
    }
  },
  "arrows": {
    "advanced": {
      "showArrows": {"desktop": {"value": "on"}},
      "position":   {"desktop": {"value": "outside"}}
    }
  },
  "dotNav": {
    "advanced": {
      "showDots": {"desktop": {"value": "on"}}
    }
  },
  "builderVersion": "5.10.0"
}
```

| Attr | Path | Default | Values |
|------|------|---------|--------|
| Slides visible | `module.advanced.slidesToShow.desktop.value` | `"1"` | `"1"`–`"6"` |
| Slides per advance | `module.advanced.slidesToScroll.desktop.value` | `"1"` | any int string |
| Autoplay | `module.advanced.auto.desktop.value` | `"off"` | `"on"` / `"off"` |
| Autoplay interval | `module.advanced.speed.desktop.value` | `"2000ms"` | e.g. `"3000ms"` |
| Transition speed | `module.advanced.transitionSpeed.desktop.value` | — | e.g. `"500ms"` |
| Pause on hover | `module.advanced.pauseOnHover.desktop.value` | `"on"` | `"on"` / `"off"` |
| Center mode | `module.advanced.centerMode.desktop.value` | `"off"` | `"on"` / `"off"` |
| Show arrows | `arrows.advanced.showArrows.desktop.value` | `"on"` | `"on"` / `"off"` |
| Arrow position | `arrows.advanced.position.desktop.value` | `"inside"` | `"inside"` / `"outside"` / `"center"` |
| Show dots | `dotNav.advanced.showDots.desktop.value` | `"on"` | `"on"` / `"off"` |

`slidesToShow` supports responsive values (set desktop/tablet/phone independently).

---

## 5a-bis. The Flex Model — READ THIS BEFORE PLACING ANYTHING SIDE-BY-SIDE (⚙ source-verified 5.10, field-confirmed)

Divi 5's layout baseline (from `LayoutStyle.php::normalize_attr`) is **`display: flex` on every container** — section, row, column, group. There is no "block mode" toggle you're missing; what changes is the **flex direction**, and that's where builds go wrong:

- **Rows** flow `flexDirection: row` → columns sit side-by-side.
- **Columns and groups** flow `flexDirection: column` → **children ALWAYS stack vertically** unless you change it.

**The classic failure:** putting a logo + wordmark, or an icon + text, or nav links as separate modules inside a column and expecting them inline. They will stack. To place children side-by-side inside a column or group, set the container's layout explicitly:

```json
"module.decoration.layout.desktop.value": {
  "display": "flex", "flexDirection": "row",
  "alignItems": "center", "columnGap": "16px", "flexWrap": "wrap"
}
```

Key rules (all from source):
- **`display` is NOT responsive** — one value for all breakpoints (`normalize_attr` reads it from `desktop.value` only). **`flexDirection`, `alignItems`, `justifyContent`, gaps, and `flexWrap` ARE responsive.** So the correct mobile-stacking pattern is: `display:"flex"` once, `flexDirection:"row"` on desktop, `flexDirection:"column"` on phone — never try to switch display per breakpoint.
- **Vertical centering** (hero content, split bars): `alignItems` on the flex parent (`center`), plus `minHeight` on the section.
- **Right-aligning a lone child** (header button): `justifyContent:"flex-end"` on its column.
- **Custom fraction columns can wrap.** `1_4 + 1_2 + 1_4` = 100% *before* the row's column gap — with a default gap the total exceeds 100% and the last column wraps below. When using explicit fractions, set the row's `columnGap` yourself (or size fractions to leave room). Even auto-distributed columns don't have this problem.
- **Flex vs Grid, when to use which:** GRID for uniform repeating cells (card grids, galleries, footer link columns of equal width) — you get `gridColumnCount` per breakpoint and offset rules. FLEX for one-dimensional composition — nav bars, logo lockups, icon+text pairs, split header/footer bars, vertical centering. If you're tempted to eyeball widths so things line up in a row, it's flex with gaps; if it's a matrix, it's grid.
- **Fill-height editorial images in flex columns: use the container's BACKGROUND, not an image module.** An image module with `height` + `objectFit:"cover"` fills reliably inside **grid cells** (card grids ✓ field-confirmed) but under-fills inside plain **flex columns** (renders at intrinsic-ish size). For a split-section image half, set the column's `background.image` (`size:"cover"`) + `minHeight` — bulletproof, responsive, and overlay-friendly. Reserve image modules for content images inside grid cells or naturally-flowing content. This applies to ANY fixed-size editorial image in a flex column — split halves, center-column feature images, quote cards — not just full-height ones.
- **Hero vertical centering**: section = flex column already, so `justifyContent:"center"` + `minHeight` on the section centers the content block vertically. (`alignItems` would center horizontally here — main axis is vertical.)
- **Overlay chips/cards: flow-over-background, never the position group** — the position group doesn't emit CSS from programmatic writes (see STYLING). Give the container the photo as `background.image` and place the chip as a normal in-flow child; `alignItems:flex-start` shrinks it to content.
- **The Visual Builder stores `display:"block"` on columns it touches** — which overrides any `flexDirection` and stacks the children. When programmatically reusing or restoring a VB-edited layout, re-set `display:"flex"` on every column that needs a row lockup (logo + wordmark, icon + text). Field-confirmed on a VB-edited header.
- **Rows never auto-stack on any breakpoint.** Set `layout.<band>.value {"flexDirection":"column","rowGap":…}` explicitly; setting it at `tablet` cascades down through phoneWide and phone. Do this on every multi-column row including Theme Builder header/footer rows, and neutralize stacked-band side effects (vertical hairlines → width 0, heavy paddings, `disabledOn` for desktop-only ornaments).
- **Uneven-height siblings stretch each other** (`align-items: stretch` default on rows): a card set next to a taller sidebar inherits its height and distributes the surplus internally as mystery gaps. `alignItems:"flex-start"` on the row.
- The Visual Builder's layout panel exposes exactly these values — a build that sets them explicitly matches what a human would click, and stays editable.

## 5b. Grid Layout (NEW in 5.x — ⚙ source-verified)

Any flex container (`section`, `row`, `column`, `group`) — and grid-based modules like `blog`/`portfolio`/`instagram-feed` — can switch from flex to **CSS Grid** via `module.decoration.layout`. This is set on the **container**; children are placed automatically (or per-item via `sizing` grid keys).

```json
"module": {
  "decoration": {
    "layout": {
      "desktop": {"value": {
        "display": "grid",
        "gridColumnWidths": "equal",
        "gridColumnCount": "3",
        "rowGap": "16px",
        "columnGap": "16px"
      }}
    }
  }
}
```

### Grid container keys (`layout.*.value`)

| Key | Purpose | Example |
|-----|---------|---------|
| `display` | `"flex"` (default) or `"grid"` | `"grid"` |
| `gridColumnWidths` | `"equal"` (uniform) or `"custom"` | `"equal"` |
| `gridColumnCount` | number of columns (string) | `"3"` |
| `gridColumnMinWidth` | min track width for auto-fit | `"200px"` |
| `gridRowCount` / `gridRowHeights` / `gridRowMinHeight` | row sizing | `"2"` |
| `gridTemplateColumns` / `gridTemplateRows` | full CSS track lists (accepts multiple `fr`/fixed tracks) | `"2fr 1fr 1fr"` |
| `gridAutoColumns` / `gridAutoRows` | implicit track sizes (full CSS values) | `"minmax(100px, 1fr)"` |
| `gridAutoFlow` | `"row"` / `"column"` / `"dense"` | `"row dense"` |
| `gridDensity` | packing density helper | `"dense"` |
| `gridJustifyItems` | inline alignment of items | `"stretch"` |
| `rowGap` / `columnGap` | gaps between tracks | `"16px"` |

### Per-item grid placement (`module.decoration.sizing.*.value`)

Set on a **child** (column/group/module) to span or position it within the parent grid:

| Key | Purpose |
|-----|---------|
| `gridColumnSpan` / `gridRowSpan` | span N tracks |
| `gridColumnStart` / `gridColumnEnd` | explicit column line placement |
| `gridRowStart` / `gridRowEnd` | explicit row line placement |
| `gridAlignSelf` / `gridJustifySelf` | per-item alignment |

### Grid Offset Rules (5.9 Grid Editor — ⚙ source-verified 5.10.0)

Since 5.9 the grid **container** can place children by position via `gridOffsetRules` inside the same `module.decoration.layout.*.value` — no need to touch each child's `sizing`. A single rule supports the full range of start, end, and span settings, and values accept **number variables**.

```json
"layout": {"desktop": {"value": {
  "display": "grid",
  "gridColumnCount": "4",
  "gridOffsetRules": {"rules": [
    {"targetOffset": "1", "offsetValues": {"columnSpan": "2", "rowSpan": "2"}},
    {"targetOffset": "last-child", "offsetValues": {"columnStart": "1", "columnEnd": "-1"}},
    {"targetOffset": "custom", "customTargetOffset": "2n+1", "offsetValues": {"rowSpan": "2"}}
  ]}
}}}
```

| Key | Values | Emitted CSS |
|-----|--------|-------------|
| `targetOffset` | `"first-child"`, `"last-child"`, a number string (`"1"`, `"2"`…), or `"custom"` | `> *:first-of-type` / `:last-of-type` / `:nth-of-type(N)` on the container's children |
| `customTargetOffset` | any nth pattern, e.g. `"2n+1"` (only with `targetOffset:"custom"`) | `> *:nth-of-type(2n+1)` |
| `offsetValues.columnStart` / `columnEnd` | grid line numbers (negative OK: `"-1"`) | `grid-column-start` / `grid-column-end` |
| `offsetValues.columnSpan` / `rowSpan` | track count | `grid-column-end: span N` / `grid-row-end: span N` |
| `offsetValues.rowStart` / `rowEnd` | grid line numbers | `grid-row-start` / `grid-row-end` |
| `offsetValues.gridTemplateColumns` | full track list | `grid-template-columns` on that child |

- Only processed when `display:"grid"` on the same value object — silently ignored otherwise.
- ⚠️ **`columnSpan` and `columnEnd` both write `grid-column-end`** (same for `rowSpan`/`rowEnd`) — set one per rule, not both, or the later declaration wins unpredictably.
- Empty/`null` offset values are skipped; a rule with no `targetOffset` or no valid values emits nothing.
- Per-child `sizing` keys (below→above) still work and are simpler for one-off placement; offset rules shine for repeating patterns (`2n+1` masonry accents) and preset-driven grids.

> **Note:** Column "Apply Structure Template" now offers Flex *and* Grid templates depending on the column's `display` mode. Grid is ideal for masonry-style galleries, magazine layouts, and feature mosaics where flex wrapping is awkward.

> **⚠️ Grid does NOT auto-stack on mobile.** Unlike flex rows (which wrap via `flexWrap`), a grid keeps its `gridColumnCount` on every breakpoint — a 3-column grid stays 3 columns on phones (just narrower). **Always set responsive `gridColumnCount`. This is render-confirmed (page 76): desktop 3 → tablet 2 → phone 1 stacks correctly.**
> ```json
> "layout": {
>   "desktop": {"value": {"display": "grid", "gridColumnWidths": "equal", "gridColumnCount": "3", "rowGap": "16px", "columnGap": "16px"}},
>   "tablet":  {"value": {"gridColumnCount": "2"}},
>   "phone":   {"value": {"gridColumnCount": "1"}}
> }
> ```
> Only `display`/`gridColumnWidths`/gaps need to be on `desktop`; lower breakpoints just override `gridColumnCount`. `phoneWide` is optional (omitting it inherits from `tablet`'s wider value until `phone`).

**Render-confirmed (scenario 20 + page 76):** `display:"grid"` + responsive `gridColumnCount` + `rowGap`/`columnGap` on a `group` produced a clean equal-column grid that stacks 3→2→1 across breakpoints; per-item `aspectRatio` + image `fit` gave uniform cropped tiles.

---

## 5c. `divi/global-layout` (✓ render-confirmed — scenario 33)

References a **saved global layout/module** so one edit updates every place it is used. The reference is the **`globalModule`** attribute holding the saved layout's WP post ID **as a string**:

```html
<!-- wp:divi/global-layout {"globalModule":"123","builderVersion":"5.10.0"} -->
<!-- /wp:divi/global-layout -->
```

- ⚠️ The attribute is **`globalModule`** (string id), **not** `ref`. The front-end parser matches `"globalModule":"<id>"` (`BlockParser.php:889`) and inlines that post's content where the block sits.
- The referenced post is a **Divi Library item** (`et_pb_layout`, scope `global`); its `post_content` is ordinary Divi block markup (typically a full `section`). Place the `global-layout` block where that content belongs — for a global *section*, at the **top level** under the placeholder (sibling of other sections). Confirmed: one library item referenced twice on a page rendered both instances.
- Requires the referenced layout to already exist on the **target** site (same post ID). Portability across sites is not guaranteed — the ID must resolve.
- For self-contained, portable pages prefer inlining the modules instead of `global-layout`.

---

## 6. Parent–Child Reference

Valid children for each container module:

| Parent | Valid Children |
|--------|----------------|
| `section` | `row`, `global-layout` |
| `fullwidth section` | fullwidth modules only (`fullwidth-header`) — no row/column wrapper |
| `row` | `column` only |
| `column` | `group`, `group-carousel`, any content/interactive/media/data module, nested `row` |
| `group` | any content module, nested `row` |
| `group-carousel` | `group` only |
| `accordion` | `accordion-item` |
| `tabs` | `tab` |
| `counters` | `counter` |
| `contact-form` | `contact-field` |
| `pricing-tables` | `pricing-table` |
| `slider` | `slide` |
| `video-slider` | `video-slider-item` |
| `social-media-follow` | `social-media-follow-network` |
| `icon-list` | `icon-list-item` |
| `timeline` | `timeline-item` |
| `map` / `fullwidth-map` | `map-pin` |

---

## 7. Admin Labels & Custom CSS

```json
"module": {
  "meta": {
    "adminLabel": {"desktop": {"value": "Hero Section"}}
  },
  "advanced": {
    "htmlAttributes": {
      "class": {"desktop": {"value": "my-custom-class"}},
      "id":    {"desktop": {"value": "hero-section"}}
    }
  }
}
```

---

## 7. Python Helpers for Layout

```python
import json
BV = "5.6.2"

def section(attrs, children):
    a = json.dumps(attrs, ensure_ascii=False, separators=(',', ':'))
    return f'<!-- wp:divi/section {a} -->\r\n{children}<!-- /wp:divi/section -->\r\n'

def row(attrs, children):
    a = json.dumps(attrs, ensure_ascii=False, separators=(',', ':'))
    return f'<!-- wp:divi/row {a} -->\r\n{children}<!-- /wp:divi/row -->\r\n'

def column(attrs, children):
    a = json.dumps(attrs, ensure_ascii=False, separators=(',', ':'))
    return f'<!-- wp:divi/column {a} -->\r\n{children}<!-- /wp:divi/column -->\r\n'

def make_equal_row(col_count, children_list, max_width="1280px"):
    """Build a flex row with equal-width columns."""
    flex_map = {1: "24_24", 2: "12_24", 3: "8_24", 4: "6_24"}
    flex = flex_map[col_count]
    row_attrs = {
        "module": {
            "advanced": {"flexColumnStructure": {"desktop": {"value": f"equal-columns_{col_count}"}}},
            "decoration": {
                "layout": {
                    "desktop":   {"value": {"flexWrap": "nowrap"}},
                    "phone":     {"value": {"flexWrap": "wrap"}},
                    "phoneWide": {"value": {"flexWrap": "wrap"}}
                },
                "sizing": {"desktop": {"value": {"maxWidth": max_width}}}
            }
        },
        "builderVersion": BV
    }
    cols = ""
    for child in children_list:
        col_attrs = {
            "module": {"decoration": {"sizing": {
                "desktop":   {"value": {"flexType": flex}},
                "phone":     {"value": {"flexType": "24_24"}},
                "phoneWide": {"value": {"flexType": "24_24"}}
            }}},
            "builderVersion": BV
        }
        cols += column(col_attrs, child)
    return row(row_attrs, cols)
```

---

*DIVI5 Layout Skill — V0.8.2 | Builder Version 5.10.0 | Created by Shashank Gupta @ divilove.com*
