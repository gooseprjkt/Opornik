import 'package:flutter/material.dart';
import '../database/database_service.dart';
import '../models/section.dart';
import 'section_screen.dart';

class ChapterScreen extends StatefulWidget {
  final int chapterId;
  final String chapterName;

  const ChapterScreen({
    super.key,
    required this.chapterId,
    required this.chapterName,
  });

  @override
  State<ChapterScreen> createState() => _ChapterScreenState();
}

class _ChapterScreenState extends State<ChapterScreen> {
  late Future<List<Section>> _sectionsFuture;

  @override
  void initState() {
    super.initState();
    _sectionsFuture = DatabaseService().getSections(chapterId: widget.chapterId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.chapterName),
        centerTitle: true,
      ),
      body: FutureBuilder<List<Section>>(
        future: _sectionsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Секций нет :('));
          } else {
            final sections = snapshot.data!;
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: sections.length,
              itemBuilder: (context, index) {
                final section = sections[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    title: Text(
                      section.name,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SectionScreen(
                            sectionId: section.id,
                            sectionName: section.name,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
