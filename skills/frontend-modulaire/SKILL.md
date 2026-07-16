---
name: frontend-modulaire
description: "OBLIGATOIRE pour: créer/étendre un module métier, routes, sidebar, permissions, clients API, hooks. Déclencheurs: module, route, permission, page, hook, settings tab. NE PAS utiliser pour: le pur visuel (ui-design) ni le serveur (backend-api-python)."
---

# Architecture frontend à modules — règles génériques

## Frontières (CRITIQUES)

- Un module importe depuis `shared/*` ; JAMAIS depuis un autre module.
- `shared/` n'importe JAMAIS depuis `modules/`.
- Communication inter-modules : bus d'événements uniquement.
- Enregistrement des modules dans UN fichier de config unique.

## Structure d'un module

`index.ts` (définition), `README.md` (obligatoire), `api/`, `components/`,
`hooks/`, `pages/`, `types/`, `docs/` pour les modules fonctionnels.

## Définition de module — checklist

- `id` stable, `name`, `icon`, `color`, `basePath`, `order`.
- `requiredPermission` OBLIGATOIRE (`<module>_access_section`) — un module
  sans permission d'entrée est visible par TOUS (bug vécu). Créer la clé
  backend correspondante (défaut false).
- Permissions à 4 niveaux : Module → Route → Item de sidebar → Composant.
- `settingsTab` seulement si le module a des paramètres.
- Badge/compteur : attraper les erreurs, retourner 0.

## Couche données

- Clients API dans `api/`, hooks de query dans `hooks/`, mappers explicites
  snake_case (backend) → camelCase (UI).
- Invalider les queries concernées après mutation.
- Erreur backend : relayer le `detail` de l'API dans l'UI plutôt qu'un
  message générique (le backend connaît la vraie cause).

## Documentation

README de module à jour après toute modification (rédaction niveau junior).
Validation : typecheck + build + module visible au lancement.
