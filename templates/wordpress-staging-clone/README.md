# wordpress-staging-clone — cloner un WordPress de prod vers un staging

> Né le 2026-08-13 (premier usage : staging d'une radio FM sur mutualisé OVH).
> Le POURQUOI de chaque garde-fou est expliqué dans
> [playbooks/wordpress-staging-agent-mcp.md](../../playbooks/wordpress-staging-agent-mcp.md) —
> le lire avant de modifier le script.

## Ce que ça fait

Copie un site WordPress de production (fichiers + base) vers un sous-domaine de
staging du MÊME hébergement mutualisé, puis neutralise la copie pour qu'elle ne
puisse pas nuire : e-mails coupés (mu-plugin `staging-guard.php`), indexation
refusée, extensions à risque désactivées, URLs réécrites.

La production n'est touchée qu'en LECTURE. Plusieurs verrous empêchent les
accidents (import dans la base de prod, effacement d'un mauvais dossier,
double transformation d'URLs).

## Usage

```bash
cp clone-wp-staging.conf.example clone-wp-staging.conf   # puis remplir
./clone-wp-staging.sh --inspect   # lecture seule : découvre chemins, WP, tailles
./clone-wp-staging.sh --clone     # exécute ; demande le mot de passe DB à la saisie
```

Relançable sans risque : la copie est incrémentale (rsync), l'import est
idempotent (dump avec DROP TABLE).

## Prérequis

- SSH par clé vers un utilisateur dédié au staging (jamais le login principal).
- WP-CLI sur l'hébergement : absent chez OVH → déposer `wp-cli.phar` dans le
  home (release officielle, vérifier le SHA-512). Le script le détecte seul.
- La base MySQL du staging créée au préalable (OVH Manager).

## Les 3 fichiers

| Fichier | Rôle |
|---|---|
| `clone-wp-staging.sh` | le script — générique, tout vient de la conf |
| `clone-wp-staging.conf.example` | modèle de conf commenté (placeholders) |
| `clone-wp-staging.conf` | VOTRE conf remplie — jamais committée |
