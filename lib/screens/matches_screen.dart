import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:new_oviedu/widgets/bottom_nav_bar.dart';
import 'package:new_oviedu/screens/home_screen.dart';
import 'package:new_oviedu/screens/chat_detail_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class MatchesScreen extends StatefulWidget {
  @override
  _MatchesScreenState createState() => _MatchesScreenState();
}

class _MatchesScreenState extends State<MatchesScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<Map<String, dynamic>> _matches = [];

  final List<Map<String, String>> forYouGroups = [
    {
      'title': 'Scientist',
      'imageUrl': 'https://www.shutterstock.com/image-vector/young-boy-doing-chemical-experiments-600nw-2270840959.jpg',
      'subtitle': 'Become a Scientist',
    },
    {
      'title': 'Creatives',
      'imageUrl': 'https://t3.ftcdn.net/jpg/02/78/42/76/360_F_278427683_zeS9ihPAO61QhHqdU1fOaPk2UClfgPcW.jpg',
      'subtitle': 'Match Your Aesthetics',
    },
    {
      'title': 'Sports',
      'imageUrl': 'https://t3.ftcdn.net/jpg/02/78/42/76/360_F_278427683_zeS9ihPAO61QhHqdU1fOaPk2UClfgPcW.jpg',
      'subtitle': 'Match Your Mentor in Sports',
    },
    {
      'title': 'Music And Arts',
      'imageUrl': 'https://cdn.prod.website-files.com/65a997ed5f68daf1805ed393/665672afcde77f4a6db80207_4k2aqoPGfHW3PCFqa0DWjE4vlv5CtPMLVYZ9QXmpmNzOJhcJA-out-0.png',
      'subtitle': 'Match Your Aesthetics',
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadMatches();
  }

  Future<void> _loadMatches() async {
    String currentUserId = _auth.currentUser!.uid;
    QuerySnapshot matchSnapshot = await _firestore.collection('matches')
        .where('menteeId', isEqualTo: currentUserId)
        .where('mentorApproved', isEqualTo: true)
        .get();

    List<String> mentorIds = matchSnapshot.docs.map((doc) => doc['mentorId'] as String).toList();

    if (mentorIds.isNotEmpty) {
      QuerySnapshot mentorSnapshot = await _firestore.collection('mentors')
          .where(FieldPath.documentId, whereIn: mentorIds)
          .get();

      setState(() {
        _matches = mentorSnapshot.docs.map((doc) {
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
        title: Text('Matches', style: GoogleFonts.aBeeZee()),
        backgroundColor: Colors.purple[700],
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomeScreen()),
            );
          },
        ),
      ),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Your Matches',
                style: GoogleFonts.aBeeZee(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),
              _matches.isEmpty
                  ? Center(child: Text('No matches yet. Keep swiping!'))
                  : GridView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.75,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemCount: _matches.length,
                      itemBuilder: (context, index) {
                        return _buildMatchCard(_matches[index]);
                      },
                    ),
              SizedBox(height: 32),
              Text(
                'For You',
                style: GoogleFonts.aBeeZee(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),
              GridView.builder(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1 / 1.5,
                  mainAxisSpacing: 10.0,
                  crossAxisSpacing: 10.0,
                ),
                itemCount: forYouGroups.length,
                itemBuilder: (context, index) {
                  return _buildForYouCard(forYouGroups[index]);
                },
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavBar(currentIndex: 1),
    );
  }

  Widget _buildMatchCard(Map<String, dynamic> mentor) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: () => _showMentorDetails(mentor),
        child: Padding(
          padding: EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.network(
                  mentor['profileImageUrl'] ?? 'https://via.placeholder.com/150',
                  height: 100,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(height: 8),
              Text(
                mentor['name'] ?? 'Unknown',
                style: GoogleFonts.aBeeZee(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                mentor['profession'] ?? 'Profession not set',
                style: GoogleFonts.aBeeZee(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _navigateToChatScreen(mentor),
                      child: Text('Message'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple[700],
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(horizontal: 8),
                      ),
                    ),
                  ),
                  SizedBox(width: 4),
                  ElevatedButton(
                    onPressed: () => _showRatingDialog(mentor),
                    child: Icon(Icons.star, size: 18),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.all(8),
                      minimumSize: Size(36, 36),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildForYouCard(Map<String, String> group) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: NetworkImage(group['imageUrl']!),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            Colors.black.withOpacity(0.5),
            BlendMode.darken,
          ),
        ),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            padding: EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(15),
                bottomRight: Radius.circular(15),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  group['title']!,
                  style: GoogleFonts.aBeeZee(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  group['subtitle']!,
                  style: GoogleFonts.aBeeZee(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
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
                Text(mentor['name'] ?? 'Unknown', style: GoogleFonts.aBeeZee(fontSize: 24, fontWeight: FontWeight.bold)),
                Text(mentor['profession'] ?? 'No profession specified', style: GoogleFonts.aBeeZee(fontSize: 18, color: Colors.grey[600])),
                SizedBox(height: 16),
                _buildInfoSection('Experience', mentor['experience'] ?? 'Not specified'),
                _buildInfoSection('Company', mentor['company'] ?? 'Not specified'),
                _buildInfoSection('Expertise', (mentor['expertise'] as List<dynamic>?)?.join(', ') ?? 'Not specified'),
                _buildInfoSection('Education', (mentor['education'] as List<dynamic>?)?.join(', ') ?? 'Not specified'),
                _buildInfoSection('Certifications', (mentor['certifications'] as List<dynamic>?)?.join(', ') ?? 'Not specified'),
                _buildInfoSection('About', mentor['about'] ?? 'No information provided'),
                _buildInfoSection('Rating', '${mentor['rating'] ?? 'Not rated yet'}'),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () => _navigateToChatScreen(mentor),
                      child: Text('Chat with Mentor'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple[700],
                        foregroundColor: Colors.white,
                        minimumSize: Size(150, 36),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () => _showRatingDialog(mentor),
                      child: Text('Rate Mentor'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        minimumSize: Size(150, 36),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

 void _showRatingDialog(Map<String, dynamic> mentor) {
    double rating = 0;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Rate ${mentor['name']}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RatingBar.builder(
                initialRating: mentor['rating'] ?? 0,
                minRating: 1,
                direction: Axis.horizontal,
                allowHalfRating: true,
                itemCount: 5,
                itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                itemBuilder: (context, _) => Icon(
                  Icons.star,
                  color: Colors.amber,
                ),
                onRatingUpdate: (value) {
                  rating = value;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('Submit'),
              onPressed: () {
                _submitRating(mentor['id'], rating);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _submitRating(String mentorId, double rating) async {
    String currentUserId = _auth.currentUser!.uid;
    await _firestore.collection('ratings').add({
      'mentorId': mentorId,
      'menteeId': currentUserId,
      'rating': rating,
      'timestamp': FieldValue.serverTimestamp(),
    });

    // Update the mentor's average rating
    QuerySnapshot ratingSnapshot = await _firestore.collection('ratings')
        .where('mentorId', isEqualTo: mentorId)
        .get();
    
    double averageRating = ratingSnapshot.docs
        .map((doc) => (doc.data() as Map<String, dynamic>)['rating'] as double)
        .reduce((a, b) => a + b) / ratingSnapshot.docs.length;

    await _firestore.collection('mentors').doc(mentorId).update({
      'rating': averageRating,
    });

    // Refresh the matches list
    _loadMatches();
  }

  Widget _buildInfoSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: GoogleFonts.aBeeZee(fontSize: 18, fontWeight: FontWeight.bold)),
        Text(content, style: GoogleFonts.aBeeZee(fontSize: 16)),
        SizedBox(height: 16),
      ],
    );
  }

  void _navigateToChatScreen(Map<String, dynamic> mentor) async {
    String currentUserId = _auth.currentUser!.uid;
    String chatId = '${currentUserId}_${mentor['id']}';
    
    DocumentSnapshot chatDoc = await _firestore.collection('chats').doc(chatId).get();
    
    if (!chatDoc.exists) {
      await _firestore.collection('chats').doc(chatId).set({
        'participants': [currentUserId, mentor['id']],
        'lastMessage': '',
        'lastMessageTime': FieldValue.serverTimestamp(),
      });
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatDetailScreen(
          chatId: chatId,
          otherUserName: mentor['name'] ?? 'Unknown',
          otherUserId: mentor['id'],
        ),
      ),
    );
  }
}
