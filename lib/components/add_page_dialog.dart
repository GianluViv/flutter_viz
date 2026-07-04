import 'dart:convert';

import 'package:vivido/local_storage/local_project_service.dart';
import 'package:vivido/model/screen_list_response.dart';
import 'package:vivido/templates/page_template.dart';
import 'package:vivido/templates/template_library_service.dart';
import 'package:vivido/templates/template_theme.dart';
import 'package:vivido/utils/AppConstant.dart';
import 'package:vivido/utils/AppFunctions.dart';
import 'package:vivido/utils/AppWidget.dart';
import 'package:vivido/widgets/screen_json_parser_class.dart';
import 'package:vivido/widgetsProperty/comman_property_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';

import '../main.dart';

class AddPageDialog extends StatefulWidget {
  static String tag = '/AddTemplateDialog';

  @override
  AddPageDialogState createState() => AddPageDialogState();
}

class AddPageDialogState extends State<AddPageDialog> {
  TextEditingController pageNameController = TextEditingController();

  Color _themeColor = kTemplateBaseColor;
  List<PageTemplate> _templates = [];
  bool _loadingTemplates = true;

  @override
  void initState() {
    super.initState();
    trackScreenView(PRE_BUILD_SCREEN);
    _loadTemplates();
  }

  Future<void> _loadTemplates() async {
    final all = await locator<TemplateLibraryService>().allTemplates();
    if (!mounted) return;
    setState(() {
      _templates = all;
      _loadingTemplates = false;
    });
  }

  /// Screen names double as Dart identifiers downstream, so keep them
  /// alphanumeric and short — mirrors the constraints on the name field.
  String _sanitizeName(String raw) {
    final cleaned = raw.replaceAll(RegExp('[^0-9a-zA-Z]'), '');
    return cleaned.length > 15 ? cleaned.substring(0, 15) : cleaned;
  }

  /// Creates a new page in the current local project via LocalProjectService,
  /// replacing the old addScreen() REST call.
  Future<void> addScreenApi({required String name, String? rootScreenData}) async {
    hideKeyboard(context);
    appStore.setLoading(true);

    try {
      final screen = await locator<LocalProjectService>().addScreen(
        appStore.currentProject!,
        name: name,
        screenJsonData: rootScreenData,
      );
      appStore.screenList.add(screen);

      /// Showing added screen data
      appStore.selectedDropdownScreen = appStore.screenList[appStore.screenList.length - 1];
      appStore.setScreenDetails(appStore.screenList[appStore.screenList.length - 1]);
      applyScreenJsonToView(appStore.screenList[appStore.screenList.length - 1].screenJsonData);
      LiveStream().emit(updateScreenList);
      if (rootScreenData != null) {
        Future.delayed(Duration(seconds: 1), () async {
          await updateScreenImageApi(screen);
        });
      } else {
        appStore.setLoading(false);
        finish(context);
      }
    } catch (e) {
      appStore.setLoading(false);
      finish(context);
      getToast(e.toString());
    }
  }

  Future<void> updateScreenImageApi(ScreenListData screen) async {
    screenshotController.capture(delay: Duration(milliseconds: 10)).then((capturedImage) async {
      String screenImage = base64.encode(capturedImage!);
      await locator<LocalProjectService>().updateScreenData(appStore.currentProject!, screen.id!, screenImage: screenImage);
      appStore.setLoading(false);
      finish(context);
      appStore.updateScreenImage(screenImage, appStore.selectedScreenId);
    }).catchError((onError) {
      print(onError);
    });
  }

  void _createBlank() {
    final name = _sanitizeName(pageNameController.text);
    if (name.isEmpty) {
      getToast(language!.enterScreenText);
      return;
    }
    addScreenApi(name: name);
  }

