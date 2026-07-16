---
name: ui-design
description: "OBLIGATOIRE pour: pages, dashboards, formulaires, états, responsive d'une plateforme opérationnelle. Déclencheurs: design, UI, layout, formulaire, responsive. NE PAS utiliser pour: routes/permissions (frontend-modulaire)."
---

# UI d'une plateforme opérationnelle — grammaire générique

## Sensation produit

Surface de TRAVAIL, pas une landing : calme, dense, hiérarchie claire.
Identité par petites touches de couleur (icônes, accents) — jamais d'aplats
pleine page ni de dégradés décoratifs.

## Règles de layout

- En-têtes ANTI-DÉBORDEMENT mobile : jamais de `flex justify-between` rigide —
  `flex-wrap` + `gap`, textes variables en `min-w-0 truncate`, icônes
  `shrink-0` (défaut récurrent constaté sur ~20 pages).
- Grilles prévisibles (1 → 2 → 3/4 colonnes par breakpoint).
- Cartes sobres (bordure légère, ombre discrète) ; pas de cartes imbriquées.
- Couleurs : palette standard du framework, accent par module en style inline
  depuis la config du module — pas de thème custom.

## États à couvrir pour CHAQUE écran avec données

Normal, chargement (spinner compact couleur module), vide (actionnable),
erreur (bandeau rouge sobre relayant le détail backend), restreint par
permission, mobile ET desktop.

## Formulaires

Champs groupés, labels clairs, erreurs près du champ, secrets write-only
(placeholder « laisser vide pour conserver »), feedback de succès visible À
CÔTÉ de l'action qui l'a déclenché (pas seulement en haut de page — leçon).

## QA finale

Pas de texte coupé/superposé ; loading/empty/error présents partout où il y a
du fetch ; le résultat ressemble au reste de l'application.
