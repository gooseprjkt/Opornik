import 'package:flutter/material.dart';
import '../database/database_service.dart';
import '../models/chapter.dart';
import '../models/part.dart';
import 'chapter_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<Map<Part, List<Chapter>>> _partsAndChaptersFuture;

  @override
  void initState() {
    super.initState();
    _partsAndChaptersFuture = _loadPartsAndChapters();
  }

  Future<Map<Part, List<Chapter>>> _loadPartsAndChapters() async {
    final parts = await DatabaseService().getParts();
    final Map<Part, List<Chapter>> partsAndChapters = {};

    for (final part in parts) {
      final chapters = await DatabaseService().getChapters(partId: part.id);
      partsAndChapters[part] = chapters;
    }

    return partsAndChapters;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<Map<Part, List<Chapter>>>(
        future: _partsAndChaptersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Ошибка: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Данных нет :('));
          } else {
            final partsAndChapters = snapshot.data!;
            
            List<Widget> items = [];
            
            for (final entry in partsAndChapters.entries) {
              final part = entry.key;
              final chapters = entry.value;
              
              items.add(Padding(
                padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
                child: Text(
                  part.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ));
              
              for (final chapter in chapters) {
                items.add(Card(
                  margin: const EdgeInsets.only(bottom: 12.0),
                  child: ListTile(
                    title: Text(
                      chapter.name,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChapterScreen(
                            chapterId: chapter.id,
                            chapterName: chapter.name,
                          ),
                        ),
                      );
                    },
                  ),
                ));
              }
            }
            
            return ListView(
              padding: const EdgeInsets.all(16),
              children: items,
            );
          }
        },
      ),
    );
  }
}
