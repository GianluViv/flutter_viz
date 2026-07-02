import 'dart:io';

import 'package:flutter_viz/externalClasses/on_hover.dart';
import 'package:flutter_viz/local_storage/local_project_service.dart';
import 'package:flutter_viz/main.dart';
import 'package:flutter_viz/model/download_model.dart';
import 'package:flutter_viz/screen/preview_screen.dart';
import 'package:flutter_viz/screen/welcome_screen.dart';
import 'package:flutter_viz/utils/AppColors.dart';
import 'package:flutter_viz/utils/AppCommon.dart';
import 'package:flutter_viz/utils/AppCommonApiCall.dart';
import 'package:flutter_viz/utils/AppConstant.dart';
import 'package:flutter_viz/utils/AppFunctions.dart';
import 'package:flutter_viz/utils/AppWidget.dart';
import 'package:flutter_viz/widgets/screen_json_parser_class.dart';
import 'package:flutter_viz/widgets/widgets.dart';
import 'package:flutter_viz/widgetsProperty/comman_property_view.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lottie/lottie.dart';
import 'package:nb_utils/nb_utils.dart';

class HeaderComponent extends StatefulWidget {
  @override
  _HeaderComponentState createState() => _HeaderComponentState();
}

class _HeaderComponentState extends State<HeaderComponent> {
  TextEditingController screenController = TextEditingController();
  bool isDarkMode = appStore.isDarkMode;

  /// Zips the whole project folder (project.json, media/, export/) into a
  /// single `.fwz` file wherever the user picks.
  Future<void> exportProjectAsFwz() async {
    final project = appStore.currentProject;
    if (project == null) return;
    try {
      final savePath = await FilePicker.platform.saveFile(
        dialogTitle: "Export Project",
        fileName: "${getFileName(projectFileName: project.name)}.fwz",
        type: FileType.custom,
        allowedExtensions: ['fwz'],
      );
      if (savePath == null) return;

      final outputPath = savePath.endsWith('.fwz') ? savePath : '$savePath.fwz';
      await locator<LocalProjectService>().exportToFwz(project, File(outputPath));
      getToast("Exported to $outputPath");
    } catch (e) {
      log("project .fwz export failed: $e");
      getToast(e.toString());
    }
  }

