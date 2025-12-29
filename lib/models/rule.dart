import 'section.dart';

class Rule {
  final int id;
  final int sectionId;
  final String annotation;
  final String annotationMarkup;
  final String content;
  final String contentMarkup;
  final Section? section;

  Rule({
    required this.id,
    required this.sectionId,
    required this.annotation,
    required this.annotationMarkup,
    required this.content,
    required this.contentMarkup,
    this.section,
  });

  factory Rule.fromJson(Map<String, dynamic> json) {
    Section? section;
    if (json['section'] != null) {
      section = Section.fromJson(json['section'] as Map<String, dynamic>);
    }

    return Rule(
      id: json['id'] as int,
      sectionId: json['section_id'] as int,
      annotation: json['annotation'] as String,
      annotationMarkup: json['annotation_markup'] as String,
      content: json['content'] as String,
      contentMarkup: json['content_markup'] as String,
      section: section,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'section_id': sectionId,
      'annotation': annotation,
      'annotation_markup': annotationMarkup,
      'content': content,
      'content_markup': contentMarkup,
      if (section != null) 'section': section!.toJson(),
    };
  }
}