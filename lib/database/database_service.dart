import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../models/index.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  List<Part>? _parts;
  List<Chapter>? _chapters;
  List<Section>? _sections;
  List<Rule>? _rules;

  Future<void> _loadData() async {
    if (_parts != null) return;

    String partsJson = await rootBundle.loadString('assets/part.json');
    String chaptersJson = await rootBundle.loadString('assets/chapter.json');
    String sectionsJson = await rootBundle.loadString('assets/section_core.json');
    String rulesJson = await rootBundle.loadString('assets/rule_core.json');

    List partsList = json.decode(partsJson);
    List chaptersList = json.decode(chaptersJson);
    List sectionsList = json.decode(sectionsJson);
    List rulesList = json.decode(rulesJson);

    _parts = partsList.map((json) => Part.fromJson(json)).toList();
    _chapters = chaptersList.map((json) => Chapter.fromJson(json)).toList();
    _sections = sectionsList.map((json) => Section.fromJson(json)).toList();
    _rules = rulesList.map((json) => Rule.fromJson(json)).toList();
  }

  Future<List<Part>> getParts() async {
    await _loadData();
    return _parts ?? [];
  }

  Future<List<Chapter>> getChapters({int? partId}) async {
    await _loadData();
    if (partId != null) {
      return _chapters!.where((chapter) => chapter.partId == partId).toList();
    }
    return _chapters ?? [];
  }

  Future<List<Section>> getSections({int? chapterId}) async {
    await _loadData();
    if (chapterId != null) {
      return _sections!.where((section) => section.chapterId == chapterId).toList();
    }
    return _sections ?? [];
  }

  Future<List<Rule>> getRules({int? sectionId}) async {
    await _loadData();
    if (sectionId != null) {
      return _rules!.where((rule) => rule.sectionId == sectionId).toList();
    }
    return _rules ?? [];
  }

  Future<Rule> getRuleById(int id) async {
    await _loadData();
    final rule = _rules!.firstWhere((rule) => rule.id == id, orElse: () => throw Exception('Rule not found with id: $id'));
    return rule;
  }

  Future<List<Rule>> searchRules(String query) async {
    await _loadData();
    if (query.isEmpty) {
      return [];
    }

    String lowerQuery = query.toLowerCase();
    return _rules!.where((rule) {
      return rule.annotation.toLowerCase().contains(lowerQuery) ||
             rule.content.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  Future<Section> getSectionWithChapter(int sectionId) async {
    await _loadData();
    final section = _sections!.firstWhere((section) => section.id == sectionId, orElse: () => throw Exception('Section not found with id: $sectionId'));
    return section;
  }

  Future<Chapter> getChapterWithPart(int chapterId) async {
    await _loadData();
    final chapter = _chapters!.firstWhere((chapter) => chapter.id == chapterId, orElse: () => throw Exception('Chapter not found with id: $chapterId'));
    return chapter;
  }
}
