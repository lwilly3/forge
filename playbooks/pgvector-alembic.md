# pgvector + Alembic : le drop fantôme qui détruit les embeddings

> Incident réel (2026-07) : 3 migrations autogénérées ont détruit la colonne
> vectorielle en TEST et provoqué un crash-loop du conteneur (alembic en boucle).

## Le piège

Si une colonne/index (ex. `embedding_vector` + index HNSW) est créée AU
RUNTIME (par du code applicatif) et pas dans l'ORM, **chaque**
`alembic revision --autogenerate` émettra `drop_column` / `drop_index` pour
elle — silencieusement, au milieu d'une migration légitime.

## Les parades (toutes les trois)

1. **Neutraliser** (commenter) les drops dans CHAQUE migration autogénérée,
   avec un commentaire expliquant pourquoi il ne faut JAMAIS les réactiver.
2. **Test-garde** : un test qui grep les migrations à la recherche de lignes
   `op.*` actives touchant les objets runtime — il échoue si quelqu'un oublie.
3. **Reconstruction idempotente** : le code runtime doit savoir recréer la
   colonne/l'index s'ils manquent (et re-vectoriser depuis une forme canonique
   stockée en dur, ex. JSON) — c'est ce qui a permis la récupération sans perte.

## Généralisation

Vaut pour TOUT objet DB hors-ORM : colonnes runtime, index conditionnels,
extensions, vues. L'autogénération Alembic ne connaît que l'ORM.
