import 'dart:convert';
import 'dart:io';

import 'package:vivido/local_storage/ai_terminal_service.dart';
import 'package:vivido/local_storage/local_project_service.dart';
import 'package:vivido/local_storage/project.dart';
import 'package:vivido/main.dart';
import 'package:vivido/utils/AppColors.dart';
import 'package:vivido/utils/AppCommon.dart';
import 'package:vivido/utils/AppConstant.dart';
import 'package:vivido/utils/AppFunctions.dart';
import 'package:vivido/model/widget_model.dart';
import 'package:vivido/widgets/ai_widget_schema.g.dart';
import 'package:vivido/widgets/screen_json_parser_class.dart';
import 'package:vivido/widgets/widgets.dart';
import 'package:vivido/widgetsProperty/comman_property_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:path/path.dart' as p;
import 'package:xterm/xterm.dart';

/// Left-hand "IA" panel: hands the current screen off to Claude Code as an
/// editable JSON file, then reloads the AI's changes back into the live preview.
///
/// The round-trip is intentionally file-based and one screen at a time:
///  - "Prepara" writes `<project>/ai/<screen>.json` (the widget tree, pretty
///    printed) plus a `<project>/CLAUDE.md` describing the format.
///  - the user runs `claude` in the project folder and edits that JSON.
///  - "Ricarica" reads the file back, applies it to the view and persists it.
///
/// Claude edits a separate file (`ai/…json`), never `project.json`, so the
/// app's 30s autosave never clobbers the AI's work.
class AiPanelComponent extends StatefulWidget {
  @override
  _AiPanelComponentState createState() => _AiPanelComponentState();
}

class _AiPanelComponentState extends State<AiPanelComponent> {
  bool _busy = false;

  String get _currentScreenName => appStore.selectedDropdownScreen?.name ?? 'screen';

  String _screenFileName() => "${getFileName(projectFileName: _currentScreenName)}.json";

