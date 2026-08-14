# WordPress via MCP — mode d'emploi pour les agents (Claude & Codex)

> Vérifié 2026-08-14. Le POURQUOI du mécanisme : [playbooks/wordpress-staging-agent-mcp.md](../playbooks/wordpress-staging-agent-mcp.md).
> Ce document est le mode d'emploi OPÉRATOIRE : connexion, outils, abilities, pièges, interdits.

## Connexion

Le site expose un serveur MCP (plugin officiel `mcp-adapter`) :

- Endpoint : `https://www.staging.radioaudace.com/wp-json/mcp/mcp-adapter-default-server`
- Auth : `Authorization: Basic <base64(agent-audace:app-password)>` — app password
  WordPress du compte `agent-audace`, révocable dans wp-admin → profil.
- **Claude Code** : serveur `wp-staging-radioaudace` (déjà dans la config projet).
- **Codex** : `[mcp_servers.wp-staging-radioaudace]` dans `~/.codex/config.toml`,
  via `npx mcp-remote <endpoint> --header "Authorization: Basic …" --transport http-only`
  (pont stdio→HTTP ; déjà configuré sur cette machine).

## Les 3 méta-outils MCP

Tout passe par le mcp-adapter :

1. `mcp-adapter-discover-abilities` — catalogue des abilities publiques.
2. `mcp-adapter-get-ability-info` — schémas détaillés d'une ability.
3. `mcp-adapter-execute-ability` — exécution :
   `{"ability_name": "audace/<nom>", "parameters": {...}}`.
   Réponse enveloppée : `{"success": true, "data": {...}}`.

## Abilities `audace/*` (plugin audace-agent-abilities, repo `lwilly3/audace-agent-abilities-wp`)

| Ability | Type | Rôle |
|---|---|---|
| `site-info` | lecture | versions, thème, extensions, `is_staging` — à appeler en premier |
| `list-recent-posts` | lecture | derniers articles (count ≤20, status publish/draft/any) |
| `get-design-tokens` | lecture | identité visuelle Extra (`et_extra`), + clés arbitraires via `keys` |
| `list-design-surfaces` | lecture | pages ET layouts Extra (la une = layout, PAS une page) |
| `get-page-layout` | lecture | structure builder en arbre (`include_raw` pour les shortcodes) |
| `create-draft` | écriture | article en brouillon FORCÉ (jamais publié) |
| `duplicate-surface-as-draft` | écriture | clone toute surface en brouillon « (Refonte) … » — le bac à sable |
| `update-surface-layout` | écriture | remplace structure+CSS d'un BROUILLON uniquement ; valide l'équilibre des shortcodes ; purge et-cache |

Référence complète (schémas, exemples) : `docs/ABILITIES.md` du repo du plugin.

## Le cycle d'écriture (OBLIGATOIRE)

`update-surface-layout` **refuse toute cible publiée**. Pour modifier une surface
en ligne sur le staging :

1. Sauvegarde si nécessaire : `duplicate-surface-as-draft` (l'original reste intact).
2. Passer la cible en brouillon (WP-CLI, voir ci-dessous).
3. Écrire via l'ability (elle purge les caches Divi).
4. Republier (WP-CLI), re-purger si besoin.

## Accès serveur (SSH + WP-CLI)

- SSH : `audaceq-stgradio@ssh.cluster130.hosting.ovh.net` (clé installée ; home
  réel `/homez.1012/audaceq`, site dans `stagingRadioAudace/`).
- WP-CLI : ABSENT chez OVH → `php ~/wp-cli.phar <cmd>` avec `PATH` complété de `/usr/bin`.
- Statuts : `php ~/wp-cli.phar post update <ID> --post_status=draft|publish`.
- Purge caches : `rm -rf wp-content/et-cache && php ~/wp-cli.phar transient delete --all`.

## Pièges réseau et thème (chacun vérifié à nos dépens)

- **ModSecurity OVH** : bloque TOUS les PUT (toute origine), et les POST au
  **User-Agent curl**. Utiliser POST + un UA applicatif (`RadioManager/...`,
  httpx, ou le client MCP qui a le sien). Rafale bloquée = **ban IP ~15 min sur
  tous les domaines** (le public n'est pas affecté — vérifier d'ailleurs).
- **MCP streamable HTTP** : après `initialize`, chaque appel exige le header
  `Mcp-Session-Id` (le client MCP le gère ; en curl manuel, le récupérer soi-même).
- **Thème Extra** : la une = layout avec meta `_extra_layout_home=1` ; pleine
  largeur = meta `_extra_sidebar_location=none` ; le CPT layout n'a PAS de vue
  single (recette = bascule contrôlée). Tout le savoir Extra : skill
  `extra-skill` (forge, symlinké).

## Écosystème piloté par RadioManager (module Social)

La **grille des programmes** (émissions, présentateurs, visuels, mode
relance/normal, page grille activable) est administrée dans RadioManager et
poussée via le plugin analytics (`POST /wp-json/audace-analytics/v1/program-grid`
+ `program-media` pour les images, header `X-Audace-Secret`). Les agents ne
modifient PAS l'option `audace_grille` à la main : passer par RadioManager
(routes backend `/social/wp-program/*`) — source de vérité en base.

## Interdits (identiques pour tous les agents)

1. **Jamais publier** via une ability — la publication est un geste humain ou
   un statut WP-CLI assumé sur le staging uniquement.
2. **Jamais toucher à la PROD** (`www.radioaudace.com`) : tout se passe sur le
   staging jusqu'à décision de promotion explicite de l'utilisateur.
3. Pas de secrets en clair dans les repos ni les sorties : l'app password vit
   dans les configs locales, le X-Audace-Secret se lit depuis le serveur.
4. Les modifications de design suivent la règle du skill extra-skill :
   **imiter les patterns du site, jamais inventer d'attributs**.
