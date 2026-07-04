import 'package:vivido/utils/AppConstant.dart';
import 'package:vivido/widgets/handle_keyboard_event.dart';
import 'package:vivido/widgetsClass/text_class.dart';
import 'package:vivido/widgetsProperty/app_bar_property_view.dart';
import 'package:vivido/widgetsProperty/bottom_navigation_bar_property_view.dart';
import 'package:vivido/widgetsProperty/button_property_view.dart';
import 'package:vivido/widgetsProperty/calender_property_view.dart';
import 'package:vivido/widgetsProperty/card_property_view.dart';
import 'package:vivido/widgetsProperty/check_box_property_view.dart';
import 'package:vivido/widgetsProperty/checkbox_list_tile_property_view.dart';
import 'package:vivido/widgetsProperty/chip_view_property.dart';
import 'package:vivido/widgetsProperty/circle_image_property_view.dart';
import 'package:vivido/widgetsProperty/clip_rrect_property_view.dart';
import 'package:vivido/widgetsProperty/column_property_view.dart';
import 'package:vivido/widgetsProperty/comman_property_view.dart';
import 'package:vivido/widgetsProperty/constrained_box_property_view.dart';
import 'package:vivido/widgetsProperty/container_property_view.dart';
import 'package:vivido/widgetsProperty/credit_card_view_property_view.dart';
import 'package:vivido/widgetsProperty/divider_property_view.dart';
import 'package:vivido/widgetsProperty/drop_down_property_view.dart';
import 'package:vivido/widgetsProperty/grid_view_property_view.dart';
import 'package:vivido/widgetsProperty/icon_button_property_view.dart';
import 'package:vivido/widgetsProperty/icon_property_view.dart';
import 'package:vivido/widgetsProperty/image_icon_property_view.dart';
import 'package:vivido/widgetsProperty/image_property_view.dart';
import 'package:vivido/widgetsProperty/left_drawer_property_view.dart';
import 'package:vivido/widgetsProperty/linear_progress_indicator_property_view.dart';
import 'package:vivido/widgetsProperty/circular_progress_indicator_property_view.dart';
import 'package:vivido/widgetsProperty/fab_property_view.dart';
import 'package:vivido/widgetsProperty/list_tile_property_view.dart';
import 'package:vivido/widgetsProperty/list_view_property_view.dart';
import 'package:vivido/widgetsProperty/lottie_animation_property_view.dart';
import 'package:vivido/widgetsProperty/otp_text_field_property_view.dart';
import 'package:vivido/widgetsProperty/opacity_property_view.dart';
import 'package:vivido/widgetsProperty/page_view_property_view.dart';
import 'package:vivido/widgetsProperty/radio_property_view.dart';
import 'package:vivido/widgetsProperty/rating_bar_property_view.dart';
import 'package:vivido/widgetsProperty/root_view_property_view.dart';
import 'package:vivido/widgetsProperty/rotated_box_property_view.dart';
import 'package:vivido/widgetsProperty/row_property_view.dart';
import 'package:vivido/widgetsProperty/sized_box_property_view.dart';
import 'package:vivido/widgetsProperty/slider_property_view.dart';
import 'package:vivido/widgetsProperty/stack_property_view.dart';
import 'package:vivido/widgetsProperty/switch_list_tile_property_view.dart';
import 'package:vivido/widgetsProperty/switch_property_view.dart';
import 'package:vivido/widgetsProperty/tab_bar_property_view.dart';
import 'package:vivido/widgetsProperty/tab_property.dart';
import 'package:vivido/widgetsProperty/tab_view_properties.dart';
import 'package:vivido/widgetsProperty/text_field_property_view.dart';
import 'package:vivido/widgetsProperty/text_property_view.dart';
import 'package:vivido/widgetsProperty/web_view_property_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

import '../../main.dart';

class SelectedWidgetProperty extends StatefulWidget {
  @override
  _SelectedWidgetPropertyState createState() => _SelectedWidgetPropertyState();
}

class _SelectedWidgetPropertyState extends State<SelectedWidgetProperty> {
  final FocusScopeNode _node = FocusScopeNode();

