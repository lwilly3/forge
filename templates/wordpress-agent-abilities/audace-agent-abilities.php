<?php
/**
 * Plugin Name:       Audace Agent Abilities
 * Description:       Vocabulaire métier exposé aux agents IA via l'Abilities API et le MCP Adapter. v0.1 : état du site, articles récents, création de brouillons (jamais de publication directe).
 * Version:           0.1.0
 * Requires at least: 6.9
 * Requires PHP:      7.4
 * Author:            Audace Media Group
 *
 * Principe de sécurité : chaque ability déclare la permission WordPress minimale
 * nécessaire, et l'écriture est limitée aux brouillons — la publication reste
 * un geste humain (ou une ability future, explicitement séparée).
 */

if ( ! defined( 'ABSPATH' ) ) {
	exit;
}

/*
 * La catégorie DOIT être déclarée sur son propre hook, avant les abilities,
 * et exige label ET description — sinon rejet silencieux (visible uniquement
 * via l'action doing_it_wrong_run quand WP_DEBUG est désactivé).
 */
add_action(
	'wp_abilities_api_categories_init',
	static function () {
		if ( ! function_exists( 'wp_register_ability_category' ) ) {
			return;
		}
		wp_register_ability_category(
			'audace',
			array(
				'label'       => 'Audace',
				'description' => 'Capacités métier exposées aux agents IA des sites Audace Media Group.',
			)
		);
	}
);