  /// Generates the Dart source for every screen and writes all the files into a
  /// folder the user picks, ready to be dropped into a real Flutter project.
  Future<void> exportProjectSource() async {
    final project = appStore.currentProject;
    if (project == null) return;

    final dirPath = await FilePicker.platform.getDirectoryPath(
      dialogTitle: language!.downloadProject,
    );
    if (dirPath == null) return;

    appStore.setProjectDownloading(true);
    try {
      // Keyed by file name so screens/helpers with the same name are written once.
      final Map<String, String> files = {};

      for (final screen in appStore.screenList) {
        appStore.codeViewData.clear();
        appStore.headerImport.clear();
        appStore.yamlImportLib.clear();

        DownloadModel aDownloadModel = await applyScreenJsonToView(screen.screenJsonData, isForDownload: true);
        aDownloadModel.fileName = screen.name;
        final filesContent = await viewFinalSourceData(aDownloadModel.selectedWidgetList, downloadModel: aDownloadModel);

        files["${getFileName(projectFileName: aDownloadModel.fileName)}.dart"] = filesContent.join();

        // External helper classes referenced by this screen.
        for (final import in appStore.headerImport) {
          final rawName = import.replaceAll("import ", "").replaceAll("'", "").replaceAll(";", "").trim();
          if (rawName.startsWith('package:') || rawName.startsWith('dart:')) continue;
          final fileName = rawName.split('/').last;
          if (files.containsKey(fileName)) continue;
          String fileContent = await loadFileContent(rawName);
          fileContent = fileContent.replaceAll("package:flutter_viz/externalClasses/", '');
          files[fileName] = fileContent;
        }
      }

      for (final entry in files.entries) {
        await File('$dirPath${Platform.pathSeparator}${entry.key}').writeAsString(entry.value);
      }

      appStore.setProjectDownloading(false);
      trackUserEvent(DOWNLOAD_PROJECT_CODE);
      getToast("Exported to $dirPath");
    } catch (e) {
      appStore.setProjectDownloading(false);
      log("project source export failed: $e");
      getToast(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Observer(builder: (_) {
      return Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(color: context.scaffoldBackgroundColor),
        child: (appStore.selectedMenu == SCREEN_LIST_INDEX || appStore.selectedMenu == WIDGETS_INDEX || appStore.selectedMenu == TREE_INDEX || appStore.selectedMenu == PRE_COMPONENTS_INDEX)
            ? Row(
                children: [
                  getHeaderLogoImage(),
                  16.width,
                  OnHover(
                    builder: (isHovered) {
                      return elevationButtonWithText(
                        isHovered: isHovered,
                        toolTipMessage: "My Projects",
                        image: 'project_white.svg',
                        title: "My Projects",
                        onPressed: () {
                          appStore.isProjectDownloading = false;
                          WelcomeScreen().launch(getContext, isNewTask: true);
                        },
                      );
                    },
                  ),
                  16.width,
                  OnHover(builder: (isHovered) {
                    return elevationButtonWithIcon(
                      isHovered: isHovered,
                      toolTipMessage: language!.save,
                      icon: Icons.save,
                      title: language!.save,
                      onPressed: () async {
                        if (appStore.isProjectDownloading) {
                          getToast(language!.downloadingInProgress);
                        } else if (appStore.selectedScreenId! > 0) {
                          saveScreenApi();
                        }
                      },
                    );
                  }),
                  16.width,
                  OnHover(builder: (isHovered) {
                    return elevationButtonHighLightColor(
                      isHovered: isHovered,
                      child: highLightIcon(isHovered, icon: Icons.undo),
                      toolTipMessage: "Undo",
                      onPressed: () {
                        if (appStore.canUndo()) {
                          appStore.undo();
                        } else {
                          getToast("Nothing to undo");
                        }
                      },
                    );
                  }),
                  8.width,
                  OnHover(builder: (isHovered) {
                    return elevationButtonHighLightColor(
                      isHovered: isHovered,
                      child: highLightIcon(isHovered, icon: Icons.redo),
                      toolTipMessage: "Redo",
                      onPressed: () {
                        if (appStore.canRedo()) {
                          appStore.redo();
                        } else {
                          getToast("Nothing to redo");
                        }
                      },
                    );
                  }),
                  16.width,
                  OnHover(builder: (isHovered) {
                    return elevationButtonHighLightColor(
                      isHovered: isHovered,
                      child: fwzIcon(isHovered),
                      toolTipMessage: "Export Project as .fwz",
                      onPressed: exportProjectAsFwz,
                    );
                  }),
                  16.width,
                  OnHover(builder: (isHovered) {
                    return Observer(
                      builder: (_) => elevationButtonHighLightColor(
                        isHovered: isHovered,
                        child: (appStore.isProjectDownloading)
                            ? Container(
                                width: 25,
                                height: 25,
                                child: Lottie.asset('images/loader.json').center(),
                              )
                            : highLightIcon(isHovered, icon: Icons.code),
                        toolTipMessage: (appStore.isProjectDownloading) ? language!.downloadingInProgress : "Export Dart code",
                        onPressed: () async {
                          if (appStore.isProjectDownloading) {
                            getToast(language!.downloadingInProgress);
                          } else {
                            exportProjectSource();
                          }
                        },
                      ),
                    );
                  }),
                  Spacer(),
                  OnHover(builder: (isHovered) {
                    return elevationButtonHighLightColor(
                      isHovered: isHovered,
                      child: SvgPicture.asset(
                        "${WidgetIconPath}preview.svg",
                        color: isHovered
                            ? btnBackgroundColor
                            : appStore.isDarkMode
                                ? Colors.white
                                : btnBackgroundColor,
                        height: btnIconSize,
                        width: btnIconSize,
                      ),
                      toolTipMessage: language!.preview,
                      onPressed: () async {
                        appStore.setPreviewCode(true);
                        PreviewScreen().launch(context);
                      },
                    );
                  }),
                  16.width,
                  darkModeSwitchWidget(),
                ],
              )
            : Row(
                children: [
                  getHeaderLogoImage(),
                  16.width,
                  darkModeSwitchWidget(),
                ],
              ),
      );
    });
  }
}
