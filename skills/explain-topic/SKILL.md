---
name: explain-topic
description: Enseigner un sujet du codebase (sous-système, concept, workflow, module, feature) façon Distill — 4 sections dans l'ordre strict — Intro au sujet (ce que c'est, où ça vit, quel problème ça résout, ses contrats, glossaire « Notions à connaître »), Intuition avant les détails (objectif + exemple concret, sans code), Figures (les sujets méritent plus de diagrammes que les diffs — architecture, séquence, états), Lecture littéraire du code (fichiers dans l'ordre narratif, prose avant code). Déclencheurs — « explique comment X fonctionne », « walk me through le module Y », « apprends-moi le pipeline Z », « aide-moi à comprendre [feature] ». Ce n'est PAS une revue (pas de bugs) et PAS lié à un diff (ça c'est explain-diff). Livrable = message de chat en français, sauvegarde optionnelle dans docs/.
---

# explain-topic

`grep` et l'arborescence sont de mauvais professeurs : ils montrent des noms en ordre alphabétique et supposent qu'on sait déjà ce qu'on regarde. Ce skill produit un **document d'enseignement** sur un sujet existant du codebase, pour quelqu'un qui construit son modèle mental. **En français.**

**Ce que ce n'est pas** : pas une revue (rediriger vers `/code-review`), pas lié à un diff (ça c'est `explain-diff`), pas de la doc utilisateur final (ça c'est le Centre d'aide / `help-center-maintenance`).

La colonne vertébrale est fixe — ne jamais sauter, fusionner ni réordonner :

1. **Intro au sujet** — ce que c'est, où ça vit, quel problème ça résout, ses contrats avec l'extérieur.
2. **Intuition avant les détails** — l'objectif + un exemple concret ; pas de code.
3. **Figures** — les sujets en méritent plus que les diffs (2–4 typiquement) : architecture, séquence, états.
4. **Lecture littéraire du code** — fichiers en ordre sémantique, chaque fichier précédé d'un paragraphe de prose.

## Résolution du sujet

La phrase libre de l'utilisateur est la requête (« explique le refresh de token », « comment marche l'eventBus »). Lancer un subagent Explore pour localiser : points d'entrée, logique principale, modèles de données, consommateurs, tests. Demander des chemins + rôle en une ligne, pas des extraits.

**Contexte repo à charger** : `CLAUDE.md` racine, `README.md` du/des modules concernés (convention RadioManager : chaque module a un README 12 sections), `docs/reference/` et `docs/modules/<module>/` si pertinents. L'Intro les *synthétise*, elle ne les récite pas.

**Sujet transversal frontend/backend** : le backend FastAPI vit dans un repo séparé (`/Users/happi/App/API/FASTAPI/`) — si le sujet traverse le contrat API, lire les deux côtés ; l'ordre de lecture va toujours modèle de données → backend → frontend, jamais l'inverse.

## Étapes

### 1. Lire le code EN ENTIER, classer, ordonner

Lire la surface complète, pas seulement le point d'entrée. Classer :

| Rôle | Contenu | Dans la lecture |
|---|---|---|
| **Cœur** | les fichiers qui *définissent* le sujet — entrées, logique, modèles de données | en premier, en ordre du Plan |
| **Support** | l'entourage — appelants, config, petits utilitaires, DTOs de contrat | après le Cœur, « voilà comment le Cœur se connecte au reste » |
| **Auxiliaire** | tests, code généré, lockfiles, migrations historiques | une liste repliée à la fin, non lue |

En dériver le **Plan** — l'ordre logique de compréhension (« modèle de données → producteur → consommateur → cycle de vie → chemins d'erreur »), qui devient l'ordre de la section 4.

