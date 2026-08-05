# explain-diff — comprendre un changement de code (doc junior)

> Skill **vivant** : la source de vérité est ce dossier, symlinkée vers
> `~/.claude/skills/explain-diff`. Adapté le 2026-08-05 du repo public
> [lwilly3/Ai-code-explain-diff-and-topic](https://github.com/lwilly3/Ai-code-explain-diff-and-topic).

## Le besoin d'existence

`git diff` montre les changements dans l'ordre des fichiers, mélange l'essentiel
avec le bruit (lockfiles, formatage) et suppose que tu connais déjà le système
modifié. Résultat : relire une branche livrée il y a trois semaines, ou le travail
fait par un autre agent (Codex) sur l'autre machine, demande un effort énorme.

Ce skill transforme un diff en **leçon** : il t'amène d'abord au niveau de
connaissance nécessaire, puis te fait entrer dans le changement.

## Ce qu'il produit

Un message de chat en français, toujours dans le même ordre :

1. **Contexte** — le système AVANT le changement (sans jamais le mentionner),
   terminé par un glossaire « Notions à connaître » (3-5 termes, une phrase chacun).
2. **Intuition** — l'objectif + un exemple concret avant/après, sans aucun code,
   terminé par « Si tu ne retiens qu'une chose : … ».
3. **Figures** — diagrammes Mermaid ou tableaux, seulement s'ils apportent
   quelque chose que la prose ne peut pas dire.
4. **Lecture du code** — les fichiers dans l'ordre qui raconte l'histoire
   (Cœur → Conséquences → Auxiliaire replié), un paragraphe de prose avant
   chaque extrait.

En option : sauvegarde dans `docs/walkthroughs/` du projet (sans commit — le
protocole release du projet reste maître).

## Comment l'utiliser

En langage naturel, le skill se déclenche seul :

- « explique ce diff »
- « explique ce qui a changé sur cette branche »
- « qu'est-ce que change la PR #42 ? »
- « aide-moi à comprendre le travail de Codex avant que je rebase »

Ou explicitement : `/explain-diff`.

Sans précision, la cible est la branche courante comparée à la branche par
défaut du repo (souvent `develop` dans mes projets), travail non commité inclus.

## Ce qu'il ne fait PAS

- **Pas une revue de code** : aucun bug signalé, aucune sévérité, aucune
  suggestion de correction → utiliser `/code-review`.
- **Pas de la doc utilisateur final** → Centre d'aide du projet.
- **Jamais de données réelles** dans les exemples (comptes, sociétés, IPs,
  tokens) : valeurs fictives obligatoires.

## Cas d'usage typiques (vécus)

- Recette différée : se réapproprier un module poussé en PROD sans recette
  (Legal, Stations, U1.1…).
- Workflow 2 machines : comprendre ce que l'autre agent a livré avant de rebaser.
- Auto-relecture : vérifier que le récit de sa propre journée de travail tient
  debout avant de committer.
