# Mémoire d'entreprise (RAG) — ce qui fait la différence en vrai

> Distillé de ~15 itérations de recette réelle (RadioManager v0.90-0.118).
> Chaque mécanisme répond à un ÉCHEC observé, pas à une théorie.

## Architecture minimale qui tient

- Ingestion : documents découpés en chunks, embeddings + **forme canonique
  texte conservée** (permet de re-vectoriser après tout sinistre) ; un
  document par période pour les corpus continus (WhatsApp mensuel), ré-import
  incrémental « remplace si plus riche, sinon saute » (les exports sont
  cumulatifs).
- Recherche HYBRIDE — le vectoriel seul ment : top-k vectoriel (index HNSW)
  + recherche EXACTE (ILIKE) additive + fuzzy (trigrammes, fautes de frappe)
  + garde de fréquence (un terme présent partout ne discrimine rien).
- **Conscience temporelle** : fenêtre extraite de la question (« cette
  semaine », mois, dates) filtrant par date de source. Piège de bordure : les
  documents MENSUELS datés du 1er sortent d'une fenêtre glissante en milieu
  de mois → aligner le début de fenêtre sur le mois.
- **Résolution du demandeur** : « mes messages » → enrichir la requête du nom
  du demandeur ; prioriser les passages où il est AUTEUR (pattern de
  signature) sur ceux où il est mentionné.
- Mode identité : les questions sur l'agent lui-même (« tes outils ? »)
  répondent depuis un MANIFESTE, jamais depuis les passages.

## Boucle qualité (l'agent qui s'améliore)

- Feedback humain 👍/👎 par réponse ; questions ÉTALON rejouées chaque nuit
  (score %, alerte en cas de régression) ; leçons curées (proposées depuis les
  feedbacks négatifs, APPROUVÉES par un humain, plafond bas) injectées dans le
  prompt.
- Prompts de fidélité : relire ligne à ligne avant d'affirmer une absence ;
  restitution VERBATIM sur demande ; ne répondre qu'à la dernière question ;
  comparer toutes les dates pour « le plus récent ».
- Chaque échec de recette → un fix + une question étalon + si besoin un test.

## Voir aussi

pgvector-alembic.md (le piège de migration qui détruit les embeddings).
