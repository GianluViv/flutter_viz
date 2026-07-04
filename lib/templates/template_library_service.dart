import 'dart:convert';
import 'dart:io';

import 'package:vivido/templates/builtin_templates.dart';
import 'package:vivido/templates/page_template.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Local, backend-free store for page templates. Combines the in-code
/// [builtinTemplates] with user templates persisted to
/// `<AppData>/Vivido/templates.json`.
///
/// This is the local replacement for the old remote `category-template-list`
/// REST endpoint; see docs/local-desktop-plan.md and the "local template
/// library" note. Registered as a `get_it` singleton in `main.dart`.
class TemplateLibraryService {
  Directory? _appDataDirectoryOverride;

  Future<Directory> get _appDataDirectory async {
    if (_appDataDirectoryOverride != null) return _appDataDirectoryOverride!;
    final supportDir = await getApplicationSupportDirectory();
    return Directory(p.join(supportDir.path, 'Vivido'));
  }

  /// Redirects storage to a test-controlled folder.
  void setAppDataDirectoryForTesting(Directory directory) {
    _appDataDirectoryOverride = directory;
  }

  Future<File> _storeFile() async {
    final root = await _appDataDirectory;
    if (!await root.exists()) await root.create(recursive: true);
    return File(p.join(root.path, 'templates.json'));
  }

  /// User-saved templates only (most recent first).
  Future<List<PageTemplate>> userTemplates() async {
    final file = await _storeFile();
    if (!await file.exists()) return [];
    try {
      final content = await file.readAsString();
      if (content.trim().isEmpty) return [];
      final List<dynamic> list = json.decode(content) as List<dynamic>;
      return list.map((e) => PageTemplate.fromJson(e as Map<String, dynamic>)).toList().reversed.toList();
    } catch (_) {
      return [];
    }
  }

  /// Built-in templates followed by user templates.
  Future<List<PageTemplate>> allTemplates() async {
    return [...builtinTemplates(), ...await userTemplates()];
  }

  Future<void> saveTemplate({
    required String name,
    required String category,
    required String screenJsonData,
    String? previewImage,
  }) async {
    final file = await _storeFile();
    final existing = await _rawUserList();
    existing.add(PageTemplate(
      id: 'user_${DateTime.now().microsecondsSinceEpoch}',
      category: category.isEmpty ? 'Custom' : category,
      name: name,
      screenJsonData: screenJsonData,
      previewImage: previewImage,
    ).toJson());
    await file.writeAsString(json.encode(existing));
  }

  Future<void> deleteTemplate(String id) async {
    final file = await _storeFile();
    final existing = await _rawUserList();
    existing.removeWhere((e) => e['id'] == id);
    await file.writeAsString(json.encode(existing));
  }

  Future<List<Map<String, dynamic>>> _rawUserList() async {
    final file = await _storeFile();
    if (!await file.exists()) return [];
    try {
      final content = await file.readAsString();
      if (content.trim().isEmpty) return [];
      return (json.decode(content) as List<dynamic>).cast<Map<String, dynamic>>();
    } catch (_) {
      return [];
    }
  }
}
