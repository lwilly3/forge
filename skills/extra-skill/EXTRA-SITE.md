# EXTRA-SITE — la mécanique du thème (une, archives, design tokens)

> Ce qui distingue Extra d'un WordPress ordinaire. Vérifié sur site réel 2026-08-13.

## §1 Le category builder : la une n'est PAS une page

Extra rend la page d'accueil et les archives de catégories via des **posts du
CPT `layout`**, construits au builder et liés par la **taxonomie `category`** :

- `wp option get show_on_front` → `layout` (mécanisme Extra actif).
- Un layout rattaché au terme d'une catégorie (« infos », « emissions »…)
  s'affiche sur l'archive de cette catégorie.
- Le layout de la une est celui marqué comme home (sur le site étudié : layout
  « main layout », rattaché à une catégorie marqueur « accueil »).

Conséquences pour une refonte :
- Refondre la une = éditer un **layout**, pas une page. Les lister :
  `wp post list --post_type=layout --fields=ID,post_title,post_status`.
- Les modules typiques d'un layout sont les modules Posts d'Extra
  (voir EXTRA-MODULES.md) : la une est une composition de flux d'articles.
- Dupliquer un layout en brouillon fonctionne comme pour une page (mêmes metas
  + `_extra_sidebar*`).

## §2 Les design tokens : l'option `et_extra`

L'identité visuelle globale vit dans UNE option sérialisée :
`wp option get et_extra --format=json` (~320 clés sur le site étudié). Clés
importantes :

| Clé | Rôle |
|---|---|
| `accent_color` | couleur d'accent globale du site |
| `extra_logo` | URL du logo |
| `content_width`, `sidebar_width`, `gutter_width` | largeurs de base (px / %) |
| `*_nav_*_color`, `fixed_primary_nav_*` | couleurs des navigations (nombreuses) |
| `boxed_layout`, `boxed_layout_background_color` | mode encadré |
| polices : clés `*font*` | typographie globale |

- **Lire ces tokens AVANT de concevoir** : une refonte cohérente réutilise
  l'accent, les largeurs et les polices du site (ou les fait évoluer
  explicitement, jamais par accident).
- Modifier `et_extra` = changement GLOBAL du site → uniquement sur staging,
  avec sauvegarde de l'option avant (`wp option get et_extra > backup.json`).
- Presets globaux du builder : option `et_extra_builder_global_presets_ng`.
- Couleurs auto par catégorie : `has_auto_assign_category_color` — chaque
  catégorie peut avoir sa couleur (utilisée par les modules Posts).

## §3 Sidebars et gabarits

- Pages : gabarit par meta `_et_pb_page_layout` (full width / right sidebar / no sidebar).
- Layouts : `_extra_sidebar` (`on/off`) + `_extra_sidebar_location` (`left/right`).
- Les sidebars sont des zones de widgets classiques (`wp widget list <sidebar>`).

## §4 Où vit le code du thème (pour approfondir)

| Chemin (dans le thème Extra) | Contenu |
|---|---|
| `includes/builder/` | le Divi Builder embarqué (modules standard, shortcode manager) |
| `module-posts.php`, `includes/modules.php` | les modules Posts propres à Extra |
| `includes/modules-defaults.php` | valeurs par défaut des modules Extra |
| `framework/` | category builder, options, intégrations |
| `home.php`, `index-content.php` | rendu de la une (layouts) |

## §5 Inventaire du site pilote (staging Radio Audace, 2026-08-13)

Corpus de référence pour apprendre par imitation :

- **Layouts** : 1505 « main layout » (une : hero + 2 carousels + masonry),
  1157 « infos », 1131 « emissions », 1186/1188 (items), 25/26 (anciens).
- **Pages builder** : 1786 VMPlayer, 1300 invites, 1203 A propos, 673 contacts.
- Tokens : accent `#0f3ebf`, content_width 1920, sidebar 33 %, gutter 4.
- `_builder_version` observée : 4.14.1 (à reprendre pour les nouveaux contenus).
