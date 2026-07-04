import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_viz/model/widget_model.dart';
import 'package:flutter_viz/utils/AppConstant.dart';
import 'package:flutter_viz/widgets/widgets.dart';
import 'package:flutter_viz/widgetsClass/Icon_class.dart';
import 'package:flutter_viz/widgetsClass/Image_class.dart';
import 'package:flutter_viz/widgetsClass/app_bar_class.dart';
import 'package:flutter_viz/widgetsClass/circle_image_class.dart';
import 'package:flutter_viz/widgetsClass/column_class.dart';
import 'package:flutter_viz/widgetsClass/container_class.dart';
import 'package:flutter_viz/widgetsClass/divider_class.dart';
import 'package:flutter_viz/widgetsClass/fab_class.dart';
import 'package:flutter_viz/widgetsClass/icon_button_class.dart';
import 'package:flutter_viz/widgetsClass/list_tile_class.dart';
import 'package:flutter_viz/widgetsClass/root_view_class.dart';
import 'package:flutter_viz/widgetsClass/row_class.dart';
import 'package:flutter_viz/widgetsClass/sized_box_class.dart';
import 'package:flutter_viz/widgetsClass/text_button_class.dart';
import 'package:flutter_viz/widgetsClass/text_class.dart';
import 'package:flutter_viz/widgetsClass/text_field_class.dart';

/// A small, type-safe DSL for authoring FlutterViz page templates as real
/// [WidgetModel] trees, plus a serializer that turns such a tree into the exact
/// `screenJsonData` string that [applyScreenJsonToView] consumes.
///
/// Templates are built with the canonical [getWidgets] factory (so widgetType /
/// widgetSubType / default view-model are always correct) and then customized
/// through the typed helpers below. This avoids hand-writing fragile JSON.

/// Builds an `iconDataJson` map in the format expected by the widget classes.
Map<String, dynamic> tIconData(IconData icon, {String name = 'icon'}) {
  return {
    'iconName': name,
    'codePoint': icon.codePoint,
    'fontFamily': icon.fontFamily ?? 'MaterialIcons',
  };
}

/// Generic node factory: creates a canonical widget via [getWidgets], applies
/// [config] to its view-model, and attaches [children] (for layout widgets).
WidgetModel tNode(
  String subType, {
  void Function(dynamic vm)? config,
  List<WidgetModel>? children,
}) {
  final WidgetModel model = getWidgets(subType);
  if (config != null) config(model.widgetViewModel);
  if (children != null) {
    model.subWidgetsList ??= [];
    model.subWidgetsList!
      ..clear()
      ..addAll(children);
  }
  return model;
}

// ---------------------------------------------------------------------------
// Layout widgets
// ---------------------------------------------------------------------------

WidgetModel tColumn({
  List<WidgetModel> children = const [],
  String mainAxisAlignment = AxisAlignmentStart,
  String crossAxisAlignment = AxisAlignmentCenter,
  String mainAxisSize = AxisMax,
  bool scrollable = false,
  EdgeInsets? padding,
  bool expanded = false,
  int flex = 1,
}) {
  return tNode(WidgetTypeColumn, children: children, config: (vm) {
    final c = vm as ColumnClass;
    c.mainAxisAlignment = mainAxisAlignment;
    c.crossAxisAlignment = crossAxisAlignment;
    c.mainAxisSize = mainAxisSize;
    c.isScrollable = scrollable;
    if (padding != null) c.padding = padding;
    c.isExpanded = expanded;
    c.flex = flex;
    // Templates control their own layout; opt out of the palette's centered default.
    c.isAlignX = false;
    c.isAlignY = false;
  });
}

WidgetModel tRow({
  List<WidgetModel> children = const [],
  String mainAxisAlignment = AxisAlignmentStart,
  String crossAxisAlignment = AxisAlignmentCenter,
  String mainAxisSize = AxisMax,
  EdgeInsets? padding,
  bool expanded = false,
  int flex = 1,
}) {
  return tNode(WidgetTypeRow, children: children, config: (vm) {
    final c = vm as RowClass;
    c.mainAxisAlignment = mainAxisAlignment;
    c.crossAxisAlignment = crossAxisAlignment;
    c.mainAxisSize = mainAxisSize;
    if (padding != null) c.padding = padding;
    c.isExpanded = expanded;
    c.flex = flex;
    c.isAlignX = false;
    c.isAlignY = false;
  });
}

