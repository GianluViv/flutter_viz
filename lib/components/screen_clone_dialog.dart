import 'dart:convert';

import 'package:flutter_viz/local_storage/local_project_service.dart';
import 'package:flutter_viz/utils/AppConstant.dart';
import 'package:flutter_viz/utils/AppFunctions.dart';
import 'package:flutter_viz/utils/AppWidget.dart';
import 'package:flutter_viz/widgets/screen_json_parser_class.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';

import '../main.dart';

class ScreenCloneDialog extends StatefulWidget {
  static String tag = '/ScreenCloneDialog';

  final bool isEdit;

  ScreenCloneDialog({this.isEdit = false});

  @override
  ScreenCloneDialogState createState() => ScreenCloneDialogState();
}

class ScreenCloneDialogState extends State<ScreenCloneDialog> {
  TextEditingController screenController = TextEditingController();

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    if (widget.isEdit) {
      screenController.text = appStore.selectedDropdownScreen!.name!;
    }
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  ///add screen — local equivalent of the old addScreen() REST call.
  Future<void> addScreenApi() async {
    trackUserEvent(SAVE_SCREEN);
    if (screenController.text.trim().isEmpty)
      return getToast(errorThisFieldRequired);
    else if (!screenController.text.startsWith(RegExp(r'[A-Za-z]'))) return getToast(language!.screenNameValidationMsg);
    hideKeyboard(context);
    appStore.setLoading(true);

    if (widget.isEdit) {
      try {
        await locator<LocalProjectService>().renameScreen(appStore.currentProject!, appStore.selectedScreenId!, screenController.text);
        appStore.setLoading(false);
        appStore.updateScreenName(screenController.text, appStore.selectedScreenId);
        appStore.fileName = screenController.text;
        LiveStream().emit(updateScreenList);
        finish(context);
      } catch (e) {
        appStore.setLoading(false);
        finish(context);
        getToast(e.toString());
      }
      return;
    }

    trackUserEvent(SCREEN_CLONE);
    screenshotController.capture(delay: Duration(milliseconds: 10)).then((capturedImage) async {
      String screenImage = base64.encode(capturedImage!);
      Map<String, dynamic> rootScreenDataJson = await widgetClassToJsonData();

      try {
        final service = locator<LocalProjectService>();
        final screen = await service.addScreen(
          appStore.currentProject!,
          name: screenController.text,
          screenJsonData: json.encode(rootScreenDataJson),
        );
        await service.updateScreenData(appStore.currentProject!, screen.id!, screenImage: screenImage);
        screen.screenImage = screenImage;
        appStore.setLoading(false);
        appStore.screenList.add(screen);

        /// Showing added screen data
        appStore.selectedDropdownScreen = appStore.screenList[appStore.screenList.length - 1];
        appStore.setScreenDetails(appStore.screenList[appStore.screenList.length - 1]);
        applyScreenJsonToView(appStore.screenList[appStore.screenList.length - 1].screenJsonData);
        LiveStream().emit(updateScreenList);
        finish(context);
      } catch (e) {
        appStore.setLoading(false);
        finish(context);
        getToast(e.toString());
      }
    }).catchError((onError) {
      print(onError);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: context.width() * 0.3,
      height: 200,
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(language!.newScreenName, style: boldTextStyle(size: 20)),
                  CloseButton(),
                ],
              ),
              30.height,
              AppTextField(
                controller: screenController,
                textFieldType: TextFieldType.NAME,
                decoration: commonInputDecoration(hintName: 'Screen name'),
                textStyle: primaryTextStyle(),
                autoFocus: false,
                maxLines: 1,
              ),
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
                  dialogPrimaryColorButton(
                    text: language!.save,
                    onTap: () {
                      addScreenApi();
                    },
                  ),
                ],
              ),
            ],
          ),
          Observer(builder: (_) => loadingAnimation().visible(appStore.isLoading)).center(),
        ],
      ),
    );
  }
}
