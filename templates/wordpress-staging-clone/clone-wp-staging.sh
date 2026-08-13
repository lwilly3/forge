#!/bin/bash
# ---------------------------------------------------------------------------
# clone-wp-staging.sh — Clone un WordPress de production vers un staging
# sur le MEME hebergement mutualise OVH, via SSH + WP-CLI.
#
#   ./clone-wp-staging.sh --inspect          # lecture seule : decouvre les chemins
#   ./clone-wp-staging.sh --clone            # execute le clonage
#
# La production n'est JAMAIS modifiee : seule une lecture (dump SQL + copie de
# fichiers) y est faite. Tout ce qui ecrit vise le dossier de staging.
#
# Le staging est neutralise a la fin : envoi d'e-mails coupe, extensions a
# risque desactivees, indexation refusee, bandeau d'avertissement en admin.
# ---------------------------------------------------------------------------
set -euo pipefail

CONF="${CONF:-$(dirname "$0")/clone-wp-staging.conf}"
MODE="${1:---inspect}"

if [ ! -f "$CONF" ]; then
  echo "✗ Config absente : $CONF" >&2
  echo "  Copier clone-wp-staging.conf.example puis le remplir." >&2
  exit 1
fi
# shellcheck disable=SC1090
source "$CONF"

: "${SSH_TARGET:?SSH_TARGET manquant dans la config}"

ssh_run() { ssh -o BatchMode=yes -o ConnectTimeout=15 "$SSH_TARGET" "$@"; }

# Preambule execute a distance : PATH complet + detection de WP-CLI
# (OVH mutualise ne fournit pas wp ; on retombe sur wp-cli.phar dans le home).
REMOTE_PRELUDE='
export PATH="/usr/bin:/usr/local/bin:$PATH"
if command -v wp >/dev/null 2>&1; then
  WP="wp"
elif [ -f "$HOME/wp-cli.phar" ]; then
  WP="php $HOME/wp-cli.phar"
else
  echo "✗ WP-CLI introuvable (ni wp, ni ~/wp-cli.phar)" >&2; exit 1
fi
'

# ===========================================================================
# MODE INSPECTION — aucune ecriture
# ===========================================================================
if [ "$MODE" = "--inspect" ]; then
  echo "▸ Inspection de $SSH_TARGET (lecture seule)"
  ssh_run "bash -s" <<REMOTE
set -u
$REMOTE_PRELUDE
echo "--- Environnement ---"
echo "hote   : \$(hostname)"
echo "home   : \$HOME"
echo "php    : \$(php -v 2>/dev/null | head -1)"
echo "wp-cli : \$(\$WP --version 2>/dev/null || echo INDISPONIBLE)"
echo
echo "--- Installations WordPress ---"
for f in \$(find "\$HOME/" -maxdepth 2 -name wp-config.php 2>/dev/null); do
  d=\$(dirname "\$f")
  echo "• \$d"
  echo "    version : \$(\$WP --path="\$d" core version 2>/dev/null || echo '?')"
  echo "    url     : \$(\$WP --path="\$d" option get home 2>/dev/null || echo '?')"
  echo "    taille  : \$(du -sh "\$d" 2>/dev/null | cut -f1)"
done
echo
echo "--- Espace disque ---"
df -h "\$HOME/" 2>/dev/null | tail -1
REMOTE
  exit 0
fi

if [ "$MODE" != "--clone" ]; then
  echo "Usage : $0 [--inspect|--clone]" >&2
  exit 1
fi

# ===========================================================================
# MODE CLONAGE
# ===========================================================================
: "${SRC_DIR:?SRC_DIR manquant}"
: "${DST_DIR:?DST_DIR manquant}"
: "${SRC_URL:?SRC_URL manquant}"
: "${DST_URL:?DST_URL manquant}"
: "${DST_DB_NAME:?DST_DB_NAME manquant}"
: "${DST_DB_USER:?DST_DB_USER manquant}"
: "${DST_DB_HOST:?DST_DB_HOST manquant}"

# Mot de passe de la base : demande a la saisie s'il n'est pas dans la config,
# pour ne pas avoir a l'ecrire sur disque ni dans l'historique du shell.
if [ -z "${DST_DB_PASS:-}" ]; then
  if [ -t 0 ]; then
    printf "Mot de passe de la base %s : " "$DST_DB_NAME" >&2
    read -rs DST_DB_PASS
    echo >&2
  else
    echo "✗ DST_DB_PASS vide et pas de terminal pour le demander." >&2
    echo "  Renseigner DST_DB_PASS dans $CONF, ou lancer ce script depuis un terminal." >&2
    exit 1
  fi
fi
: "${DST_DB_PASS:?mot de passe vide}"

if [ "$SRC_DIR" = "$DST_DIR" ]; then
  echo "✗ SRC_DIR et DST_DIR sont identiques — abandon." >&2
  exit 1
fi

echo "▸ Clonage"
echo "    source      : $SRC_DIR  ($SRC_URL)"
echo "    destination : $DST_DIR  ($DST_URL)"
echo "    base cible  : $DST_DB_NAME @ $DST_DB_HOST"
echo

