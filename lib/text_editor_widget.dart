import 'package:flutter/material.dart';

class TextEditorWidget extends StatelessWidget {
  final TextEditingController titleController;
  final TextEditingController contentController;

  const TextEditorWidget({
    Key? key,
    required this.titleController,
    required this.contentController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: titleController,
          decoration: const InputDecoration(
            labelText: 'Title',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: TextField(
            controller: contentController,
            decoration: const InputDecoration(
              labelText: 'Content',
              border: OutlineInputBorder(),
            ),
            maxLines: null,
            expands: true,
            keyboardType: TextInputType.multiline,
          ),
        ),
      ],
    );
  }
}
