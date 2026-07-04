/// A page template that can seed a new screen. [screenJsonData] is the exact
/// string consumed by `applyScreenJsonToView` / stored in `ScreenListData`.
///
/// Built-in templates are authored in code (see `builtin_templates.dart`);
/// user templates are saved to disk by `TemplateLibraryService` and carry a
/// base64 [previewImage] captured from the canvas.
class PageTemplate {
  final String id;
  final String category;
  final String name;
  final String screenJsonData;
  final String? previewImage;
  final bool builtin;

  const PageTemplate({
    required this.id,
    required this.category,
    required this.name,
    required this.screenJsonData,
    this.previewImage,
    this.builtin = false,
  });

  factory PageTemplate.fromJson(Map<String, dynamic> json) {
    return PageTemplate(
      id: json['id'] as String,
      category: json['category'] as String? ?? 'Custom',
      name: json['name'] as String? ?? 'Template',
      screenJsonData: json['screenJsonData'] as String,
      previewImage: json['previewImage'] as String?,
      builtin: false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'category': category,
        'name': name,
        'screenJsonData': screenJsonData,
        'previewImage': previewImage,
      };
}
