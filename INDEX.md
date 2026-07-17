# INDEX de la Forge — charger ce fichier d'abord, puis seulement l'utile

## Playbooks (savoir)
- [multi-worker-state](playbooks/multi-worker-state.md) — état partagé sous gunicorn multi-workers : DB source de vérité, verrous, élection de leader
- [pgvector-alembic](playbooks/pgvector-alembic.md) — colonnes runtime vs autogénération Alembic : le drop fantôme qui détruit les embeddings
- [meta-whatsapp](playbooks/meta-whatsapp.md) — WhatsApp Cloud API de zéro à opérationnel : webhook, WABA subscribed_apps, fenêtre 24 h, wa_id anciens formats, tokens
- [smtp-imap](playbooks/smtp-imap.md) — canaux e-mail : modes de sécurité par port, filtre des courriers automatiques, pattern file + recette
- [dokploy-deploiement](playbooks/dokploy-deploiement.md) — branches=environnements, sondes de déploiement, tunnels DB lecture seule, diagnostic sans sudo
- [repos-publics-secrets](playbooks/repos-publics-secrets.md) — hygiène des secrets : incidents réels (logs commités, token dans les logs httpx) et parades
- [notifications-preferences](playbooks/notifications-preferences.md) — entonnoir unique notify() : catalogue de types, préférences utilisateur, verrous admin, multi-canaux
- [ged-fondations](playbooks/ged-fondations.md) — GED interne : identité immuable, résolveur unique, corbeille obligatoire, audit append-only, stockage abstrait, revue croisée
- [memoire-ia-rag](playbooks/memoire-ia-rag.md) — pile mémoire d'entreprise : ingestion, recherche hybride, conscience temporelle, boucle qualité de l'agent

## Skills (processus, versions génériques)
- [release-version](skills/release-version/SKILL.md) — protocole commit/release semver + CHANGELOG
- [backend-api-python](skills/backend-api-python/SKILL.md) — FastAPI/SQLAlchemy/Alembic : venv, imports, migrations, checklist pré-push
- [frontend-modulaire](skills/frontend-modulaire/SKILL.md) — architecture à modules : registre, frontières d'import, permissions à 4 niveaux
- [context-governance](skills/context-governance/SKILL.md) — budget CLAUDE.md, placement de l'information, template de skill
- [ui-design](skills/ui-design/SKILL.md) — grammaire visuelle d'une plateforme opérationnelle

## Agents (processus)
- [CLAUDE.md.template](agents/CLAUDE.md.template) — point d'entrée type d'un projet (< 160 lignes)
- [memoire-conventions](agents/memoire-conventions.md) — mémoire de session persistante : format, index, synchronisation repo
- [hooks/check-context-budget.sh](agents/hooks/check-context-budget.sh) — le garde-fou automatique du budget de contexte

## Templates (code)
- (vide — règle du second usage : le premier projet qui réclame un squelette le fait naître ici)
