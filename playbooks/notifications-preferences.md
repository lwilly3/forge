# Notifications : l'entonnoir unique et ses préférences

> Pattern éprouvé (RadioManager v0.114-115, 2026-07) : 3 canaux, préférences
> par utilisateur, verrous admin — sans toucher aux modules émetteurs.

## Le principe fondateur

UNE fonction `notify(destinataires, message, kind=...)` par laquelle passent
TOUS les modules. Toute politique (préférences, canaux, verrous, quotas)
se résout LÀ — les émetteurs n'en savent rien. Poser cet entonnoir au
premier jour d'un projet coûte 20 lignes ; l'introduire après coûte une
migration de tous les appels.

## Le modèle qui marche

- **Catalogue de types** (`kind` → libellé, description, défauts par canal) ;
  kind inconnu → catégorie « autre » : AUCUNE notification n'échappe au réglage.
- **Préférences éparses** (user × kind × canal → enabled) : on ne stocke que
  les écarts au défaut.
- **Politiques admin** (kind × canal → libre | verrouillé_actif |
  verrouillé_inactif) : le verrou PRIME sur la préférence.
- Résolution : verrou > préférence > défaut — une seule fonction, testée.
- Canaux externes = files en base + tâche planifiée (voir smtp-imap.md) ;
  un nouveau canal = une colonne dans la matrice, rien d'autre.

## UI

Une matrice types × canaux avec interrupteurs ; lignes verrouillées grisées
avec cadenas « défini par l'administration » ; l'admin voit en plus le
sélecteur de verrou par cellule. GET unique renvoyant l'état FUSIONNÉ
(effectif + verrous) : la page se dessine sans logique client.