**Garde-fou sujet trop large** : si plus de ~15 fichiers Cœur+Support ressortent, s'arrêter et confirmer le périmètre avec `AskUserQuestion` avant d'écrire (« j'ai trouvé A, B, C — tout couvrir, ou resserrer sur X ? »).

### 2. Section 1 — Intro au sujet

Persona : quelqu'un qui travaille dans le repo depuis un moment mais connaît peu ce sous-système. Il connaît les langages et frameworks (React/TS, FastAPI, Flutter selon le repo) — pas les internes. **Toujours préférer sur-expliquer.**

Couvrir dans l'ordre, un paragraphe chacun :

- **Ce que c'est** — le rôle dans le produit, la phrase-autocollant que le lecteur emporte. Aucun nom de fichier ni de fonction.
- **Où ça vit** — au niveau des packages/modules, pas des fichiers (« la logique vit dans `src/modules/legal/`, le contrat de permissions dans `shared/types/permissions.ts` »).
- **Le problème résolu** — pourquoi ça existe ; qu'est-ce qui casserait sans. Ancré dans le comportement produit.
- **Les contrats avec l'extérieur** — ce que le sujet consomme (routes API, événements eventBus, collections Firestore, permissions) et produit. Nommer chaque frontière explicitement.
- **Un piège spécifique** — asymétrie ou invariant non évident. Seulement s'il y en a un vrai.

**Clore par `### Notions à connaître`** : 3–5 puces `**terme** — définition en une phrase.` Termes porteurs et plausiblement nouveaux — pas ce que le persona possède déjà. Glossaire cumulatif du lecteur : toujours l'inclure, une phrase max par définition.

Longueur : 4–6 paragraphes courts + glossaire (un peu plus long qu'`explain-diff` — pas de delta sur lequel s'appuyer).

### 3. Section 2 — Intuition avant les détails

- **Objectif** — 1–2 phrases, ancrées dans le résultat produit.
- **L'essence** — un paragraphe sur *comment*, au niveau des idées. Aucun nom de fichier ni de fonction.
- **Un exemple concret** — un scénario tracé dans le *comportement*. Valeurs manifestement fausses (`fakeuser1`, `station-1`) — **jamais de données réelles** (utilisateurs, sociétés, IPs, tokens).

Pas de bloc de code. Une demi-page max. Si l'objectif ne tient pas en deux phrases, le périmètre est trop large — retourner au garde-fou, ou nommer explicitement les deux moitiés.

**Clore par une ancre** : **« Si tu ne retiens qu'une chose : »** + le fait porteur, une seule phrase. Toujours l'inclure ; ne pas paraphraser le titre de section.

### 4. Section 3 — Figures

Chaque figure doit **apporter ce que la prose ne peut pas** — sinon une ligne : « *Rien ici qu'une explication statique n'ait déjà couvert.* ». Mais un sujet a presque toujours plusieurs facettes (flux de données, cycle de vie, contrats, régimes) : viser 2–4 figures ciblées, jamais un méga-diagramme.

- **Architecture** (`flowchart TD` + `subgraph` par package) — le flux producteur → transport → consommateur. La figure la plus souvent manquante et la plus rentable. 6–10 nœuds max.
- **Séquence** (`sequenceDiagram`) — interactions ordonnées dans le temps entre acteurs (ex. login → token → refresh silencieux).
- **États** (`stateDiagram-v2`) — cycle de vie si le sujet a des statuts dont les transitions portent du sens.
- **Tableau Markdown** — entrées→sorties concrètes, valeur d'enum→signification.
- **Exemple exécuté à la main** — l'entrée de la section 2 pas à pas dans le vrai code.
- **`essaie ça`** — commande locale reproductible sans setup exotique (ex. `npm run dev` port 5180 + scénario, requête sur la DB locale de test).

Une légende d'une ligne par figure. Jamais d'ASCII art (`─│┌┐`) — Mermaid.

### 5. Section 4 — Lecture littéraire du code

Fichiers en **ordre du Plan**, pas du système de fichiers :

- Un titre par fichier — `#### Cœur · chemin/fichier.ts` (ou `Support`).
- Avant le code, **un paragraphe de prose** : ce que le fichier fait, quelle étape du Plan il réalise, pourquoi cette forme si non évident. Impossible à écrire → retourner lire le code.
- Puis les **lignes clés** en bloc balisé — pas le fichier entier. La prose dit le *pourquoi*, le code dit le *quoi* — ne jamais paraphraser le code.

Support après le Cœur ; les tests ne sont pas lus. Auxiliaire à la fin en un bloc `<details><summary>Auxiliaire (K fichiers) — survol</summary>…</details>`.

Ne jamais introduire en section 4 une notion que l'Intro n'a pas préparée — sinon la rajouter en section 1 (prose ou glossaire).

### 6. Livrer

Message de chat complet, en français. Ouvrir par :

```
**Sujet : <phrase du sujet>** — lu à <SHA-court de HEAD>
```

Puis les 4 sections (`## Intro`, `## Intuition`, `## Figures`, `## Lecture du code`) et un pied de page :

```
---
*explain-topic · <sujet> · <SHA-court>*
```

Rien d'autre — pas de résumé, pas de suggestions de suite.

**Sauvegarde durable (optionnelle)** : si demandée, écrire `docs/topics/<slug>.md` dans le repo — **sans committer** (committer suit le protocole `release-version` du projet, uniquement à la demande). Terminer le chat par `📚 Aussi sauvegardé : <chemin>`.

## Cas limites

- **Sujet large** — > ~15 fichiers porteurs : confirmer le périmètre avant d'écrire ; ne pas produire 40 pages que personne ne lira.
- **Sujet trans-repo** (frontend + backend + migration) — l'Intro explique le contrat à chaque frontière ; lecture en ordre modèle de données → backend → frontend.
- **Sujet modèle de données** — l'Intro explique le rôle et le cycle de vie de la *table*, pas la mécanique ORM ; les migrations Alembic vont en Auxiliaire (historiques), les modèles + sites de requête sont Cœur.
- **Sujet très étroit** (une fonction, un enum) — dégénéré : Intro un paragraphe, Intuition une phrase, probablement pas de figures, une seule section Cœur. Le dire.
- **Ne pas élargir le périmètre demandé** — « explique le hash de fingerprint » ne devient pas « tout le pipeline d'événements » sans confirmation.
