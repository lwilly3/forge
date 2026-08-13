# wordpress-agent-abilities — le vocabulaire des agents dans WordPress

> Né le 2026-08-13, validé le même soir sur le staging d'une radio FM :
> brouillon n° 2013 créé via la chaîne Claude → MCP → Abilities API.
> Le mécanisme d'ensemble : [playbooks/wordpress-staging-agent-mcp.md](../../playbooks/wordpress-staging-agent-mcp.md).

## Ce que ça fait

Plugin WordPress (mono-fichier) qui enregistre des **abilities** — les capacités
métier que les agents IA découvrent et exécutent via le mcp-adapter officiel.
Sans ce plugin, `discover` renvoie une liste vide : l'adaptateur n'est que la
plomberie, ce plugin est le vocabulaire.

v0.1 — trois abilities volontairement prudentes :

| Ability | Type | Rôle |
|---|---|---|
| `audace/site-info` | lecture | photographie du site (versions, thème, extensions, is_staging) |
| `audace/list-recent-posts` | lecture | derniers articles (id, titre, statut, catégories) |
| `audace/create-draft` | écriture | crée un article en **brouillon forcé** — ne publie JAMAIS |

## Principes de conception (à conserver en étendant)

- **Une permission WordPress explicite par ability** (`current_user_can`), la
  plus basse possible.
- **L'écriture ne publie jamais** : statut `draft` forcé dans le code, pas dans
  la doc. La publication sera une ability séparée, explicitement nommée.
- **Pas de création silencieuse** : les catégories inconnues sont signalées
  (`unknown_categories`), jamais créées à la volée.
- **Annotations honnêtes** (`readonly`/`destructive`/`idempotent`) : les agents
  s'en servent pour doser leur prudence.
- `meta.public` + `meta.mcp.public` → découvrable par le mcp-adapter.

## Pièges d'enregistrement (coûtés une soirée)

1. La **catégorie est obligatoire** et se déclare sur SON hook
   (`wp_abilities_api_categories_init`), avant les abilities, avec `label`
   **et** `description` — sinon rejet.
2. Les rejets sont **silencieux quand WP_DEBUG est désactivé** : pour voir les
   messages, écouter `add_action('doing_it_wrong_run', ...)` — le filtre
   `doing_it_wrong_trigger_error` n'est même pas appliqué sans WP_DEBUG.
3. `wp_register_ability` hors du hook `wp_abilities_api_init` → NULL, toujours.

## Adapter à un nouveau site

Renommer le namespace (`audace/` → `<marque>/`), la catégorie et les
descriptions ; étendre ability par ability (médias, mise à jour de brouillon,
design) en gardant les principes ci-dessus. Déployer dans
`wp-content/plugins/`, activer, vérifier avec
`wp eval 'print_r(array_keys(wp_get_abilities()));'`.
