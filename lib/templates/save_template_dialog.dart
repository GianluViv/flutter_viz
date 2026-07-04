import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:vivido/main.dart';
import 'package:vivido/templates/template_library_service.dart';
import 'package:vivido/utils/AppFunctions.dart';
import 'package:vivido/utils/AppWidget.dart';
import 'package:vivido/widgets/screen_json_parser_class.dart';
import 'package:nb_utils/nb_utils.dart';

/// Saves the current canvas as a reusable local template (widget JSON + a
/// captured preview) into [TemplateLibraryService]. This is how the template
/// library grows from real pages the user designs.
class SaveTemplateDialog extends StatefulWidget {
  @override
  State<SaveTemplateDialog> createState() => _SaveTemplateDialogState();
}

class _SaveTemplateDialogState extends State<SaveTemplateDialog> {
  final nameController = TextEditingController();
  final categoryController = TextEditingController(text: 'Custom');
  bool _saving = false;

  Future<void> _save() async {
    final name = nameController.text.trim();
    if (name.isEmpty) {
      getToast("Inserisci un nome");
      return;
    }
    setState(() => _saving = true);
    try {
      final Map<String, dynamic> screenData = await widgetClassToJsonData();
      final screenJsonData = jsonEncode(screenData);

      String? preview;
      try {
        final captured = await screenshotController.capture(delay: Duration(milliseconds: 10));
        if (captured != null) preview = base64.encode(captured);
      } catch (_) {
        // Preview is best-effort; a template is still valid without it.
      }

      await locator<TemplateLibraryService>().saveTemplate(
        name: name,
        category: categoryController.text.trim(),
        screenJsonData: screenJsonData,
        previewImage: preview,
      );
      if (!mounted) return;
      finish(context);
      getToast("Template salvato");
    } catch (e) {
      if (mounted) setState(() => _saving = false);
      getToast(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 420,
      child: _saving
          ? SizedBox(height: 140, child: loadingAnimation().center())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Salva come template", style: boldTextStyle(size: 20)),
                    CloseButton(),
                  ],
                ),
                8.height,
                Text("Salva la pagina corrente nella tua libreria di modelli.", style: secondaryTextStyle()),
                16.height,
                AppTextField(
                  controller: nameController,
                  textFieldType: TextFieldType.NAME,
                  decoration: commonInputDecoration(hintName: "Nome template"),
                  textStyle: primaryTextStyle(),
                  autoFocus: true,
                ),
                12.height,
                AppTextField(
                  controller: categoryController,
                  textFieldType: TextFieldType.OTHER,
                  decoration: commonInputDecoration(hintName: "Categoria"),
                  textStyle: primaryTextStyle(),
                ),
                20.height,
                dialogPrimaryColorButton(text: "Salva", onTap: _save),
              ],
            ),
    );
  }
}
