import 'dart:convert';

import 'package:flutter_viz/local_storage/local_project_service.dart';
import 'package:flutter_viz/model/models.dart';
import 'package:flutter_viz/network/network_utils.dart';
import 'package:flutter_viz/network/rest_apis.dart';
import 'package:flutter_viz/utils/AppCommon.dart';
import 'package:flutter_viz/utils/AppFunctions.dart';
import 'package:flutter_viz/widgets/screen_json_parser_class.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nb_utils/nb_utils.dart';

import '../main.dart';
import 'AppConstant.dart';

/// Get Media List api call
Future<void> allMediaListApi() async {
  await getMediaList().then((value) async {
    appStore.mediaList.clear();
    appStore.mediaList.addAll(value.data!);
  }).catchError((e) {
    printLogData("${e.toString()}");
  });
}

Future uploadMedia(BuildContext context, {required Function() onUpdate}) async {
  final ImagePicker _picker = ImagePicker();
  List<XFile>? imageXFiles = [];
  List<MediaRequestModel> imageUint8List = [];
  imageXFiles = await _picker.pickMultiImage();
  imageXFiles.forEach((element) async {
    imageUint8List.add(MediaRequestModel(file: await element.readAsBytes(), fileName: element.name));
  });
  appStore.setLoading(true);
  Future.delayed(Duration(seconds: 5), () {
    if (imageUint8List.isNotEmpty) {
      addMediaApi(context, imageUint8List, onUpdate: onUpdate);
    }
  });
}

///add media url
Future<void> addMediaApi(BuildContext context, List<MediaRequestModel> imageUint8List, {required Function() onUpdate}) async {
  hideKeyboard(context);

  MultipartRequest multiPartRequest = await getMultiPartRequest('usermedia-save');
  multiPartRequest.fields['attachment_count'] = imageUint8List.length.toString();

  for (int i = 0; i < imageUint8List.length; i++) {
    final file = MultipartFile.fromBytes('user_attachment' + '_$i', imageUint8List[i].file!, filename: imageUint8List[i].fileName!);
    multiPartRequest.files.add(file);
  }

  multiPartRequest.headers.addAll(buildHeaderTokens());
  await sendMultiPartRequest(
    multiPartRequest,
    onSuccess: (data) async {
      appStore.setLoading(false);
      getToast("Media has been added successfully");
      onUpdate.call();
    },
    onError: (error) {
      appStore.setLoading(false);
    },
  ).catchError((e) {
    appStore.setLoading(false);
  });
}

/// Local equivalent of the old addScreen() REST save — flushes the current
/// screen to project.json via LocalProjectService (Ctrl+S / header save button).
Future<void> saveScreenApi() async {
  trackUserEvent(SAVE_SCREEN);
  if (appStore.currentProject == null) return;
  Map<String, dynamic> rootScreenDataJson = await widgetClassToJsonData();
  screenshotController.capture(delay: Duration(milliseconds: 10)).then((capturedImage) async {
    String? screenImage;
    if (rootScreenDataJson['widgetsData'].isNotEmpty ||
        rootScreenDataJson['appBarData'].isNotEmpty ||
        rootScreenDataJson['bottomBarNavigationData'].isNotEmpty ||
        rootScreenDataJson['drawerData'].isNotEmpty) {
      screenImage = base64.encode(capturedImage!);
    }
    String screenJsonData = json.encode(rootScreenDataJson);

    await locator<LocalProjectService>().updateScreenData(
      appStore.currentProject!,
      appStore.selectedScreenId!,
      screenJsonData: screenJsonData,
      screenImage: screenImage,
    );
    appStore.updateScreenNewData(screenJsonData, appStore.selectedScreenId);
    appStore.updateScreenImage(screenImage, appStore.selectedScreenId);
    getToast(language!.save);
  }).catchError((onError) {
    print(onError);
  });
}