  Widget getPropertyView(BuildContext context) {
    if (appStore.currentSelectedWidget!.widgetSubType == WidgetTypeText)
      return TextPropertyView();
    else if (appStore.currentSelectedWidget!.widgetSubType == WidgetTypeImage)
      return ImagePropertyView();
    else if (appStore.currentSelectedWidget!.widgetSubType == WidgetTypeTextField)
      return TextFieldPropertyView();
    else if (appStore.currentSelectedWidget!.widgetSubType == WidgetTypeTextButton)
      return ButtonPropertyView();
    else if (appStore.currentSelectedWidget!.widgetSubType == WidgetTypeCheckBox)
      return CheckBoxPropertyView();
    else if (appStore.currentSelectedWidget!.widgetSubType == WidgetTypeRadio)
      return RadioPropertyView();
    else if (appStore.currentSelectedWidget!.widgetSubType == WidgetIconType)
      return IconPropertyView();
    else if (appStore.currentSelectedWidget!.widgetSubType == WidgetTypeIconButton)
      return IconButtonPropertyView();
    else if (appStore.currentSelectedWidget!.widgetSubType == WidgetTypeAppBar)
      return AppBarPropertyView();
    else if (appStore.currentSelectedWidget!.widgetSubType == WidgetTypeBottomNavigationBar)
      return BottomNavigationBarPropertyView();
    else if (appStore.currentSelectedWidget!.widgetSubType == WidgetTypeChipView)
      return ChipViewProperty();
    else if (appStore.currentSelectedWidget!.widgetSubType == WidgetTypeLeftDrawer)
      return LeftDrawerPropertyView();
    else if (appStore.currentSelectedWidget!.widgetSubType == WidgetTypeContainer)
      return ContainerPropertyView();
    else if (appStore.currentSelectedWidget!.widgetSubType == WidgetTypeColumn)
      return ColumnPropertyView();
    else if (appStore.currentSelectedWidget!.widgetSubType == WidgetTypeStack)
      return StackPropertyView();
    else if (appStore.currentSelectedWidget!.widgetSubType == WidgetTypeRow)
      return RowPropertyView();
    else if (appStore.currentSelectedWidget!.widgetSubType == WidgetTypeListTile)
      return ListTilePropertyView();
    else if (appStore.currentSelectedWidget!.widgetSubType == WidgetTypeCard)
      return CardPropertyView();
    else if (appStore.currentSelectedWidget!.widgetSubType == WidgetTypeList)
      return ListViewPropertyView();
    else if (appStore.currentSelectedWidget!.widgetSubType == WidgetTypeGrid)
      return GridViewPropertyView();
    else if (appStore.currentSelectedWidget!.widgetSubType == WidgetTypeSwitchListTile)
      return SwitchListTilePropertyView();
    else if (appStore.currentSelectedWidget!.widgetSubType == WidgetTypeCheckboxListTile)
      return CheckboxListTilePropertyView();
    else if (appStore.currentSelectedWidget!.widgetSubType == WidgetTypeSizedBox)
      return SizedBoxPropertyView();
    else if (appStore.currentSelectedWidget!.widgetSubType == WidgetTypeDivider)
      return DividerPropertyView();
    else if (appStore.currentSelectedWidget!.widgetSubType == WidgetTypeCalender)
      return CalenderPropertyView();
    else if (appStore.currentSelectedWidget!.widgetSubType == WidgetTypeDropDown)
      return DropDownPropertyView();
    else if (appStore.currentSelectedWidget!.widgetSubType == WidgetTypeWebView)
      return WebViewPropertyView();
    else if (appStore.currentSelectedWidget!.widgetSubType == WidgetTypeCircleImage)
      return CircleImagePropertyView();
    else if (appStore.currentSelectedWidget!.widgetSubType == WidgetTypeSlider)
      return SliderPropertyView();
    else if (appStore.currentSelectedWidget!.widgetSubType == WidgetTypeRatingBar)
      return RatingBarPropertyView();
    else if (appStore.currentSelectedWidget!.widgetSubType == WidgetTypeRotatedBox)
      return RotatedBoxPropertyView();
    else if (appStore.currentSelectedWidget!.widgetSubType == WidgetTypeConstrainedBox)
      return ConstrainedBoxPropertyView();
    else if (appStore.currentSelectedWidget!.widgetSubType == WidgetTypeClipRRect)
      return ClipRRectPropertyView();
    else if (appStore.currentSelectedWidget!.widgetSubType == WidgetTypeOpacity)
      return OpacityPropertyView();
    else if (appStore.currentSelectedWidget!.widgetSubType == WidgetTypeImageIcon)
      return ImageIconPropertyView();
    else if (appStore.currentSelectedWidget!.widgetSubType == WidgetTypeRootView)
      return RootViewProperty();
    else if (appStore.currentSelectedWidget!.widgetSubType == WidgetTypePageView)
      return PageViewPropertyView();
    else if (appStore.currentSelectedWidget!.widgetSubType == WidgetTypeTabView)
      return TabViewProperties();
    else if (appStore.currentSelectedWidget!.widgetSubType == WidgetTypeTab)
      return TabProperty();
    else if (appStore.currentSelectedWidget!.widgetSubType == WidgetTypeTabBar)
      return TabBarPropertyView();
    else if (appStore.currentSelectedWidget!.widgetSubType == WidgetTypeCreditCardView)
      return CreditCardViewPropertyView();
    else if (appStore.currentSelectedWidget!.widgetSubType == WidgetTypeLottieAnimation)
      return LottieAnimationPropertyView();
    else if (appStore.currentSelectedWidget!.widgetSubType == WidgetTypeSwitch)
      return SwitchPropertyView();
    else if (appStore.currentSelectedWidget!.widgetSubType == WidgetTypeOTPTextField)
      return OTPTextFieldPropertyView();
    else if (appStore.currentSelectedWidget!.widgetSubType == WidgetTypeLinearProgressIndicator)
      return LinearProgressIndicatorPropertyView();
    else if (appStore.currentSelectedWidget!.widgetSubType == WidgetTypeCircularProgressIndicator)
      return CircularProgressIndicatorPropertyView();
    else if (appStore.currentSelectedWidget!.widgetSubType == WidgetTypeFAB)
      return FabPropertyView();
    else
      return Container(
        child: Text(language!.defaultProperty),
      );
  }

  @override
  void initState() {
    super.initState();
    tabKeyEvent(_node);
  }

  @override
  void setState(fn) {
    super.setState(fn);
  }

  @override
  void dispose() {
    _node.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (context) {
        return Listener(
          onPointerDown: (_) => FocusScope.of(context).requestFocus(FocusNode()),
          child: FocusScope(node: _node, child: getPropertyView(context)),
        );
      },
    );
  }

  int getFontSize() {
    var textModel = appStore.currentSelectedWidget!.widgetViewModel as TextClass;
    if (textModel.fontSize == null) {
      return DEFAULT_FONT_SIZE.toInt();
    } else {
      return textModel.fontSize!.toInt();
    }
  }
}
