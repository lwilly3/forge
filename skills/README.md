# Skills — guide de prise en main (niveau junior)

> Dernière mise à jour : 2026-08-05

## C'est quoi, un skill ?

Un skill est un **mode d'emploi packagé pour l'agent IA** (Claude Code, Codex…).
C'est un dossier contenant au minimum un fichier `SKILL.md` : quelques dizaines de
lignes qui disent à l'agent *quand* se déclencher et *comment* exécuter une tâche
précise (committer selon un protocole, expliquer un diff, concevoir une UI…).

Quand tu écris « explique ce diff » dans une session, l'agent lit la description du
skill, comprend que la demande correspond, charge les instructions et les suit.
Tu peux aussi forcer l'invocation en tapant `/nom-du-skill`.

## Pourquoi ce dossier existe

Trois problèmes concrets ont motivé sa création :

1. **Réutilisation** — un bon skill écrit pour un projet (ex. RadioManager) resservait
   dans les suivants, mais restait enfermé dans le repo du projet.
2. **Synchronisation 2 machines** — `~/.claude/skills/` est local à chaque machine :
   un skill créé sur l'une n'existait pas sur l'autre, contrairement à la mémoire
   qui est déjà synchronisée par git.
3. **Compréhension** — un `SKILL.md` est écrit pour l'agent, pas pour un humain qui
   découvre. Chaque skill a donc ici un `README.md` qui explique en langage simple
   son besoin d'existence, ce qu'il fait et comment s'en servir.

## Les deux familles de skills

| Famille | Où est la source de vérité | Installation |
|---|---|---|
| **Vivants (globaux)** | ICI, dans `forge/skills/` | lien symbolique vers `~/.claude/skills/` (script `install.sh`) |
| **Génériques (référence)** | ici en copie ; chaque projet a sa version spécialisée dans `.claude/skills/` | copier dans le projet puis adapter |

- **Vivants** : `explain-diff`, `explain-topic`. Le fichier que l'agent lit EST le
  fichier du repo (symlink). Modifier le skill = modifier le repo → il ne reste
  qu'à committer et l'autre machine récupère la mise à jour par `git pull`.
- **Génériques** : `release-version`, `backend-api-python`, `frontend-modulaire`,
  `context-governance`, `ui-design`. Ce sont des bases de départ : chaque projet
  les copie et les spécialise (chemins, conventions, ports). On ne les symlinke
  pas car la version projet diverge volontairement de la version générique.

## Installer sur une nouvelle machine

```bash
git clone git@github.com:lwilly3/forge.git ~/App/forge
~/App/forge/skills/install.sh          # crée les symlinks des skills vivants
```

Le script est idempotent : le relancer ne casse rien. Il refuse d'écraser un
vrai dossier existant (il faut le supprimer soi-même d'abord).

## Cycle de vie d'un skill

1. **Naissance dans un projet** — un besoin répétitif apparaît, on écrit le skill
   dans `.claude/skills/` du projet (ou directement ici s'il est générique d'emblée).
2. **Généralisation** — dès qu'il sert (ou servirait) à un 2e projet : retirer les
   spécificités, le déplacer dans `forge/skills/`, créer le symlink, écrire son
   `README.md`, ajouter la ligne dans `INDEX.md` racine.
3. **Mise à jour** — éditer le fichier (depuis n'importe quel projet, via le
   symlink ou directement ici), puis :
   ```bash
   cd ~/App/forge && git add -A && git commit -m "skills: <quoi>" && git push
   ```
   Sur l'autre machine : `cd ~/App/forge && git pull` (les symlinks pointent déjà
   au bon endroit, rien d'autre à faire).
4. **Retrait** — supprimer le dossier + le symlink + la ligne d'INDEX, avec une
   ligne de commit qui explique pourquoi.

## Règles d'écriture (résumé)

- Le `SKILL.md` reste **concis** (il est chargé dans le contexte de l'agent — chaque
  ligne coûte) ; la pédagogie humaine va dans le `README.md` du skill, jamais dans
  le `SKILL.md`.
- La description (frontmatter `description:`) porte les **déclencheurs** : c'est
  elle qui décide si le skill se charge. La soigner en premier.
- Un skill = une tâche. S'il couvre deux besoins, le couper en deux.
- Dire aussi ce que le skill **ne fait pas** et vers quoi rediriger
  (ex. explain-diff n'est pas une revue de code → `/code-review`).

## Catalogue

### Vivants (symlinkés, source de vérité ici)

| Skill | Sert à | Doc |
|---|---|---|
| `explain-diff` | Se faire expliquer pédagogiquement un diff / une branche / une PR | [README](explain-diff/README.md) |
| `explain-topic` | Se faire enseigner un sujet existant du codebase (sous-système, mécanisme, module) | [README](explain-topic/README.md) |

### Génériques (bases à copier-spécialiser dans chaque projet)

| Skill | Sert à |
|---|---|
| `release-version` | Protocole commit / release SemVer / CHANGELOG |
| `backend-api-python` | FastAPI, SQLAlchemy, Alembic : venv, migrations, checklist pré-push |
| `frontend-modulaire` | Architecture frontend à modules : registre, frontières d'import, permissions |
| `context-governance` | Budget CLAUDE.md et placement de l'information |
| `ui-design` | Grammaire visuelle d'une plateforme opérationnelle |
