import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:new_oviedu/widgets/bottom_nav_bar_old.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Map<String, dynamic> _menteeData = {};
  int _mentorsConnected = 0;

  @override
  void initState() {
    super.initState();
    _loadMenteeData();
    _loadMentorsConnected();
  }

  Future<void> _loadMenteeData() async {
    String uid = _auth.currentUser!.uid;
    DocumentSnapshot menteeDoc = await _firestore.collection('users').doc(uid).get();
    setState(() {
      _menteeData = menteeDoc.data() as Map<String, dynamic>;
    });
  }

  Future<void> _loadMentorsConnected() async {
    String uid = _auth.currentUser!.uid;
    QuerySnapshot matchesSnapshot = await _firestore
        .collection('matches')
        .where('menteeId', isEqualTo: uid)
        .where('mentorApproved', isEqualTo: true)
        .get();
    setState(() {
      _mentorsConnected = matchesSnapshot.docs.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    height: 200,
                    color: Colors.purple[700],
                  ),
                  Positioned(
                    bottom: 0,
                    child: CircleAvatar(
                      radius: 70,
                      backgroundImage: NetworkImage(_menteeData['profileImageUrl'] ?? 'https://via.placeholder.com/150'),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Text(
                _menteeData['name'] ?? 'Unknown',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                _menteeData['profession'] ?? 'No profession specified',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 20),
              _buildInfoTile('Email', _menteeData['email'] ?? 'Not specified'),
              _buildInfoTile('Location', _menteeData['location'] ?? 'Not specified'),
              _buildInfoTile('Experience', '${_menteeData['experience'] ?? '0'} years'),
              _buildInfoTile('Skills', (_menteeData['skills'] as List<dynamic>?)?.join(', ') ?? 'Not specified'),
              _buildInfoTile('Mentors Connected', _mentorsConnected.toString()),
              SizedBox(height: 20),
              ElevatedButton(
                child: Text('Edit Profile'),
                onPressed: () {
                  // TODO: Implement edit profile functionality
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple[700],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavBar(currentIndex: 4),
    );
  }

  Widget _buildInfoTile(String title, String content) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Text(content),
          ),
        ],
      ),
    );
  }
}
