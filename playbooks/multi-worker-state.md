# État partagé sous serveur multi-workers (gunicorn/uvicorn)

> Vérifié en production sur FastAPI + gunicorn 4 workers (2026). Source :
> RadioManager, `docs/MULTI_WORKER_STATE.md` + 6 tests de régression.

## Le piège

En production, CHAQUE worker est un processus séparé : tout singleton, cache
ou variable de module existe en N copies aveugles l'une de l'autre. Un réglage
modifié via l'API par le worker 1 reste invisible du worker 2 ; deux workers
peuvent écraser mutuellement un fichier d'état.

## Les quatre règles

1. **Source de vérité = stockage partagé** (PostgreSQL de préférence, sinon
   fichier sur volume) — RELIRE avant chaque lecture/écriture, jamais la
   mémoire seule.
2. **Read-modify-write fichier = verrou exclusif (flock) sur TOUT le cycle**,
   et écriture ATOMIQUE : tmp + `os.replace`. Jamais `open("w")` direct sur un
   fichier partagé (il tronque AVANT d'obtenir le verrou).
3. **Chaque écrivain n'écrit QUE ses champs** (updates ciblés, pas de dump
   complet de l'état qui écraserait les champs des autres).
4. **Boucle de fond = élection de leader par flock** : un seul worker exécute
   le planificateur ; les autres constatent le verrou pris et passent.

## Réflexe de conception

Toute nouvelle fonctionnalité avec de l'état doit répondre à : « que se
passe-t-il si deux workers font ça en même temps ? » — et le scénario de
course devient un test de régression.
