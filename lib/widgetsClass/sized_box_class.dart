import 'package:vivido/model/widget_model.dart';
import 'package:vivido/utils/AppCommon.dart';
import 'package:vivido/utils/AppConstant.dart';
import 'package:vivido/utils/AppFunctions.dart';
import 'package:vivido/widgets/widgets.dart';
import 'package:vivido/widgetsProperty/comman_property_view.dart';
import 'package:flutter/material.dart';

class SizedBoxClass {
  /// Height
  double? height;

  /// Width
  double? width;

  /// width type
  String? widthType;

  /// height type
  String? heightType;

  /// Is Expanded
  bool? isExpanded;

  ///Flex
  int? flex;

  SizedBoxClass({
    this.height,
    this.width,
    this.widthType = TypePX,
    this.heightType = TypePX,
    this.isExpanded = false,
    this.flex = 1,
  });

  SizedBoxClass.fromJson(Map<String, dynamic> json) {
    height = json['height'] != null ? fromJsonHeight(json['height'], heightType ?? TypePX) : DEFAULT_SIZED_BOX_HEIGHT;
    width = json['width'] != null ? fromJsonWidth(json['width'], widthType ?? TypePX) : DEFAULT_SIZED_BOX_WIDTH;
    widthType = json['widthType'] != null ? json['widthType'] : TypePX;
    heightType = json['heightType'] != null ? json['heightType'] : TypePX;
    isExpanded = json['isExpanded'] != null ? json['isExpanded'] : false;
    flex = json['flex'] != null ? json['flex'] : DEFAULT_FLEX;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.height != null) {
      data['height'] = this.height;
    }
    if (this.width != null) {
      data['width'] = this.width;
    }
    if (this.widthType != null) {
      data['widthType'] = this.widthType;
    }
    if (this.heightType != null) {
      data['heightType'] = this.heightType;
    }
    if (this.isExpanded != null) {
      data['isExpanded'] = this.isExpanded;
    }
    if (this.flex != null) {
      data['flex'] = this.flex;
    }
    return data;
  }

  Widget getSizedBoxDefaultWidget(WidgetModel widgetModel) {
    Widget childData = SizedBox(
      height: fromJsonHeight(height ?? DEFAULT_SIZED_BOX_HEIGHT, heightType),
      width: fromJsonWidth(width ?? DEFAULT_SIZED_BOX_WIDTH, widthType),
    );
    return getGestureDetector(widgetModel, childData);
  }

  Widget getSizedBoxWidget(WidgetModel widgetModel) {
    if (getExpanded(widgetModel, isExpanded)) {
      return Expanded(
        child: getSizedBoxDefaultWidget(widgetModel),
        flex: flex ?? 1,
      );
    } else {
      return getSizedBoxDefaultWidget(widgetModel);
    }
  }

  /// For view code
  getCodeAsString(WidgetModel widgetModel) {
    String sizedBoxString = "\nSizedBox(\n"
        "${height != 0 ? 'height:${getHeightString(height ?? DEFAULT_SIZED_BOX_HEIGHT, heightType)},\n' : ""}"
        "${width != 0 ? 'width:${getWidthString(width ?? DEFAULT_SIZED_BOX_WIDTH, widthType)},\n' : ""}"
        ")";
    if (getExpanded(widgetModel, isExpanded)) {
      return "Expanded(\n"
          "flex: ${flex ?? 1},\n"
          "child: $sizedBoxString,\n"
          ")";
    } else {
      return sizedBoxString;
    }
  }
}
