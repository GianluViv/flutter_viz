import 'dart:convert';
import 'dart:io';

import 'package:flutter_viz/local_storage/local_project_service.dart';
import 'package:flutter_viz/local_storage/project.dart';
import 'package:flutter_viz/main.dart';
import 'package:flutter_viz/utils/AppColors.dart';
import 'package:flutter_viz/utils/AppCommon.dart';
import 'package:flutter_viz/utils/AppFunctions.dart';
import 'package:flutter_viz/widgets/screen_json_parser_class.dart';
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
                SelectableText(project.directory.path, style: primaryTextStyle(size: 13)),
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

const String _guideContent = '''
# FlutterViz — istruzioni per l'IA

Questa è la cartella di un progetto **FlutterViz** (UI builder visuale).
Non modificare `project.json`, `media/` o `export/`.

## Cosa modificare

La cartella `ai/` contiene un file JSON per ogni pagina esportata dall'utente
(es. `ai/home_screen.json`). Ogni file è **l'albero dei widget** di quella
pagina, in JSON leggibile. Modifica questi file per cambiare la UI.

Dopo le modifiche l'utente preme «Ricarica dall'IA» dentro l'app per applicarle
all'anteprima. Modifica solo i file in `ai/`.

## Struttura del JSON

Chiavi di primo livello:
- `widgetsData`  → il nodo radice dell'albero dei widget della pagina.
- `appBarData`, `bottomBarNavigationData`, `drawerData` → opzionali (possono
  essere oggetti vuoti se non usati).

Ogni **nodo widget** ha:
- `id`      : stringa **univoca** in tutta la pagina. Non duplicarla; se
             aggiungi un nodo, assegna un nuovo id univoco.
- `type`    : categoria del widget (contenitore o foglia).
- `subType` : tipo specifico (es. `WidgetTypeContainer`, `WidgetTypeText`, …).
- `childData` : lista dei nodi figli (per i contenitori); assente/vuota per le
               foglie.
- altre proprietà specifiche del widget (testo, colori, padding, allineamento…).

## Regole

- Mantieni il JSON valido e la stessa struttura di chiavi.
- Mantieni ogni `id` univoco; per i nuovi nodi usa id nuovi.
- Cambia pure testi, colori, proprietà, e aggiungi/rimuovi/riordina i figli
  dentro `childData`.
- Non rinominare le chiavi di primo livello.
''';
