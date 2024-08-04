import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:new_oviedu/mentor/widgets/mentor_bottom_nav_bar.dart';
import 'package:new_oviedu/mentor/screens/mentor_profile_creation_screen.dart';
import 'package:new_oviedu/mentor/screens/mentor_settings_screen.dart';

class MentorProfileScreen extends StatefulWidget {
  @override
  _MentorProfileScreenState createState() => _MentorProfileScreenState();
}

class _MentorProfileScreenState extends State<MentorProfileScreen> {
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
                      backgroundImage: NetworkImage(_mentorData['profileImageUrl'] ?? 'https://via.placeholder.com/150'),
                    ),
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: IconButton(
                      icon: Icon(Icons.more_vert, color: Colors.white),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => MentorSettingsScreen()),
                        );
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Text(
                _mentorData['name'] ?? 'Unknown',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                _mentorData['profession'] ?? 'No profession specified',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 20),
              _buildInfoTile('Company', _mentorData['company'] ?? 'Not specified'),
              _buildInfoTile('Experience', '${_mentorData['experience'] ?? '0'} years'),
              _buildInfoTile('Expertise', (_mentorData['expertise'] as List<dynamic>?)?.join(', ') ?? 'Not specified'),
              _buildInfoTile('Education', (_mentorData['education'] as List<dynamic>?)?.join(', ') ?? 'Not specified'),
              _buildInfoTile('Certifications', (_mentorData['certifications'] as List<dynamic>?)?.join(', ') ?? 'Not specified'),
              SizedBox(height: 20),
              Text('Statistics', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              _buildStatCard('Mentees Engaged', _mentorData['menteesEngaged']?.toString() ?? '0'),
              _buildStatCard('Network Size', _mentorData['networkSize']?.toString() ?? '0'),
              _buildStatCard('Contributions', _mentorData['contributions']?.toString() ?? '0'),
              SizedBox(height: 20),
              ElevatedButton(
                child: Text('Edit Profile'),
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MentorProfileCreationScreen(mentorData: _mentorData),
                    ),
                  );
                  if (result == true) {
                    _loadMentorData(); // Reload data if profile was updated
                  }
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
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
      bottomNavigationBar: MentorBottomNavBar(currentIndex: 4),
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

  Widget _buildStatCard(String title, String value) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: TextStyle(fontSize: 18)),
            Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
