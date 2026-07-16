---
name: context-governance
description: "OBLIGATOIRE pour: modifier le point d'entrée agent (CLAUDE.md/AGENTS.md), les skills, la doc de référence. Déclencheurs: CLAUDE.md, skill, gouvernance, où mettre. NE PAS utiliser pour: la doc d'un module métier."
---

# Gouvernance du contexte agent — règles génériques

## Budgets

- Point d'entrée (CLAUDE.md) : **160 lignes max** — appliqué par hook.
- Un skill : ~120 lignes ; au-delà, scinder ou renvoyer vers la référence.
- Index mémoire : une ligne par mémoire, détail dans des fichiers thématiques.

## Où va quoi

| Contenu | Emplacement |
|---|---|
| Règle nécessaire à CHAQUE session | Point d'entrée, compact |
| Workflow déclenché par un TYPE de tâche | Skill |
| Référence consultable (routes, schémas, flows) | docs/reference/ |
| Doc d'un module | README du module |
| Fait de session non dérivable du repo | Mémoire d'agent |

## Procédure avant de toucher au point d'entrée

1. Skill d'abord ; 2. Référence ensuite ; 3. Lien enfin ; 4. Point d'entrée en
DERNIER recours (1-3 lignes, en condensant l'existant si le budget approche).
Toute modification doit le laisser plus petit ou égal.

## Template de skill (frontmatter + sections, dans cet ordre)

`name`, `description` machine (« OBLIGATOIRE pour / Déclencheurs / NE PAS
utiliser pour ») puis : PRIMARY RESPONSIBILITY, USE WHEN, DO NOT USE WHEN,
TRIGGERS, OWNED DIRECTORIES, DEPENDENCIES, RELATED DOCUMENTATION. Chaque
skill nomme ses voisins (découvrabilité sans tout charger).

## Anti-patterns

- Coller le détail d'une feature livrée dans le point d'entrée (→ CHANGELOG).
- Documenter deux fois « pour être sûr » (→ une source, des pointeurs).
- Laisser un second outil (Codex…) créer des COPIES de skills — elles
  dérivent immédiatement : pointeurs/symlinks uniquement (incident vécu).
