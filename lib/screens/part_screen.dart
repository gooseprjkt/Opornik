import 'package:flutter/material.dart';
import '../database/database_service.dart';
import '../models/chapter.dart';
import 'chapter_screen.dart';

class PartScreen extends StatefulWidget {
  final int partId;
  final String partName;

  const PartScreen({
    super.key,
    required this.partId,
    required this.partName,
  });

  @override
  State<PartScreen> createState() => _PartScreenState();
}

class _PartScreenState extends State<PartScreen> {
  late Future<List<Chapter>> _chaptersFuture;

  @override
  void initState() {
    super.initState();
    _chaptersFuture = DatabaseService().getChapters(partId: widget.partId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.partName),
        centerTitle: true,
      ),
      body: FutureBuilder<List<Chapter>>(
        future: _chaptersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No chapters available'));
          } else {
            final chapters = snapshot.data!;
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: chapters.length,
              itemBuilder: (context, index) {
                final chapter = chapters[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
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
                );
              },
            );
          }
        },
      ),
    );
  }
}