import 'package:flutter/widgets.dart' show FocusScopeNode;

/// No-op outside the browser.

void suppressBrowserContextMenu() {}

void downloadTextFileInBrowser(List<String> lines, String fileName) {}

void downloadUrlInBrowser(String? url, String fileName) {}

void addTabKeyListener(FocusScopeNode node) {}