ssh_run "SRC_DIR='$SRC_DIR' DST_DIR='$DST_DIR' SRC_URL='$SRC_URL' DST_URL='$DST_URL' \
         DST_DB_NAME='$DST_DB_NAME' DST_DB_USER='$DST_DB_USER' \
         DST_DB_PASS='$DST_DB_PASS' DST_DB_HOST='$DST_DB_HOST' \
         DISABLE_PLUGINS='${DISABLE_PLUGINS:-}' ALLOW_WIPE_DST='${ALLOW_WIPE_DST:-no}' \
         ADMIN_USER='${ADMIN_USER:-}' ADMIN_PASS='${ADMIN_PASS:-}' ADMIN_EMAIL='${ADMIN_EMAIL:-}' \
         bash -s" <<REMOTE
set -euo pipefail
$REMOTE_PRELUDE

[ -f "\$SRC_DIR/wp-config.php" ] || { echo "✗ Pas de WordPress dans \$SRC_DIR" >&2; exit 1; }

mkdir -p "\$DST_DIR"
RESTES=\$(find "\$DST_DIR" -mindepth 1 -maxdepth 1 ! -name '.well-known' ! -name '.ovhconfig' 2>/dev/null | wc -l)
if [ "\$RESTES" -gt 0 ]; then
  if [ "\${ALLOW_WIPE_DST:-no}" != "yes" ]; then
    echo "✗ \$DST_DIR n'est pas vide (\$RESTES entrees)." >&2
    echo "  Poser ALLOW_WIPE_DST=\"yes\" dans la config pour autoriser son remplacement." >&2
    exit 1
  fi
  # Garde-fous avant toute suppression : le chemin doit designer un staging,
  # etre sous le home, et ne surtout pas etre le dossier de production.
  case "\$DST_DIR" in
    *[Ss]taging*) : ;;
    *) echo "✗ Refus de vider \"\$DST_DIR\" : le chemin ne contient pas \"staging\"." >&2; exit 1 ;;
  esac
  [ "\$DST_DIR" != "\$SRC_DIR" ] || { echo "✗ DST_DIR == SRC_DIR" >&2; exit 1; }
  [ "\$DST_DIR" != "\$HOME" ] || { echo "✗ DST_DIR est le home" >&2; exit 1; }
  echo "⓪ Contenu existant detecte : il sera aligne sur la source (rsync --delete)."
fi

DUMP="\$HOME/staging-dump-radioaudace.sql"

echo "① Export de la base de production (lecture seule)…"
\$WP --path="\$SRC_DIR" db export "\$DUMP" --add-drop-table --quiet
echo "   → \$(ls -lh "\$DUMP" | awk '{print \$5}')"

echo "② Copie des fichiers (~1 Go, patienter)…"
# rsync plutot que tar : reprend une copie interrompue, et ne s'effondre pas
# quand un fichier bouge sous lui — le site source est en production.
set +e
rsync -a --delete \
      --exclude='wp-content/cache' \
      --exclude='wp-content/et-cache' \
      --exclude='wp-content/updraft' \
      --exclude='wp-content/uploads/backup*' \
      "\$SRC_DIR/" "\$DST_DIR/"
RC=\$?
set -e
# 24 = des fichiers ont disparu pendant le transfert (caches, sessions) : sans gravite.
if [ "\$RC" -ne 0 ] && [ "\$RC" -ne 24 ]; then
  echo "✗ rsync a echoue (code \$RC)" >&2; exit 1
fi
[ "\$RC" -eq 24 ] && echo "   (des fichiers temporaires ont disparu pendant la copie — sans consequence)"
echo "   → \$(du -sh "\$DST_DIR" | cut -f1) en place"

echo "③ Reconfiguration de wp-config.php…"
cd "\$DST_DIR"
# wp config set edite wp-config.php de maniere fiable (guillemets, echappement).
\$WP config set DB_NAME     "\$DST_DB_NAME" --quiet
\$WP config set DB_USER     "\$DST_DB_USER" --quiet
\$WP config set DB_PASSWORD "\$DST_DB_PASS" --quiet
\$WP config set DB_HOST     "\$DST_DB_HOST" --quiet
echo "   → base declaree : \$(\$WP config get DB_NAME)"

# ═══ VERROU DE SECURITE ═══
# Rien n'est importe tant que le staging pointe sur la base de la production :
# un import a cet endroit ecraserait le site public.
SRC_DB=\$(\$WP --path="\$SRC_DIR" config get DB_NAME)
DST_DB=\$(\$WP config get DB_NAME)
if [ "\$DST_DB" = "\$SRC_DB" ]; then
  echo "✗ ARRET : le staging pointe sur la base de production (\$SRC_DB)." >&2
  echo "  Aucune ecriture n'a ete faite. Verifier wp-config.php avant de relancer." >&2
  exit 1
