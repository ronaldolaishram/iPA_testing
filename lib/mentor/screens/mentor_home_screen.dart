import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:new_oviedu/mentor/widgets/mentor_bottom_nav_bar.dart';

class MentorHomeScreen extends StatefulWidget {
  @override
  _MentorHomeScreenState createState() => _MentorHomeScreenState();
}

class _MentorHomeScreenState extends State<MentorHomeScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Map<String, dynamic> _mentorData = {};

  @override
  void initState() {
    super.initState();
    _loadMentorData();
  }

  Future<void> _loadMentorData() async {
    String uid = _auth.currentUser!.uid;
    DocumentSnapshot mentorDoc = await _firestore.collection('mentors').doc(uid).get();
    QuerySnapshot matchesSnapshot = await _firestore.collection('matches').where('mentorId', isEqualTo: uid).get();

    setState(() {
      _mentorData = mentorDoc.data() as Map<String, dynamic>;
      _mentorData['menteesEngaged'] = matchesSnapshot.size;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mentor Dashboard'),
        backgroundColor: Colors.purple[700],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome, ${_mentorData['name'] ?? 'Mentor'}!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              _buildStatCard('Mentees Engaged', _mentorData['menteesEngaged']?.toString() ?? '0'),
              _buildStatCard('Network Size', _mentorData['networkSize']?.toString() ?? '0'),
              _buildStatCard('Contributions', _mentorData['contributions']?.toString() ?? '0'),
              SizedBox(height: 20),
              Text(
                'Recent Activities',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              // Add a list of recent activities here
            ],
          ),
        ),
      ),
      bottomNavigationBar: MentorBottomNavBar(currentIndex: 0),
    );
  }

  Widget _buildStatCard(String title, String value) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(fontSize: 18, color: Colors.grey[600])),
            SizedBox(height: 8),
            Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
