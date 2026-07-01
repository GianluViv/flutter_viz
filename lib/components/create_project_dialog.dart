import 'package:flutter_viz/local_storage/local_project_service.dart';
import 'package:flutter_viz/main.dart';
import 'package:flutter_viz/screen/dashboard_screen.dart';
import 'package:flutter_viz/utils/AppConstant.dart';
import 'package:flutter_viz/utils/AppFunctions.dart';
import 'package:flutter_viz/utils/AppWidget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';

class CreateProjectDialog extends StatefulWidget {
  static String tag = '/CreateProjectDialog';

  @override
  CreateProjectDialogState createState() => CreateProjectDialogState();
}

class CreateProjectDialogState extends State<CreateProjectDialog> {
  final formKey = GlobalKey<FormState>();

  TextEditingController projectNameController = TextEditingController();

  /// Creates a project folder on disk (project.json + media/ + export/), adds a
  /// default "Home Screen", and jumps straight into the editor.
  Future<void> createProject() async {
    if (!formKey.currentState!.validate()) return;
    hideKeyboard(context);
    formKey.currentState!.save();
    appStore.setLoading(true);

    try {
      final service = locator<LocalProjectService>();
      final project = await service.newProject(projectNameController.text.trim());
      await service.addScreen(project, name: "Home Screen");
      appStore.setLoading(false);
      appStore.loadProject(project);
      appStore.selectedMenu = WIDGETS_INDEX;
      DashboardScreen().launch(context, isNewTask: true);
    } catch (e) {
      appStore.setLoading(false);
      getToast(e.toString());
    }
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 500,
      child: Stack(
        alignment: AlignmentDirectional.center,
        children: [
          Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(language!.createProject, style: boldTextStyle(size: 22)),
                    CloseButton(),
                  ],
                ).paddingSymmetric(horizontal: 30),
                8.height,
                Text(language!.enterProjectText, style: secondaryTextStyle()).paddingSymmetric(horizontal: 30),
                16.height,
                AppTextField(
                  controller: projectNameController,
                  textFieldType: TextFieldType.NAME,
                  decoration: commonInputDecoration(hintName: "Project Name"),
                  textStyle: primaryTextStyle(),
                  autoFocus: false,
                  maxLines: 1,
                  maxLength: 30,
                  validator: (String? value) {
                    if (value!.isEmpty) return errorThisFieldRequired;
                    return null;
                  },
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.allow(RegExp("[0-9a-zA-Z ]")),
                  ],
                ).paddingSymmetric(horizontal: 30),
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
                      text: language!.createNew,
                      onTap: createProject,
                    ),
                  ],
                ).paddingSymmetric(horizontal: 30),
                16.height,
              ],
            ),
          ),
          Observer(builder: (context) => loadingAnimation().visible(appStore.isLoading)).center(),
        ],
      ),
    );
  }
}