add_action(
	'wp_abilities_api_init',
	static function () {

		if ( ! function_exists( 'wp_register_ability' ) ) {
			return; // Abilities API absente (WP < 6.9) : ne rien exposer.
		}

		/* ------------------------------------------------------------------ */
		/* audace/site-info — photographie de l'installation (lecture seule)  */
		/* ------------------------------------------------------------------ */
		wp_register_ability(
			'audace/site-info',
			array(
				'label'       => 'État du site',
				'category'    => 'audace',
				'description' => 'Photographie du site WordPress : nom, URL, versions, thème, extensions actives, volumétrie, et indicateur de pré-production. À appeler en premier pour connaître le terrain.',
				'output_schema' => array(
					'type'       => 'object',
					'properties' => array(
						'name'           => array( 'type' => 'string' ),
						'url'            => array( 'type' => 'string' ),
						'wp_version'     => array( 'type' => 'string' ),
						'theme'          => array( 'type' => 'string' ),
						'theme_version'  => array( 'type' => 'string' ),
						'active_plugins' => array( 'type' => 'array', 'items' => array( 'type' => 'string' ) ),
						'post_count'     => array( 'type' => 'integer' ),
						'page_count'     => array( 'type' => 'integer' ),
						'is_staging'     => array( 'type' => 'boolean' ),
					),
				),
				'permission_callback' => static function ( $input = array() ) {
					return current_user_can( 'manage_options' );
				},
				'execute_callback' => static function ( $input = array() ) {
					$theme = wp_get_theme();
					$plugins = array();
					foreach ( (array) get_option( 'active_plugins', array() ) as $p ) {
						$plugins[] = dirname( $p ) !== '.' ? dirname( $p ) : basename( $p, '.php' );
					}
					return array(
						'name'           => get_bloginfo( 'name' ),
						'url'            => home_url(),
						'wp_version'     => get_bloginfo( 'version' ),
						'theme'          => $theme->get( 'Name' ),
						'theme_version'  => $theme->get( 'Version' ),
						'active_plugins' => $plugins,
						'post_count'     => (int) wp_count_posts( 'post' )->publish,
						'page_count'     => (int) wp_count_posts( 'page' )->publish,
						'is_staging'     => file_exists( WPMU_PLUGIN_DIR . '/staging-guard.php' ),
					);
				},
				'meta' => array(
					'public'      => true,
					'mcp'         => array( 'public' => true ),
					'annotations' => array(
						'readonly'    => true,
						'destructive' => false,
						'idempotent'  => true,
					),
				),
			)
		);

		/* ------------------------------------------------------------------ */
		/* audace/list-recent-posts — derniers articles (lecture seule)       */
		/* ------------------------------------------------------------------ */
		wp_register_ability(
			'audace/list-recent-posts',
			array(
				'label'       => 'Articles récents',
				'category'    => 'audace',
				'description' => 'Liste les derniers articles avec id, titre, statut, date, lien et catégories. Par défaut les 5 derniers publiés ; peut lister les brouillons.',
				'input_schema' => array(
					'type'       => 'object',
					'properties' => array(
						'count'  => array(
							'type'    => 'integer',
							'minimum' => 1,
							'maximum' => 20,
							'default' => 5,
						),
						'status' => array(
							'type'    => 'string',
							'enum'    => array( 'publish', 'draft', 'any' ),
							'default' => 'publish',
						),
					),
					'additionalProperties' => false,
				),
				'output_schema' => array(
					'type'       => 'object',
					'properties' => array(
						'posts' => array(
							'type'  => 'array',
							'items' => array(
								'type'       => 'object',
								'properties' => array(
									'id'         => array( 'type' => 'integer' ),
									'title'      => array( 'type' => 'string' ),
									'status'     => array( 'type' => 'string' ),
									'date'       => array( 'type' => 'string' ),
									'link'       => array( 'type' => 'string' ),
									'categories' => array( 'type' => 'array', 'items' => array( 'type' => 'string' ) ),
								),
							),
						),
					),
				),
				'permission_callback' => static function ( $input = array() ) {
					return current_user_can( 'edit_posts' );
				},
				'execute_callback' => static function ( $input = array() ) {
					$count  = isset( $input['count'] ) ? min( 20, max( 1, (int) $input['count'] ) ) : 5;
					$status = isset( $input['status'] ) ? $input['status'] : 'publish';
					$posts  = get_posts(
						array(
							'numberposts' => $count,
							'post_type'   => 'post',
							'post_status' => 'any' === $status ? array( 'publish', 'draft' ) : $status,
						)
					);
					$out = array();
					foreach ( $posts as $p ) {
						$cats = array();
						foreach ( (array) get_the_category( $p->ID ) as $c ) {
							$cats[] = $c->name;
						}
						$out[] = array(
							'id'         => $p->ID,
							'title'      => get_the_title( $p ),
							'status'     => $p->post_status,
							'date'       => get_the_date( 'Y-m-d H:i', $p ),
							'link'       => get_permalink( $p ),
							'categories' => $cats,
						);
					}
					return array( 'posts' => $out );
				},
				'meta' => array(
					'public'      => true,
					'mcp'         => array( 'public' => true ),
					'annotations' => array(
						'readonly'    => true,
						'destructive' => false,
						'idempotent'  => true,
					),
				),
			)
		);

		/* ------------------------------------------------------------------ */
		/* audace/create-draft — créer un brouillon (SEULE ability d'écriture)*/
		/* ------------------------------------------------------------------ */
		wp_register_ability(
			'audace/create-draft',
			array(
				'label'       => 'Créer un brouillon',
				'category'    => 'audace',
				'description' => 'Crée un article en BROUILLON (jamais publié : le statut draft est forcé quoi qu\'il arrive). Catégories : noms existants uniquement, les inconnus sont ignorés et signalés. Retourne l\'id et les liens d\'édition/aperçu.',
				'input_schema' => array(
					'type'       => 'object',
					'properties' => array(
						'title'      => array( 'type' => 'string', 'minLength' => 3 ),
						'content'    => array(
							'type'        => 'string',
							'description' => 'Corps de l\'article en HTML.',
						),
						'excerpt'    => array( 'type' => 'string' ),
						'categories' => array(
							'type'        => 'array',
							'items'       => array( 'type' => 'string' ),
							'description' => 'Noms de catégories EXISTANTES.',
						),
					),
					'required'             => array( 'title', 'content' ),
					'additionalProperties' => false,
				),
				'output_schema' => array(
					'type'       => 'object',
					'properties' => array(
						'id'                 => array( 'type' => 'integer' ),
						'status'             => array( 'type' => 'string' ),
						'edit_link'          => array( 'type' => 'string' ),
						'preview_link'       => array( 'type' => 'string' ),
						'unknown_categories' => array( 'type' => 'array', 'items' => array( 'type' => 'string' ) ),
					),
				),
				'permission_callback' => static function ( $input = array() ) {
					return current_user_can( 'edit_posts' );
				},
				'execute_callback' => static function ( $input = array() ) {
					$cat_ids = array();
					$unknown = array();
					if ( ! empty( $input['categories'] ) ) {
						foreach ( (array) $input['categories'] as $name ) {
							$term = get_term_by( 'name', $name, 'category' );
							if ( $term ) {
								$cat_ids[] = (int) $term->term_id;
							} else {
								$unknown[] = $name;
							}
						}
					}
					$id = wp_insert_post(
						array(
							'post_type'     => 'post',
							'post_status'   => 'draft', // Forcé : cette ability ne publie JAMAIS.
							'post_title'    => sanitize_text_field( $input['title'] ),
							'post_content'  => wp_kses_post( $input['content'] ),
							'post_excerpt'  => isset( $input['excerpt'] ) ? sanitize_text_field( $input['excerpt'] ) : '',
							'post_category' => $cat_ids,
						),
						true
					);
					if ( is_wp_error( $id ) ) {
						return $id;
					}
					return array(
						'id'                 => $id,
						'status'             => get_post_status( $id ),
						'edit_link'          => get_edit_post_link( $id, 'raw' ),
						'preview_link'       => get_preview_post_link( $id ),
						'unknown_categories' => $unknown,
					);
				},
				'meta' => array(
					'public'      => true,
					'mcp'         => array( 'public' => true ),
					'annotations' => array(
						'readonly'    => false,
						'destructive' => false, // Crée sans rien écraser.
						'idempotent'  => false,
					),
				),
			)
		);
	}
);
