import 'package:flutter/material.dart';
import 'notes_model.dart';
import 'note_service.dart';

enum EditMode { text, richText, voice, camera, drawing }

class CreateNotePage extends StatefulWidget {
  const CreateNotePage({super.key});

  @override
  State<CreateNotePage> createState() => _CreateNotePageState();
}

class _CreateNotePageState extends State<CreateNotePage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  NoteCategory _selectedCategory = NoteCategory.defaultNotebook;
  EditMode _currentMode = EditMode.text;

  final NotesService _notesService = NotesService();

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _saveNote() async {
    try {
      final note = Note(
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
        category: _selectedCategory,
        creationDate: DateTime.now(),
      );
      await _notesService.createNote(note);
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    }
  }

  void _setEditMode(EditMode mode) {
    setState(() {
      _currentMode = mode;
    });
  }

  Widget _buildEditor() {
    switch (_currentMode) {
      case EditMode.text:
        return _buildTextEditor();
      case EditMode.richText:
        return _buildRichTextEditor();
      case EditMode.voice:
        return _buildVoiceEditor();
      case EditMode.camera:
        return _buildCameraEditor();
      case EditMode.drawing:
        return _buildDrawingEditor();
    }
  }

  Widget _buildTextEditor() {
    return Column(
      children: [
        TextField(
          controller: _titleController,
          decoration: const InputDecoration(
            labelText: 'Title',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: TextField(
            controller: _contentController,
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

  Widget _buildRichTextEditor() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Rich text formatting toolbar
        Container(
          padding: const EdgeInsets.all(8),

          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Text style buttons
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _buildStyleButton('Title', Colors.black),
                      _buildStyleButton('Subtitle', Colors.grey[600]!),
                      _buildStyleButton('Heading', Colors.black),
                      _buildStyleButton(
                        'Body',
                        Colors.orange,
                        isSelected: true,
                      ),
                      _buildStyleButton('Note', Colors.grey[600]!),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 8),
              // Formatting buttons
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
              // List formatting
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
            controller: _contentController,
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

  Widget _buildStyleButton(
    String text,
    Color color, {
    bool isSelected = false,
  }) {
    return Container(
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
    );
  }

  Widget _buildVoiceEditor() {
    return Column(
      children: [
        const Spacer(),
        // Voice recording interface
        Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => _setEditMode(EditMode.text),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(color: Colors.orange),
                    ),
                  ),
                  DropdownButton<String>(
                    value: 'English',
                    items: ['English', 'Spanish', 'French', 'German']
                        .map(
                          (lang) =>
                              DropdownMenuItem(value: lang, child: Text(lang)),
                        )
                        .toList(),
                    onChanged: (value) {},
                  ),
                ],
              ),
              const SizedBox(height: 40),
              const Text(
                '00:00 / 05:00',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 40),
              // Audio waveform visualization (simplified)
              Container(
                height: 60,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: List.generate(50, (index) {
                    return Container(
                      width: 2,
                      height: (index % 5 + 1) * 10.0,
                      margin: const EdgeInsets.symmetric(horizontal: 1),
                      color: index < 20 ? Colors.orange : Colors.grey[300],
                    );
                  }),
                ),
              ),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Pause button
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.pause, size: 30),
                  ),
                  // Record button
                  Container(
                    width: 80,
                    height: 80,
                    decoration: const BoxDecoration(
                      color: Colors.orange,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.stop,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const Spacer(),
      ],
    );
  }

  Widget _buildCameraEditor() {
    return Column(
      children: [
        const Expanded(
          child: Center(
            child: Text(
              'Camera Mode',
              style: TextStyle(fontSize: 24, color: Colors.grey),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.camera_alt),
                label: const Text('Take Photo'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.photo_library),
                label: const Text('Choose from Gallery'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.document_scanner),
                label: const Text('Scan Document'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDrawingEditor() {
    return Column(
      children: [
        Expanded(
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: const Center(
              child: Text(
                'Drawing Canvas\n(Tap to draw)',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            ),
          ),
        ),
        // Drawing tools
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            border: Border(top: BorderSide(color: Colors.grey[300]!)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(icon: const Icon(Icons.brush), onPressed: () {}),
              IconButton(icon: const Icon(Icons.edit), onPressed: () {}),
              IconButton(icon: const Icon(Icons.palette), onPressed: () {}),
              IconButton(icon: const Icon(Icons.undo), onPressed: () {}),
              IconButton(icon: const Icon(Icons.redo), onPressed: () {}),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomToolbar() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildToolbarIcon(Icons.check, EditMode.text),
          _buildToolbarIcon(Icons.text_fields, EditMode.richText),
          _buildToolbarIcon(Icons.mic, EditMode.voice),
          _buildToolbarIcon(Icons.camera_alt, EditMode.camera),
          _buildToolbarIcon(Icons.brush, EditMode.drawing),
        ],
      ),
    );
  }

  Widget _buildToolbarIcon(IconData icon, EditMode mode) {
    bool isSelected = _currentMode == mode;
    return GestureDetector(
      onTap: () => _setEditMode(mode),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.orange.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: isSelected ? Colors.orange : Colors.grey[600],
          size: 24,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}, ${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')} ${DateTime.now().hour >= 12 ? 'pm' : 'am'} | Default notebook',
        ),
        titleTextStyle: const TextStyle(fontSize: 14, color: Colors.grey),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.black),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.check, color: Colors.black),
            onPressed: _saveNote,
          ),
        ],
      ),
      body: Column(
        children: [
          // Category dropdown (only show in text mode)
          if (_currentMode == EditMode.text)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: DropdownButton<NoteCategory>(
                value: _selectedCategory,
                isExpanded: true,
                items: NoteCategory.values.map((category) {
                  return DropdownMenuItem<NoteCategory>(
                    value: category,
                    child: Text(category.toString().split('.').last),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedCategory = value;
                    });
                  }
                },
              ),
            ),
          // Main editor area
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: _buildEditor(),
            ),
          ),
          // Bottom toolbar
          _buildBottomToolbar(),
        ],
      ),
    );
  }
}
