---
name: backend-api-python
description: "OBLIGATOIRE pour: endpoints, modèles SQLAlchemy, schémas Pydantic, migrations Alembic, dépendances Python. Déclencheurs: backend, FastAPI, endpoint, migration, alembic. NE PAS utiliser pour: la consommation de l'API côté frontend."
---

# Backend FastAPI/SQLAlchemy/Alembic — règles génériques

## Environnement

- TOUJOURS le venv du projet (`venv/bin/python`, `venv/bin/alembic`) — jamais
  les binaires globaux.
- Imports internes ABSOLUS avec le préfixe du package (`from app.x import y`) :
  les imports relatifs qui marchent en local crashent dans le conteneur.
- Toute dépendance importée DOIT être dans requirements.txt (manquante =
  crash prod).

## SQLAlchemy — pièges

- `back_populates` explicite des deux côtés (pas `backref`).
- Index préfixés par domaine (`ix_<module>_<table>_<col>`).
- FK croisées : `remote_side=[id]` côté « one » ; FK circulaires : créer les
  tables sans FK puis `add_column`+`create_foreign_key`.
- Pydantic : TOUT nouveau champ exposé doit être ajouté au SCHÉMA de réponse —
  Pydantic filtre silencieusement les champs inconnus (bug invisible côté
  front, vécu).

## Alembic — INTERDICTION de migration manuelle

1. Modifier les modèles + `models/__init__.py`.
2. `alembic revision --autogenerate` puis RELIRE le fichier : ordre des
   tables, index, FK — et NEUTRALISER les drops d'objets runtime (voir
   playbook pgvector-alembic — vaut pour tout objet hors-ORM).
3. `alembic upgrade head` en local AVANT de pousser.
4. Le conteneur applique `upgrade head` au démarrage : une migration cassée =
   crash-loop de l'environnement.

## Multi-worker

Prod = N workers : appliquer le playbook multi-worker-state à toute
fonctionnalité qui a de l'état. Scénario de course → test de régression.

## Tests

- `set -o pipefail` avec tout pipe pytest (sinon `| tail` masque l'échec).
- Tests hermétiques : identifiants uniques (uuid) par exécution, purge des
  tables concernées en fixture autouse — la DB locale accumule les runs.
