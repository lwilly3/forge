# EXTRA-MODULES — inventaire des modules et méthode d'apprentissage

> Deux familles : les modules **Posts propres à Extra** (le cœur des layouts de
> une/catégories) et les modules **Divi standard** (le cœur des pages).
> Slugs extraits du code d'Extra 4.27.5 (2026-08-13).

## §1 Modules propres à Extra (9) — pour les layouts

Définis par le thème (`module-posts.php`, `includes/modules.php` ; défauts dans
`includes/modules-defaults.php`) :

| Slug | Rôle |
|---|---|
| `et_pb_posts` | grille/liste d'articles (le module Posts de base) |
| `et_pb_posts_blog_feed_standard` | flux blog présentation standard |
| `et_pb_posts_blog_feed_masonry` | flux blog en maçonnerie (utilisé sur la une pilote) |
| `et_pb_posts_carousel` | carrousel d'articles (×2 sur la une pilote) |
| `et_pb_featured_posts_slider` | slider d'articles à la une |
| `et_pb_tabbed_posts` + `et_pb_tabbed_posts_tab` | articles en onglets (par catégorie) |
| `et_pb_ads` + `et_pb_ads_ad` | emplacements publicitaires |

Traits communs des modules Posts : filtrage par catégories (attention aux noms
exacts, accents compris), nombre d'articles, affichage des métadonnées
(auteur/date/commentaires), et exploitation de la couleur de catégorie
(`has_auto_assign_category_color` dans et_extra).

### Registre des articles déjà affichés

**Validé sur Extra 4.27.5, staging Radio Audace, 2026-08-17.** Les modules
Posts partagent le tableau global `$extra_displayed_post_ids`. Le rendu de la
classe de base dans `includes/modules.php` :

1. initialise le registre lorsqu'il est vide ;
2. le transmet à `post__not_in` quand l'attribut
   `ignore_displayed_posts` est actif ;
3. fusionne les identifiants de la requête du module dans le registre après
   son rendu.

Un composant PHP exécuté après les modules Posts peut donc consulter ce tableau
pour produire un flux complémentaire sans doublons. Sur Radio Audace, un bloc
branché sur `get_footer` a exclu les vingt destinations déjà présentes et
rendu six articles distincts avant le footer.

Limites : ce registre est propre à Extra, dépend de l'ordre de rendu et doit
être revalidé après changement de version ou de thème. Le hook `get_footer`
n'est pertinent que pour un composant transversal ; une modification de la
composition du builder suit toujours le cycle copie-brouillon-bascule.

## §2 Modules Divi standard (~50) — pour les pages

Slugs disponibles (shortcode manager du builder embarqué) — les plus utiles en
refonte :

- **Structure** : `et_pb_section`, `et_pb_row`, `et_pb_column`
  (+ variantes `_inner`), `et_pb_fullwidth_header`, `et_pb_fullwidth_slider`,
  `et_pb_fullwidth_image`, `et_pb_fullwidth_menu`, `et_pb_fullwidth_code`.
- **Contenu** : `et_pb_text`, `et_pb_heading`, `et_pb_image`, `et_pb_button`,
  `et_pb_blurb`, `et_pb_cta`, `et_pb_divider`, `et_pb_icon`, `et_pb_code`,
  `et_pb_gallery`, `et_pb_video`, `et_pb_audio`, `et_pb_testimonial`,
  `et_pb_team_member`.
- **Interactif** : `et_pb_tabs`, `et_pb_toggle`, `et_pb_accordion`,
  `et_pb_contact_form`, `et_pb_signup`, `et_pb_login`, `et_pb_search`,
  `et_pb_menu`, `et_pb_comments`.
- **Données** : `et_pb_blog`, `et_pb_portfolio`, `et_pb_filterable_portfolio`,
  `et_pb_pricing_tables`, `et_pb_number_counter`, `et_pb_circle_counter`,
  `et_pb_countdown_timer`, `et_pb_map` (+`_pin`), `et_pb_sidebar`,
  `et_pb_social_media_follow`, `et_pb_slider`, `et_pb_post_slider`.
- **Post courant** : `et_pb_post_title`, `et_pb_post_content`, `et_pb_post_nav`.

## §3 LA méthode : apprendre par imitation, pas par invention

Les attributs du builder legacy sont nombreux, versionnés et mal documentés.
La stratégie fiable :

1. **Trouver un exemplaire réel** du module sur le site :
   `wp db query "SELECT ID FROM wp_posts WHERE post_content LIKE '%et_pb_posts_carousel%' AND post_status='publish' LIMIT 3"`
   (ou parcourir le corpus d'EXTRA-SITE §5).
2. **Extraire son shortcode complet** (`wp post get <id> --field=post_content`)
   et étudier ses attributs réels.
3. **Copier-adapter** : partir de l'exemplaire, changer contenu/couleurs/
   espacements — ne jamais inventer un nom d'attribut non observé.
4. En l'absence d'exemplaire sur le site : consulter les défauts du module dans
   `includes/modules-defaults.php` (modules Extra) ou créer un spécimen dans le
   Visual Builder sur le staging puis le lire en base — le builder est
   l'oracle de son propre format.

## §4 Correspondances maquette → modules (réflexes de refonte)

| Élément de maquette | Module(s) candidat(s) |
|---|---|
| Hero avec titre + fond image | `et_pb_fullwidth_header` (ou section à fond + `et_pb_heading`) |
| Grille d'articles | `et_pb_posts` / `et_pb_posts_blog_feed_masonry` (layout) ou `et_pb_blog` (page) |
| Carrousel d'actus | `et_pb_posts_carousel` (layout) / `et_pb_post_slider` (page) |
| Bandeau d'appel à l'action | `et_pb_cta` |
| Cartes icône+titre+texte | `et_pb_blurb` (une par carte, 1 colonne chacune) |
| FAQ | `et_pb_accordion` / `et_pb_toggle` |
| Formulaire de contact | `et_pb_contact_form` |
| Bloc HTML/embed spécifique (player radio…) | `et_pb_code` |
