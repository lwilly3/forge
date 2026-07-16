---
name: release-version
description: "OBLIGATOIRE pour: committer, pousser, publier une release frontend/app. Déclencheurs: commit, push, release, version, changelog. NE PAS utiliser pour: le repo backend s'il a son propre cycle."
---

# Release & Versioning — protocole générique

## Protocole

1. **Classifier** le diff : `feat` → MINOR ; `fix` seul → PATCH ; breaking →
   MAJOR ; docs/refactor/chore → pas de bump. Jamais sauter de version.
2. **Si bump** : version dans le manifeste du projet (package.json…) →
   section CHANGELOG.md datée (Ajouté/Corrigé/Technique/Supprimé) → script de
   génération des versions si le projet en a un → tout dans LE MÊME commit.
3. Message : `feat(version): release vX.Y.Z — description courte`
   (`fix(version):` pour un PATCH). Sinon message conventionnel
   (`docs(scope):`, `refactor(scope):`…).

## Branches = environnements (si le projet déploie en continu)

- Branche d'intégration (develop) → déploiement AUTO de l'environnement de
  TEST : ne pousser que du déployable.
- Branche de production (main) : JAMAIS de push direct — merge fast-forward
  depuis develop APRÈS validation sur TEST (parité backend comprise).

## Vérifications finales

- Typecheck/tests verts AVANT le commit de release.
- Manifeste et dernière entrée CHANGELOG cohérents.
- Après push : sonder le déploiement (voir playbook dokploy-deploiement).
