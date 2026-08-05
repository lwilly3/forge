# word-report-design — rapports Word soignés avec docx-js (doc junior)

> Premier template de la Forge (règle du second usage remplie le 2026-08-05 :
> exports Word des walkthroughs `pipeline-authentification` et `fonctionnalites-ia`
> de RadioManager). Utilisé par les skills vivants [[explain-diff]] / [[explain-topic]].

## Le besoin d'existence

Générer un `.docx` lisible sans pandoc ni LibreOffice (souvent absents des
machines), avec une mise en page constante : page de garde, sommaire cliquable,
hiérarchie de titres colorée, encadrés « point clé » et « piège », glossaire en
tableau, blocs de code encadrés, tableaux zébrés, en-tête/pied paginé.

## Utilisation

```bash
npm install docx           # dans un dossier de travail (scratchpad)
```

```javascript
const { Packer } = require('docx');
const D = require('./report-design');
// Optionnel : accent aux couleurs du sujet (ex. violet module IA)
Object.assign(D.PAL, { accent: '5B21B6', accent2: '7C3AED' });
const { P, GAP, H1, H2, H3, BULLET, NUM, BREAK, keyBox, noteBox, codeBox,
        figureBox, table, glossary, cover, tocTitle, buildDoc, TableOfContents } = D;

const children = [
  ...cover({ title: 'Mon rapport', subtitle: 'Sous-titre', accent: '5B21B6',
             metaRows: [['Généré par', '`mon-skill`'], ['Date', '2026-08-05']],
             date: 'Généré le 5 août 2026' }),
  tocTitle(), new TableOfContents('Sommaire', { hyperlink: true, headingStyleRange: '1-2' }), BREAK(),
  H1('Section'),
  P('Du texte avec **gras** et `code` inline.'),
  keyBox('★ Si tu ne retiens qu\'une chose', 'Le fait porteur.'),
  codeBox(['ligne 1', 'ligne 2']),
  table(['Col A', 'Col B'], [['a', 'b']], [4677, 4677]),
];
Packer.toBuffer(buildDoc({ headerText: 'Mon en-tête', children }))
  .then(b => require('fs').writeFileSync('rapport.docx', b));
```

## Règles intégrées (issues du skill docx + corrections vécues)

- A4, marges généreuses, Arial 11, interligne 1,15, texte justifié.
- Largeurs de tableaux TOUJOURS en DXA (les pourcentages cassent Google Docs) ;
  somme des `columnWidths` = largeur du tableau ; padding de cellule partout.
- Titres avec `keepNext`/`keepLines` : jamais orphelins en bas de page.
- Petits encadrés et lignes de tableau `cantSplit` : pas de coupure moche.
- Le titre du Sommaire n'est PAS un Heading (sinon il s'auto-liste dans la TOC).
- Puces via la config `numbering` (jamais de « • » manuel).
- Word affichera « Mettre à jour les champs ? » à l'ouverture : normal, c'est la TOC.
- Vérification sans LibreOffice : dézipper et parser les XML (`zipfile` +
  `xml.dom.minidom`) — voir les générateurs d'exemple dans l'historique RadioManager.

## Limites

- Pas de rendu Mermaid : retranscrire les diagrammes en listes pas-à-pas
  (`figureBox` + `NUM('seqN')`) — la version Markdown reste la vue graphique.
- `TableOfContents` exige des Headings natifs (pas de styles custom sur les titres).
