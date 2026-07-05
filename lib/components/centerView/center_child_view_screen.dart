import 'package:vivido/components/ai_panel_component.dart';
import 'package:vivido/components/faqs_component.dart';
import 'package:vivido/components/media_component.dart';
import 'package:vivido/components/predefine_list_component.dart';
import 'package:vivido/components/screen_list_component.dart';
import 'package:vivido/components/reorder_screen_widget.dart';
import 'package:vivido/components/screens_page_components.dart';
import 'package:vivido/components/tree_view_components.dart';
import 'package:vivido/components/widgets_information_component.dart';
import 'package:vivido/components/centerView/center_body_component.dart';
import 'package:vivido/components/leftView/left_component_list_component.dart';
import 'package:vivido/components/leftView/left_widget_list_component.dart';
import 'package:vivido/components/rightView/right_screen_component.dart';
import 'package:vivido/utils/AppColors.dart';
import 'package:vivido/utils/AppCommon.dart';
import 'package:vivido/utils/AppConstant.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

import '../../main.dart';

class CenterChildViewScreen extends StatefulWidget {
  final bool isExpanded;

  CenterChildViewScreen({this.isExpanded = true});

  @override
  _CenterChildViewScreenState createState() => _CenterChildViewScreenState();
}

class _CenterChildViewScreenState extends State<CenterChildViewScreen> {
  @override
  void initState() {
    super.initState();
  }

