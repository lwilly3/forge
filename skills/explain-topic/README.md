# explain-topic — apprendre un sujet du codebase (doc junior)

> Skill **vivant** : la source de vérité est ce dossier, symlinkée vers
> `~/.claude/skills/explain-topic`. Adapté le 2026-08-05 du repo public
> [lwilly3/Ai-code-explain-diff-and-topic](https://github.com/lwilly3/Ai-code-explain-diff-and-topic).

## Le besoin d'existence

`grep` et l'arborescence de fichiers montrent des noms, pas de la compréhension.
Revenir dans un sous-système pas ouvert depuis des mois (le refresh de token,
l'eventBus, la GED…), ou préparer un chantier sur un mécanisme existant, oblige
à reconstruire son modèle mental à la main, fichier par fichier.

Ce skill produit une **leçon sur un sujet existant** du code — sans lien avec un
diff (ça, c'est `explain-diff`).

## Ce qu'il produit

Un message de chat en français, toujours dans le même ordre :

1. **Intro au sujet** — ce que c'est, où ça vit (niveau packages, pas fichiers),
   quel problème ça résout, ses contrats avec l'extérieur, un piège éventuel,
   puis le glossaire « Notions à connaître ».
2. **Intuition** — l'objectif + un scénario concret tracé dans le comportement,
   sans aucun code, terminé par « Si tu ne retiens qu'une chose : … ».
3. **Figures** — un sujet mérite plus de diagrammes qu'un diff (2-4) :
   architecture (`flowchart`), séquence, cycle d'états, tableaux.
4. **Lecture du code** — les fichiers dans l'ordre de compréhension
   (modèle de données → backend → frontend, jamais l'inverse), un paragraphe
   de prose avant chaque extrait.

En option : sauvegarde dans `docs/topics/` du projet (sans commit).

## Comment l'utiliser

En langage naturel, le skill se déclenche seul :

- « explique comment fonctionne le refresh silencieux de token »
- « apprends-moi le pipeline de permissions »
- « walk me through le module Juridique »
- « aide-moi à comprendre l'eventBus entre modules »

Ou explicitement : `/explain-topic <sujet>`.

Garde-fou intégré : si le sujet est trop large (plus de ~15 fichiers porteurs),
le skill demande de resserrer le périmètre AVANT d'écrire, au lieu de produire
40 pages illisibles.

## Ce qu'il ne fait PAS

- **Pas une revue de code** → `/code-review`.
- **Pas lié à un diff** → `/explain-diff`.
- **Pas de la doc utilisateur final** → Centre d'aide du projet.
- **Jamais de données réelles** dans les exemples : valeurs fictives obligatoires.

## Cas d'usage typiques (vécus)

- Se remettre dans un sous-système avant de le modifier (auth, GED, outbox…).
- Préparer un cadrage : comprendre l'existant avant l'atelier d'un nouveau
  module (Hydrocarbures s'appuyant sur l'outbox, par exemple).
- Onboarding : générer la leçon une fois, la sauvegarder dans `docs/topics/`
  et la donner à lire.
