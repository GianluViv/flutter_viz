import 'package:flutter/material.dart';

import 'package:vivido/main.dart';

const colorPrimary = Color(0xffffffff);
const scaffoldSecondaryDark = Color(0xFFf2f2f3);
const appShadowColorDark = Color(0x1A3E3942);

///Light Mode Text Color
const textColorPrimary = Color(0xFF212435);
const textColorSecondary = Color(0xFF404C6D);

///DarkMode Text Color
const darModePrimaryTextColor = Color(0xffFFFFFF);
const darkModeSubTextColor = Color(0xCCe8eaed);

const darkModeHighLightColor = Color(0xFF8ab4f8);
const darkModePrimaryColorBackground = Color(0xff202124);
const darkModeSecondaryBackgroundDark = Color(0xff303134);

/// new color
const widgetInfoCardColor = Color(0xFFFAFAFA);
const widgetDesColor = Color(0xFF818181);
const primaryTextColor = Color(0xFF000000);

///primary color button
const btnWhiteTextColor = Color(0xFFFFFFFF);
/// User-selectable accent tones (theme). Selected index persisted as ACCENT_COLOR_INDEX.
const List<Color> accentPalette = [
  Color(0xFF3A57E8), // Indaco (default)
  Color(0xFF0E9F6E), // Verde
  Color(0xFF7C3AED), // Viola
  Color(0xFFF97316), // Arancio
  Color(0xFFE11D63), // Rosa
];

Color get _accent => accentPalette[appStore.selectedAccentIndex.clamp(0, accentPalette.length - 1)];

Color _shiftLightness(Color c, double delta) {
  final hsl = HSLColor.fromColor(c);
  return hsl.withLightness((hsl.lightness + delta).clamp(0.0, 1.0)).toColor();
}

/// Primary accent — follows the selected tone (was a const color).
Color get btnBackgroundColor => _accent;

/// Left Side view color
Color get leftExpansionTileBackgroundColor => HSLColor.fromColor(_accent).withSaturation(0.85).withLightness(0.95).toColor();

/// button hover color
Color get primaryButtonHoverColor => _shiftLightness(_accent, -0.10);
Color get highLightButtonHoverColor => HSLColor.fromColor(_accent).withLightness(0.90).toColor();

/// button shadow color
const primaryButtonShadow = Color(0x4D3a57e8);
const highLightButtonDarkShadow = Color(0x4D707789);
const highLightButtonLightShadow = Color(0x4Debeefc);

const centerBackgroundColor = Color(0xFFf5f6fa);
const dropDownColor = Color(0xffffffff);

///end region

const iconColor = Color(0xFF5C5C5C);

const mouseHoverColor = Colors.green;
Color get selectedViewSelectionColor => _accent;

const headerBackgroundColor = Color(0xFFFFFFFF);
const headerLineColor = Color(0xFFE5E5E5);

/// Menu color
const menuShadowColor = Color(0xfff1f2f9);
const menuMouseHoverColor = Color(0xffebeefc);
const menuIconColor = Color(0xff212529);
const menuTextColor = Color(0xFFa6a8a9);
