# WhatsApp Cloud API (Meta) — de zéro à opérationnel

> Vérifié le 2026-07-16 sur Graph v20, app Entreprise, numéro camerounais.
> Chaque point ci-dessous a coûté une heure de recette réelle.

## La chaîne complète (dans l'ordre)

1. App Meta (type Entreprise) + produit WhatsApp ; numéro enregistré ; moyen
   de paiement ; vérification de l'entreprise.
2. Webhook : URL + jeton de vérification (poignée de main GET avec
   `hub.challenge`) ; s'abonner au champ **`messages`** sur le produit
   « WhatsApp Business Account » (PAS « User »).
3. **App en mode Live** — en Développement, seuls les tests du tableau de bord
   sont livrés ; AUCUN message réel.
4. ⚠️ **LE piège : l'abonnement du WABA** (`POST /{waba_id}/subscribed_apps`).
   Webhook vérifié + champ abonné + Live NE SUFFISENT PAS : sans cette
   inscription, Meta ne livre RIEN (et le bouton « Test » du dashboard, lui,
   passe — diagnostic trompeur). Interrupteur « S'abonner aux webhooks » par
   compte sur la page Étape 2, ou appel API. Prévoir un bouton produit.
5. Token durable : utilisateur système Business Manager, actifs App **ET**
   compte WhatsApp attribués (sinon token aveugle), permissions
   `whatsapp_business_messaging` + `_management`, expiration Jamais.
   `debug_token` OMET `granular_scopes.target_ids` quand l'accès est « tous
   les actifs » → stocker le WABA ID explicitement, l'introspection n'est
   qu'un fallback.

## Règles d'exploitation

- **Fenêtre 24 h** : texte libre autorisé seulement dans les 24 h suivant le
  dernier message DU destinataire (erreur 131047 sinon → templates approuvés
  pour les envois à froid). Le cas conversationnel (répondre à qui vient
  d'écrire) n'est jamais affecté.
- **wa_id anciens formats** : des comptes WhatsApp gardent le numéro d'avant
  une renumérotation nationale (Cameroun 2014 : 237 77… sans le « 6 »). Le
  rapprochement avec un annuaire doit comparer les 8 derniers chiffres, avec
  garde d'unicité.
- **Signature** : vérifier `X-Hub-Signature-256` (HMAC app secret) sur le corps
  BRUT ; refuser en 403 sans logguer le contenu.
- **Ne jamais mettre le token en paramètre d'URL loggué** : httpx loggue les
  URLs en INFO → token en clair dans les logs conteneur (incident réel ;
  parade : logger httpx à WARNING + révoquer le token exposé).
- **Politique des inconnus** : par défaut, ignorer en silence les numéros hors
  annuaire (ni action, ni réponse — répondre confirme que le numéro est
  actif). Guichet ouvert = choix admin explicite.
