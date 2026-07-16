# La Forge — capital technique privé

> Repo PRIVÉ. Il capitalise le savoir, les mécanismes et le processus agentique
> éprouvés sur les projets livrés (RadioManager Modular en premier), pour que
> chaque nouveau projet démarre avec l'expérience des précédents.

## Les trois actifs (ne pas les mélanger)

| Actif | Dossier | Nature | Cycle de vie |
|---|---|---|---|
| Le SAVOIR | `playbooks/` | pièges, leçons, procédures — du texte daté | vieillit lentement, se re-vérifie à l'usage |
| Le CODE | `templates/` | squelettes clonables | n'entre ici QUE par la règle du second usage |
| Le PROCESSUS | `agents/` + `skills/` | comment les agents IA travaillent | se copie au démarrage de chaque projet |

## Règles de la maison

1. **Règle du second usage** : on n'extrait un template de code que quand un
   DEUXIÈME projet le réclame réellement. Avant : un playbook suffit.
2. **Tout est daté et contextualisé** : chaque playbook porte « vérifié le … sur … ».
   À la réutilisation, on re-vérifie — jamais de confiance aveugle.
3. **Jamais de secret**, même en privé : placeholders et `.env.example` partout.
4. **INDEX.md d'abord** : une ligne par actif ; un agent charge l'index puis
   UNIQUEMENT les fichiers utiles à sa tâche (économie de contexte).
5. La Forge s'applique sa propre gouvernance : une information = un
   propriétaire ; les autres fichiers pointent.

## Démarrer un nouveau projet

1. Cloner le template adapté depuis `templates/` (ou partir de zéro si aucun).
2. Copier `agents/CLAUDE.md.template` → `CLAUDE.md` du projet et l'adapter
   (< 160 lignes, hook de budget inclus).
3. Copier les `skills/` pertinents dans `.claude/skills/` du projet.
4. Lier les playbooks utiles depuis le CLAUDE.md du projet (pointer, pas copier).

## Propriété intellectuelle (services payants)

La Forge est un outillage générique PRÉEXISTANT : au contrat, elle reste la
propriété du prestataire ; seul le code spécifique livré appartient au client.
À écrire noir sur blanc dans chaque devis/contrat.
