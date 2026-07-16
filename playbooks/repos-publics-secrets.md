# Hygiène des secrets — leçons d'incidents réels

> Deux incidents vécus (2026-07), zéro dégât grâce à une réaction rapide.
> Ces règles valent même pour les repos PRIVÉS (un privé peut devenir public).

## Incidents fondateurs

1. **Fichier de logs commité** (`api_logs.log*` suivi depuis l'origine d'un
   repo public) : contenait des tokens de test. Parade : `git rm --cached` +
   .gitignore ; la purge d'historique est une décision propriétaire (BFG /
   filter-repo), à évaluer selon la sensibilité réelle.
2. **Token API en clair dans les logs conteneur** : une lib HTTP (httpx)
   loggue les URLs en INFO ; un appel avec le token en paramètre d'URL l'a
   écrit dans `docker logs`. Parade : logger httpx à WARNING, préférer les
   en-têtes Authorization aux query params, RÉVOQUER immédiatement tout token
   exposé (logs, conversation, capture d'écran).

## Règles permanentes

- Secrets UNIQUEMENT en variables d'environnement / gestionnaire dédié ;
  `.env` ignoré par git, `.env.example` commité avec des placeholders.
- Secrets chiffrés au repos en base (Fernet), APIs write-only (« configuré ✓ »).
- Jamais d'IP, port ssh, nom d'hôte interne dans un repo : placeholders.
- Ne jamais AFFICHER un secret dans un terminal/chat : le capturer dans une
  variable shell (`PW=$(ssh … grep …)`) et l'utiliser sans l'imprimer.
- Fichiers verrous Office (`~$*.docx`), logs, dumps → .gitignore d'office.
- Avant tout commit d'un nouveau type de fichier : « que contient-il si je le
  lis comme un attaquant ? »
