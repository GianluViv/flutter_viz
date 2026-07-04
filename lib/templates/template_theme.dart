import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_viz/utils/AppCommon.dart';

/// The primary/brand color every built-in template is authored with. Choosing a
/// different theme in the wizard recolors occurrences of this value to the
/// picked color via [recolorScreenJson].
const Color kTemplateBaseColor = Color(0xFF5567FF);

/// A named preset shown as a swatch in the page-creation wizard.
class TemplateTheme {
  final String name;
  final Color color;

  const TemplateTheme(this.name, this.color);
}

/// Preset color themes offered before the free color picker.
const List<TemplateTheme> kPresetThemes = [
  TemplateTheme('Blu', Color(0xFF5567FF)),
  TemplateTheme('Indaco', Color(0xFF3F51B5)),
  TemplateTheme('Viola', Color(0xFF7C4DFF)),
  TemplateTheme('Teal', Color(0xFF009688)),
  TemplateTheme('Verde', Color(0xFF2E9E5B)),
  TemplateTheme('Arancio', Color(0xFFFB8C00)),
  TemplateTheme('Rosso', Color(0xFFE53935)),
  TemplateTheme('Rosa', Color(0xFFEC407A)),
  TemplateTheme('Scuro', Color(0xFF2B2D42)),
];

/// Returns a copy of [screenJson] where every color value equal to [from] is
/// replaced by [to]. Operates on the decoded JSON so only real color fields
/// (hex strings) are affected — never, say, a piece of body text.
String recolorScreenJson(String screenJson, {required Color from, required Color to}) {
  if (from.toARGB32() == to.toARGB32()) return screenJson;
  final decoded = jsonDecode(screenJson);
  final swapped = _swap(decoded, from.toARGB32(), toJsonColor(to));
  return jsonEncode(swapped);
}

dynamic _swap(dynamic node, int fromValue, String toHex) {
  if (node is Map) {
    return node.map((key, value) => MapEntry(key, _swap(value, fromValue, toHex)));
  }
  if (node is List) {
    return node.map((e) => _swap(e, fromValue, toHex)).toList();
  }
  if (node is String) {
    final parsed = _parseColorValue(node);
    if (parsed != null && parsed == fromValue) return toHex;
  }
  return node;
}

/// Parses a hex color string (`RRGGBB`, `AARRGGBB`, optionally `#`-prefixed)
/// into an ARGB int, or null if it isn't a color-shaped string.
int? _parseColorValue(String s) {
  final hex = s.replaceFirst('#', '');
  if (hex.length != 6 && hex.length != 8) return null;
  final value = int.tryParse(hex, radix: 16);
  if (value == null) return null;
  return hex.length == 6 ? (0xFF000000 | value) : value;
}
