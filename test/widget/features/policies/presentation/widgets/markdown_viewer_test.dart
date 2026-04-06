import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_library/features/policies/presentation/widgets/markdown_viewer.dart';

void main() {
  group('MarkdownViewer Widget Tests', () {
    Widget createTestWidget({
      required String content,
      String? title,
      DateTime? lastUpdated,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: MarkdownViewer(
            content: content,
            title: title,
            lastUpdated: lastUpdated,
          ),
        ),
      );
    }

    testWidgets('displays markdown content correctly', (WidgetTester tester) async {
      // Arrange
      const markdownContent = '''
# Header 1
This is a test markdown content.

## Header 2
- List item 1
- List item 2

**Bold text** and *italic text*.
''';

      // Act
      await tester.pumpWidget(createTestWidget(content: markdownContent));

      // Assert
      expect(find.byType(MarkdownBody), findsOneWidget);
      expect(find.text('This is a test markdown content.'), findsOneWidget);
    });

    testWidgets('displays title when provided', (WidgetTester tester) async {
      // Arrange
      const content = '# Test Content';
      const title = 'Privacy Policy';

      // Act
      await tester.pumpWidget(createTestWidget(
        content: content,
        title: title,
      ));

      // Assert
      expect(find.text(title), findsOneWidget);
    });

    testWidgets('does not display title when not provided', (WidgetTester tester) async {
      // Arrange
      const content = '# Test Content';

      // Act
      await tester.pumpWidget(createTestWidget(content: content));

      // Assert
      // Only the markdown content title should be present, not a separate title widget
      expect(find.byType(MarkdownBody), findsOneWidget);
    });

    testWidgets('displays last updated date when provided', (WidgetTester tester) async {
      // Arrange
      const content = '# Test Content';
      final lastUpdated = DateTime(2024, 1, 15);

      // Act
      await tester.pumpWidget(createTestWidget(
        content: content,
        lastUpdated: lastUpdated,
      ));

      // Assert
      expect(find.textContaining('Last updated:'), findsOneWidget);
      expect(find.textContaining('January 15, 2024'), findsOneWidget);
    });

    testWidgets('does not display last updated when not provided', (WidgetTester tester) async {
      // Arrange
      const content = '# Test Content';

      // Act
      await tester.pumpWidget(createTestWidget(content: content));

      // Assert
      expect(find.textContaining('Last updated:'), findsNothing);
    });

    testWidgets('displays both title and last updated when provided', (WidgetTester tester) async {
      // Arrange
      const content = '# Test Content';
      const title = 'Terms & Conditions';
      final lastUpdated = DateTime(2024, 1, 15);

      // Act
      await tester.pumpWidget(createTestWidget(
        content: content,
        title: title,
        lastUpdated: lastUpdated,
      ));

      // Assert
      expect(find.text(title), findsOneWidget);
      expect(find.textContaining('Last updated:'), findsOneWidget);
      expect(find.textContaining('January 15, 2024'), findsOneWidget);
    });

    testWidgets('handles empty content gracefully', (WidgetTester tester) async {
      // Arrange
      const emptyContent = '';

      // Act
      await tester.pumpWidget(createTestWidget(content: emptyContent));

      // Assert
      expect(find.byType(MarkdownBody), findsOneWidget);
      expect(tester.takeException(), isNull); // No exceptions should be thrown
    });

    testWidgets('handles complex markdown content', (WidgetTester tester) async {
      // Arrange
      const complexContent = '''
# Main Title

This is a paragraph with **bold** and *italic* text.

## Section 1

1. Numbered list item 1
2. Numbered list item 2
3. Numbered list item 3

### Subsection

- Bullet point 1
- Bullet point 2

[Link text](https://example.com)

> This is a blockquote

```
Code block content
```

| Column 1 | Column 2 |
|----------|----------|
| Cell 1   | Cell 2   |
''';

      // Act
      await tester.pumpWidget(createTestWidget(content: complexContent));

      // Assert
      expect(find.byType(MarkdownBody), findsOneWidget);
      expect(find.text('Main Title'), findsOneWidget);
      expect(find.text('Section 1'), findsOneWidget);
      expect(find.text('Subsection'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('has proper scrollable layout', (WidgetTester tester) async {
      // Arrange
      final content = '''
# Very Long Content
${List.generate(50, (index) => 'This is line ${index + 1} of very long content that should be scrollable.').join('\n\n')}
''';

      // Act
      await tester.pumpWidget(createTestWidget(content: content));

      // Assert
      expect(find.byType(SingleChildScrollView), findsOneWidget);
      expect(find.byType(MarkdownBody), findsOneWidget);
    });

    testWidgets('applies proper padding and layout structure', (WidgetTester tester) async {
      // Arrange
      const content = '# Test';
      const title = 'Test Policy';

      // Act
      await tester.pumpWidget(createTestWidget(
        content: content,
        title: title,
      ));

      // Assert
      expect(find.byType(SingleChildScrollView), findsOneWidget);
      expect(find.byType(Padding), findsWidgets);
    });

    testWidgets('handles markdown rendering errors gracefully', (WidgetTester tester) async {
      // Arrange
      const invalidContent = '''
# Header
[Invalid link](
> Unclosed blockquote
''';

      // Act
      await tester.pumpWidget(createTestWidget(content: invalidContent));

      // Assert
      expect(find.byType(MarkdownBody), findsOneWidget);
      expect(tester.takeException(), isNull); // Should handle gracefully
    });

    testWidgets('maintains consistent styling across different content types', (WidgetTester tester) async {
      // Arrange
      const content = '''
# Header
Normal text
**Bold text**
*Italic text*
- List item
1. Numbered item
''';

      // Act
      await tester.pumpWidget(createTestWidget(content: content));

      // Assert
      expect(find.byType(MarkdownBody), findsOneWidget);
      
      // Verify the markdown widget has proper configuration
      final markdown = tester.widget<MarkdownBody>(find.byType(MarkdownBody));
      expect(markdown.selectable, isTrue);
      expect(markdown.data, equals(content));
    });
  });
}