WidgetModel tContainer({
  List<WidgetModel> children = const [],
  Color? bgColor,
  EdgeInsets? padding,
  EdgeInsets? margin,
  double? width,
  double? height,
  bool fullWidth = false,
  double borderRadius = 0,
  Color borderColor = const Color(0x00000000),
  double borderWidth = 0,
  String alignment = AlignmentTypeNone,
  String shape = BoxShapeTypeRectangle,
  bool expanded = false,
  int flex = 1,
}) {
  return tNode(WidgetTypeContainer, children: children, config: (vm) {
    final c = vm as ContainerClass;
    c.bgColor = bgColor ?? const Color(0x00000000);
    c.padding = padding ?? EdgeInsets.zero;
    c.margin = margin ?? EdgeInsets.zero;
    if (fullWidth) {
      c.width = 100;
      c.widthType = TypePercentage;
    } else if (width != null) {
      c.width = width;
      c.widthType = TypePX;
    } else {
      c.isWidthClear = true;
    }
    if (height != null) {
      c.height = height;
      c.heightType = TypePX;
    } else {
      c.isHeightClear = true;
    }
    c.shape = shape;
    if (shape != BoxShapeTypeCircle) {
      c.borderRadius = BorderRadius.circular(borderRadius);
    }
    c.borderColor = borderColor;
    c.borderWidth = borderWidth;
    c.alignment = alignment;
    c.isExpanded = expanded;
    c.flex = flex;
    c.isAlignX = false;
    c.isAlignY = false;
  });
}

WidgetModel tSizedBox({double? width, double? height}) {
  return tNode(WidgetTypeSizedBox, config: (vm) {
    final s = vm as SizedBoxClass;
    if (width != null) {
      s.width = width;
      s.widthType = TypePX;
    }
    if (height != null) {
      s.height = height;
      s.heightType = TypePX;
    }
  });
}

// ---------------------------------------------------------------------------
// Leaf widgets
// ---------------------------------------------------------------------------

WidgetModel tText(
  String text, {
  double fontSize = 14,
  Color color = const Color(0xFF000000),
  String fontWeight = FontWeightTypeNormal,
  TextAlign textAlign = TextAlign.start,
  int? maxLines,
  EdgeInsets? padding,
}) {
  return tNode(WidgetTypeText, config: (vm) {
    final t = vm as TextClass;
    t.text = text;
    t.fontSize = fontSize;
    t.textColor = color;
    t.fWeight = fontWeight;
    t.textAlign = textAlign;
    t.maxLines = maxLines;
    if (padding != null) t.padding = padding;
  });
}

WidgetModel tTextField({
  String hintText = '',
  String? labelText,
  bool fill = true,
  Color fillColor = const Color(0xFFF3F4F6),
  Color borderColor = const Color(0xFFE0E0E0),
  double borderWidth = 1,
  double borderRadius = 8,
  String inputBorder = InputBorderTypeOutLine,
  bool obscureText = false,
  IconData? prefixIcon,
  Color prefixIconColor = const Color(0xFF9E9E9E),
}) {
  return tNode(WidgetTypeTextField, config: (vm) {
    final f = vm as TextFieldClass;
    f.hintText = hintText;
    f.labelText = labelText;
    f.isFill = fill;
    f.fillColor = fillColor;
    f.borderColor = borderColor;
    f.borderWidth = borderWidth;
    f.borderRadius = BorderRadius.circular(borderRadius);
    f.inputBorder = inputBorder;
    f.obscureText = obscureText;
    // Emit isExpanded explicitly: TextFieldClass.fromJson otherwise dereferences
    // appStore.currentSelectedWidget when this key is absent.
    f.isExpanded = false;
    if (prefixIcon != null) {
      f.prefixIconDataJson = tIconData(prefixIcon);
      f.prefixIconColor = prefixIconColor;
      f.prefixIconSize = 20;
    }
  });
}

