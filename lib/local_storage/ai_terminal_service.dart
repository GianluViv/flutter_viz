import 'dart:convert';
import 'dart:io';

import 'package:flutter_pty/flutter_pty.dart';
import 'package:xterm/xterm.dart';

/// Long-lived holder for the embedded "IA" terminal.
///
/// The [AiPanelComponent] widget is rebuilt/recreated every time the user
/// toggles the IA menu, so the PTY (and any running `claude` session) must live
/// *outside* the widget to survive. This singleton keeps one shell per project
/// directory: switching menus and coming back reattaches to the same session;
/// opening a different project spawns a fresh shell and kills the old one.
class AiTerminalService {
  AiTerminalService._();
  static final AiTerminalService instance = AiTerminalService._();

  Terminal? _terminal;
  Pty? _pty;
  String? _dir;

  /// The [Terminal] bound to a live shell running in [directory]. Reuses the
  /// existing session when [directory] is unchanged.
  Terminal terminalFor(String directory) {
    if (_terminal != null && _dir == directory) return _terminal!;

    disposeSession();
    _dir = directory;

    final terminal = Terminal(maxLines: 10000);
    final pty = Pty.start(
      _defaultShell(),
      workingDirectory: directory,
      columns: terminal.viewWidth,
      rows: terminal.viewHeight,
    );

    // PTY output -> terminal (decoded as UTF-8, tolerating partial sequences).
    pty.output
        .cast<List<int>>()
        .transform(const Utf8Decoder(allowMalformed: true))
        .listen(terminal.write);

    pty.exitCode.then((code) {
      terminal.write('\r\n\x1b[90m[shell terminata: $code — riapri il pannello per riavviarla]\x1b[0m\r\n');
      if (identical(_pty, pty)) {
        _pty = null;
        _terminal = null;
        _dir = null;
      }
    });

    // Terminal input -> PTY, and keep the PTY's window size in sync.
    terminal.onOutput = (data) => pty.write(utf8.encode(data));
    terminal.onResize = (w, h, pw, ph) => pty.resize(h, w);

    _terminal = terminal;
    _pty = pty;
    return terminal;
  }

  /// Kills the current shell (if any). Called on project close / dispose.
  void disposeSession() {
    try {
      _pty?.kill();
    } catch (_) {}
    _pty = null;
    _terminal = null;
    _dir = null;
  }

  static String _defaultShell() {
    if (Platform.isWindows) {
      return Platform.environment['COMSPEC'] ?? 'cmd.exe';
    }
    return Platform.environment['SHELL'] ?? '/bin/bash';
  }
}
