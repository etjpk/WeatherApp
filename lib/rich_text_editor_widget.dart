import 'package:flutter/material.dart';

class RichTextEditorWidget extends StatelessWidget {
  final TextEditingController contentController;
  final int selectedStyleIndex;
  final Function(int) onStyleSelected;

  const RichTextEditorWidget({
    Key? key,
    required this.contentController,
    required this.selectedStyleIndex,
    required this.onStyleSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> styleButtons = [
      {'label': 'Title', 'color': Colors.black},
      {'label': 'Subtitle', 'color': Colors.grey[600]},
      {'label': 'Heading', 'color': Colors.black},
      {'label': 'Body', 'color': Colors.orange},
      {'label': 'Note', 'color': Colors.grey[600]},
    ];

    Widget buildStyleButton(
      String text,
      Color color,
      bool isSelected,
      int idx,
    ) {
      return GestureDetector(
        onTap: () => onStyleSelected(idx),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected ? Colors.orange : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            text,
            style: TextStyle(
              color: isSelected ? Colors.white : color,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(styleButtons.length, (idx) {
                    final btn = styleButtons[idx];
                    return buildStyleButton(
                      btn['label'],
                      btn['color'],
                      selectedStyleIndex == idx,
                      idx,
                    );
                  }),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: const Icon(Icons.format_bold),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(Icons.format_italic),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(Icons.format_underlined),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(Icons.format_strikethrough),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(Icons.text_fields),
                    onPressed: () {},
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: const Icon(Icons.format_list_bulleted),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(Icons.format_list_numbered),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(Icons.checklist),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(Icons.format_align_left),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(Icons.format_align_center),
                    onPressed: () {},
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: TextField(
            controller: contentController,
            decoration: const InputDecoration(
              hintText: 'Start typing...',
              border: InputBorder.none,
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
