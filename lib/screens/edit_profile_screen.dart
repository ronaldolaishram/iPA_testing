import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class EditProfileScreen extends StatefulWidget {
  final Map<String, dynamic> userData;

  EditProfileScreen({required this.userData});

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  late TextEditingController _nameController;
  late TextEditingController _professionController;
  late TextEditingController _experienceController;
  late TextEditingController _aboutController;
  late List<String> _skills;
  late List<String> _interests;
  File? _profileImage;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.userData['name']);
    _professionController = TextEditingController(text: widget.userData['profession']);
    _experienceController = TextEditingController(text: widget.userData['experience']);
    _aboutController = TextEditingController(text: widget.userData['about']);
    _skills = List<String>.from(widget.userData['skills'] ?? []);
    _interests = List<String>.from(widget.userData['interests'] ?? []);
  }

  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _profileImage = File(image.path);
      });
    }
  }

  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      setState(() {
        _isLoading = true;
      });

      try {
        String userId = _auth.currentUser!.uid;
        String? imageUrl = widget.userData['profileImageUrl'];

        // Upload new profile image if selected
        if (_profileImage != null) {
          Reference ref = _storage.ref().child('profile_images').child(userId + '.jpg');
          await ref.putFile(_profileImage!);
          imageUrl = await ref.getDownloadURL();
        }

        // Update user profile data in Firestore
        await _firestore.collection('users').doc(userId).update({
          'name': _nameController.text,
          'profession': _professionController.text,
          'experience': _experienceController.text,
          'skills': _skills,
          'about': _aboutController.text,
          'interests': _interests,
          'profileImageUrl': imageUrl,
        });

        Navigator.pop(context, true);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating profile: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }

      setState(() {
        _isLoading = false;
      });
    }
  }

  void _addItem(List<String> list, String title) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String newItem = '';
        return AlertDialog(
          title: Text('Add $title'),
          content: TextField(
            onChanged: (value) {
              newItem = value;
            },
            decoration: InputDecoration(hintText: "Enter $title"),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Add'),
              onPressed: () {
                setState(() {
                  if (newItem.isNotEmpty) {
                    list.add(newItem);
                  }
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile'),
        backgroundColor: Colors.purple[700],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: CircleAvatar(
                          radius: 60,
                          backgroundImage: _profileImage != null
                              ? FileImage(_profileImage!)
                              : (widget.userData['profileImageUrl'] != null
                                  ? NetworkImage(widget.userData['profileImageUrl'])
                                  : null) as ImageProvider?,
                          child: (_profileImage == null && widget.userData['profileImageUrl'] == null)
                              ? Icon(Icons.camera_alt, size: 60, color: Colors.white)
                              : null,
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(labelText: 'Name'),
                      validator: (value) => value!.isEmpty ? 'Please enter your name' : null,
                    ),
                    TextFormField(
                      controller: _professionController,
                      decoration: InputDecoration(labelText: 'Profession'),
                      validator: (value) => value!.isEmpty ? 'Please enter your profession' : null,
                    ),
                    TextFormField(
                      controller: _experienceController,
                      decoration: InputDecoration(labelText: 'Experience'),
                      validator: (value) => value!.isEmpty ? 'Please enter your experience' : null,
                    ),
                    TextFormField(
                      controller: _aboutController,
                      decoration: InputDecoration(labelText: 'About Me'),
                      maxLines: 3,
                      validator: (value) => value!.isEmpty ? 'Please write something about yourself' : null,
                    ),
                    SizedBox(height: 20),
                    Text('Skills', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Wrap(
                      spacing: 8,
                      children: _skills.map((skill) => Chip(
                        label: Text(skill),
                        onDeleted: () {
                          setState(() {
                            _skills.remove(skill);
                          });
                        },
                      )).toList(),
                    ),
                    ElevatedButton(
                      child: Text('Add Skill'),
                      onPressed: () => _addItem(_skills, 'Skill'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple[700],
                        foregroundColor: Colors.white,
                      ),
                    ),
                    SizedBox(height: 20),
                    Text('Interests', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Wrap(
                      spacing: 8,
                      children: _interests.map((interest) => Chip(
                        label: Text(interest),
                        onDeleted: () {
                          setState(() {
                            _interests.remove(interest);
                          });
                        },
                      )).toList(),
                    ),
                    ElevatedButton(
                      child: Text('Add Interest'),
                      onPressed: () => _addItem(_interests, 'Interest'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple[700],
                        foregroundColor: Colors.white,
                      ),
                    ),
                    SizedBox(height: 30),
                    Center(
                      child: ElevatedButton(
                        child: Text('Save Changes'),
                        onPressed: _updateProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple[700],
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _professionController.dispose();
    _experienceController.dispose();
    _aboutController.dispose();
    super.dispose();
  }
}