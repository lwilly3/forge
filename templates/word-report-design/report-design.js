/**
 * Bibliothèque de design pour les rapports Word RadioManager (walkthroughs).
 * Design : page de garde, sommaire, hiérarchie colorée, encadrés, tableaux stylés.
 */
const {
  Document, Paragraph, TextRun, Table, TableRow, TableCell,
  AlignmentType, LevelFormat, HeadingLevel, BorderStyle, WidthType,
  ShadingType, PageNumber, Header, Footer, TableOfContents, PageBreak,
} = require('docx');

// Palette par défaut (surchargée par report)
const PAL = {
  accent: '1F4E79',      // bleu foncé — titres H1
  accent2: '2E75B6',     // bleu moyen — H2
  light: 'EAF2F9',       // fond d'encadré info
  keyBg: 'FFF6E5',       // fond « à retenir »
  keyBar: 'E8A33D',      // barre « à retenir »
  codeBg: 'F5F5F5',
  grey: '666666',
  tableHead: 'D5E8F0',
  figureBg: 'F3F7FB',
};

// --- Inline : **gras** et `code` ---
function runs(text, extra = {}) {
  const out = [];
  const re = /(\*\*[^*]+\*\*|`[^`]+`)/g;
  let last = 0, m;
  while ((m = re.exec(text)) !== null) {
    if (m.index > last) out.push(new TextRun({ text: text.slice(last, m.index), ...extra }));
    const tok = m[0];
    if (tok.startsWith('**')) out.push(new TextRun({ text: tok.slice(2, -2), bold: true, ...extra }));
    else out.push(new TextRun({ text: tok.slice(1, -1), font: 'Consolas', size: (extra.size || 22) - 2, color: '9C3D00', ...extra, bold: false }));
    last = m.index + tok.length;
  }
  if (last < text.length) out.push(new TextRun({ text: text.slice(last), ...extra }));
  return out;
}

const SP = { line: 276, after: 160 }; // interligne 1.15

const P = (t, o = {}) => new Paragraph({ children: runs(t), spacing: SP, alignment: AlignmentType.JUSTIFIED, ...o });
/** Respiration après un encadré/tableau quand le bloc suivant est du texte. */
const GAP = () => new Paragraph({ children: [], spacing: { after: 120 } });
const H1 = t => new Paragraph({ heading: HeadingLevel.HEADING_1, children: [new TextRun(t)] });
const H2 = t => new Paragraph({ heading: HeadingLevel.HEADING_2, children: runs(t) });
const H3 = t => new Paragraph({ heading: HeadingLevel.HEADING_3, children: runs(t) });
const BULLET = t => new Paragraph({ numbering: { reference: 'bullets', level: 0 }, children: runs(t), spacing: { line: 276, after: 80 } });
const NUM = ref => t => new Paragraph({ numbering: { reference: ref, level: 0 }, children: runs(t), spacing: { line: 276, after: 60 } });
const BREAK = () => new Paragraph({ children: [new PageBreak()] });

// --- Encadré générique : table 1 cellule, barre gauche épaisse ---
function box(paragraphs, { fill, bar, width = 9354, unbreakable = false }) {
  return new Table({
    width: { size: width, type: WidthType.DXA },
    columnWidths: [width],
    rows: [new TableRow({
      cantSplit: unbreakable,
      children: [new TableCell({
        width: { size: width, type: WidthType.DXA },
        shading: { fill, type: ShadingType.CLEAR },
        borders: {
          left: { style: BorderStyle.SINGLE, size: 24, color: bar },
          top: { style: BorderStyle.SINGLE, size: 1, color: fill },
          bottom: { style: BorderStyle.SINGLE, size: 1, color: fill },
          right: { style: BorderStyle.SINGLE, size: 1, color: fill },
        },
        margins: { top: 140, bottom: 140, left: 220, right: 220 },
        children: paragraphs,
      })],
    })],
  });
}

/** Encadré « Si tu ne retiens qu'une chose » / point clé */
const keyBox = (label, text) => box([
  new Paragraph({ children: [new TextRun({ text: label, bold: true, color: 'B07515', size: 22 })], spacing: { after: 60 } }),
  new Paragraph({ children: runs(text), spacing: { line: 276, after: 0 } }),
], { fill: PAL.keyBg, bar: PAL.keyBar, unbreakable: true });

/** Encadré info/note */
const noteBox = text => box([
  new Paragraph({ children: runs(text), spacing: { line: 276, after: 0 } }),
], { fill: PAL.light, bar: PAL.accent2, unbreakable: true });

/** Bloc de code encadré */
const codeBox = lines => box(
  lines.map((l, i) => new Paragraph({
    children: [new TextRun({ text: l === '' ? ' ' : l, font: 'Consolas', size: 18 })],
    spacing: { after: i === lines.length - 1 ? 0 : 20 },
  })),
  { fill: PAL.codeBg, bar: 'BBBBBB' },
);

/** Figure : légende + contenu (paragraphes) dans un bloc teinté */
const figureBox = (title, caption, paragraphs) => box([
  new Paragraph({ children: [new TextRun({ text: title, bold: true, size: 22, color: PAL.accent })], spacing: { after: 40 } }),
  new Paragraph({ children: runs(caption, { italics: true, size: 20, color: PAL.grey }), spacing: { after: 120 } }),
  ...paragraphs,
], { fill: PAL.figureBg, bar: PAL.accent2 });

// --- Tableau stylé (lignes zébrées) ---
const thin = { style: BorderStyle.SINGLE, size: 1, color: 'CCCCCC' };
const cellBorders = { top: thin, bottom: thin, left: thin, right: thin };
function table(headers, rows, widths) {
  const total = widths.reduce((a, b) => a + b, 0);
  const mk = (txt, { head = false, zebra = false } = {}, w) => new TableCell({
    borders: cellBorders,
    width: { size: w, type: WidthType.DXA },
    shading: head ? { fill: PAL.tableHead, type: ShadingType.CLEAR }
      : zebra ? { fill: 'F7FAFC', type: ShadingType.CLEAR } : undefined,
    margins: { top: 90, bottom: 90, left: 130, right: 130 },
    children: [new Paragraph({ children: runs(txt, head ? { bold: true } : {}), spacing: { after: 0 } })],
  });
  return new Table({
    width: { size: total, type: WidthType.DXA },
    columnWidths: widths,
    rows: [
      new TableRow({ tableHeader: true, cantSplit: true, children: headers.map((h, i) => mk(h, { head: true }, widths[i])) }),
      ...rows.map((r, ri) => new TableRow({ cantSplit: true, children: r.map((v, i) => mk(v, { zebra: ri % 2 === 1 }, widths[i])) })),
    ],
  });
}

/** Tableau de métadonnées (page de garde) : 2 colonnes, sans ligne d'en-tête. */
function metaTable(rows, widths = [2600, 6754]) {
  const total = widths.reduce((a, b) => a + b, 0);
  const line = { style: BorderStyle.SINGLE, size: 1, color: 'E3E3E3' };
  return new Table({
    width: { size: total, type: WidthType.DXA },
    columnWidths: widths,
    rows: rows.map(([k, v]) => new TableRow({
      cantSplit: true,
      children: [
        new TableCell({
          borders: { top: line, bottom: line, left: { style: BorderStyle.NONE }, right: { style: BorderStyle.NONE } },
          width: { size: widths[0], type: WidthType.DXA },
          margins: { top: 90, bottom: 90, left: 0, right: 130 },
          children: [new Paragraph({ children: [new TextRun({ text: k, bold: true, color: PAL.grey, size: 20 })], spacing: { after: 0 } })],
        }),
        new TableCell({
          borders: { top: line, bottom: line, left: { style: BorderStyle.NONE }, right: { style: BorderStyle.NONE } },
          width: { size: widths[1], type: WidthType.DXA },
          margins: { top: 90, bottom: 90, left: 0, right: 0 },
          children: [new Paragraph({ children: runs(v, { size: 20 }), spacing: { after: 0 } })],
        }),
      ],
    })),
  });
}

/** Glossaire : tableau terme → définition */
const glossary = entries => table(['Terme', 'Définition'], entries, [2600, 6754]);

// --- Page de garde ---
function cover({ title, subtitle, metaRows, accent = PAL.accent, date = '' }) {
  return [
    new Paragraph({ spacing: { before: 2200, after: 0 }, children: [] }),
    new Paragraph({
      border: { top: { style: BorderStyle.SINGLE, size: 48, color: accent, space: 10 } },
      children: [new TextRun({ text: title, bold: true, size: 54, color: accent, font: 'Arial' })],
      spacing: { after: 160, line: 300 },
    }),
    new Paragraph({
      border: { bottom: { style: BorderStyle.SINGLE, size: 6, color: 'DDDDDD', space: 10 } },
      children: [new TextRun({ text: subtitle, size: 26, color: PAL.grey })],
      spacing: { after: 900 },
    }),
    metaTable(metaRows),
    ...(date ? [new Paragraph({
      alignment: AlignmentType.RIGHT,
      children: [new TextRun({ text: date, size: 20, color: '999999' })],
      spacing: { before: 700 },
    })] : []),
    BREAK(),
  ];
}

/** Titre de la page Sommaire (hors numérotation TOC — ce n'est pas un Heading). */
const tocTitle = (accent = PAL.accent) => new Paragraph({
  children: [new TextRun({ text: 'Sommaire', bold: true, size: 32, color: accent, font: 'Arial' })],
  border: { bottom: { style: BorderStyle.SINGLE, size: 8, color: PAL.accent2, space: 4 } },
  spacing: { after: 240 },
});

// --- Document complet ---
function buildDoc({ headerText, children, footerText = 'RadioManager' }) {
  return new Document({
    styles: {
      default: { document: { run: { font: 'Arial', size: 22 } } },
      paragraphStyles: [
        { id: 'Heading1', name: 'Heading 1', basedOn: 'Normal', next: 'Normal', quickFormat: true,
          run: { size: 32, bold: true, font: 'Arial', color: PAL.accent },
          paragraph: {
            spacing: { before: 360, after: 200 }, outlineLevel: 0, keepNext: true, keepLines: true,
            border: { bottom: { style: BorderStyle.SINGLE, size: 8, color: PAL.accent2, space: 4 } },
          } },
        { id: 'Heading2', name: 'Heading 2', basedOn: 'Normal', next: 'Normal', quickFormat: true,
          run: { size: 26, bold: true, font: 'Arial', color: PAL.accent2 },
          paragraph: { spacing: { before: 280, after: 140 }, outlineLevel: 1, keepNext: true, keepLines: true } },
        { id: 'Heading3', name: 'Heading 3', basedOn: 'Normal', next: 'Normal', quickFormat: true,
          run: { size: 23, bold: true, font: 'Arial', color: '444444' },
          paragraph: { spacing: { before: 200, after: 120 }, outlineLevel: 2, keepNext: true, keepLines: true } },
      ],
    },
    numbering: {
      config: ['bullets', 'seq1', 'seq2', 'seq3', 'seq4', 'seq5'].map(ref => ({
        reference: ref,
        levels: [{
          level: 0,
          format: ref === 'bullets' ? LevelFormat.BULLET : LevelFormat.DECIMAL,
          text: ref === 'bullets' ? '•' : '%1.',
          alignment: AlignmentType.LEFT,
          style: { paragraph: { indent: { left: 620, hanging: 320 } } },
        }],
      })),
    },
    sections: [{
      properties: { page: { size: { width: 11906, height: 16838 }, margin: { top: 1440, right: 1276, bottom: 1440, left: 1276 } } },
      headers: {
        default: new Header({
          children: [new Paragraph({
            border: { bottom: { style: BorderStyle.SINGLE, size: 4, color: 'DDDDDD', space: 2 } },
            children: [new TextRun({ text: headerText, size: 17, color: '999999' })],
          })],
        }),
      },
      footers: {
        default: new Footer({
          children: [new Paragraph({
            alignment: AlignmentType.CENTER,
            children: [
              new TextRun({ text: `${footerText} · `, size: 17, color: '999999' }),
              new TextRun({ children: ['Page ', PageNumber.CURRENT, ' / ', PageNumber.TOTAL_PAGES], size: 17, color: '999999' }),
            ],
          })],
        }),
      },
      children,
    }],
  });
}

module.exports = {
  PAL, runs, P, GAP, H1, H2, H3, BULLET, NUM, BREAK,
  keyBox, noteBox, codeBox, figureBox, table, glossary, metaTable, cover, tocTitle, buildDoc,
  TableOfContents, Paragraph, TextRun,
};
