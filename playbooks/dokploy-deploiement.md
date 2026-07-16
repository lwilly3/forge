# Déploiement Dokploy/Docker — branches, sondes, diagnostic

> Vérifié 2026-07 sur deux VPS (PROD + TEST), apps compose Dokploy.

## Le contrat de base

- **Branches = environnements** : `develop` → déploiement AUTO du serveur TEST
  (webhook) ; `main` = PROD, JAMAIS de push direct — promotion par merge
  fast-forward develop→main APRÈS validation sur TEST (parité backend comprise).
- Ne pousser sur develop que du code EN ÉTAT D'ÊTRE DÉPLOYÉ (chaque push part
  en TEST dans la minute).
- Migrations appliquées au démarrage du conteneur (`alembic upgrade head` dans
  l'entrypoint) : une migration cassée = crash-loop → voir Diagnostic.

## Sonder un déploiement (sans console Dokploy)

- Commit déployé : le checkout `/etc/dokploy/compose/<app>/code/` est lisible →
  `git log --oneline -1` par ssh.
- Vivacité : sonde HTTP sur un endpoint **nouveau dans la release** (un 401
  sur une route ancienne ne prouve rien — leçon apprise).
- Boucle : `sleep 30` × N en tâche de fond jusqu'à (commit attendu ET code
  HTTP attendu).

## Diagnostic sans sudo

- Logs de BUILD lisibles : `/etc/dokploy/logs/<app>/`.
- Crash-loop détectable par échantillonnage `ps` (le process alembic/uvicorn
  apparaît/disparaît en boucle).
- Inspection DB en LECTURE : tunnel `ssh -f -N -L <port_local>:127.0.0.1:5432
  <alias>` + psql local ; credentials lus depuis le `.env` du compose (souvent
  world-readable sur le serveur) capturés dans une variable shell, JAMAIS
  affichés. Les tunnels meurent : les recréer sur un port neuf au timeout.

## Hygiène

- IP/ports/alias ssh HORS des repos (même privés par défaut) : placeholders
  dans la doc, détails dans ~/.ssh/config et la mémoire d'agent locale.
- Espace disque : nettoyer les artefacts de build après usage.
