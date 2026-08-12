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

## Skills — guide junior + installation : [skills/README.md](skills/README.md)

### Vivants (source de vérité ICI, symlinkés vers ~/.claude/skills via `skills/install.sh`)
- [explain-diff](skills/explain-diff/README.md) — leçon pédagogique sur un diff/branche/PR : contexte → intuition → figures → lecture du code
- [explain-topic](skills/explain-topic/README.md) — leçon pédagogique sur un sujet existant du codebase (sous-système, mécanisme, module)

### Génériques (bases à copier-spécialiser dans chaque projet)
- [release-version](skills/release-version/SKILL.md) — protocole commit/release semver + CHANGELOG
- [backend-api-python](skills/backend-api-python/SKILL.md) — FastAPI/SQLAlchemy/Alembic : venv, imports, migrations, checklist pré-push
- [frontend-modulaire](skills/frontend-modulaire/SKILL.md) — architecture à modules : registre, frontières d'import, permissions à 4 niveaux
- [context-governance](skills/context-governance/SKILL.md) — budget CLAUDE.md, placement de l'information, template de skill
- [ui-design](skills/ui-design/SKILL.md) — grammaire visuelle d'une plateforme opérationnelle

## Agents (processus)
- [cooperation-claude-codex](agents/cooperation-claude-codex.md) — deux agents IA sur le même repo : AGENTS.md, skills pointeurs, hooks partagés, mémoire via git, règles git de survie
- [CLAUDE.md.template](agents/CLAUDE.md.template) — point d'entrée type d'un projet (< 160 lignes)
- [AGENTS.md.template](agents/AGENTS.md.template) — point d'entrée type pour Codex : extraction opérationnelle de CLAUDE.md + section multi-agents
- [memoire-conventions](agents/memoire-conventions.md) — mémoire de session persistante : format, index, synchronisation repo
- [hooks/check-context-budget.sh](agents/hooks/check-context-budget.sh) — le garde-fou automatique du budget de contexte
- [hooks/sync-memory.sh](agents/hooks/sync-memory.sh) — sauvegarde auto de la mémoire agent dans le repo + restauration sur nouvelle machine

## Templates (code)
- [word-report-design](templates/word-report-design/README.md) — rapports Word soignés en docx-js (page de garde, sommaire, encadrés, tableaux zébrés) — né du second usage 2026-08-05 (exports des walkthroughs explain-topic)
