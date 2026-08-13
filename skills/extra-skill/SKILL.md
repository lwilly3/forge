---
name: extra-skill
description: Concevoir et refondre le design de sites WordPress sous le thème Extra (Elegant Themes) — builder Divi LEGACY en shortcodes et_pb_*, category builder (CPT layout), options et_extra, modules Posts propres à Extra. Déclencheurs — refonte/design d'une page ou de la une d'un site Extra, reproduire une maquette sur Extra, modifier un layout de catégorie, lire/écrire des shortcodes et_pb. NE PAS utiliser pour un site sous thème Divi 5 (blocs wp:divi/*) — c'est divi5-skill.
---

# Extra Skill — refonte de design sur le thème Extra

Connaissances extraites du code réel d'Extra 4.27.5 et d'un site en production
(2026-08-13). Fichiers de référence — ne lire que le nécessaire :

| Fichier | Quand le lire |
|---|---|
| `EXTRA-BUILDER.md` | **Toujours** — format shortcode legacy, structure, metas de page, règles d'écriture |
| `EXTRA-SITE.md` | Mécanique du thème : category builder (une + archives), options et_extra (design tokens), sidebars |
| `EXTRA-MODULES.md` | Inventaire des modules (9 propres à Extra + Divi standard) et méthode d'apprentissage par imitation |

## Règles CRITIQUES (résumé)

1. **Jamais d'écriture sur une page/layout publié** : dupliquer en brouillon,
   travailler dessus, faire valider, puis appliquer délibérément.
2. **Imiter, ne pas inventer** : les attributs des modules legacy sont mal
   documentés — TOUJOURS lire une page existante du site (`wp post get <id>
   --field=post_content`) et copier ses patterns d'attributs, plutôt que de
   deviner des noms d'attributs.
3. La une et les archives de catégories ne sont PAS des pages : ce sont des
   posts du CPT `layout` liés par la taxonomie `category` (voir EXTRA-SITE.md).
4. Après toute écriture en base : **purger `wp-content/et-cache` + transients**,
   sinon l'ancien design ressort (CSS compressé en cache).
5. Vérifier visuellement (captures desktop + mobile du preview) avant de
   présenter un résultat — le rendu Extra dépend de réglages globaux invisibles
   dans le shortcode.
6. Ce skill décrit le format LEGACY (`[et_pb_*]`, `bb_built="1"`). Si le site
   affiche des blocs `wp:divi/*`, c'est Divi 5 → utiliser divi5-skill.
