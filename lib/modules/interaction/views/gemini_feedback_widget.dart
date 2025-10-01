import 'package:flutter/material.dart';
import 'package:markdown_widget/markdown_widget.dart';

class GeminiFeedbackWidget extends StatelessWidget {
  final String text;
  const GeminiFeedbackWidget({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    // Wrap the MarkdownWidget in a Container/SizedBox with a maxHeight
    // if you want the Markdown content itself to scroll within that height.
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: MarkdownWidget(
          data: text, // Assuming 'data' is the correct property name
          shrinkWrap: true, // 👈 important
          physics:
              const NeverScrollableScrollPhysics(), // 👈 disable inner scroll
        ),
      ),
    );
  }
}
