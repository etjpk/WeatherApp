import 'package:application_journey/Services/post_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter_quill/flutter_quill.dart'
    hide Text; // ✅ ADD 'hide Text'
import 'dart:convert';

class CreatePostScreen extends StatefulWidget {
  @override
  _CreatePostScreenState createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  bool _isUploading = false;
  final QuillController _quillController = QuillController.basic();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  bool _isPublic = true;

  List<File> _selectedImages = [];
  Map<String, dynamic> userData = {};

  String _getContentAsJson() {
    return jsonEncode(_quillController.document.toDelta().toJson());
  }

  Future<void> _pickImages() async {
    if (_selectedImages.length >= 10) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Maximum 10 images allowed')));
      return;
    }

    try {
      final pickedFiles = await ImagePicker().pickMultiImage(
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 90,
      );

      if (pickedFiles != null && pickedFiles.isNotEmpty) {
        // Check if adding new images would exceed limit
        if (_selectedImages.length + pickedFiles.length > 10) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Can only add ${10 - _selectedImages.length} more images',
              ),
            ),
          );
          return;
        }

        setState(() {
          _selectedImages.addAll(
            pickedFiles.map((file) => File(file.path)).toList(),
          );
        });
      }
    } catch (e) {
      print('Error picking images: $e');
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  Future<void> _fetchUserData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        setState(() {
          userData = userDoc.data() ?? {};
        });
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _quillController.dispose();
    super.dispose();
  }

  void _submit() async {
    setState(() => _isUploading = true);
    try {
      if (!_formKey.currentState!.validate()) {
        setState(() => _isUploading = false);
        return;
      }

      if (_quillController.document.isEmpty()) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Please enter some content')));
        setState(() => _isUploading = false);
        return;
      }

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please log in to create a post')),
        );
        setState(() => _isUploading = false);
        return;
      }

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      final userData = userDoc.data();

      if (userData == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('User profile not found')));
        setState(() => _isUploading = false);
        return;
      }

      await PostService().createPost(
        title: _titleController.text,
        content: _getContentAsJson(),
        authorId: user.uid,
        authorName: userData['name'] ?? 'Unknown',
        authorUsername: userData['username'] ?? 'unknown',
        authorAvatar: userData['profileImageUrl'] ?? '',
        imageFiles: _selectedImages,
        visibility: _isPublic ? 'public' : 'following',
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Post created successfully!😊',
            style: TextStyle(color: Colors.black),
          ),
          backgroundColor: const Color.fromARGB(255, 144, 234, 147),
        ),
      );

      await Future.delayed(const Duration(milliseconds: 1500));
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to create post: $e')));
    } finally {
      setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Post', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: _isUploading ? null : _submit,
            child: Text(
              'Post',
              style: TextStyle(
                color: Colors.blue,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Title Field
                  TextFormField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      labelText: 'Title',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a title';
                      }
                      if (value.length > 100) {
                        return 'Title cannot be more than 100 characters';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),

                  // 2. Row: Camera Icon + Image Preview Grid
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Camera Icon (keep same as before)
                      GestureDetector(
                        onTap: _pickImages,
                        child: Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: Icon(
                            Icons.add_a_photo,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                      ),
                      SizedBox(width: 16),
                      // Image Preview Grid (enhanced)
                      Expanded(
                        child: _selectedImages.isEmpty
                            ? Container(
                                height: 56,
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Center(
                                  child: Text(
                                    'No images selected',
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                                ),
                              )
                            : Container(
                                height: _selectedImages.length <= 3
                                    ? 56
                                    : 120, // Dynamic height
                                child: GridView.builder(
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 3,
                                        crossAxisSpacing: 4,
                                        mainAxisSpacing: 4,
                                      ),
                                  itemCount:
                                      _selectedImages.length +
                                      (_selectedImages.length < 10 ? 1 : 0),
                                  itemBuilder: (context, index) {
                                    if (index == _selectedImages.length &&
                                        _selectedImages.length < 10) {
                                      // Add more button
                                      return GestureDetector(
                                        onTap: _pickImages,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.grey[300],
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            border: Border.all(
                                              color: Colors.grey[400]!,
                                            ),
                                          ),
                                          child: Icon(
                                            Icons.add,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      );
                                    }

                                    // Image with delete button
                                    return Stack(
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          child: Image.file(
                                            _selectedImages[index],
                                            width: double.infinity,
                                            height: double.infinity,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        Positioned(
                                          top: 2,
                                          right: 2,
                                          child: GestureDetector(
                                            onTap: () => _removeImage(index),
                                            child: Container(
                                              padding: EdgeInsets.all(2),
                                              decoration: BoxDecoration(
                                                color: Colors.black54,
                                                shape: BoxShape.circle,
                                              ),
                                              child: Icon(
                                                Icons.close,
                                                size: 12,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ),
                      ),
                    ],
                  ),

                  SizedBox(height: 16),
                  // Show image count when images are selected
                  if (_selectedImages.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        '${_selectedImages.length}/10 images selected',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ),

                  // 3. Content Label
                  Text(
                    'Content',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
                  ),
                  SizedBox(height: 8),

                  // 4. Rich Text Editor Box - SIMPLE AND WORKING
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey[300]!),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 12,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    padding: EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        QuillSimpleToolbar(
                          controller: _quillController,
                          config: const QuillSimpleToolbarConfig(),
                        ),
                        SizedBox(height: 12),
                        Container(
                          height: 200,
                          child: QuillEditor.basic(
                            controller: _quillController,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24),

                  // 5. Post Visibility Toggle
                  Text(
                    'Post Visibility',
                    style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
                  ),
                  SizedBox(height: 8),
                  ToggleButtons(
                    isSelected: [_isPublic, !_isPublic],
                    onPressed: (index) =>
                        setState(() => _isPublic = index == 0),
                    borderRadius: BorderRadius.circular(20),
                    selectedColor: Colors.white,
                    color: Colors.black,
                    fillColor: Colors.black,
                    selectedBorderColor: Colors.black,
                    borderColor: Colors.black26,
                    borderWidth: 2,
                    constraints: BoxConstraints(minHeight: 36, minWidth: 100),
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          'Public',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          'Followers',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24),

                  // 6. Post Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isUploading ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.black,
                        shape: StadiumBorder(),
                        elevation: 2,
                      ),
                      child: _isUploading
                          ? SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              'Post',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
