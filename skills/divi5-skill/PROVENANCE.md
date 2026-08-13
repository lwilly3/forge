# Provenance — divi5-skill

> Note forge : fichier ajouté par nous, absent du paquet d'origine. Ne pas confondre avec la doc de l'auteur.

- **Origine** : paquet tiers `divi5-skill.skill` (archive ZIP) téléchargé le 2026-08-12.
- **Auteur** : Shashank Gupta — divilove.com (voir frontmatter des fichiers DIVI5-*.md).
- **Version importée** : **v0.7.0** — cible Divi 5.9.x/5.10.x, `builderVersion: "5.10.0"`.
- **Rôle dans la forge** : skill vivant symlinké, adaptateur « connaissance Divi 5 » du projet outillage agents ↔ WordPress (voir mémoire `wordpress-agent-tooling`). Sites Extra actuels NON couverts (builder legacy) — ce skill ne sert que pour des sites/stagings sous thème Divi 5.
- **Deux modes de publication documentés** : plugin tiers Divi Connect (clé API — à auditer avant toute installation sur un site) OU API REST WordPress native (`DIVI5-WORDPRESS.md`) — mode privilégié chez nous car compatible mcp-adapter sans plugin tiers.
- **Mise à jour** : suivre les releases de l'auteur au rythme des versions Divi (v0.6.0 → 5.8, v0.7.0 → 5.9/5.10). En cas de nouvelle version : remplacer les fichiers DIVI5-*.md + SKILL.md, conserver ce PROVENANCE.md, mettre à jour la version ci-dessus, committer.
- **Évaluation (2026-08-12)** : qualité élevée — coverage map distinguant testé-en-rendu vs vérifié-source, process de conception gated (découverte → plan → approbation → build), règles anti-page-blanche explicites.
