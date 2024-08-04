import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart'; // Add this import

import 'package:new_oviedu/mentor/screens/mentor_chat_screen.dart';
import 'package:new_oviedu/mentor/screens/mentor_home_screen.dart';
import 'package:new_oviedu/mentor/widgets/mentor_bottom_nav_bar.dart';

class MentorChatsListScreen extends StatefulWidget {
  @override
  _MentorChatsListScreenState createState() => _MentorChatsListScreenState();
}

class _MentorChatsListScreenState extends State<MentorChatsListScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late Stream<QuerySnapshot> _chatsStream;

  @override
  void initState() {
    super.initState();
    _loadChats();
  }

  void _loadChats() {
    String currentUserId = _auth.currentUser!.uid;
    _chatsStream = _firestore
        .collection('chats')
        .where('participants', arrayContains: currentUserId)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MentorHomeScreen()),
        );
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Chats', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
          backgroundColor: Colors.purple[700],
          elevation: 0,
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: _chatsStream,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text('Something went wrong'));
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            List<Map<String, dynamic>> chats = snapshot.data!.docs.map((doc) {
              Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
              data['id'] = doc.id;
              return data;
            }).toList();

            return ListView.builder(
              itemCount: chats.length,
              itemBuilder: (context, index) {
                return _buildChatItem(chats[index]);
              },
            );
          },
        ),
        bottomNavigationBar: MentorBottomNavBar(currentIndex: 3),
      ),
    );
  }

  Widget _buildChatItem(Map<String, dynamic> chat) {
    String currentUserId = _auth.currentUser!.uid;
    List<dynamic> participants = chat['participants'];
    String menteeId = participants.firstWhere((id) => id != currentUserId);

    return FutureBuilder<DocumentSnapshot>(
      future: _firestore.collection('users').doc(menteeId).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return SizedBox.shrink();

        Map<String, dynamic> menteeData = snapshot.data!.data() as Map<String, dynamic>;
        String menteeName = menteeData['name'] ?? 'Unknown Mentee';

        return ListTile(
          leading: CircleAvatar(
            backgroundImage: NetworkImage(menteeData['profileImageUrl'] ?? 'https://via.placeholder.com/150'),
          ),
          title: Text(menteeName, style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
          subtitle: Text(chat['lastMessage'] ?? 'No messages yet', maxLines: 1, overflow: TextOverflow.ellipsis),
          trailing: Text(_formatTimestamp(chat['lastMessageTime']), style: GoogleFonts.poppins(fontSize: 12)),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MentorChatScreen(
                  chatId: chat['id'],
                  menteeName: menteeName,
                  menteeId: menteeId,
                ),
              ),
            );
          },
        );
      },
    );
  }

  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return '';
    DateTime dateTime = timestamp.toDate();
    return DateFormat('MMM d, h:mm a').format(dateTime);
  }
}