  Widget getChildView(BuildContext context) {
    /// Widgets View
    if (appStore.selectedMenu == WIDGETS_INDEX) {

      return Stack(
        children: [
          Positioned(
            top: 0,
            bottom: 0,
            left: getLeftWidgetsWidth(context),
            child: AnimatedContainer(
              duration: Duration(milliseconds: 500),
              curve: widget.isExpanded ? Curves.easeIn : Curves.easeOut,
              child: CenterBodyComponent(),
              width: getCenterScreenWidth(context, isExpanded: widget.isExpanded),
            ),
          ),
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            child: Container(
              child: RightScreenComponent(),
              width: getRightPropertyViewWidth(context),
            ),
          ),
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: Container(
              child: LeftWidgetListComponent(),
              width: getLeftWidgetsWidth(context),
            ),
          ),
        ],
      );
    }

    /// Widgets View
    if (appStore.selectedMenu == PRE_COMPONENTS_INDEX) {

      return Stack(
        children: [
          Positioned(
            top: 0,
            bottom: 0,
            left: getLeftWidgetsWidth(context),
            child: AnimatedContainer(
              duration: Duration(milliseconds: 500),
              curve: widget.isExpanded ? Curves.easeIn : Curves.easeOut,
              child: CenterBodyComponent(),
              width: getCenterScreenWidth(context, isExpanded: widget.isExpanded),
            ),
          ),
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            child: Container(
              child: RightScreenComponent(),
              width: getRightPropertyViewWidth(context),
            ),
          ),
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: Container(
              child: LeftComponentListComponent(),
              width: getLeftWidgetsWidth(context),
            ),
          ),
        ],
      );
    } else if (appStore.selectedMenu == SCREEN_INDEX) {
      /// Screens or Pages View
      return Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            child: ScreensPageComponents(),
            width: getLeftWidgetsWidth(context),
          ),
          Container(
            child: CenterBodyComponent(),
            width: getCenterScreenWidth(context, isExpanded: widget.isExpanded),
          ),
          Container(
            child: RightScreenComponent(),
            width: getRightPropertyViewWidth(context),
          )
        ],
      );
    } else if (appStore.selectedMenu == TREE_INDEX) {
      /// Tree View

      return Stack(
        children: [
          Positioned(
            top: 0,
            bottom: 0,
            left: getLeftWidgetsWidth(context),
            child: Container(
              child: CenterBodyComponent(),
              width: getCenterScreenWidth(context, isExpanded: widget.isExpanded),
            ),
          ),
          Positioned(
            top: 0,
            bottom: 0,
            left: 0,
            child: Container(
              child: TreeViewComponents(),
              width: getLeftWidgetsWidth(context),
            ),
          ),
          Positioned(
            top: 0,
            bottom: 0,
            right: 0,
            child: Container(
              child: RightScreenComponent(),
              width: getRightPropertyViewWidth(context),
            ),
          )
        ],
      );
    } else if (appStore.selectedMenu == COMPONENT_INDEX) {
      /// Component View

      return Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            child: PredefineListComponent(),
            width: getLeftWidgetsWidth(context),
          ),
          Container(
            child: CenterBodyComponent(),
            width: getCenterScreenWidth(context),
          ),
          Container(
            child: ReorderScreenWidget(),
            width: getRightPropertyViewWidth(context),
          )
        ],
      );
    } else if (appStore.selectedMenu == WIDGETS_INFO_INDEX) {
      /// Widgets Information View
      return Container(
        child: WidgetsInformationComponent(),
        width: getChildWidgetsWidth(context, isExpanded: widget.isExpanded),
        height: MediaQuery.of(context).size.height,
      );
    } else if (appStore.selectedMenu == FAQS_INDEX) {
      /// FAQS View
      return Container(
        child: FaqsComponent(),
        width: getChildWidgetsWidth(context, isExpanded: widget.isExpanded),
        height: MediaQuery.of(context).size.height,
      );
    } else if (appStore.selectedMenu == SCREEN_LIST_INDEX) {
      /// Screen list View
      return Stack(
        children: [
          Positioned(
            top: 0,
            bottom: 0,
            left: getLeftWidgetsWidth(context),
            child: AnimatedContainer(
              duration: Duration(milliseconds: 500),
              curve: widget.isExpanded ? Curves.easeIn : Curves.easeOut,
              child: CenterBodyComponent(),
              width: getCenterScreenWidth(context, isExpanded: widget.isExpanded),
            ),
          ),
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            child: Container(
              child: RightScreenComponent(),
              width: getRightPropertyViewWidth(context),
            ),
          ),
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: Container(
              child: ScreenListComponent(),
              width: getLeftWidgetsWidth(context),
            ),
          ),
        ],
      );
    } else if (appStore.selectedMenu == MEDIA_INDEX) {
      /// Media View
      return Container(
        child: MediaComponent(),
        width: getChildWidgetsWidth(context, isExpanded: widget.isExpanded),
        height: MediaQuery.of(context).size.height,
      );
    } else if (appStore.selectedMenu == AI_INDEX) {
      /// IA panel — keep the live preview visible so "reload" updates it live.
      return Stack(
        children: [
          Positioned(
            top: 0,
            bottom: 0,
            left: getLeftWidgetsWidth(context),
            child: AnimatedContainer(
              duration: Duration(milliseconds: 500),
              curve: widget.isExpanded ? Curves.easeIn : Curves.easeOut,
              child: CenterBodyComponent(),
              width: getCenterScreenWidth(context, isExpanded: widget.isExpanded),
            ),
          ),
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            child: Container(
              child: RightScreenComponent(),
              width: getRightPropertyViewWidth(context),
            ),
          ),
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: Container(
              child: AiPanelComponent(),
              width: getLeftWidgetsWidth(context),
            ),
          ),
        ],
      );
    } else {
      return SizedBox();
    }
  }

  /// Menus that render the resizable left column. Others (FAQ, widget info,
  /// empty state) are full-width and get no drag handle. The `-1` menus
  /// (PRE_COMPONENTS/COMPONENT/SCREEN) are unreachable via `selectedMenu`.
  static const Set<int> _leftPanelMenus = {
    SCREEN_LIST_INDEX,
    WIDGETS_INDEX,
    TREE_INDEX,
    MEDIA_INDEX,
    AI_INDEX,
  };

  @override
  Widget build(BuildContext context) {
    return Observer(builder: (_) {
      final child = getChildView(context);
      if (!_leftPanelMenus.contains(appStore.selectedMenu)) return child;

      // Single overlaid drag handle sitting on the left column's right edge.
      // Reading getLeftWidgetsWidth (an observable) keeps it glued to the edge
      // as the width changes, and this whole builder is already reactive.
      const double hitWidth = 10;
      return Stack(
        children: [
          child,
          Positioned(
            top: 0,
            bottom: 0,
            left: getLeftWidgetsWidth(context) - hitWidth / 2,
            width: hitWidth,
            child: LeftPanelResizeHandle(),
          ),
        ],
      );
    });
  }
}

/// Thin vertical grip that drag-resizes the shared left column via
/// [AppStore.setLeftPanelWidth]. Placement is handled by the caller.
class LeftPanelResizeHandle extends StatefulWidget {
  @override
  State<LeftPanelResizeHandle> createState() => _LeftPanelResizeHandleState();
}

class _LeftPanelResizeHandleState extends State<LeftPanelResizeHandle> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.resizeLeftRight,
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onHorizontalDragUpdate: (details) {
          appStore.setLeftPanelWidth(appStore.leftPanelWidth + details.delta.dx);
        },
        child: Center(
          child: Observer(
            builder: (_) => Container(
              width: 2,
              color: _hovering ? btnBackgroundColor : Colors.transparent,
            ),
          ),
        ),
      ),
    );
  }
}