WidgetModel tButton(
  String text, {
  Color bgColor = const Color(0xFF5567FF),
  Color textColor = const Color(0xFFFFFFFF),
  double fontSize = 15,
  String fontWeight = FontWeightTypeBold,
  double borderRadius = 8,
  double elevation = 0,
  double? width,
  bool fullWidth = false,
  double height = 48,
  Color borderColor = const Color(0x00000000),
  double borderWidth = 0,
}) {
  return tNode(WidgetTypeTextButton, config: (vm) {
    final b = vm as TextButtonClass;
    b.text = text;
    b.backgroundColor = bgColor;
    b.textColor = textColor;
    b.tFontSize = fontSize;
    b.tFontWeight = fontWeight;
    b.borderRadius = BorderRadius.circular(borderRadius);
    b.elevation = elevation;
    b.borderColor = borderColor;
    b.borderWidth = borderWidth;
    b.height = height;
    if (fullWidth) {
      b.minWidth = 100;
      b.widthType = TypePercentage;
    } else if (width != null) {
      b.minWidth = width;
      b.widthType = TypePX;
    }
  });
}

WidgetModel tImage({
  String? assetPath,
  String? networkUrl,
  double width = 120,
  double height = 120,
  String fit = boxFitCover,
  bool fullWidth = false,
}) {
  return tNode(WidgetTypeImage, config: (vm) {
    final i = vm as ImageClass;
    if (networkUrl != null) {
      i.imageType = ImageTypeNetwork;
      i.path = networkUrl;
    } else if (assetPath != null) {
      i.imageType = ImageTypeAsset;
      i.path = assetPath;
    }
    i.fit = fit;
    if (fullWidth) {
      i.width = 100;
      i.widthType = TypePercentage;
    } else {
      i.width = width;
      i.widthType = TypePX;
    }
    i.height = height;
    i.heightType = TypePX;
  });
}

WidgetModel tCircleImage({
  String? assetPath,
  String? networkUrl,
  double radius = 48,
}) {
  return tNode(WidgetTypeCircleImage, config: (vm) {
    final c = vm as CircleImageClass;
    if (networkUrl != null) {
      c.imageType = ImageTypeNetwork;
      c.path = networkUrl;
    } else if (assetPath != null) {
      c.imageType = ImageTypeAsset;
      c.path = assetPath;
    }
    c.radius = radius;
    c.radiusType = TypePX;
    c.boxFit = boxFitCover;
  });
}

WidgetModel tIcon(
  IconData icon, {
  Color color = const Color(0xFF212435),
  double size = 24,
  String name = 'icon',
}) {
  return tNode(WidgetIconType, config: (vm) {
    final i = vm as IconClass;
    i.iconDataJson = tIconData(icon, name: name);
    i.iconColor = color;
    i.iconSize = size;
  });
}

WidgetModel tIconButton(
  IconData icon, {
  Color color = const Color(0xFF212435),
  double size = 24,
  String name = 'icon',
}) {
  return tNode(WidgetTypeIconButton, config: (vm) {
    final i = vm as IconButtonClass;
    i.iconDataJson = tIconData(icon, name: name);
    i.iconColor = color;
    i.iconSize = size;
  });
}

WidgetModel tDivider({
  Color color = const Color(0xFFE0E0E0),
  double thickness = 1,
  double indent = 0,
  double endIndent = 0,
  double height = 16,
}) {
  return tNode(WidgetTypeDivider, config: (vm) {
    final d = vm as DividerClass;
    d.dividerColor = color;
    d.dividerThickness = thickness;
    d.dividerIndent = indent;
    d.dividerEndIndent = endIndent;
    d.height = height;
  });
}

