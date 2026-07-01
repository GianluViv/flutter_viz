import 'dart:html' as html;

import 'package:flutter/widgets.dart' show FocusScopeNode;

void suppressBrowserContextMenu() {
  html.document.onContextMenu.listen((event) => event.preventDefault());
}

void downloadTextFileInBrowser(List<String> lines, String fileName) {
  var blob = html.Blob(lines, 'text/plain', 'native');
  html.AnchorElement(href: html.Url.createObjectUrlFromBlob(blob).toString())
    ..setAttribute("download", fileName)
    ..click();
}

void downloadUrlInBrowser(String? url, String fileName) {
  html.AnchorElement(href: url)
    ..setAttribute("download", fileName)
    ..click();
}

void addTabKeyListener(FocusScopeNode node) {
  html.document.addEventListener('keydown', (event) => {if (event.type == 'tab') node.nextFocus()});
}
