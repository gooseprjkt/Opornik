import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/index.dart';

class MarkupFormatter {
  static Widget formatContent(BuildContext context, String content, String markupJson) {
    try {
      final markupDto = MarkupDto.fromJson(
        (jsonDecode(markupJson) as Map<String, dynamic>),
      );

      // Create the base text span
      TextSpan textSpan = TextSpan(
        text: content,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.6),
        children: _buildFormattedSpans(content, markupDto),
      );

      return SelectableText.rich(
        textSpan,
        textAlign: TextAlign.justify,
      );
    } catch (e) {
      // If there's an error in markup formatting, return plain text
      return SelectableText(
        content,
        textAlign: TextAlign.justify,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.6),
      );
    }
  }

  static List<InlineSpan> _buildFormattedSpans(String content, MarkupDto markupDto) {
    // Start with the full text as a single span
    List<FormattedSpan> formattedSpans = [
      FormattedSpan(0, content.length, const TextStyle(), content)
    ];

    // Apply character spans (for emphasis, bold, etc.)
    for (var charSpan in markupDto.characterSpans) {
      int start = charSpan.start;
      int end = charSpan.end;
      
      // Make sure the span indices are within bounds
      if (start >= 0 && end <= content.length && start < end) {
        String attribute = charSpan.attribute;
        TextStyle style = _getStyleForAttribute(attribute);
        
        // Split the existing spans according to the new formatting
        formattedSpans = _splitSpans(formattedSpans, start, end, style);
      }
    }

    // Convert to InlineSpan list
    return formattedSpans.map((fs) => 
      TextSpan(text: fs.text, style: fs.style)
    ).toList();
  }

  static TextStyle _getStyleForAttribute(String attribute) {
    switch (attribute) {
      case 'EMPHASIS':
        return const TextStyle(fontStyle: FontStyle.italic, fontWeight: FontWeight.w500);
      case 'BOLD':
        return const TextStyle(fontWeight: FontWeight.bold);
      case 'MONOSPACE':
        return const TextStyle(fontFamily: 'monospace');
      default:
        return const TextStyle();
    }
  }

  // Helper function to split spans
  static List<FormattedSpan> _splitSpans(
    List<FormattedSpan> existingSpans,
    int formatStart,
    int formatEnd,
    TextStyle formatStyle
  ) {
    List<FormattedSpan> result = [];

    for (var span in existingSpans) {
      int spanStart = span.start;
      int spanEnd = span.end;
      
      // Case 1: The format span is completely outside this span
      if (formatEnd <= spanStart || formatStart >= spanEnd) {
        result.add(span);
        continue;
      }

      // Case 2: The format span completely covers this span
      if (formatStart <= spanStart && formatEnd >= spanEnd) {
        result.add(FormattedSpan(
          spanStart, 
          spanEnd, 
          formatStyle, 
          span.text
        ));
        continue;
      }

      // Case 3: Partial overlap - we need to split the span
      // Part before the format
      if (formatStart > spanStart) {
        int beforeEnd = formatStart;
        result.add(FormattedSpan(
          spanStart,
          beforeEnd,
          span.style,
          span.text.substring(0, beforeEnd - spanStart)
        ));
      }

      // Part in the middle (the format part)
      int formatSpanStart = formatStart > spanStart ? formatStart : spanStart;
      int formatSpanEnd = formatEnd < spanEnd ? formatEnd : spanEnd;
      result.add(FormattedSpan(
        formatSpanStart,
        formatSpanEnd,
        formatStyle,
        span.text.substring(
          formatSpanStart - spanStart,
          formatSpanEnd - spanStart
        )
      ));

      // Part after the format
      if (formatEnd < spanEnd) {
        int afterStart = formatEnd;
        result.add(FormattedSpan(
          afterStart,
          spanEnd,
          span.style,
          span.text.substring(afterStart - spanStart)
        ));
      }
    }

    return result;
  }
}

// Helper class to represent a formatted text span with position info
class FormattedSpan {
  final int start;
  final int end;
  final TextStyle style;
  final String text;

  FormattedSpan(this.start, this.end, this.style, this.text);
}