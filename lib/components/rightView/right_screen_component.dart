import 'package:flutter_viz/components/screen_clone_dialog.dart';
import 'package:flutter_viz/local_storage/local_project_service.dart';
import 'package:flutter_viz/main.dart';
import 'package:flutter_viz/utils/AppColors.dart';
import 'package:flutter_viz/utils/AppCommon.dart';
import 'package:flutter_viz/utils/AppConstant.dart';
import 'package:flutter_viz/utils/AppFunctions.dart';
import 'package:flutter_viz/utils/AppWidget.dart';
import 'package:flutter_viz/widgets/widgets.dart';
import 'package:flutter_viz/widgetsProperty/comman_property_view.dart';
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

  ///Local equivalent of the old deleteScreen() REST call.
  Future deleteScreenApi({int? screenId}) async {
    if (appStore.currentProject == null || screenId == null) return;
    await locator<LocalProjectService>().deleteScreen(appStore.currentProject!, screenId);
    appStore.removeScreen(screenId);
    LiveStream().emit(getUpdatedData, true);
    LiveStream().emit(updateScreenList);
  }

  _getView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        16.height,
        Observer(
            builder: (_) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      child: tooltipView(
                        message: language!.editScreenName,
                        child: outLineIconButton(
                          context,
                          editIcon(
                            context,
                            () async {
                              await showInDialog(
                                context,
                                builder: (context) => ScreenCloneDialog(isEdit: true),
                              );
                              setState(() {});
                            },
                          ),
                        ),
                      ),
                    ).visible(appStore.selectedScreenId! > 0),
                    GestureDetector(
                      child: tooltipView(
                        message: language!.clone,
                        child: outLineIconButton(context, cloneIcon(context)),
                      ),
                      onTap: () async {
                        bool? res = await showInDialog(
                          context,
                          builder: (context) {
                            return ScreenCloneDialog();
                          },
                        );
                        if (res ?? false) {
                          setState(() {});
                        }
                      },
                    ).visible(appStore.selectedScreenId! > 0),
                    GestureDetector(
                      child: tooltipView(
                        message: language!.viewSourceCode,
                        child: outLineIconButton(context, sourceCodeIcon(context)),
                      ),
                      onTap: () {
                        viewSourceCode(context);
                      },
                    ).visible(appStore.selectedScreenId! > 0),
                    GestureDetector(
                      child: tooltipView(
                        message: language!.clearCurrentScreenData,
                        child: outLineIconButton(context, clearIcon(context)),
                      ),
                      onTap: () {
                        showInDialog(
                          context,
                          builder: (context) {
                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(language!.areYouClearScreenData, style: primaryTextStyle()),
                                30.height,
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    dialogGrayBorderButton(
                                      text: language!.cancel,
                                      onTap: () {
                                        finish(context);
                                      },
                                    ),
                                    16.width,
                                    SizedBox(
                                      height: 36,
                                      width: 110,
                                      child: TextButton(
                                        child: Text(language!.clear, style: TextStyle(color: Colors.red, fontSize: btnTextSize)),
                                        style: TextButton.styleFrom(
                                          backgroundColor: Colors.red.withValues(alpha: 0.1),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(COMMON_BUTTON_BORDER_RADIUS), side: BorderSide(color: Colors.red, width: 0.5)),
                                        ),
                                        onPressed: () {
                                          trackUserEvent(CLEAR_DATA);
                                          finish(context);
                                          appStore.resetView();
                                        },
                                      ),
                                    )
                                  ],
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ).visible(appStore.selectedScreenId! > 0),
                    GestureDetector(
                      child: tooltipView(
                        message: language!.deleteScreen,
                        child: deleteIconOutline(context),
                      ),
                      onTap: () {
                        deleteConfirmationDialog(
                          context: context,
                          messageText: language!.areYouWantDeleteScreen,
                          onAccept: () {
                            finish(context);
                            trackUserEvent(DELETE_SCREEN);
                            deleteScreenApi(screenId: appStore.selectedDropdownScreen!.id);
                          },
                        );
                      },
                    ).visible(appStore.selectedScreenId! > 0),
                  ],
                ).paddingOnly(left: 16),
                16.height,
                Divider(color: COMMON_BORDER_COLOR),
              ],
            ),
          ),
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
