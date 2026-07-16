# Canaux e-mail (SMTP sortant, IMAP entrant)

> Vérifié 2026-07 sur un hébergement cPanel (mail.<domaine>) + Gmail.

## SMTP — les modes de sécurité par port

| Port | Mode | Implémentation |
|---|---|---|
| 465 | TLS IMPLICITE (SMTPS) | `SMTP_SSL` dès la connexion |
| 587 | STARTTLS | session claire puis upgrade |
| 25  | clair/STARTTLS | éviter (souvent bloqué) |

Confondre 465 et STARTTLS donne « Connection unexpectedly closed: timed out ».
Laisser l'admin CHOISIR le mode (auto par port + override) : chaque hébergeur
a ses manies.

## Entrant (IMAP → objets applicatifs)

- Boîte DÉDIÉE à l'usage (jamais une boîte personnelle).
- **Filtrer les courriers automatiques** avant de créer quoi que ce soit :
  en-têtes `Auto-Submitted`, `Precedence: bulk/auto_reply`, expéditeurs
  mailer-daemon/postmaster/no-reply*, objets « mail delivery », « out of
  office »… Sinon les bounces deviennent des objets métier (incident réel).
- Déduplication par Message-ID dans un journal d'ingestion (unique constraint).
- Pièces jointes : liste blanche de content-types + taille max + stockage
  externe (Drive/S3) — jamais en base.

## Pattern d'envoi : file + recette

JAMAIS d'envoi SMTP dans le chemin d'une requête HTTP : `notify()` enqueue en
base (`status=pending`, tentatives, last_error), une tâche planifiée envoie
par lots (N/tour, M tentatives puis `failed` visible). Résiste aux pannes du
serveur mail et aux redémarrages.

## Secrets

Mots de passe chiffrés au repos (Fernet), API write-only (« configuré ✓ » sans
jamais renvoyer la valeur), champ vide = conserver.
