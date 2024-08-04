import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:new_oviedu/screens/home_screen.dart';
import 'package:new_oviedu/screens/profile_creation_screen.dart';

class AuthScreen extends StatefulWidget {
  final String userType;

  AuthScreen({required this.userType});

  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLogin = true;
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';
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

  Future<void> _submit() async {
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
          // Check if user exists in Firestore
          DocumentSnapshot userDoc = await _firestore.collection('users').doc(userCredential.user!.uid).get();
          if (userDoc.exists) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomeScreen()),
            );
          } else {
            // User doesn't exist in Firestore, send to profile creation
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => ProfileCreationScreen(userType: widget.userType),
              ),
            );
          }
        } else {
          // Sign up
          UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
            email: _email,
            password: _password,
          );
          
          // Create user document in Firestore
          await _firestore.collection('users').doc(userCredential.user!.uid).set({
            'email': _email,
            'userType': widget.userType,
            'createdAt': FieldValue.serverTimestamp(),
          });

          // Navigate to profile creation
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => ProfileCreationScreen(userType: widget.userType),
            ),
          );
        }
      } on FirebaseAuthException catch (e) {
        String errorMessage = 'An error occurred. Please try again later.';
        if (e.code == 'user-not-found') {
          errorMessage = 'No user found for that email.';
        } else if (e.code == 'wrong-password') {
          errorMessage = 'Wrong password provided.';
        } else if (e.code == 'email-already-in-use') {
          errorMessage = 'The account already exists for that email.';
        } else if (e.code == 'invalid-email') {
          errorMessage = 'The email address is not valid.';
        } else if (e.code == 'weak-password') {
          errorMessage = 'The password provided is too weak.';
        }
        _showErrorDialog(errorMessage);
      } catch (e) {
        _showErrorDialog(e.toString());
      }

      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('An Error Occurred'),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            child: Text('Okay'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          )
        ],
      ),
    );
  }

  Future<void> _forgotPassword() async {
    String email = '';
    
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Reset Password'),
        content: TextField(
          onChanged: (value) {
            email = value;
          },
          decoration: InputDecoration(hintText: "Enter your email"),
        ),
        actions: [
          TextButton(
            child: Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: Text('Send Reset Link'),
            onPressed: () async {
              if (email.isNotEmpty) {
                try {
                  await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Password reset link sent to $email')),
                  );
                } catch (e) {
                  Navigator.pop(context);
                  _showErrorDialog('Error: ${e.toString()}');
                }
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.purple[700]!, Colors.purple[500]!],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 8,
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _isLogin ? 'Login' : 'Sign Up',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 20),
                          TextFormField(
                            decoration: InputDecoration(
                              labelText: 'Email',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.email),
                            ),
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.isEmpty || !value.contains('@')) {
                                return 'Please enter a valid email address';
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
                              onPressed: _submit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.purple[700],
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                              ),
                            ),
                          TextButton(
                            child: Text(
                              _isLogin ? 'Create new account' : 'I already have an account',
                              style: TextStyle(color: Colors.purple[700]),
                            ),
                            onPressed: _switchAuthMode,
                          ),
                          if (_isLogin)
                            TextButton(
                              child: Text(
                                'Forgot Password?',
                                style: TextStyle(color: Colors.purple[700]),
                              ),
                              onPressed: _forgotPassword,
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