  void _createFromTemplate(PageTemplate template) {
    final typed = _sanitizeName(pageNameController.text);
    final name = typed.isNotEmpty ? typed : _sanitizeName(template.name);
    final recolored = template.builtin
        ? recolorScreenJson(template.screenJsonData, from: kTemplateBaseColor, to: _themeColor)
        : template.screenJsonData;
    addScreenApi(name: name, rootScreenData: recolored);
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 760,
      child: Stack(
        alignment: AlignmentDirectional.center,
        children: [
          Observer(builder: (_) {
            if (appStore.isLoading) {
              return SizedBox(height: 200, child: loadingAnimation().center());
            }
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(language!.createScreen, style: boldTextStyle(size: 22)),
                      CloseButton(),
                    ],
                  ),
                  8.height,
                  Text(language!.enterScreenText, style: secondaryTextStyle()),
                  16.height,
                  AppTextField(
                    controller: pageNameController,
                    textFieldType: TextFieldType.NAME,
                    decoration: commonInputDecoration(hintName: "Screen Name"),
                    textStyle: primaryTextStyle(),
                    autoFocus: false,
                    maxLines: 1,
                    maxLength: 15,
                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp("[0-9a-zA-Z]"))],
                  ),
                  16.height,
                  _themeSelector(),
                  20.height,
                  Text("Modelli", style: boldTextStyle(size: 16)),
                  12.height,
                  _templateGrid(),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _themeSelector() {
    final bool customSelected = !kPresetThemes.any((t) => t.color.toARGB32() == _themeColor.toARGB32());
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Tema colore", style: boldTextStyle(size: 16)),
        10.height,
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            ...kPresetThemes.map((theme) => _swatch(theme.color, theme.color.toARGB32() == _themeColor.toARGB32())),
            GestureDetector(
              onTap: () {
                showColorPicker(context, _themeColor, applyOnWidget: (c) {
                  setState(() => _themeColor = c);
                });
              },
              child: Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: SweepGradient(colors: [Colors.red, Colors.green, Colors.blue, Colors.red]),
                  border: Border.all(color: customSelected ? Colors.black : Colors.grey.withValues(alpha: 0.4), width: customSelected ? 3 : 1),
                ),
                child: Icon(Icons.colorize, size: 16, color: Colors.white),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _swatch(Color color, bool selected) {
    return GestureDetector(
      onTap: () => setState(() => _themeColor = color),
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: selected ? Colors.black : Colors.transparent, width: 3),
        ),
        child: selected ? Icon(Icons.check, size: 16, color: Colors.white) : null,
      ),
    );
  }

  Widget _templateGrid() {
    if (_loadingTemplates) {
      return SizedBox(height: 120, child: loadingAnimation().center());
    }
    return Wrap(
      spacing: 14,
      runSpacing: 14,
      children: [
        _blankCard(),
        ..._templates.map(_templateCard),
      ],
    );
  }

  Widget _blankCard() {
    return _cardShell(
      onTap: _createBlank,
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.withValues(alpha: 0.4), width: 1.2, style: BorderStyle.solid),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add, size: 30, color: Colors.grey),
            8.height,
            Text("Vuota", style: primaryTextStyle(size: 13)),
          ],
        ),
      ),
      name: "Pagina vuota",
    );
  }

  Widget _templateCard(PageTemplate template) {
    Widget preview;
    if (template.previewImage != null && template.previewImage!.isNotEmpty) {
      preview = ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.memory(base64Decode(template.previewImage!), fit: BoxFit.cover, width: double.infinity),
      );
    } else {
      preview = _mockPreview(template);
    }
    return _cardShell(onTap: () => _createFromTemplate(template), child: preview, name: template.name);
  }

  /// A lightweight stylized mock for built-in templates (which ship without a
  /// captured screenshot), tinted with the currently selected theme color.
  Widget _mockPreview(PageTemplate template) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.25)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 40,
            color: _themeColor,
            alignment: Alignment.center,
            child: Text(template.name, style: boldTextStyle(color: Colors.white, size: 12)),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _bar(width: 44, color: _themeColor.withValues(alpha: 0.25)),
                  8.height,
                  _bar(width: double.infinity),
                  6.height,
                  _bar(width: double.infinity),
                  6.height,
                  _bar(width: 60),
                  10.height,
                  Container(height: 12, width: double.infinity, decoration: BoxDecoration(color: _themeColor, borderRadius: BorderRadius.circular(4))),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bar({required double width, Color? color}) {
    return Container(
      height: 8,
      width: width,
      decoration: BoxDecoration(color: color ?? Colors.grey.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(4)),
    );
  }

  Widget _cardShell({required Widget child, required VoidCallback onTap, required String name}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 150,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 170, width: 150, child: child),
            6.height,
            Text(name, style: primaryTextStyle(size: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }
}
