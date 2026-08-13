#!/bin/bash
# Installe les skills VIVANTS de la Forge sur cette machine (symlinks).
# Idempotent : peut être relancé sans risque. Refuse d'écraser un vrai dossier.
set -euo pipefail

FORGE_SKILLS="$(cd "$(dirname "$0")" && pwd)"
TARGET="${HOME}/.claude/skills"

# Liste des skills vivants (source de vérité = forge/skills/<nom>)
LIVE_SKILLS=(explain-diff explain-topic divi5-skill)

mkdir -p "$TARGET"

for skill in "${LIVE_SKILLS[@]}"; do
  src="${FORGE_SKILLS}/${skill}"
  dst="${TARGET}/${skill}"
  if [ ! -d "$src" ]; then
    echo "✗ ${skill} : absent de ${FORGE_SKILLS} — git pull ?" >&2
    continue
  fi
  if [ -L "$dst" ]; then
    ln -sfn "$src" "$dst"
    echo "✓ ${skill} : symlink actualisé"
  elif [ -e "$dst" ]; then
    echo "✗ ${skill} : ${dst} existe et n'est pas un symlink — le supprimer manuellement puis relancer" >&2
  else
    ln -s "$src" "$dst"
    echo "✓ ${skill} : symlink créé"
  fi
done

echo "Terminé. Vérifier avec : ls -la ${TARGET}"
