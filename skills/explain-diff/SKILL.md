---
name: explain-diff
description: Expliquer pédagogiquement un diff/branche/PR à son auteur, façon Distill — 4 sections dans l'ordre strict — Contexte (le modèle mental AVANT le changement), Intuition avant les détails (objectif + exemple concret, sans code), Figures (Mermaid/tableaux seulement s'ils apportent), Lecture littéraire du code (fichiers dans l'ordre narratif, prose avant code). Déclencheurs — « explique ce diff », « explique cette branche », « qu'est-ce que change cette PR », « aide-moi à comprendre ce qui a changé ». Ce n'est PAS une revue de code (pas de bugs, pas de sévérités) — pour ça utiliser /code-review. Livrable = message de chat en français + rapport écrit SYSTÉMATIQUEMENT dans docs/walkthroughs/ du repo.
---

# explain-diff

`git diff` est un mauvais professeur : il montre les hunks dans l'ordre du système de fichiers et suppose que le lecteur connaît déjà le système. Ce skill produit un **document d'enseignement** sur un diff, destiné à l'auteur du changement (ou à quelqu'un qui l'apprend). **En français.**

**Ce que ce n'est pas** : pas une revue (aucun ⭐/⚠️/P0, aucune suggestion de correction — rediriger vers `/code-review` si on veut des bugs). Pas un commentaire de PR — livrable chat + rapport dans docs/, jamais posté sur la plateforme de PR.

La colonne vertébrale est fixe — ne jamais sauter, fusionner ni réordonner :

1. **Contexte** — enseigner le système dans lequel vit le changement, *sans mentionner le changement*.
2. **Intuition avant les détails** — l'objectif + un exemple concret ; pas de code.
3. **Figures** — Mermaid (flowchart/sequence/state), tableaux, `essaie ça` — seulement si elles apportent.
4. **Lecture littéraire du code** — fichiers en ordre sémantique, chaque fichier précédé d'un paragraphe de prose.

## Résolution de la cible

1. Numéro de PR explicite → `gh pr view <N> --json title,body,baseRefName,headRefOid,files` + `git fetch origin pull/<N>/head`. Lire les fichiers par SHA (`git show <headRefOid>:<path>`), jamais `gh pr checkout`.
2. Branche/ref explicite → `git rev-parse` ; base = branche par défaut du repo (**souvent `develop`** dans mes projets — vérifier, pas `main` par réflexe).
3. Sinon → branche courante vs branche par défaut : `git diff $(git merge-base origin/develop HEAD)...HEAD` + non-commité (`git diff HEAD`). Dire « y compris travail non commité » si inclus.

**Contexte repo à charger** : `CLAUDE.md` racine, `README.md` des modules touchés (convention RadioManager : chaque module a un README complet), `docs/reference/` si pertinent. Impossible d'écrire un bon Contexte sans eux.

## Étapes

### 1. Lire le diff EN ENTIER, classer, ordonner

Lire tout le diff + l'entourage de chaque fichier modifié (appelants, classes de base, tests voisins). Classer :

| Rôle | Contenu | Dans la lecture |
|---|---|---|
| **Cœur** | la logique substantielle — là où l'objectif se réalise | en premier, en ordre du Plan |
| **Conséquence** | call sites, câblage, imports, config *causés par* le Cœur | après le Cœur, présentés comme « le Cœur a forcé ceci » |
| **Auxiliaire** | tests, lockfiles, formatage, code généré | une liste repliée à la fin, non lue |

Un fichier n'est Cœur que si le lire est la façon de *d'abord* comprendre le changement. En dériver le **Plan** — les étapes logiques de l'auteur (« introduire X → y router les appelants → migrer → câbler l'UI ») — qui devient l'ordre de la section 4.

**Parité frontend/backend** : si le diff frontend consomme des routes ou permissions API, vérifier dans le repo backend (`/Users/happi/App/API/FASTAPI/`) qu'elles existent, et l'expliquer dans le Contexte — le contrat vit des deux côtés.

### 2. Section 1 — Contexte

**Le lecteur ne sait pas encore ce qui a changé. Ne pas le mentionner** — pas de « Cette PR ajoute… ».

Persona : quelqu'un qui travaille dans le repo depuis un moment mais connaît peu ce sous-système. Il connaît les langages et frameworks (React/TS, FastAPI, Flutter selon le repo) — pas les internes du sous-système. **Toujours préférer sur-expliquer.**

Couvrir dans l'ordre : le rôle et la forme de chaque sous-système touché (un paragraphe chacun) → l'état *antérieur* de la chose modifiée (tout le reste est un delta contre cet état) → le contexte multi-PR/epic s'il existe → un piège spécifique sur lequel le diff repose.

**Clore par `### Notions à connaître`** : 3–5 puces `**terme** — définition en une phrase.` Termes porteurs et plausiblement nouveaux (acronyme, terme inventé par le codebase, DTO récurrent) — pas ce que le persona possède déjà. C'est le glossaire personnel cumulatif du lecteur : toujours l'inclure, définitions d'une phrase max.

