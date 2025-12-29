class Part {
  final int id;
  final String name;

  Part({
    required this.id,
    required this.name,
  });

  factory Part.fromJson(Map<String, dynamic> json) {
    return Part(
      id: json['id'] as int,
      name: json['name'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}