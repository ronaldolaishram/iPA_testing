import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:new_oviedu/mentor/widgets/mentor_bottom_nav_bar.dart';
import 'package:new_oviedu/mentor/screens/mentor_home_screen.dart';
import 'package:google_fonts/google_fonts.dart';

class MentorSwipeScreen extends StatefulWidget {
  @override
  _MentorSwipeScreenState createState() => _MentorSwipeScreenState();
}

class _MentorSwipeScreenState extends State<MentorSwipeScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> _mentees = [];
  int _currentIndex = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMentees();
  }

  Future<void> _loadMentees() async {
    setState(() {
      _isLoading = true;
    });

    String mentorId = _auth.currentUser!.uid;

    QuerySnapshot swipesSnapshot = await _firestore.collection('swipes')
      .where('mentorId', isEqualTo: mentorId)
      .where('isLiked', isEqualTo: true)
      .get();

    List<String> swipedMenteeIds = swipesSnapshot.docs
      .map((doc) => doc['menteeId'] as String)
      .toList();

    QuerySnapshot matchesSnapshot = await _firestore.collection('matches')
      .where('mentorId', isEqualTo: mentorId)
      .get();

    List<String> matchedMenteeIds = matchesSnapshot.docs
      .map((doc) => doc['menteeId'] as String)
      .toList();

    List<String> menteeIdsToShow = swipedMenteeIds
      .where((id) => !matchedMenteeIds.contains(id))
      .toList();

    if (menteeIdsToShow.isNotEmpty) {
      QuerySnapshot menteeSnapshot = await _firestore.collection('users')
        .where(FieldPath.documentId, whereIn: menteeIdsToShow)
        .get();

      setState(() {
        _mentees = menteeSnapshot.docs.map((doc) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          data['id'] = doc.id;
          return data;
        }).toList();
        _currentIndex = 0;
        _isLoading = false;
      });
    } else {
      setState(() {
        _mentees = [];
        _isLoading = false;
      });
    }
  }

  void _swipe(bool isAccepted) async {
    if (_currentIndex >= _mentees.length) return;

    String mentorId = _auth.currentUser!.uid;
    String menteeId = _mentees[_currentIndex]['id'];

    if (isAccepted) {
      await _firestore.collection('matches').add({
        'mentorId': mentorId,
        'menteeId': menteeId,
        'mentorApproved': true,
        'menteeApproved': true,
        'timestamp': FieldValue.serverTimestamp(),
      });
    }

    await _firestore.collection('swipes').add({
      'mentorId': mentorId,
      'menteeId': menteeId,
      'isLiked': isAccepted,
      'timestamp': FieldValue.serverTimestamp(),
    });

    setState(() {
      _currentIndex++;
    });

    if (_currentIndex >= _mentees.length) {
      _loadMentees();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Swipe Mentees', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.purple[700],
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MentorHomeScreen())),
        ),
      ),
      body: _isLoading
        ? Center(child: CircularProgressIndicator(color: Colors.purple[700]))
        : _mentees.isNotEmpty && _currentIndex < _mentees.length
          ? _buildSwipeCard(_mentees[_currentIndex])
          : Center(
              child: Text(
                'No more mentees to swipe',
                style: GoogleFonts.poppins(fontSize: 18, color: Colors.grey[600]),
              ),
            ),
      bottomNavigationBar: MentorBottomNavBar(currentIndex: 2),
    );
  }

  Widget _buildSwipeCard(Map<String, dynamic> mentee) {
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Card(
            elevation: 8,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  child: Image.network(
                    mentee['profileImageUrl'] ?? 'https://via.placeholder.com/150',
                    height: 250,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        mentee['name'] ?? 'Unknown',
                        style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Text(
                        mentee['profession'] ?? 'No profession specified',
                        style: GoogleFonts.poppins(fontSize: 18, color: Colors.grey[600]),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'About',
                        style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                      SizedBox(height: 8),
                      Text(
                        mentee['about'] ?? 'No description available',
                        style: GoogleFonts.poppins(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildActionButton(Icons.close, Colors.red, () => _swipe(false)),
              _buildActionButton(Icons.check, Colors.green, () => _swipe(true)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, Color color, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Icon(icon, color: Colors.white, size: 30),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        shape: CircleBorder(),
        padding: EdgeInsets.all(20),
        elevation: 5,
      ),
    );
  }
}