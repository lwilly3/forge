# extra-skill — pourquoi ce skill existe

> Skill vivant de la forge (symlinké). Né le 2026-08-13.

## Le besoin

Le projet « agents ↔ WordPress » vise la **refonte du design** des sites Audace,
qui tournent sous le thème **Extra** avec le builder Divi *legacy* (shortcodes
`[et_pb_*]`). Le skill `divi5-skill` (tiers) couvre le format moderne Divi 5
(blocs `wp:divi/*`) — mais il est inutilisable sur Extra. Il fallait l'équivalent
pour le monde legacy : c'est ce skill.

## Sa particularité : extrait du réel

Contrairement à une doc générique, ce skill a été construit en analysant le
code d'Extra 4.27.5 ET un site en production (staging Radio Audace) :
inventaire réel des modules (dont les 9 propres à Extra), mécanisme vérifié de
la une (CPT `layout` + taxonomie category, `show_on_front=layout`), les 320
design tokens de l'option `et_extra`, et un corpus de pages/layouts de
référence pour apprendre par imitation.

Sa règle centrale : **imiter les patterns observés sur le site, ne jamais
inventer d'attributs** — le builder legacy est mal documenté, le site est
l'oracle.

## Fichiers

- `SKILL.md` — routeur + règles critiques (chargé par l'agent au déclenchement)
- `EXTRA-BUILDER.md` — le format shortcode, les metas de page, le workflow d'écriture sûre
- `EXTRA-SITE.md` — category builder, design tokens, sidebars, corpus du site pilote
- `EXTRA-MODULES.md` — inventaire des modules + méthode d'apprentissage + correspondances maquette→module

## Mise à jour

À chaque découverte sur un site Extra (nouvel attribut compris, nouveau piège,
nouveau module utilisé) : compléter le fichier concerné et committer. Quand un
site migrera vers Divi 5, ce skill restera pour les sites encore sur Extra.
