# Templates — vides par principe

La règle du second usage gouverne ce dossier : un squelette de code n'entre ici
que lorsqu'un DEUXIÈME projet en a réellement besoin — on l'extrait alors du
premier (nettoyé, paramétré, sans secret), on le documente, et on le maintient.

Candidats identifiés (mûrs dans RadioManager Modular, à extraire à la demande) :
- `frontend-modulaire/` — React+TS : registre de modules, eventBus, permissions
  à 4 niveaux, onglets de paramètres, launchpad.
- `backend-fastapi/` — auth JWT+2FA+refresh, entonnoir notify(), canaux
  externes (SMTP/IMAP/WhatsApp), moteur de recettes, discipline Alembic.
- `infra-dokploy/` — Dockerfile, compose, sondes de déploiement, sauvegardes.
