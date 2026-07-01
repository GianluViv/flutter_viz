import 'package:flutter_viz/components/add_screen_dialog.dart';
import 'package:flutter_viz/local_storage/local_project_service.dart';
import 'package:flutter_viz/main.dart';
import 'package:flutter_viz/model/screen_list_response.dart';
import 'package:flutter_viz/utils/AppColors.dart';
import 'package:flutter_viz/utils/AppConstant.dart';
import 'package:flutter_viz/utils/AppFunctions.dart';
import 'package:flutter_viz/widgets/screen_json_parser_class.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';

class ScreensPageComponents extends StatefulWidget {
  @override
  _ScreensPageComponentsState createState() => _ScreensPageComponentsState();
}

class _ScreensPageComponentsState extends State<ScreensPageComponents> {
  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    getScreenListApi();

    LiveStream().on(getUpdatedData, (value) {
      if (value == true) {
        getScreenListApi();
      }
    });
  }

  /// Reloads the screen list from project.json (local equivalent of getScreenList()).
  Future<void> getScreenListApi() async {
    if (appStore.currentProject == null) return;
    try {
      final reopened = await locator<LocalProjectService>().openProject(appStore.currentProject!.directory);
      appStore.currentProject = reopened;
      appStore.screenList.clear();
      appStore.screenList.add(ScreenListData(name: "New Screen", id: -1));
      appStore.screenList.addAll(reopened.screens);
    } catch (e) {
      getToast(e.toString());
    }
  }

  Future<void> deleteScreenApi({int? screenId}) async {
    if (appStore.currentProject == null || screenId == null) return;
    try {
      await locator<LocalProjectService>().deleteScreen(appStore.currentProject!, screenId);
      LiveStream().emit(getUpdatedData, true);
    } catch (e) {
      getToast(e.toString());
    }
  }

  @override
  void dispose() {
    super.dispose();
    LiveStream().dispose(getUpdatedData);
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) {
        return Container(
          color: appStore.isDarkMode ? darkModePrimaryColorBackground : Colors.white,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.add, color: btnBackgroundColor),
                      Text(language!.newScreen, style: primaryTextStyle(color: btnBackgroundColor)),
                    ],
                  ).onTap(() async {
                    bool? res = await showInDialog(context, title: Text(language!.addScreen), builder: (context) {
                      return AddScreenDialog();
                    });
                    if (res ?? false) {
                      setState(() {});
                    }
                  }),
                  Icon(Icons.refresh).onTap(() {
                    getScreenListApi();
                  })
                ],
              ).paddingAll(8),
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: appStore.screenList.length,
                  itemBuilder: (context, position) {
                    return GestureDetector(
                      child: Container(
                        alignment: Alignment.center,
                        height: 50,
                        margin: EdgeInsets.all(8),
                        padding: EdgeInsets.all(8),
                        child: Row(
                          children: [
                            Text("${appStore.screenList[position].name.validate()}", style: TextStyle()).expand(),
                            Icon(Icons.restore_from_trash, color: iconColor, size: 16).onTap(() async {
                              showConfirmDialog(
                                context,
                                language!.areYouSureDeleteScreen,
                                onAccept: () {
                                  deleteScreenApi(screenId: appStore.screenList[position].id.validate());
                                },
                                buttonColor: Colors.red,
                                positiveText: language!.delete,
                                negativeText: language!.cancel,
                              );
                            }),
                            8.width,
                            Icon(Icons.arrow_forward_ios_outlined, color: iconColor, size: 16),
                          ],
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border(left: BorderSide(color: (appStore.selectedScreenId == appStore.screenList[position].id) ? btnBackgroundColor : Colors.grey, width: 5)),
                        ),
                      ),
                      onTap: () {
                        appStore.setScreenDetails(appStore.screenList[position]);
                        applyScreenJsonToView(appStore.screenList[position].screenJsonData);
                        // setState(() {});
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
