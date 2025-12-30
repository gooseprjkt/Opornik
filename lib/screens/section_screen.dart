import 'package:flutter/material.dart';
import '../database/database_service.dart';
import '../models/rule.dart';
import 'rule_screen.dart';

class SectionScreen extends StatefulWidget {
  final int sectionId;
  final String sectionName;

  const SectionScreen({
    super.key,
    required this.sectionId,
    required this.sectionName,
  });

  @override
  State<SectionScreen> createState() => _SectionScreenState();
}

class _SectionScreenState extends State<SectionScreen> {
  late Future<List<Rule>> _rulesFuture;

  @override
  void initState() {
    super.initState();
    _rulesFuture = DatabaseService().getRules(sectionId: widget.sectionId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.sectionName),
        centerTitle: true,
      ),
      body: FutureBuilder<List<Rule>>(
        future: _rulesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Ошибка: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Правил нет :('));
          } else {
            final rules = snapshot.data!;
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: rules.length,
              itemBuilder: (context, index) {
                final rule = rules[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    title: Text(
                      rule.annotation,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    subtitle: Text(
                      rule.content.length > 100 ? '${rule.content.substring(0, 100)}...' : rule.content,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RuleScreen(
                            rule: rule,
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
