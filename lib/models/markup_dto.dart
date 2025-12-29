import 'span.dart';

class MarkupDto {
  final List<ParagraphSpan> paragraphSpans;
  final List<CharacterSpan> characterSpans;
  final List<LinkSpan> linkSpans;

  MarkupDto({
    required this.paragraphSpans,
    required this.characterSpans,
    required this.linkSpans,
  });

  factory MarkupDto.fromJson(Map<String, dynamic> json) {
    return MarkupDto(
      paragraphSpans: (json['ps'] as List)
          .map((item) => ParagraphSpan.fromJson(item as Map<String, dynamic>))
          .toList(),
      characterSpans: (json['cs'] as List)
          .map((item) => CharacterSpan.fromJson(item as Map<String, dynamic>))
          .toList(),
      linkSpans: (json['ls'] as List)
          .map((item) => LinkSpan.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ps': paragraphSpans.map((span) => span.toJson()).toList(),
      'cs': characterSpans.map((span) => span.toJson()).toList(),
      'ls': linkSpans.map((span) => span.toJson()).toList(),
    };
  }
}