fi
# Test de connexion via mysqli (PHP), PAS via « wp db » : le client mysql
# du serveur (MariaDB 10.3) + --default-character-set=utf8 echoue face a
# MySQL 8.4, alors que mysqli — le moteur de WordPress — fonctionne.
if ! php -r 'exit(@mysqli_connect(getenv("H"), getenv("U"), getenv("P"), getenv("N")) ? 0 : 1);' \
     H="\${DST_DB_HOST%%:*}" U="\$DST_DB_USER" P="\$DST_DB_PASS" N="\$DST_DB_NAME" 2>/dev/null; then
  echo "✗ Connexion impossible a \$DST_DB — mot de passe ou hote incorrect ?" >&2
  echo "  (une base OVH fraichement creee peut mettre quelques minutes a repondre)" >&2
  exit 1
fi
echo "   → verrou OK : cible \$DST_DB, distincte de la production (\$SRC_DB)"

echo "④ Import de la base (client mysql direct — « wp db » casse sur MySQL 8.4)…"
export MYSQL_PWD="\$DST_DB_PASS"
mysql --no-defaults -h "\${DST_DB_HOST%%:*}" -u "\$DST_DB_USER" "\$DST_DB_NAME" < "\$DUMP"
echo "   → importee"

echo "⑤ Remplacement des URLs…"
# On remplace les HOTES, jamais le domaine nu : remplacer « exemple.com » par
# « staging.exemple.com » retransformerait les occurrences deja converties
# en « staging.staging.exemple.com ».
SRC_HOST="\${SRC_URL#https://}"; DST_HOST="\${DST_URL#https://}"
\$WP search-replace "\$SRC_HOST" "\$DST_HOST" --all-tables-with-prefix --precise --quiet
SRC_NOWWW="\${SRC_HOST#www.}"; DST_NOWWW="\${DST_HOST#www.}"
\$WP search-replace "//\$SRC_NOWWW" "//\$DST_NOWWW" --all-tables-with-prefix --precise --quiet
echo "   → \$SRC_HOST remplace par \$DST_HOST"

# Les caches Divi/Extra stockent du CSS compresse contenant les URLs de prod,
# hors de portee de search-replace : on les purge, le theme les regenerera.
rm -rf "\$DST_DIR/wp-content/et-cache"
\$WP transient delete --all --quiet 2>/dev/null || true

echo "⑥ Neutralisation du staging…"
\$WP option update home "\$DST_URL" --quiet
\$WP option update siteurl "\$DST_URL" --quiet
\$WP option update blog_public 0 --quiet

# Garde-fou permanent : coupe TOUT envoi d'e-mail et signale le staging.
# Un mu-plugin ne peut pas etre desactive depuis l'admin par megarde.
mkdir -p "\$DST_DIR/wp-content/mu-plugins"
cat > "\$DST_DIR/wp-content/mu-plugins/staging-guard.php" <<'PHP'
<?php
/**
 * Plugin Name: Staging Guard
 * Description: Filet de securite du site de pre-production : aucun e-mail ne peut
 *              sortir, l'indexation est refusee, et l'admin affiche un avertissement.
 *              Ne pas installer sur le site de production.
 */
if ( ! defined( 'ABSPATH' ) ) { exit; }

// 1. Aucun e-mail ne quitte le staging (newsletters, notifications, formulaires).
add_filter( 'pre_wp_mail', '__return_false', PHP_INT_MAX );

// 2. Refus d'indexation, quoi qu'en disent les reglages.
add_filter( 'pre_option_blog_public', '__return_zero', PHP_INT_MAX );

// 3. Bandeau visible dans l'administration.
add_action( 'admin_notices', function () {
    echo '<div class="notice notice-warning"><p><strong>Site de pre-production</strong> — '
       . 'copie de travail. Les e-mails sont bloques et le site n\'est pas indexe. '
       . 'Les modifications faites ici n\'affectent pas le site public.</p></div>';
} );
PHP
echo "   → e-mails bloques, indexation refusee, bandeau admin actif"

if [ -n "\${DISABLE_PLUGINS:-}" ]; then
  echo "⑦ Desactivation des extensions a risque…"
  for p in \$DISABLE_PLUGINS; do
    \$WP plugin deactivate "\$p" --quiet 2>/dev/null && echo "   → \$p desactive" || echo "   → \$p (absent/deja inactif)"
  done
fi

\$WP cache flush --quiet 2>/dev/null || true
\$WP rewrite flush --quiet 2>/dev/null || true

if [ -n "\${ADMIN_USER:-}" ] && [ -n "\${ADMIN_PASS:-}" ] && [ -n "\${ADMIN_EMAIL:-}" ]; then
  echo "⑧ Compte administrateur dedie…"
  \$WP user create "\$ADMIN_USER" "\$ADMIN_EMAIL" --role=administrator \
     --user_pass="\$ADMIN_PASS" --quiet 2>/dev/null \
    && echo "   → \$ADMIN_USER cree" || echo "   → \$ADMIN_USER existe deja"
fi

rm -f "\$DUMP"

echo
echo "✓ Clonage termine."
echo "  Site  : \$DST_URL"
echo "  Admin : \$DST_URL/wp-admin"
echo "  WordPress \$(\$WP core version)  ·  theme \$(\$WP theme list --status=active --field=name | head -1)"
echo "  Extensions actives : \$(\$WP plugin list --status=active --format=count)"
REMOTE
