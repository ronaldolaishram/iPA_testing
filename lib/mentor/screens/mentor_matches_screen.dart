import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:new_oviedu/mentor/widgets/mentor_bottom_nav_bar.dart';
import 'package:new_oviedu/mentor/screens/mentor_chat_screen.dart';
import 'package:new_oviedu/mentor/screens/mentor_home_screen.dart';

class MentorMatchesScreen extends StatefulWidget {
  @override
  _MentorMatchesScreenState createState() => _MentorMatchesScreenState();
}

class _MentorMatchesScreenState extends State<MentorMatchesScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> _matches = [];

  @override
  void initState() {
    super.initState();
    _loadMatches();
  }

  Future<void> _loadMatches() async {
    String mentorId = _auth.currentUser!.uid;
    QuerySnapshot matchSnapshot = await _firestore.collection('matches')
        .where('mentorId', isEqualTo: mentorId)
        .where('mentorApproved', isEqualTo: true)
        .get();

    List<String> menteeIds = matchSnapshot.docs
        .map((doc) => doc['menteeId'] as String)
        .toList();

    if (menteeIds.isNotEmpty) {
      QuerySnapshot menteeSnapshot = await _firestore.collection('users')
          .where(FieldPath.documentId, whereIn: menteeIds)
          .get();

      setState(() {
        _matches = menteeSnapshot.docs.map((doc) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          data['id'] = doc.id;
          return data;
        }).toList();
      });
    } else {
      setState(() {
        _matches = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Matches', style: GoogleFonts.poppins()),
        backgroundColor: Colors.purple[700],
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MentorHomeScreen())),
        ),
      ),
      body: _matches.isEmpty
          ? Center(child: Text('No matches yet. Keep swiping!', style: GoogleFonts.poppins()))
          : ListView.builder(
              itemCount: _matches.length,
              itemBuilder: (context, index) {
                return _buildMatchCard(_matches[index]);
              },
            ),
      bottomNavigationBar: MentorBottomNavBar(currentIndex: 1),
    );
  }

  Widget _buildMatchCard(Map<String, dynamic> mentee) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundImage: NetworkImage(mentee['profileImageUrl'] ?? 'https://via.placeholder.com/150'),
        ),
        title: Text(mentee['name'] ?? 'Unknown', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        subtitle: Text(mentee['profession'] ?? 'No profession specified', style: GoogleFonts.poppins()),
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoSection('About', mentee['about'] ?? 'No information available'),
                _buildInfoSection('Experience', mentee['experience'] ?? 'Not specified'),
                _buildInfoSection('Education', (mentee['education'] as List<dynamic>?)?.join(', ') ?? 'Not specified'),
                _buildInfoSection('Skills', (mentee['skills'] as List<dynamic>?)?.join(', ') ?? 'Not specified'),
                _buildInfoSection('Interests', (mentee['interests'] as List<dynamic>?)?.join(', ') ?? 'Not specified'),
                SizedBox(height: 16),
                ElevatedButton(
                  child: Text('Chat'),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MentorChatScreen(
                          chatId: '${_auth.currentUser!.uid}_${mentee['id']}',
                          menteeName: mentee['name'] ?? 'Unknown',
                          menteeId: mentee['id'],
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple[700],
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
        Text(content, style: GoogleFonts.poppins(fontSize: 16)),
        SizedBox(height: 16),
      ],
    );
  }
}