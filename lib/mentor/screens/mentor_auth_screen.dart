import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:new_oviedu/mentor/screens/mentor_profile_creation_screen.dart';
import 'package:new_oviedu/mentor/screens/mentor_home_screen.dart';

class MentorAuthScreen extends StatefulWidget {
  @override
  _MentorAuthScreenState createState() => _MentorAuthScreenState();
}

class _MentorAuthScreenState extends State<MentorAuthScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';
  bool _isLogin = true;
  bool _isLoading = false;
  bool _obscureText = true;
  TextEditingController _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _switchAuthMode() {
    setState(() {
      _isLogin = !_isLogin;
    });
  }

  void _appendEmailDomain(String domain) {
    String currentText = _emailController.text;
    int atIndex = currentText.indexOf('@');
    if (atIndex != -1) {
      currentText = currentText.substring(0, atIndex);
    }
    _emailController.text = currentText + domain;
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        _isLoading = true;
      });

      try {
        if (_isLogin) {
          // Login
          UserCredential userCredential = await _auth.signInWithEmailAndPassword(
            email: _email,
            password: _password,
          );

          // Check if user profile exists
          DocumentSnapshot userDoc = await _firestore.collection('mentors').doc(userCredential.user!.uid).get();

          if (userDoc.exists) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => MentorHomeScreen()),
            );
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => MentorProfileCreationScreen()),
            );
          }
        } else {
          // Sign up
          UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
            email: _email,
            password: _password,
          );

          // Create initial mentor document
          await _firestore.collection('mentors').doc(userCredential.user!.uid).set({
            'email': _email,
            'createdAt': FieldValue.serverTimestamp(),
          });

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => MentorProfileCreationScreen()),
          );
        }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isLogin ? 'Mentor Login' : 'Mentor Sign Up'),
        backgroundColor: Colors.purple[700],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty || !value.contains('@')) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                  onSaved: (value) => _email = value!,
                  controller: _emailController,
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      child: Text('@gmail.com'),
                      onPressed: () {
                        _appendEmailDomain('@gmail.com');
                      },
                    ),
                    ElevatedButton(
                      child: Text('@icloud.com'),
                      onPressed: () {
                        _appendEmailDomain('@icloud.com');
                      },
                    ),
                  ],
                ),
                SizedBox(height: 10),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureText ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureText = !_obscureText;
                        });
                      },
                    ),
                  ),
                  obscureText: _obscureText,
                  validator: (value) {
                    if (value == null || value.isEmpty || value.length < 6) {
                      return 'Password must be at least 6 characters long';
                    }
                    return null;
                  },
                  onSaved: (value) => _password = value!,
                ),
                SizedBox(height: 20),
                                if (_isLoading)
                  CircularProgressIndicator()
                else
                  ElevatedButton(
                    child: Text(_isLogin ? 'Login' : 'Sign Up'),
                    onPressed: _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple[700],
                      foregroundColor: Colors.white,
                    ),
                  ),
                TextButton(
                  child: Text(_isLogin ? 'Create an account' : 'I already have an account'),
                  onPressed: _switchAuthMode,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

