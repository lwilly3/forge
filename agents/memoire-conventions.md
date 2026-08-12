# Mémoire d'agent persistante — conventions

> Le mécanisme qui a permis de traverser des dizaines de compactions de
> contexte sans perdre le fil (RadioManager, 2026).

## Format

- Un fichier = un fait, avec frontmatter (`name`, `description`, `type:
  user|feedback|project|reference`).
- `MEMORY.md` = INDEX (une ligne par mémoire, un lien, un accroche) — chargé
  à chaque session ; jamais de contenu dedans.
- Dates ABSOLUES (jamais « hier ») ; noms de fichiers/flags re-vérifiés à la
  relecture (la mémoire reflète un état passé).

## Quoi mémoriser / ne pas mémoriser

- OUI : décisions propriétaire, état des environnements, credentials-pointeurs
  (« les détails sont dans ~/.ssh/config »), leçons d'incidents, plans en cours
  avec leur reste-à-faire.
- NON : ce que le repo enregistre déjà (code, CHANGELOG, git log) — pointer.

## Synchronisation

Après chaque jalon : mettre à jour le fichier thématique concerné (remplacer,
pas empiler), puis copier la mémoire dans le repo (`.claude/memory/`) et
committer — la mémoire suit le projet, pas seulement la machine.

Automatisation éprouvée : le hook [hooks/sync-memory.sh](hooks/sync-memory.sh)
fait la copie à chaque écriture mémoire (`restore` pour l'autre sens sur une
nouvelle machine) — branchement décrit dans
[cooperation-claude-codex](cooperation-claude-codex.md).

## Sécurité

JAMAIS de secret en mémoire : pointeurs uniquement.
