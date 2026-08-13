# WordPress : staging cloné + agents IA via MCP — le mécanisme complet

> Vérifié 2026-08-13 sur un hébergement mutualisé OVH (offre Performance, PHP 8.4)
> avec un site WordPress 7.0.4 / thème Extra. Premier site branché : une radio FM.
> Les valeurs propres à chaque site (hôtes SSH, chemins, bases) vivent dans la
> mémoire d'agent, JAMAIS ici.

## Le mécanisme en trois briques

1. **Staging cloné** — copie totale du site public (fichiers + base) sur un
   sous-domaine du même hébergement, détachée sur sa propre base MySQL.
   Script éprouvé : `templates/wordpress-staging-clone/`.
2. **Neutralisation** — le clone ne peut pas nuire : mu-plugin `staging-guard.php`
   (aucun e-mail ne sort, indexation refusée, bandeau admin) + désactivation des
   extensions à risque (newsletter, sauvegardes, analytics).
3. **Pont MCP** — plugin officiel `WordPress/mcp-adapter` (WP ≥ 6.9, Abilities API
   du core) + utilisateur WP dédié aux agents + mot de passe d'application.
   Claude/Codex parlent au site en JSON-RPC via
   `/wp-json/mcp/mcp-adapter-default-server`.

L'adaptateur ne fournit QUE la plomberie (transport, session, auth, 3 méta-outils
discover/get-info/execute). `discover` renvoie une liste **vide** sur un WP nu :
le vocabulaire métier vient d'un plugin d'abilities à écrire par nous.

## Reproduction sur un nouveau site (checklist)

1. **OVH Manager** : Multisite → ajouter `staging.<domaine>` (SSL Let's Encrypt) ;
   Bases de données → créer la base du staging (un emplacement inclus est souvent
   libre ; mot de passe alphanumérique UNIQUEMENT, contrainte OVH) ; FTP-SSH →
   créer un utilisateur SSH dédié révocable, répertoire cible `.`.
2. **Clé SSH** : `ssh-copy-id` (l'humain tape le mot de passe, l'agent ne le voit
   jamais). Le home réel est du type `/homez.NNN/<login>` — le découvrir via
   `--inspect`, ne pas le deviner.
3. **WP-CLI** : absent chez OVH → `wp-cli.phar` téléchargé dans le home depuis
   la release officielle, empreinte SHA-512 vérifiée. Invoquer `php ~/wp-cli.phar`,
   PATH complété de `/usr/bin` (sinon mysqldump introuvable).
4. **Clonage** : `clone-wp-staging.sh --inspect` puis `--clone` (le mot de passe
   de base est demandé à la saisie, jamais écrit dans la config). Lire les pièges
   ci-dessous AVANT de modifier le script.
5. **Recette** : titre, thème, nombre d'articles, `home`/`siteurl`, ZÉRO URL de
   prod dans le HTML rendu, bandeau staging dans l'admin.
6. **MCP** : `wp plugin install https://github.com/WordPress/mcp-adapter/releases/latest/download/mcp-adapter.zip --activate` ;
   `wp user create agent-<nom> <email> --role=administrator` ;
   `wp user application-password create agent-<nom> claude-code --porcelain` ;
   côté poste : `claude mcp add --transport http <nom> <endpoint> --header
   "Authorization: Basic $(printf 'user:apppass' | base64)"` → vérifier
   `claude mcp list` = ✔ Connected. Outils visibles à la session suivante.

## Pièges vérifiés (chacun a coûté une itération)

- **Sous-domaine OVH ≠ dossier vide** : le module « WordPress 1-clic » peut avoir
  déposé une install vierge (avec SA base auto-créée). Inspecter avant d'écraser.
- **`tar` + `set -e` sur un site vivant** : « fichier modifié pendant sa lecture »
  = code d'erreur = abandon. Utiliser **rsync** (reprise incrémentale ; tolérer
  le code retour 24).
- **LE piège critique** : après la copie, `wp-config.php` du staging pointe encore
  sur la **base de production**. Importer ou search-replace à cet instant détruit
  le site public. Le script verrouille : DB_NAME staging ≠ DB_NAME prod, sinon refus.
- **Édition de wp-config à travers 2 shells** : un `php -r` inline y casse en
  silence (échappement des quotes). Toujours `wp config set`.
- **MySQL 8.4 vs client MariaDB 10.3 d'OVH** : `wp db query/import` (shell-out
  vers `mysql --default-character-set=utf8`) échoue ; **mysqli (PHP) fonctionne**.
  → importer via `mysql` direct (MYSQL_PWD), tester la connexion via mysqli,
  garder `wp search-replace` (il passe par wpdb, pas par le binaire).
- **search-replace du domaine nu = double transformation** : remplacer
  `exemple.com` → `staging.exemple.com` retransforme les occurrences déjà
  converties en `staging.staging.` Remplacer les **hôtes** (`www.exemple.com`,
  puis `//exemple.com`), jamais le domaine nu.
- **Caches Divi/Extra** : CSS compressé en base + `wp-content/et-cache` gardent
  les URLs de prod hors de portée de search-replace → purger et-cache +
  transients après clonage, le thème régénère.
- **ModSecurity OVH bloque les POST au User-Agent curl** (403 Apache brut) ;
  une rafale bloquée = **ban IP temporaire (~10-15 min) sur TOUS les domaines
  de l'hébergement**. Le public n'est PAS affecté — vérifier depuis une autre
  infra (WebFetch) avant de paniquer. Les clients MCP réels passent sans réglage.
- **App passwords** : le `.htaccess` WordPress standard contient déjà la règle
  `HTTP_AUTHORIZATION` ; la vérifier si 401 persistant.
- **MCP streamable HTTP** : après `initialize`, chaque appel exige le header
  `Mcp-Session-Id` renvoyé par la réponse d'initialize.

## Sécurité (non négociable)

- Un utilisateur SSH **dédié par staging**, révocable sans toucher au reste.
- L'agent ne manipule JAMAIS un mot de passe humain : saisie interactive
  (`read -rs`, ssh-copy-id) ou identifiants machine générés (`--porcelain`).
- Les extensions qui parlent au monde (newsletter, sauvegardes cloud, analytics)
  sont désactivées sur le staging — un clone actif peut spammer les vrais abonnés
  et polluer les vraies sauvegardes.
- La prod n'est touchée qu'en LECTURE (dump + rsync source).

## Tenir ce playbook à jour

Après chaque nouveau site branché ou piège rencontré : compléter la liste des
pièges, dater la vérification en tête, committer. Le script template évolue en
même temps — c'est LUI la référence exécutable, ce document explique le pourquoi.

## Suite du mécanisme (à documenter quand livré)

- Plugin « Agent Abilities » : abilities métier exposées à `discover`
  (site-info, brouillons, médias, design) — le vocabulaire des agents.
- Skill éditorial par marque (règles rédactionnelles, SEO, identité).
- Promotion staging → prod : ré-exécution délibérée des gestes validés,
  jamais de synchronisation automatique.
