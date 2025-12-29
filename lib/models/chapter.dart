class Chapter {
  final int id;
  final int partId;
  final String name;

  Chapter({
    required this.id,
    required this.partId,
    required this.name,
  });

  factory Chapter.fromJson(Map<String, dynamic> json) {
    return Chapter(
      id: json['id'] as int,
      partId: json['part_id'] as int,
      name: json['name'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'part_id': partId,
      'name': name,
    };
  }
}