  Future<Directory> _aiDir(Project project) async {
    final dir = Directory(p.join(project.directory.path, 'ai'));
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  Future<void> _prepareForAi() async {
    final project = appStore.currentProject;
    if (project == null || _busy) return;
    setState(() => _busy = true);
    try {
      // Serialize the current on-screen widget tree.
      final Map<String, dynamic> data = await widgetClassToJsonData();
      final pretty = const JsonEncoder.withIndent('  ').convert(data);

      final aiDir = await _aiDir(project);
      final file = File(p.join(aiDir.path, _screenFileName()));
      await file.writeAsString(pretty);

      // The catalog is the machine-generated source of truth for every widget
      // the app supports (real subType names + default properties). The AI reads
      // it to add widgets that aren't already on the page.
      final catalogFile = File(p.join(aiDir.path, '_catalog.json'));
      await catalogFile.writeAsString(const JsonEncoder.withIndent('  ').convert(buildWidgetCatalog()));

      await _writeGuide(project);
      await _writeSkill(project);

      getToast("Pronto per l'IA → ${file.path}");
    } catch (e) {
      getToast(e.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _reloadFromAi() async {
    final project = appStore.currentProject;
    final screenId = appStore.selectedScreenId;
    if (project == null || screenId == null || _busy) return;
    setState(() => _busy = true);
    try {
      final file = File(p.join(project.directory.path, 'ai', _screenFileName()));
      if (!await file.exists()) {
        getToast("File non trovato: ${file.path}");
        return;
      }

      // Validate + compact the AI-edited JSON before applying it.
      final decoded = json.decode(await file.readAsString());
      final compact = json.encode(decoded);

      await locator<LocalProjectService>().updateScreenData(project, screenId, screenJsonData: compact);
      appStore.updateScreenNewData(compact, screenId);
      await applyScreenJsonToView(compact);
      LiveStream().emit("updateTreeViewComponents");

      getToast("Anteprima ricaricata");
    } catch (e) {
      getToast("JSON non valido: $e");
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _writeGuide(Project project) async {
    final guide = File(p.join(project.directory.path, 'CLAUDE.md'));
    await guide.writeAsString(_guideContent);
  }

  /// Writes the `vivido-designer` skill into the project's `.claude/skills/`
  /// folder. The embedded terminal runs `claude` in the project directory, so a
  /// project-local skill is discovered automatically. This is the single source
  /// of truth for both the editing protocol and the design guidance; `CLAUDE.md`
  /// (always loaded) is just a short pointer to it.
  Future<void> _writeSkill(Project project) async {
    final skillDir = Directory(p.join(project.directory.path, '.claude', 'skills', 'vivido-designer'));
    if (!await skillDir.exists()) await skillDir.create(recursive: true);
    final skillFile = File(p.join(skillDir.path, 'SKILL.md'));
    await skillFile.writeAsString(_skillContent);
  }

  @override
  Widget build(BuildContext context) {
    return Observer(builder: (_) {
      final project = appStore.currentProject;
      return Container(
        height: context.height(),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(color: context.scaffoldBackgroundColor),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Assistente IA", style: boldTextStyle(size: 18)),
            12.height,
            if (project != null) ...[
              Text("Cartella progetto", style: secondaryTextStyle(size: 12)),
              4.height,
              SelectableText(project.directory.path, style: primaryTextStyle(size: 13), maxLines: 2),
              12.height,
            ],
            ElevatedButton.icon(
              onPressed: (project == null || _busy) ? null : _prepareForAi,
              icon: Icon(Icons.smart_toy_outlined, size: btnIconSize),
              label: Text("Prepara pagina per IA"),
              style: ElevatedButton.styleFrom(backgroundColor: btnBackgroundColor, foregroundColor: Colors.white, minimumSize: Size(double.infinity, 44)),
            ),
            if (_busy) ...[
              8.height,
              LinearProgressIndicator(),
            ],
            12.height,
            // The embedded terminal fills all remaining vertical space between
            // the two buttons. Its shell lives in AiTerminalService, so the
            // session survives menu toggles / widget rebuilds.
            Expanded(
              child: (project == null)
                  ? _terminalPlaceholder(context, "Apri un progetto per usare il terminale.")
                  : _buildTerminal(context, project),
            ),
            12.height,
            OutlinedButton.icon(
              onPressed: (project == null || _busy) ? null : _reloadFromAi,
              icon: Icon(Icons.refresh, size: btnIconSize),
              label: Text("Ricarica da IA"),
              style: OutlinedButton.styleFrom(minimumSize: Size(double.infinity, 44)),
            ),
            8.height,
            Text(
              "Nota: l'IA lavora su un file separato in ai/. «Ricarica da IA» sovrascrive lo stato corrente con la sua versione — evita di modificare la pagina a mano durante la sessione.",
              style: secondaryTextStyle(size: 11),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildTerminal(BuildContext context, Project project) {
    final terminal = AiTerminalService.instance.terminalFor(project.directory.path);
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: context.dividerColor),
      ),
      child: TerminalView(
        terminal,
        padding: EdgeInsets.all(8),
        textStyle: TerminalStyle(fontSize: 13),
        autofocus: false,
      ),
    );
  }

  Widget _terminalPlaceholder(BuildContext context, String message) {
    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: context.dividerColor),
      ),
      child: Text(message, style: secondaryTextStyle()),
    );
  }
}

/// Builds the machine-generated widget catalog written to `ai/_catalog.json`.
///
/// It walks the real palette lists (the same defaults the app instantiates when
/// you drag a widget onto the canvas) so the catalog always matches the code:
/// for every widget it records the exact `subType`, the `type` value to use,
/// whether it can hold children, and the default property object. The AI copies
/// these entries to add widgets that aren't already on the page.
Map<String, dynamic> buildWidgetCatalog() {
  final Map<String, dynamic> catalog = {};

  void addAll(List<WidgetModel> list) {
    for (final WidgetModel m in list) {
      final String? sub = m.widgetSubType;
      if (sub == null || catalog.containsKey(sub)) continue;
      try {
        final dynamic props = getWidgetsClassData(m, isPropertyJsonData: true);
        catalog[sub] = {
          "type": m.widgetType,
          "isContainer": m.widgetType != WidgetTypeNormal,
          // Full list of property keys this widget accepts (from its fromJson).
          // This is the authoritative set of names to use — the default object
          // below only shows the few keys that have a non-null default.
          "properties": kAiWidgetPropertyKeys[sub] ?? const <String>[],
          "defaultProperties": props ?? {},
        };
      } catch (_) {
        // Skip any widget that can't be serialized on its own.
      }
    }
  }

  // Containers first, then leaf widgets.
  addAll(layoutWidgetsList);
  addAll(baseWidgetsList);

  return catalog;
}

const String _guideContent = '''
# Vivido — progetto UI builder

Questa è la cartella di un progetto **Vivido** (UI builder visuale).

Per **creare, modificare o migliorare** le pagine dell'app usa la skill
**`vivido-designer`** (in `.claude/skills/vivido-designer/SKILL.md`):
contiene sia il protocollo tecnico completo (formato dei nodi, catalogo widget,
nomi esatti delle proprietà) sia i principi di design da applicare.

In sintesi, da tenere sempre a mente:
- modifica **solo** i file JSON dentro `ai/`, **sul posto**, senza crearne di
  nuovi né rinominarli;
- leggi **sempre** `ai/_catalog.json` prima di aggiungere o modificare widget;
- non toccare `project.json`, `media/`, `export/`, `ai/_catalog.json`;
- al termine l'utente preme «Ricarica da IA» nell'app per applicare le modifiche.
''';

/// The `vivido-designer` skill. Written verbatim to
/// `<project>/.claude/skills/vivido-designer/SKILL.md` on every "Prepara".
/// Single source of truth: technical editing protocol + design guidance.
const String _skillContent = '''
---
name: vivido-designer
description: Progetta e modifica le pagine di un progetto Vivido editando i file JSON in `ai/`. Usala ogni volta che l'utente chiede di creare, aggiungere, modificare, migliorare o "sistemare" una schermata dell'app. Copre il protocollo tecnico (formato dei nodi, catalogo widget, nomi esatti delle proprietà) e i principi di design (spaziatura, gerarchia, colore, layout).
---

# Vivido — Designer & protocollo di editing

Sei un **UI/UX designer esperto** che lavora dentro **Vivido**, un UI builder
visuale per Flutter. Il tuo compito è modificare l'albero dei widget di una
pagina — salvato come JSON in `ai/<schermata>.json` — per due tipi di richiesta:
- **richieste precise** («cambia il titolo», «aggiungi tre bottoni in colonna»):
  eseguile in modo puntuale, senza stravolgere il resto;
- **richieste aperte** («rendi più bella questa pagina», «sistema il layout»):
  qui agisci da designer, applicando la PARTE 2 di questa skill.

## Flusso di lavoro — leggi i file in quest'ordine

1. **`ai/_catalog.json`** — SEMPRE per primo. È generato dall'app e descrive tutti
   i widget disponibili con i nomi reali. Non fidarti della memoria: i nomi qui
   sono la verità.
2. **`ai/<schermata>.json`** — il file da modificare, **in place**.
3. Applichi le modifiche → l'utente preme «Ricarica da IA» nell'app per vederle.

---

# PARTE 1 — Protocollo tecnico

Regole che, se violate, fanno **sparire silenziosamente** le modifiche.

## File — cosa toccare e cosa no

- Modifica **solo** i JSON dentro `ai/`. Non toccare `project.json`, `media/`,
  `export/`, né `ai/_catalog.json`.
- Modifica **sempre il file già esistente richiesto, sul posto (in place)**.
  - **NON creare nuovi file** (né `.json`, né `.dart`, né copie/varianti come
    `HomeScreen_new.json` o `HomeScreen.modified.json`).
  - **NON rinominare né spostare** il file.
  - L'utente ricarica esattamente quel file: se scrivi altrove, le modifiche
    **non** compaiono nell'anteprima.

## Il catalogo — la fonte di verità

`ai/_catalog.json` descrive **tutti i widget disponibili**. Per ogni widget:
- la chiave = il `subType` reale (es. `Text`, `Row`, `Container`, `TextButton`);
- `type` : il valore da mettere nel campo `type` del nodo;
- `isContainer` : `true` se può avere figli (`childData`);
- `properties` : **l'elenco completo dei nomi di proprietà validi**. Usa **solo**
  questi nomi;
- `defaultProperties` : alcuni valori di default (utile per vedere i formati).

⚠️ I nomi delle proprietà **cambiano da widget a widget** e non sono
indovinabili. Esempi reali di differenze:
- colore del testo: `Text` usa `textColor`, ma `TextField` usa `fontColor`;
- sfondo: `Container` usa `bgColor`, `TextButton` usa `backgroundColor`;
- spessore linea del `Divider`: `dividerThickness` (non `thickness`).
Prima di scrivere una proprietà, **verifica che il nome sia in `properties`**;
se non c'è, viene ignorata.

⚠️ Usa **solo** i `subType` che esistono nel catalogo. Nomi come `WidgetTypeText`,
`Padding` o `ElevatedButton` **non** esistono e vengono ignorati. (Il pulsante è
`TextButton`, non "ElevatedButton".)

## Forma di un nodo widget

```json
{
  "widgetId": "id-univoco",
  "type": "NormalView",          // dal catalogo (foglie = "NormalView")
  "subType": "Text",             // dal catalogo
  "Text": { "text": "Ciao", "fontSize": 14 },  // chiave == subType, proprietà
  "childData": []                // solo se isContainer == true
}
```

Regole del nodo:
- il campo dell'id si chiama **`widgetId`** (non `id`) e deve essere **univoco**
  in tutta la pagina; per un nuovo nodo genera un id nuovo;
- l'oggetto proprietà sta sotto una chiave **uguale al `subType`**;
- `childData` è la lista dei figli: presente solo per i contenitori
  (`isContainer: true`), assente/vuota per le foglie.

## Chiavi di primo livello del file

- `widgetsData`  → nodo radice dell'albero (di solito un contenitore);
- `scaffoldData` → proprietà dello Scaffold (sfondo, safeArea, scroll);
- `appBarData`, `bottomBarNavigationData`, `drawerData` → slot opzionali
  (oggetti vuoti `{}` se non usati). Non rinominarle.

## Formati dei valori (vedi `defaultProperties` nel catalogo)

- colori: stringa `#AARRGGBB` (8 cifre hex, alpha inclusa) — es. `#ff3a57e8`;
- padding / margin / border radius: oggetto
  `{ "left":0, "top":0, "right":0, "bottom":0 }`;
- peso del font: campo **`fWeight`** con valori tipo `"400 - Normal"`,
  `"700 - Bold"` (non `"bold"`);
- allineamenti: stringhe enum **capitalizzate** (es.
  `textAlign: "Left"|"Center"|"Right"`, `mainAxisAlignment: "Center"`,
  `crossAxisAlignment: "Stretch"`).

---

# PARTE 2 — Design (l'occhio da esperto)

Quando la richiesta riguarda l'aspetto, non limitarti a "far funzionare" il JSON:
applica questi principi. L'obiettivo è una UI **pulita, coerente, gerarchica**,
in linea con **Material Design**.

## Spaziatura — la cosa che fa la differenza

- Usa una **scala coerente**: 4, 8, 12, 16, 24, 32. Niente valori a caso (13, 17…).
- Margine esterno della pagina/contenuto: **16–24**.
- Spazio tra elementi **correlati**: 8. Tra **gruppi** distinti: 24.
- Preferisci `padding` sui contenitori a spinte manuali. Il respiro (whitespace)
  è design: meglio meno elementi ben distanziati che tutto ammassato.

## Gerarchia tipografica

Massimo 2–3 livelli, distinti per **dimensione + peso**, non per colore:
- Titolo pagina/sezione: ~22–28, `fWeight` `"700 - Bold"`;
- Sottotitolo: ~16–18, `"500 - Medium"`/`"600 - SemiBold"`;
- Corpo: ~14, `"400 - Normal"`;
- Caption/etichette secondarie: ~12, colore più tenue.
Non usare 5 dimensioni diverse: crea rumore, non gerarchia.

## Colore

- **Un solo colore d'accento** (brand) + neutri (bianco/grigi/quasi-nero).
  Massimo 2–3 colori saturi in tutta la pagina.
- L'accento serve alle **azioni primarie** e a pochi elementi chiave, non a tutto.
- **Contrasto**: testo scuro su sfondo chiaro (o viceversa). Evita grigio chiaro
  su bianco per testo importante. Punta a un contrasto AA (≈4.5:1 sul corpo).
- Coerenza chiaro/scuro: se lo sfondo è scuro, adegua tutti i testi.
- Ricorda il formato `#AARRGGBB` e tieni l'alpha `ff` per i colori pieni.

## Layout e composizione

- **Allineamento**: scegli un bordo e sii coerente. Per testo/contenuto, di
  default `crossAxisAlignment: "Start"`; centra solo scelte deliberate (hero, empty
  state).
- **Prossimità**: ciò che è correlato sta vicino; separa i gruppi con più spazio,
  non con bordi ovunque.
- `mainAxisAlignment` per **distribuire** i figli (`"SpaceBetween"` per una barra
  con estremi opposti, `"Center"` per centrare un gruppo).
- Larghezza piena vs. contenuto: usa `Expanded`/`crossAxisAlignment: "Stretch"`
  per bottoni/campi a tutta larghezza dove ha senso.
- Non annidare contenitori inutili: ogni livello deve avere uno scopo.

## Componenti — convenzioni Material

- **Bottoni**: azione primaria piena (accento), secondaria outlined/testo. Un
  solo primario per vista. Angoli e altezza coerenti tra loro.
- **Card/superfici**: `borderRadius` coerente (tipicamente 8–12), ombre/elevazioni
  **leggere**, padding interno ≥ 16.
- **Liste/griglie**: spaziatura uniforme tra gli item, allineamento costante.
- **Touch target**: elementi interattivi ampi abbastanza (≈44–48 di altezza).
- **Icone**: dimensione coerente, allineate al testo che accompagnano.

## Metodo di lavoro sul design

1. Individua la **gerarchia**: cos'è primario, secondario, terziario?
2. Sistema prima **struttura e spaziatura**, poi tipografia, poi colore, infine
   i dettagli.
3. **Riusa** valori già presenti nella pagina (stessi padding, stesso accento):
   la coerenza vale più della varietà.
4. Fai modifiche **mirate e motivabili**; non riscrivere tutto l'albero se la
   richiesta è locale.

---

# Regole finali

- Modifica **solo il file richiesto, in place** — non creare altri file.
- Mantieni il JSON valido e non rinominare le chiavi di primo livello.
- Usa esattamente le chiavi di proprietà presenti in `properties`/`defaultProperties`.
- Puoi cambiare testi/colori/proprietà e aggiungere/rimuovere/riordinare i figli
  dentro `childData`.
- Alla fine, riepiloga brevemente all'utente cosa hai cambiato e perché (in ottica
  di design), così può decidere se «Ricaricare da IA».
''';
