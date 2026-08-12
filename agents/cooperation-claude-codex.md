# Coopération Claude Code + Codex sur un même projet

> Vérifié le 2026-08-12 sur RadioManager Modular. Deux agents IA travaillent
> le même repo en parallèle — parfois sur deux machines, parfois dans le MÊME
> arbre de travail sur la même machine. Ce document décrit le dispositif
> complet et sa mise en place dans un nouveau projet / sur une nouvelle machine.

## Le principe : une seule source de vérité, des pointeurs partout

Claude Code et Codex lisent des fichiers d'entrée différents (`CLAUDE.md` vs
`AGENTS.md`, `.claude/skills/` vs `.codex/skills/`). La règle qui fait tenir
le dispositif : **le contenu ne vit qu'à UN endroit** (côté `.claude/`,
historique) **et tout ce que lit Codex est un pointeur**. Zéro duplication =
zéro divergence.

## Les cinq briques

### 1. `AGENTS.md` — point d'entrée Codex

À la racine du projet, à côté de `CLAUDE.md`. Il n'en duplique pas le
contenu : il en **extrait les règles opérationnelles** (branches, commandes,
pièges) et donne un **ordre de lecture au démarrage** — quel skill ou quelle
doc relire selon la tâche. Il porte aussi la section « Travail multi-agents »
(brique 5), la plus critique.

Template prêt à copier : [AGENTS.md.template](AGENTS.md.template).

### 2. Skills : canoniques chez Claude, pointeurs chez Codex

- `.claude/skills/<nom>/SKILL.md` = **source canonique** (spécialisée projet).
- `.codex/skills/<projet>-<nom>/SKILL.md` = **pointeur** de ~10 lignes :

```markdown
---
name: <projet>-<nom>
description: Use this skill when <déclencheurs, en anglais>.
---

# <Titre>

Source canonique : lire `.claude/skills/<nom>/SKILL.md` (<résumé du contenu>).

Références associées : <2-3 chemins de docs>.
```

Détails qui comptent :
- Le `name` est **préfixé du nom du projet** : l'espace de noms des skills
  Codex est partagé entre projets, le préfixe évite les collisions.
- La `description` porte les déclencheurs (comme tout skill) — c'est elle qui
  décide du chargement, la soigner en premier.
- **Anti-pattern vécu** : laisser Codex créer des COPIES de skills — elles
  divergent silencieusement de la source (cf. skill `context-governance`).
- Un pointeur « projet » global (`<projet>.md` → `CLAUDE.md`) sert de filet
  quand aucun skill spécifique ne matche.
- À chaque **nouveau skill projet**, créer son pointeur `.codex/` dans la
  foulée — l'inscrire dans la procédure du `context-governance` du projet.

### 3. Hooks partagés : les mêmes garde-fous pour les deux agents

Les scripts vivent dans `.claude/hooks/` ; chaque agent les branche dans son
propre format de config, **sur les mêmes fichiers** :

- Claude : `.claude/settings.json` → `hooks.PostToolUse` (matcher `Edit|Write`).
- Codex : `.codex/hooks.json`, même structure, mêmes scripts.

Hooks éprouvés : `check-context-budget.sh` (budget CLAUDE.md 160 lignes) et
`sync-memory.sh` (brique 4). Copies de référence : [hooks/](hooks/).

### 4. Mémoire partagée via git

La mémoire agent vit hors repo (`~/.claude/projects/<slug>/memory/`) ; le hook
[hooks/sync-memory.sh](hooks/sync-memory.sh) la copie automatiquement dans
`.claude/memory/` (versionné) à chaque écriture. Résultat : Codex — et Claude
sur l'autre machine — lit le même contexte projet depuis le repo. `AGENTS.md`
dit à Codex quand aller la lire.

Format et règles de la mémoire : [memoire-conventions](memoire-conventions.md)
(propriétaire du sujet).

### 5. Règles git de survie multi-agents

Nées de trois collisions en une journée (2026-07-28, RadioManager) :

| Incident | Parade permanente |
|---|---|
| Codex bloqué indéfiniment : `git log` a ouvert `less` | Git NON INTERACTIF : `git config core.pager cat` sur le repo, `git --no-pager …` en cas de doute, `git -c core.editor=true …` pour rebase/merge |
| Correctif identique fait des deux côtés → le rebase « sans conflit » fusionne en doublon → build cassé poussé | Après TOUT rebase, même réussi : relancer le typecheck/gate AVANT de pousser, jamais après |
| Gros stock non commité local → toutes les collisions amplifiées | Pousser vite les travaux finis ; jamais des dizaines de fichiers en attente |

Règles complémentaires (dans `AGENTS.md`, section « Travail multi-agents ») :
- **Même arbre de travail = un seul agent à la fois.** `git status` avant de
  commencer ; des changements stagés inconnus = ne pas écraser, demander au
  propriétaire qui doit finir.
- `git fetch` + inspecter `HEAD..origin/<branche>` AVANT toute séquence de
  travail, et re-fetch juste avant chaque push.
- Leçon de fond : un rebase « sans conflit » peut quand même produire un état
  incohérent quand les deux côtés ont fait la même chose à des endroits
  différents du même fichier — seul le typecheck le voit.

## Mise en place — nouveau projet

1. `CLAUDE.md` depuis [CLAUDE.md.template](CLAUDE.md.template) (< 160 lignes).
2. `AGENTS.md` depuis [AGENTS.md.template](AGENTS.md.template) — adapter
   commandes, architecture, pièges ; garder la section multi-agents telle quelle.
3. Copier [hooks/check-context-budget.sh](hooks/check-context-budget.sh) et
   [hooks/sync-memory.sh](hooks/sync-memory.sh) dans `.claude/hooks/` du projet.
4. Les brancher deux fois : `.claude/settings.json` (PostToolUse `Edit|Write`)
   et `.codex/hooks.json` (mêmes scripts).
5. Créer un pointeur `.codex/skills/<projet>-<nom>/SKILL.md` par skill projet
   (+ le pointeur « projet » global vers `CLAUDE.md`).
6. `git config core.pager cat` dans le repo.

## Mise en place — nouvelle machine

1. Cloner la Forge et installer les skills vivants :
   `git clone git@github.com:lwilly3/forge.git ~/App/forge && ~/App/forge/skills/install.sh`.
2. Cloner le(s) projet(s).
3. `git config core.pager cat` dans CHAQUE repo cloné — c'est une config
   LOCALE, elle ne voyage pas avec le clone (piège classique).
4. Restaurer la mémoire agent depuis le repo :
   `.claude/hooks/sync-memory.sh restore`.
5. Recréer les secrets locaux (`.env.local`) depuis `.env.example` — jamais
   depuis git (cf. [repos-publics-secrets](../playbooks/repos-publics-secrets.md)).

## Limites connues (2026-08-12)

- Aucun verrou technique sur l'arbre de travail partagé : la règle « un agent
  à la fois » repose sur la discipline (`git status` d'abord) et l'arbitrage
  du propriétaire.
- Les pointeurs `.codex/skills/` ne se génèrent pas automatiquement : c'est un
  geste manuel à chaque nouveau skill projet.
