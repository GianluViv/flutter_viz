import 'package:vivido/main.dart';
import 'package:vivido/utils/AppColors.dart';
import 'package:vivido/utils/AppCommon.dart';
import 'package:vivido/utils/AppConstant.dart';
import 'package:vivido/utils/AppFunctions.dart';
import 'package:vivido/utils/AppWidget.dart';
import 'package:vivido/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';

import 'selected_widget_property.dart';

class RightScreenComponent extends StatefulWidget {
  @override
  _RightScreenComponentState createState() => _RightScreenComponentState();
}

class _RightScreenComponentState extends State<RightScreenComponent> {
  TextEditingController screenController = TextEditingController();

  @override
  void initState() {
    super.initState();
    LiveStream().on(LIVESTREAM_UPDATE_LAST_SYNC_TIME, (a) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  _getView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        16.height,
        Observer(builder: (_) {
          if (appStore.currentSelectedWidget != null) {
            return Container(
              margin: EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      "${getWidgetTitle(appStore.currentSelectedWidget!.widgetSubType)} (***${appStore.currentSelectedWidget!.id!.substring(appStore.currentSelectedWidget!.id!.length - 4, appStore.currentSelectedWidget!.id!.length)})",
                      style: primaryTextStyle(weight: FontWeight.bold, size: 18),
                    ),
                  ),
                  Observer(builder: (_) {
                    if (appStore.currentSelectedWidget!.widgetSubType != WidgetTypeRootView) {
                      return GestureDetector(
                        child: tooltipView(
                          message: "${language!.delete} ${appStore.currentSelectedWidget!.widgetSubType} ${language!.widget}",
                          child: deleteIcon(context),
                        ),
                        onTap: () {
                          deleteConfirmationDialog(
                            context: context,
                            messageText: language!.areYouSureWantToDeleteWidget,
                            onAccept: () {
                              finish(context);
                              appStore.removeSelectedWidget();
                            },
                          );
                        },
                      );
                    } else
                      return SizedBox();
                  })
                ],
              ),
            );
          } else {
            return SizedBox();
          }
        }),
        Observer(builder: (_) {
          if (appStore.currentSelectedWidget != null) {
            return SelectedWidgetProperty().visible(appStore.currentSelectedWidget!.widgetType != null);
          } else
            return SizedBox();
        }),
        SizedBox(height: 40),
      ],
    );
  }

  @override
  void dispose() {
    super.dispose();
    LiveStream().dispose(LIVESTREAM_UPDATE_LAST_SYNC_TIME);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: context.height(),
      width: context.width(),
      padding: EdgeInsets.all(0),
      decoration: boxDecorationWithShadow(
        boxShadow: [
          appStore.isDarkMode
              ? commonCardBoxShadowDarkMode()
              : BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.1),
                  spreadRadius: 8,
                  blurRadius: 8,
                  offset: Offset(0, 15),
                ),
        ],
        backgroundColor: context.scaffoldBackgroundColor,
      ),
      child: Stack(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.vertical,
            padding: EdgeInsets.only(right: 0),
            child: Observer(builder: (_) => _getView()),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: context.width(),
              color: appStore.isDarkMode ? darkModeSecondaryBackgroundDark : leftExpansionTileBackgroundColor,
              child: Text(
                "${language!.autoSaveAt} ${getDateFormatted(DateTime.now(), dateFormat: DATE_FORMAT_3)}",
                style: TextStyle(color: appStore.isDarkMode ? Colors.grey : btnBackgroundColor),
                textAlign: TextAlign.center,
              ),
              padding: EdgeInsets.all(10),
            ),
          ).visible(appStore.lastSyncTime!.isNotEmpty),
        ],
      ),
    );
  }
}
