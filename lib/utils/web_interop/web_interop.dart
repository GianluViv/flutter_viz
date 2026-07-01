/// Browser-only helpers (context menu suppression, file download via anchor
/// click) isolated behind a conditional export so `dart:html` is never part
/// of the compilation unit on desktop targets (it fails to compile there).
/// See docs/local-desktop-plan.md Fase 1 / Fase 5 for the desktop-native
/// replacements (local file export via file_picker).
library;

export 'web_interop_stub.dart' if (dart.library.html) 'web_interop_web.dart';
