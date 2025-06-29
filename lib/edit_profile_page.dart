import 'package:application_journey/registerorlogin_page.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:application_journey/models/user_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:application_journey/secrets.dart';

// Edit profile page widget for updating user information and profile picture
class EditProfilePage extends StatefulWidget {
  final Usern?
  currentUser; // Optional: current user data for pre-filling fields

  const EditProfilePage({Key? key, this.currentUser}) : super(key: key);

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late final TextEditingController _nameController;
  late final TextEditingController _usernameController;
  late final TextEditingController _bioController;
  File? _pickedImage; // Selected new profile image file
  String? _profileImageUrl; // Current profile image URL

  @override
  void initState() {
    super.initState();
    // Initialize controllers with current user data or empty strings
    _nameController = TextEditingController(
      text: widget.currentUser?.name ?? '',
    );
    _usernameController = TextEditingController(
      text: widget.currentUser?.username ?? '',
    );
    _bioController = TextEditingController(text: widget.currentUser?.bio ?? '');
  }

  // Opens device gallery to pick a new profile picture
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _pickedImage = File(pickedFile.path);
      });
    }
  }

  // Uploads selected image to ImgBB and returns the image URL
  Future<String?> _uploadImageToImgBB(File image) async {
    final uri = Uri.parse('https://api.imgbb.com/1/upload?key=$imgbbApiKey');

    final request = http.MultipartRequest('POST', uri)
      ..files.add(
        await http.MultipartFile.fromBytes(
          'image',
          await image.readAsBytes(),
          filename: 'profile_${DateTime.now().millisecondsSinceEpoch}.jpg',
        ),
      );

    try {
      final response = await request.send();
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(await response.stream.bytesToString());
        return jsonData['data']['url']; // Return image URL
      }
      return null;
    } catch (e) {
      print('ImgBB upload error: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              // Profile picture section
              Center(
                child: Column(
                  children: [
                    // Show picked image if available, otherwise show current profile image
                    _pickedImage != null
                        ? CircleAvatar(
                            radius: 60,
                            backgroundImage: FileImage(_pickedImage!),
                          )
                        : CachedNetworkImage(
                            imageUrl: widget.currentUser?.profileImageUrl ?? '',
                            imageBuilder: (context, imageProvider) =>
                                CircleAvatar(
                                  radius: 60,
                                  backgroundImage: imageProvider,
                                ),
                            placeholder: (context, url) => CircleAvatar(
                              radius: 60,
                              child: CircularProgressIndicator(),
                            ),
                            errorWidget: (context, url, error) => CircleAvatar(
                              radius: 60,
                              child: Icon(Icons.person),
                            ),
                          ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _pickImage,
                      child: const Text('Change Profile Picture'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              // Name field
              TextField(
                controller: _nameController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Name',
                  labelStyle: TextStyle(color: Colors.white),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              // Username field
              TextField(
                controller: _usernameController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Username',
                  labelStyle: TextStyle(color: Colors.white),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              // Bio field (multi-line)
              TextField(
                controller: _bioController,
                style: const TextStyle(color: Colors.white),
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: 'Bio',
                  labelStyle: const TextStyle(color: Colors.white),
                  border: const OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.deepPurple, width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 18,
                  ),
                  hintText: "Tell us about yourself...",
                  hintStyle: const TextStyle(color: Colors.grey),
                ),
              ),
              const SizedBox(height: 32),
              // Save changes button
              ElevatedButton(
                onPressed: () async {
                  String? newImageUrl;

                  // Upload new image if selected
                  if (_pickedImage != null) {
                    newImageUrl = await _uploadImageToImgBB(_pickedImage!);
                  }

                  // Save updated data to Firestore
                  final userId = FirebaseAuth.instance.currentUser?.uid;
                  if (userId != null) {
                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(userId)
                        .set({
                          'profileImageUrl':
                              newImageUrl ??
                              widget.currentUser?.profileImageUrl,
                          'name': _nameController.text,
                          'username': _usernameController.text,
                          'bio': _bioController.text,
                        }, SetOptions(merge: true));
                  }

                  Navigator.pop(context);
                },
                child: const Text('Save Changes'),
              ),
              // Log out button
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 24,
                ),
                child: SizedBox(
                  height: 100,
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    icon: Icon(Icons.logout, color: Colors.red),
                    label: Text(
                      'Log Out',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.red),
                      padding: EdgeInsets.symmetric(vertical: 16),
                      minimumSize: Size(0, 44),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      backgroundColor: Colors.transparent,
                    ),
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text('Log Out'),
                          content: Text('Are you sure you want to log out?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: Text(
                                'Log Out',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      );
                      if (confirm == true) {
                        await FirebaseAuth.instance.signOut();
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                            builder: (context) => LoginOrRegisterPage(),
                          ),
                          (route) => false,
                        );
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
