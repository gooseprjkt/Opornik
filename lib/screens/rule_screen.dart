import 'package:flutter/material.dart';
import '../models/rule.dart';
import '../utils/markup_formatter.dart';

class RuleScreen extends StatelessWidget {
  final Rule rule;

  const RuleScreen({
    super.key,
    required this.rule,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(rule.annotation),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (rule.annotation.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  rule.annotation,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
            
            MarkupFormatter.formatContent(context, rule.content, rule.contentMarkup),
          ],
        ),
      ),
    );
  }
}
