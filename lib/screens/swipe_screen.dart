import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:new_oviedu/widgets/bottom_nav_bar.dart';
import 'package:new_oviedu/screens/home_screen.dart';
import 'package:swipe_cards/swipe_cards.dart';

class SwipeScreen extends StatefulWidget {
  @override
  _SwipeScreenState createState() => _SwipeScreenState();
}

class _SwipeScreenState extends State<SwipeScreen> {
  List<SwipeItem> _swipeItems = <SwipeItem>[];
  MatchEngine? _matchEngine;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _loadMentors();
  }

  Future<void> _loadMentors() async {
    String currentUserId = _auth.currentUser!.uid;
    
    QuerySnapshot swipedMentorsSnapshot = await _firestore.collection('swipes')
      .where('menteeId', isEqualTo: currentUserId)
      .get();

    List<String> swipedMentorIds = swipedMentorsSnapshot.docs
      .map((doc) => doc['mentorId'] as String)
      .toList();

    QuerySnapshot mentorSnapshot = await _firestore.collection('mentors').get();

    List<Map<String, dynamic>> mentors = mentorSnapshot.docs
      .where((doc) => !swipedMentorIds.contains(doc.id))
      .map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      })
      .toList();

    setState(() {
      _swipeItems = mentors.map((mentor) {
        return SwipeItem(
          content: mentor,
          likeAction: () => _onSwipe(mentor, true),
          nopeAction: () => _onSwipe(mentor, false),
        );
      }).toList();
      _matchEngine = MatchEngine(swipeItems: _swipeItems);
    });
  }

  void _onSwipe(Map<String, dynamic> mentor, bool isLiked) async {
    String currentUserId = _auth.currentUser!.uid;
    
    await _firestore.collection('swipes').add({
      'menteeId': currentUserId,
      'mentorId': mentor['id'],
      'isLiked': isLiked,
      'timestamp': FieldValue.serverTimestamp(),
    });

    if (isLiked) {
      await _firestore.collection('matches').add({
        'menteeId': currentUserId,
        'mentorId': mentor['id'],
        'menteeApproved': true,
        'mentorApproved': false,
        'timestamp': FieldValue.serverTimestamp(),
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Discover Mentors'),
        backgroundColor: Colors.purple[700],
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeScreen())),
        ),
      ),
      body: _matchEngine != null
          ? _swipeItems.isNotEmpty
              ? SwipeCards(
                  matchEngine: _matchEngine!,
                  itemBuilder: (BuildContext context, int index) => _buildSwipeCard(_swipeItems[index].content),
                  onStackFinished: () => setState(() {}),
                )
              : Center(child: Text('No more mentors to swipe'))
          : Center(child: CircularProgressIndicator()),
      bottomNavigationBar: BottomNavBar(currentIndex: 2),
    );
  }

  Widget _buildSwipeCard(Map<String, dynamic> mentor) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: GestureDetector(
        onTap: () => _showMentorDetails(mentor),
        child: Column(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                child: Image.network(
                  mentor['profileImageUrl'] ?? 'https://via.placeholder.com/150',
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    mentor['name'] ?? 'Unknown',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    mentor['profession'] ?? 'No profession specified',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(IconData icon, Color color, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Icon(icon, color: Colors.white),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        shape: CircleBorder(),
        padding: EdgeInsets.all(20),
      ),
    );
  }

  void _showMentorDetails(Map<String, dynamic> mentor) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (_, controller) => SingleChildScrollView(
          controller: controller,
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: CircleAvatar(
                    radius: 60,
                    backgroundImage: NetworkImage(mentor['profileImageUrl'] ?? 'https://via.placeholder.com/150'),
                  ),
                ),
                SizedBox(height: 16),
                Text(mentor['name'] ?? 'Unknown', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                Text(mentor['profession'] ?? 'No profession specified', style: TextStyle(fontSize: 18, color: Colors.grey[600])),
                SizedBox(height: 16),
                Text('Experience', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                Text(mentor['experience'] ?? 'Not specified'),
                SizedBox(height: 16),
                Text('Expertise', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                Wrap(
                  spacing: 8,
                  children: (mentor['expertise'] as List<dynamic>?)?.map((skill) => Chip(label: Text(skill))).toList() ?? [],
                ),
                SizedBox(height: 16),
                Text('About', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                Text(mentor['about'] ?? 'No information provided'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}