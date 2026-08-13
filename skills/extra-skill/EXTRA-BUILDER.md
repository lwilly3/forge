# EXTRA-BUILDER — le format legacy du Divi Builder embarqué

> Vérifié sur Extra 4.27.5 (builder Divi 4.x embarqué dans le thème).
> C'est un format **shortcodes WordPress**, PAS des blocs Gutenberg.

## §1 Structure d'une mise en page

Hiérarchie stricte : section → row → column → modules.

```
[et_pb_section bb_built="1" admin_label="section" ...]
  [et_pb_row _builder_version="4.14.1" ...]
    [et_pb_column type="4_4" _builder_version="4.14.1" ...]
      [et_pb_text _builder_version="4.14.1" ...]Contenu HTML ici[/et_pb_text]
      [et_pb_image src="https://..." _builder_version="..." /... ou fermé]
    [/et_pb_column]
  [/et_pb_row]
[/et_pb_section]
```

- `bb_built="1"` sur la PREMIÈRE section = contenu construit avec le builder
  legacy (« BB » = Backend Builder). Le conserver.
- `type` de colonne = fraction : `4_4` (pleine), `1_2`, `1_3`, `2_3`, `1_4`,
  `3_4`, `1_5`… La somme des colonnes d'une row doit faire 1.
- `admin_label` : étiquette lisible dans le builder — la renseigner en français
  clair (« Hero une », « Grille infos ») pour les humains qui éditeront après.
- `_builder_version` : reprendre la valeur vue sur les contenus existants du
  site (ex. 4.14.1), ne pas inventer.

## §2 Attributs — conventions transverses

- **Responsive** : suffixes `_tablet`, `_phone` + `_last_edited="on|desktop"`.
  Ex. `font_size="18px" font_size_tablet="16px" font_size_phone="14px"`.
- **Couleurs** : hex `#0f3ebf` ou `rgba(22,107,191,0.22)`.
- **Espacements** : `custom_padding="haut|droite|bas|gauche|lié_v|lié_h"`
  (valeurs avec unités, champs vides autorisés : `custom_padding="20px||20px|"`).
- **Fond** : `background_color`, `background_image="https://..."`,
  `background_enable_image="on"`, gradients `background_color_gradient_*`.
- **Global colors** : les couleurs globales apparaissent comme
  `global_colors_info` (JSON encodé) + meta `_global_colors_info` sur le post —
  copier le mécanisme d'une page existante si besoin.
- Booléens = `"on"` / `"off"`.

## §3 Metas de post OBLIGATOIRES à la création

Créer une page/un layout builder par l'API ou WP-CLI sans ces metas produit un
rendu cassé (sidebar parasite, largeur contrainte) :

| Meta | Valeur | Rôle |
|---|---|---|
| `_et_pb_use_builder` | `on` | active le rendu builder |
| `_et_pb_page_layout` | `et_full_width_page` \| `et_right_sidebar` \| `et_no_sidebar` | gabarit |
| `_et_pb_gutter_width` | ex. `3` | gouttières (copier l'existant) |
| `_et_pb_custom_css` | CSS libre | styles additionnels du post |

Sur les posts du CPT `layout`, s'ajoutent `_extra_sidebar` (`on/off`) et
`_extra_sidebar_location` (`right/left`).

## §4 Écrire en sécurité (le workflow)

1. Lire l'original : `wp post get <id> --field=post_content` + ses metas.
2. **Dupliquer en brouillon** (nouveau post `draft` avec content + metas copiés).
3. Modifier le brouillon (shortcodes) — garder `bb_built="1"`, admin_labels clairs.
4. Purger : `rm -rf wp-content/et-cache` + `wp transient delete --all`.
5. Vérifier le rendu via le preview du brouillon (captures desktop/mobile).
6. Validation humaine PUIS application à l'original (remplacement délibéré).

## §5 Pièges vérifiés

- **et-cache** : CSS statique compressé (fichiers + base). Sans purge, l'ancien
  design persiste après modification en base.
- Shortcodes mal imbriqués = page silencieusement cassée sous l'éditeur —
  valider l'équilibre `[et_pb_x]...[/et_pb_x]` avant d'écrire.
- Le HTML à l'intérieur de `et_pb_text` est du HTML normal (pas d'échappement
  unicode, contrairement à Divi 5).
- `et_pb_row_inner` / `et_pb_column_inner` apparaissent dans les layouts à
  colonnes spécialisées (sidebar) — les reprendre tels quels, ne pas convertir.
- Les catégories WordPress sont sensibles aux accents (« Actualités » ≠
  « Actualites ») — vérifier les noms exacts avant tout filtre de module Posts.