Longueur : 3–5 paragraphes courts + glossaire. Plutôt trop long que trop court.

### 3. Section 2 — Intuition avant les détails

Maintenant seulement, dire ce que le changement *fait* :

- **Objectif** — 1–2 phrases, le problème résolu (fondé sur ticket + code, pas le titre de la PR).
- **L'essence** — un paragraphe sur *comment*, au niveau des idées. Aucun nom de fichier ni de fonction.
- **Un exemple concret** — un scénario tracé avant/après dans le *comportement*. Valeurs manifestement fausses (`fakeuser1`, `station-1`) — **jamais de données réelles** (utilisateurs, sociétés, IPs, tokens).

Pas de bloc de code. Une demi-page max. Si l'objectif ne tient pas en deux phrases, le diff fait plusieurs choses — le dire et donner un objectif/essence/exemple par chose.

**Clore par une ancre** : **« Si tu ne retiens qu'une chose : »** + le fait porteur, une seule phrase. Toujours l'inclure ; ne pas paraphraser le titre de section.

### 4. Section 3 — Figures

Chaque figure doit **apporter ce que la prose ne peut pas**. Sinon la section tient en une ligne : « *Rien ici qu'une explication statique n'ait déjà couvert.* » — résultat valide, ne rien fabriquer.

Options : Mermaid (`sequenceDiagram` pour un exemple tracé, `stateDiagram-v2` pour un cycle de statuts, `flowchart TD` avec `subgraph` avant/après — 6–10 nœuds max) ; tableau Markdown entrées→sorties ; exemple exécuté à la main ; `essaie ça` (commande locale reproductible, ex. `npm run dev` + scénario). Une légende d'une ligne par figure. Jamais d'ASCII art (`─│┌┐`) — Mermaid.

### 5. Section 4 — Lecture littéraire du code

Fichiers en **ordre du Plan**, pas du système de fichiers :

- Un titre par fichier — `#### Cœur · chemin/fichier.ts` (ou `Conséquence`).
- Avant le code, **un paragraphe de prose** : ce que le fichier fait maintenant, quelle étape du Plan il réalise, et pourquoi cette forme si non évident. Si le paragraphe est impossible à écrire, retourner lire le code.
- Puis les **lignes clés** en bloc balisé — pas le fichier entier. La prose dit le *pourquoi*, le code dit le *quoi* — ne jamais paraphraser le code.

Conséquences après le Cœur ; les tests ne sont pas lus. Auxiliaire à la fin en un bloc `<details><summary>Auxiliaire (K fichiers) — survol</summary>…</details>`.

Ne jamais introduire en section 4 une notion que le Contexte n'a pas préparée — sinon la rajouter en section 1.

### 6. Livrer

Message de chat complet, en français. Ouvrir par une ligne de cadre :

- **Mode PR** — `[**PR #<N> · <titre>**](<URL>)` + `— lu à <SHA-court>`.
- **Mode local** — nom de branche + SHA court, « y compris travail non commité » si applicable.

Puis les 4 sections (`## Contexte`, `## Intuition`, `## Figures`, `## Lecture du code`) et un pied de page :

```
---
*explain-diff · <cible> · <SHA-court>*
```

Rien d'autre — pas de résumé, pas de suggestions de suite.

**Sauvegarde durable (SYSTÉMATIQUE)** : écrire le même corps dans `docs/walkthroughs/<slug>.md` du repo, avec un frontmatter d'instantané (`title`, `type: diff-walkthrough`, `status: snapshot`, `generated-by: explain-diff`, cible + SHA, `date`) et une note d'en-tête précisant que c'est un instantané pédagogique, pas la doc de référence. Committer selon le protocole du projet (commit `docs(walkthroughs)`, aucun bump) sauf refus explicite. Terminer le chat par `📖 Aussi sauvegardé : <chemin>`.

**Export Word (sur demande)** : générer un `.docx` dans `docs/walkthroughs/exports/<slug>.docx` avec le template `forge/templates/word-report-design/` (page de garde, sommaire, encadrés, glossaire en tableau — lire son README) ; diagrammes Mermaid retranscrits en listes pas-à-pas. L'envoyer à l'utilisateur (SendUserFile).

## Cas limites

- **Gros diff** (> ~40 fichiers) : Contexte et Intuition ne grossissent pas ; regrouper les Conséquences par sous-système.
- **PR docs/lockfiles seulement** : dégénéré — Contexte un paragraphe, Intuition une phrase, pas de figures. Le dire.
- **Migration Alembic** : le Contexte explique le rôle de la *table*, pas l'outil ; la migration est Cœur, les modèles SQLAlchemy sont Conséquences.
- **Non-commité uniquement** : cible = `working tree vs origin/develop`, SHA `+uncommitted`.
- **Nettoyage sans rapport mêlé au diff** : le nommer dans l'Intuition et le mettre en Auxiliaire — ne pas inventer une narration qui les relie.