WidgetModel tListTile({
  required String title,
  String? subtitle,
  IconData? leadingIcon,
  Color leadingIconColor = const Color(0xFF5567FF),
  IconData? trailingIcon,
  Color trailingIconColor = const Color(0xFF9E9E9E),
  Color tileColor = const Color(0x00000000),
  Color titleColor = const Color(0xFF212435),
}) {
  return tNode(WidgetTypeListTile, config: (vm) {
    final t = vm as ListTileClass;
    t.title = title;
    t.subtitle = subtitle;
    t.tFontColor = titleColor;
    t.tileColor = tileColor;
    if (leadingIcon != null) {
      t.leadingIconDataJson = tIconData(leadingIcon);
      t.leadingIconColor = leadingIconColor;
    }
    if (trailingIcon != null) {
      t.trailingIconDataJson = tIconData(trailingIcon);
      t.trailingIconColor = trailingIconColor;
    }
  });
}

/// Builds an AppBar view-model wrapped in a [WidgetModel].
WidgetModel tAppBar({
  required String title,
  Color backgroundColor = const Color(0xFF5567FF),
  Color textColor = const Color(0xFFFFFFFF),
  Color iconColor = const Color(0xFFFFFFFF),
  bool centerTitle = false,
  IconData leadingIcon = Icons.arrow_back,
}) {
  return tNode(WidgetTypeAppBar, config: (vm) {
    final a = vm as AppBarClass;
    a.text = title;
    a.backgroundColor = backgroundColor;
    a.textColor = textColor;
    a.iconColor = iconColor;
    a.centerTitle = centerTitle;
    a.iconDataJson = tIconData(leadingIcon);
    a.isShowIconDefault = true;
  });
}

// ---------------------------------------------------------------------------
// Serialization: WidgetModel tree -> screenJsonData string
// ---------------------------------------------------------------------------

Map<String, dynamic> _nodeToJson(WidgetModel w) {
  final Map<String, dynamic> data = {
    JSON_WIDGET_ID: w.id,
    JSON_TYPE: w.widgetType,
    JSON_SUB_TYPE: w.widgetSubType,
    w.widgetSubType!: getWidgetsClassData(w, isPropertyJsonData: true),
  };
  if (w.widgetType != WidgetTypeNormal) {
    data[JSON_CHILD_DATA] = (w.subWidgetsList ?? [])
        .where((c) => c != null)
        .map((c) => _nodeToJson(c!))
        .toList();
  }
  return data;
}

/// Serializes a template [root] (plus optional scaffold color / app bar) into
/// the `screenJsonData` string format understood by [applyScreenJsonToView].
String buildScreenJson({
  required WidgetModel root,
  Color scaffoldColor = Colors.white,
  WidgetModel? appBar,
  WidgetModel? fab,
}) {
  final Map<String, dynamic> rootJson = {
    JSON_WIDGET_DATA: _nodeToJson(root),
    JSON_SCAFFOLD_DATA: {
      JSON_WIDGET_ID: getWidgetId(),
      JSON_TYPE: WidgetTypeRootView,
      JSON_SUB_TYPE: WidgetTypeRootView,
      WidgetTypeRootView: RootViewClass(bgColor: scaffoldColor).toJson(),
    },
    JSON_APPBAR_DATA: appBar != null
        ? {
            JSON_WIDGET_ID: appBar.id,
            JSON_TYPE: appBar.widgetType,
            JSON_SUB_TYPE: appBar.widgetSubType,
            WidgetTypeAppBar: (appBar.widgetViewModel as AppBarClass).toJson(),
          }
        : <String, dynamic>{},
    JSON_BOTTOM_BAR_NAVIGATION_DATA: <String, dynamic>{},
    JSON_DRAWER_DATA: <String, dynamic>{},
    JSON_FAB_DATA: fab != null
        ? {
            JSON_WIDGET_ID: fab.id,
            JSON_TYPE: fab.widgetType,
            JSON_SUB_TYPE: fab.widgetSubType,
            WidgetTypeFAB: (fab.widgetViewModel as FabClass).toJson(),
          }
        : <String, dynamic>{},
  };
  return jsonEncode(rootJson);
}
