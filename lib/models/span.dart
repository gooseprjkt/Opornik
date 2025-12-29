class ParagraphSpan {
  final int start;
  final int end;
  final String alignment;
  final Indent indent;

  ParagraphSpan({
    required this.start,
    required this.end,
    required this.alignment,
    required this.indent,
  });

  factory ParagraphSpan.fromJson(Map<String, dynamic> json) {
    return ParagraphSpan(
      start: json['s'] as int,
      end: json['e'] as int,
      alignment: json['a'] as String,
      indent: Indent.fromJson(json['i'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      's': start,
      'e': end,
      'a': alignment,
      'i': indent.toJson(),
    };
  }
}

class CharacterSpan {
  final int start;
  final int end;
  final String attribute;

  CharacterSpan({
    required this.start,
    required this.end,
    required this.attribute,
  });

  factory CharacterSpan.fromJson(Map<String, dynamic> json) {
    return CharacterSpan(
      start: json['s'] as int,
      end: json['e'] as int,
      attribute: json['a'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      's': start,
      'e': end,
      'a': attribute,
    };
  }
}

class LinkSpan {
  final int start;
  final int end;
  final int ruleId;

  LinkSpan({
    required this.start,
    required this.end,
    required this.ruleId,
  });

  factory LinkSpan.fromJson(Map<String, dynamic> json) {
    return LinkSpan(
      start: json['s'] as int,
      end: json['e'] as int,
      ruleId: json['ri'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      's': start,
      'e': end,
      'ri': ruleId,
    };
  }
}

class Indent {
  final int offset;
  final int indent;
  final String hangingType;

  Indent({
    required this.offset,
    required this.indent,
    required this.hangingType,
  });

  factory Indent.fromJson(Map<String, dynamic> json) {
    return Indent(
      offset: json['o'] as int,
      indent: json['i'] as int,
      hangingType: json['ht'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'o': offset,
      'i': indent,
      'ht': hangingType,
    };
  }
}