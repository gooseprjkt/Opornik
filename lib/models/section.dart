class Section {
  final int id;
  final int chapterId;
  final String name;
  final String markup;

  Section({
    required this.id,
    required this.chapterId,
    required this.name,
    required this.markup,
  });

  factory Section.fromJson(Map<String, dynamic> json) {
    return Section(
      id: json['id'] as int,
      chapterId: json['chapter_id'] as int,
      name: json['name'] as String,
      markup: json['markup'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'chapter_id': chapterId,
      'name': name,
      'markup': markup,
    };
  }
}