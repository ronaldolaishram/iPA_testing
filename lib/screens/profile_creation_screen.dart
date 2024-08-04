import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:new_oviedu/screens/home_screen.dart';

class ProfileCreationScreen extends StatefulWidget {
  final String userType;

  ProfileCreationScreen({required this.userType});

  @override
  _ProfileCreationScreenState createState() => _ProfileCreationScreenState();
}

class _ProfileCreationScreenState extends State<ProfileCreationScreen> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  String _name = '';
  String _profession = '';
  String _experience = '';
  List<String> _skills = [];
  String _about = '';
  List<String> _interests = [];
  File? _profileImage;
  bool _isLoading = false;

  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _profileImage = File(image.path);
      });
    }
  }

  Future<void> _uploadProfileImage() async {
    if (_profileImage == null) return;

    try {
      String userId = _auth.currentUser!.uid;
      Reference storageRef = _storage.ref().child('profile_images').child('$userId.jpg');
      
      // Upload the file
      await storageRef.putFile(_profileImage!);
      
      // Get the download URL
      String downloadURL = await storageRef.getDownloadURL();
      
      // Update user profile with the new image URL
      await _firestore.collection('users').doc(userId).update({
        'profileImageUrl': downloadURL,
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profile image uploaded successfully')),
      );
    } catch (e) {
      print('Error uploading image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload profile image. Please try again.')),
      );
    }
  }

  Future<void> _submitProfile() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        _isLoading = true;
      });

      try {
        String userId = _auth.currentUser!.uid;

        // Upload profile image if selected
        if (_profileImage != null) {
          await _uploadProfileImage();
        }

        // Save user profile data to Firestore
        await _firestore.collection('users').doc(userId).update({
          'name': _name,
          'profession': _profession,
          'experience': _experience,
          'skills': _skills,
          'about': _about,
          'interests': _interests,
          'mentorsConnected': 0,
        });

        // Navigate to home screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating profile: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }

      setState(() {
        _isLoading = false;
      });
    }
  }

  void _addSkill() {
    _addItem(_skills, 'Skill');
  }

  void _addInterest() {
    _addItem(_interests, 'Interest');
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
        title: Text('Create Your Profile'),
        backgroundColor: Colors.purple[700],
      ),
      body: SingleChildScrollView(
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
                    backgroundImage: _profileImage != null ? FileImage(_profileImage!) : null,
                    child: _profileImage == null
                        ? Icon(Icons.camera_alt, size: 60, color: Colors.white)
                        : null,
                  ),
                ),
              ),
              SizedBox(height: 20),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value!.isEmpty ? 'Please enter your name' : null,
                onSaved: (value) => _name = value!,
              ),
              SizedBox(height: 10),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Profession',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value!.isEmpty ? 'Please enter your profession' : null,
                onSaved: (value) => _profession = value!,
              ),
              SizedBox(height: 10),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Experience',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value!.isEmpty ? 'Please enter your experience' : null,
                onSaved: (value) => _experience = value!,
              ),
              SizedBox(height: 10),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'About Me',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) => value!.isEmpty ? 'Please write something about yourself' : null,
                onSaved: (value) => _about = value!,
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
                onPressed: _addSkill,
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
                onPressed: _addInterest,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple[700],
                  foregroundColor: Colors.white,
                ),
              ),
              SizedBox(height: 30),
              Center(
                child: _isLoading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                      child: Text('Create Profile'),
                      onPressed: _submitProfile,
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
}