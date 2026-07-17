# GED interne — les fondations qui tiennent

> Distillé du module Documents de RadioManager (2026-07-17), conçu par spec
> validée + revue croisée (2 IA) + tri humain. Vérifié par tests hors réseau.

## Les 7 décisions structurelles

1. **Identité immuable** : l'id du document ne change JAMAIS (renommer/
   déplacer = affichage). Toutes les références inter-modules et l'indexation
   IA pointent l'id — rien ne casse jamais.
2. **Résolveur d'accès UNIQUE** : un seul module de code décide de tout
   (liste, fiche, binaire) ; rôles hiérarchiques calqués sur des VERBES
   (lecture < écriture < suppression < destruction) ; droits POSITIFS
   uniquement (pas de deny) — le sensible va dans une bibliothèque séparée.
3. **Accès automatiques EXPLICITES** par l'annuaire : affectation active →
   rôle ; par TYPE de relation (employé oui, consultant non) ; fin de
   relation = coupure immédiate. Ne jamais écrire « membre = accès » sans
   dire quel type de membre.
4. **DELETE = corbeille, TOUJOURS** ; destruction réelle = rôle maximal,
   depuis la corbeille, trace indélébile ; rétention paramétrable PAR espace,
   purge par recette nocturne.
5. **Stockage derrière une interface** (put/get/delete/exists) + sha256 par
   version : le backend (Drive/S3) est un détail remplaçable ; « fsck »
   nocturne (chaque version existe-t-elle ?).
6. **Audit append-only y compris view/download** (item_id SANS FK : le
   journal survit à la purge) — c'est ce que le stockage cloud seul ne donne
   jamais.
7. **Partage inter-modules par INSTANTANÉ COPIÉ, pas par binaire partagé**
   (provenance conservée) : le refcounting inter-modules est une usine à
   bugs de cycle de vie.

## Sécurité des dépôts (minimum vital sans antivirus)

Inline = liste blanche par SIGNATURE serveur (jamais le MIME client) ;
HTML/SVG jamais inline (script stocké) → attachment + nosniff ; noms
assainis ; course d'écriture = contrainte unique + suppression COMPENSATOIRE
du binaire déjà envoyé (aucun orphelin).

## Le processus qui a produit ça

Spec écrite → validée par l'owner (questions fermées) → contre-expertise par
2 IA tierces → TRI (déjà-fait / retenu / différé-daté / rejeté-argumenté) →
correctifs testés. À rejouer sur tout gros chantier.
