import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
//import 'package:new_oviedu/mentor/screens/mentor_home_screen.dart';

class MentorProfileCreationScreen extends StatefulWidget {
  final Map<String, dynamic>? mentorData;

  MentorProfileCreationScreen({this.mentorData});

  @override
  _MentorProfileCreationScreenState createState() => _MentorProfileCreationScreenState();
}

class _MentorProfileCreationScreenState extends State<MentorProfileCreationScreen> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  late TextEditingController _nameController;
  late TextEditingController _professionController;
  late TextEditingController _companyController;
  late TextEditingController _experienceController;
  late TextEditingController _aboutController;
  List<String> _expertise = [];
  List<String> _education = [];
  List<String> _certifications = [];
  File? _profileImage;
  String? _currentProfileImageUrl;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.mentorData?['name'] ?? '');
    _professionController = TextEditingController(text: widget.mentorData?['profession'] ?? '');
    _companyController = TextEditingController(text: widget.mentorData?['company'] ?? '');
    _experienceController = TextEditingController(text: widget.mentorData?['experience']?.toString() ?? '');
    _aboutController = TextEditingController(text: widget.mentorData?['about'] ?? '');
    _expertise = List<String>.from(widget.mentorData?['expertise'] ?? []);
    _education = List<String>.from(widget.mentorData?['education'] ?? []);
    _certifications = List<String>.from(widget.mentorData?['certifications'] ?? []);
    _currentProfileImageUrl = widget.mentorData?['profileImageUrl'];
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

  Future<String?> _uploadProfileImage() async {
    if (_profileImage == null) return _currentProfileImageUrl;

    try {
      String userId = _auth.currentUser!.uid;
      Reference storageRef = _storage.ref().child('mentor_profile_images').child('$userId.jpg');
      
      await storageRef.putFile(_profileImage!);
      
      return await storageRef.getDownloadURL();
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        _isLoading = true;
      });

      try {
        String uid = _auth.currentUser!.uid;
        String? profileImageUrl = await _uploadProfileImage();

        await _firestore.collection('mentors').doc(uid).update({
          'name': _nameController.text,
          'profession': _professionController.text,
          'company': _companyController.text,
          'experience': _experienceController.text,
          'about': _aboutController.text,
          'expertise': _expertise,
          'education': _education,
          'certifications': _certifications,
          if (profileImageUrl != null) 'profileImageUrl': profileImageUrl,
        });

        Navigator.pop(context, true); // Return true to indicate profile was updated
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }

      setState(() {
        _isLoading = false;
      });
    }
  }

  void _addItem(List<String> list, String itemType) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String newItem = '';
        return AlertDialog(
          title: Text('Add $itemType'),
          content: TextField(
            onChanged: (value) {
              newItem = value;
            },
            decoration: InputDecoration(hintText: "Enter $itemType"),
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
        title: Text(widget.mentorData == null ? 'Create Mentor Profile' : 'Edit Mentor Profile'),
        backgroundColor: Colors.purple[700],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 60,
                    backgroundImage: _profileImage != null 
                      ? FileImage(_profileImage!) 
                      : (_currentProfileImageUrl != null 
                          ? NetworkImage(_currentProfileImageUrl!) as ImageProvider
                          : null),
                    child: _profileImage == null && _currentProfileImageUrl == null
                      ? Icon(Icons.camera_alt, size: 60, color: Colors.white)
                      : null,
                  ),
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(labelText: 'Full Name'),
                  validator: (value) => value!.isEmpty ? 'Please enter your name' : null,
                ),
                TextFormField(
                  controller: _professionController,
                  decoration: InputDecoration(labelText: 'Profession'),
                  validator: (value) => value!.isEmpty ? 'Please enter your profession' : null,
                ),
                TextFormField(
                  controller: _companyController,
                  decoration: InputDecoration(labelText: 'Company'),
                  validator: (value) => value!.isEmpty ? 'Please enter your company' : null,
                ),
                TextFormField(
                  controller: _experienceController,
                  decoration: InputDecoration(labelText: 'Years of Experience'),
                  keyboardType: TextInputType.number,
                  validator: (value) => value!.isEmpty ? 'Please enter your years of experience' : null,
                ),
                TextFormField(
                  controller: _aboutController,
                  decoration: InputDecoration(labelText: 'About Me'),
                  maxLines: 3,
                  validator: (value) => value!.isEmpty ? 'Please write something about yourself' : null,
                ),
                SizedBox(height: 20),
                Text('Expertise', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Wrap(
                  spacing: 8,
                  children: _expertise.map((skill) => Chip(
                    label: Text(skill),
                    onDeleted: () {
                      setState(() {
                        _expertise.remove(skill);
                      });
                    },
                  )).toList(),
                ),
                ElevatedButton(
                  child: Text('Add Expertise'),
                  onPressed: () => _addItem(_expertise, 'expertise'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple[700],
                    foregroundColor: Colors.white,
                  ),
                ),
                SizedBox(height: 20),
                Text('Education', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Wrap(
                  spacing: 8,
                  children: _education.map((edu) => Chip(
                    label: Text(edu),
                    onDeleted: () {
                      setState(() {
                        _education.remove(edu);
                      });
                    },
                  )).toList(),
                ),
                ElevatedButton(
                  child: Text('Add Education'),
                  onPressed: () => _addItem(_education, 'education'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple[700],
                    foregroundColor: Colors.white,
                  ),
                ),
                SizedBox(height: 20),
                Text('Certifications', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Wrap(
                  spacing: 8,
                  children: _certifications.map((cert) => Chip(
                    label: Text(cert),
                    onDeleted: () {
                      setState(() {
                        _certifications.remove(cert);
                      });
                    },
                  )).toList(),
                ),
                ElevatedButton(
                  child: Text('Add Certification'),
                  onPressed: () => _addItem(_certifications, 'certification'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple[700],
                    foregroundColor: Colors.white,
                  ),
                ),
                SizedBox(height: 30),
                if (_isLoading)
                  CircularProgressIndicator()
                else
                  ElevatedButton(
                    child: Text(widget.mentorData == null ? 'Create Profile' : 'Update Profile'),
                    onPressed: _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple[700],
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _professionController.dispose();
    _companyController.dispose();
    _experienceController.dispose();
    _aboutController.dispose();
    super.dispose();
  }
}