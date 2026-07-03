import 'dart:convert';
import 'dart:io';

import 'package:flutter_viz/local_storage/local_project_service.dart';
import 'package:flutter_viz/local_storage/project.dart';
import 'package:flutter_viz/main.dart';
import 'package:flutter_viz/utils/AppColors.dart';
import 'package:flutter_viz/utils/AppCommon.dart';
import 'package:flutter_viz/utils/AppConstant.dart';
import 'package:flutter_viz/utils/AppFunctions.dart';
import 'package:flutter_viz/model/widget_model.dart';
import 'package:flutter_viz/widgets/ai_widget_schema.g.dart';
import 'package:flutter_viz/widgets/screen_json_parser_class.dart';
import 'package:flutter_viz/widgets/widgets.dart';
import 'package:flutter_viz/widgetsProperty/comman_property_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:path/path.dart' as p;

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

  /// Opens the OS terminal in [path]. Tries a few emulators per platform and
  /// stops at the first that launches, so the app doesn't need to know which
  /// terminal the user has installed.
  Future<void> _openTerminalHere(String path) async {
    final List<List<String>> candidates;
    if (Platform.isWindows) {
      candidates = [
        ['wt.exe', '-d', path], // Windows Terminal, if installed
        ['cmd.exe', '/c', 'start', 'cmd.exe'], // fallback: classic console
      ];
    } else if (Platform.isMacOS) {
      candidates = [
        ['open', '-a', 'Terminal', path],
      ];
    } else {
      candidates = [
        ['x-terminal-emulator'],
        ['gnome-terminal'],
        ['konsole'],
        ['xfce4-terminal'],
        ['xterm'],
      ];
    }

    for (final cmd in candidates) {
      try {
        await Process.start(
          cmd.first,
          cmd.sublist(1),
          workingDirectory: path,
          mode: ProcessStartMode.detached,
        );
        return;
      } catch (_) {
        // Try the next candidate.
      }
    }
    getToast("Nessun terminale disponibile su questo sistema");
  }

  @override
  Widget build(BuildContext context) {
    return Observer(builder: (_) {
      final project = appStore.currentProject;
      return Container(
        height: context.height(),
        decoration: BoxDecoration(color: context.scaffoldBackgroundColor),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Assistente IA", style: boldTextStyle(size: 18)),
              8.height,
              Text(
                "Modifica la pagina corrente con Claude Code, poi ricarica l'anteprima.",
                style: secondaryTextStyle(),
              ),
              16.height,
              _stepText("1", "Apri un terminale nella cartella del progetto e lancia  claude"),
              _stepText("2", "«Prepara pagina per l'IA»: esporta la pagina in  ai/${_screenFileName()}  e scrive un CLAUDE.md con lo schema."),
              _stepText("3", "Chiedi a Claude di modificare quel file JSON."),
              _stepText("4", "«Ricarica dall'IA»: rilegge il file e aggiorna l'anteprima."),
              16.height,
              if (project != null) ...[
                Text("Cartella progetto", style: secondaryTextStyle(size: 12)),
                4.height,
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(child: SelectableText(project.directory.path, style: primaryTextStyle(size: 13))),
                    8.width,
                    OutlinedButton.icon(
                      onPressed: () => _openTerminalHere(project.directory.path),
                      icon: Icon(Icons.terminal, size: btnIconSize),
                      label: Text("Apri terminale qui"),
                    ),
                  ],
                ),
                16.height,
              ],
              ElevatedButton.icon(
                onPressed: (project == null || _busy) ? null : _prepareForAi,
                icon: Icon(Icons.upload_file, size: btnIconSize),
                label: Text("Prepara pagina per l'IA"),
                style: ElevatedButton.styleFrom(backgroundColor: btnBackgroundColor, foregroundColor: Colors.white, minimumSize: Size(double.infinity, 44)),
              ),
              12.height,
              OutlinedButton.icon(
                onPressed: (project == null || _busy) ? null : _reloadFromAi,
                icon: Icon(Icons.refresh, size: btnIconSize),
                label: Text("Ricarica dall'IA"),
                style: OutlinedButton.styleFrom(minimumSize: Size(double.infinity, 44)),
              ),
              16.height,
              if (_busy) LinearProgressIndicator(),
              16.height,
              Text(
                "Nota: durante la sessione IA evita di modificare la pagina qui dentro — l'IA lavora su un file separato e «Ricarica» sovrascrive lo stato corrente con la sua versione.",
                style: secondaryTextStyle(size: 12),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _stepText(String n, String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("$n. ", style: boldTextStyle()),
          Expanded(child: Text(text, style: primaryTextStyle(size: 13))),
        ],
      ),
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
# FlutterViz — istruzioni per l'IA

Questa è la cartella di un progetto **FlutterViz** (UI builder visuale).
Modifica **solo** i file JSON dentro `ai/`. Non toccare `project.json`,
`media/`, `export/` né il file `ai/_catalog.json`.

## Cosa modificare

`ai/` contiene un file JSON per ogni pagina esportata (es. `ai/HomeScreen.json`).
Ogni file è **l'albero dei widget** di quella pagina. Dopo le modifiche l'utente
preme «Ricarica dall'IA» nell'app per applicarle.

## Il catalogo — leggilo SEMPRE per primo

`ai/_catalog.json` è generato dall'app e descrive **tutti i widget disponibili**.
È la fonte di verità: se l'utente chiede widget non presenti in pagina (es.
«aggiungi tre pulsanti in verticale»), prendi da qui il `subType` corretto e le
proprietà. Per ogni widget il catalogo indica:
- la chiave = il `subType` reale (es. `Text`, `Row`, `Container`, `TextButton`);
- `type` : il valore da mettere nel campo `type` del nodo;
- `isContainer` : `true` se può avere figli (`childData`);
- `properties` : **l'elenco completo dei nomi di proprietà validi** per quel
  widget. Usa **solo** questi nomi.
- `defaultProperties` : alcuni valori di default (utile per vedere i formati).

⚠️ I nomi delle proprietà **cambiano da widget a widget** e non sono
indovinabili. Esempi reali di differenze:
- colore del testo: `Text` usa `textColor`, ma `TextField` usa `fontColor`;
- sfondo: `Container` usa `bgColor`, `TextButton` usa `backgroundColor`;
- spessore linea del `Divider`: `dividerThickness` (non `thickness`).
Prima di scrivere una proprietà, **controlla che il nome sia in `properties`**;
se non c'è, viene ignorata.

⚠️ Usa **solo** i `subType` che esistono nel catalogo. Nomi come
`WidgetTypeText`, `Padding` o `ElevatedButton` **non** esistono e vengono
ignorati. (Il pulsante è `TextButton`, non "ElevatedButton".)

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
  in tutta la pagina; per un nuovo nodo genera un id nuovo.
- l'oggetto proprietà sta sotto una chiave **uguale al `subType`**.
- `childData` è la lista dei figli: presente solo per i contenitori
  (`isContainer: true`), assente/vuota per le foglie.

## Chiavi di primo livello del file

- `widgetsData`  → nodo radice dell'albero (di solito un contenitore).
- `scaffoldData` → proprietà dello Scaffold (sfondo, safeArea, scroll).
- `appBarData`, `bottomBarNavigationData`, `drawerData` → slot opzionali
  (oggetti vuoti `{}` se non usati). Non rinominarle.

## Formati dei valori (vedi `defaultProperties` nel catalogo)

- colori: stringa `#AARRGGBB` (8 cifre hex, alpha inclusa) — es. `#ff3a57e8`.
- padding / margin / border radius: oggetto `{ "left":0, "top":0, "right":0, "bottom":0 }`.
- peso del font: campo **`fWeight`** con valori tipo `"400 - Normal"`, `"700 - Bold"`
  (non `"bold"`).
- allineamenti: stringhe enum **capitalizzate** (es. `textAlign: "Left"|"Center"|"Right"`,
  `mainAxisAlignment: "Center"`, `crossAxisAlignment: "Stretch"`).

## Regole finali

- Mantieni il JSON valido e non rinominare le chiavi di primo livello.
- Per ogni proprietà usa esattamente le chiavi che vedi in `defaultProperties`.
- Puoi cambiare testi/colori/proprietà e aggiungere/rimuovere/riordinare i figli
  dentro `childData`.
''';
