import 'package:flutter/material.dart';
import '../database/database_service.dart';
import '../models/rule.dart';
import 'rule_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  late Future<List<Rule>> _searchResultsFuture;

  @override
  void initState() {
    super.initState();
    _searchResultsFuture = DatabaseService().searchRules('');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: 'Поиск правил...',
            border: InputBorder.none,
          ),
          textInputAction: TextInputAction.search,
          onSubmitted: _performSearch,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _performSearch(_searchController.text),
          ),
        ],
      ),
      body: FutureBuilder<List<Rule>>(
        future: _searchResultsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Не найдено :('));
          } else {
            final results = snapshot.data!;
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: results.length,
              itemBuilder: (context, index) {
                final rule = results[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    title: Text(
                      rule.annotation,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    subtitle: Text(
                      rule.content.length > 100 
                          ? '${rule.content.substring(0, 100)}...' 
                          : rule.content,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RuleScreen(rule: rule),
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

  void _performSearch(String query) {
    setState(() {
      _searchResultsFuture = DatabaseService().searchRules(query);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
