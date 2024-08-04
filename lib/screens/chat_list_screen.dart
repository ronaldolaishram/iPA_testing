import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'chat_detail_screen.dart';
import 'home_screen.dart';
import 'package:new_oviedu/widgets/bottom_nav_bar.dart';

class ChatListScreen extends StatefulWidget {
  @override
  _ChatListScreenState createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
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
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Chats', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
          backgroundColor: Colors.purple[700],
          elevation: 0,
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

            if (chats.isEmpty) {
              return Center(child: Text('No chats available', style: GoogleFonts.poppins()));
            }

            return ListView.builder(
              itemCount: chats.length,
              itemBuilder: (context, index) {
                return _buildChatItem(chats[index]);
              },
            );
          },
        ),
        bottomNavigationBar: BottomNavBar(currentIndex: 3),
      ),
    );
  }

  Widget _buildChatItem(Map<String, dynamic> chat) {
    String currentUserId = _auth.currentUser!.uid;
    List<dynamic> participants = chat['participants'];
    String otherUserId = participants.firstWhere((id) => id != currentUserId, orElse: () => '');

    if (otherUserId.isEmpty) return SizedBox.shrink();

    return FutureBuilder<DocumentSnapshot>(
      future: _firestore.collection('mentors').doc(otherUserId).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data == null || snapshot.data!.data() == null) {
          return FutureBuilder<DocumentSnapshot>(
            future: _firestore.collection('users').doc(otherUserId).get(),
            builder: (context, innerSnapshot) {
              if (!innerSnapshot.hasData || innerSnapshot.data == null || innerSnapshot.data!.data() == null) {
                return SizedBox.shrink();
              }

              Map<String, dynamic>? userData = innerSnapshot.data!.data() as Map<String, dynamic>?;
              if (userData == null) return SizedBox.shrink();

              String userName = userData['name'] ?? 'Unknown User';

              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(userData['profileImageUrl'] ?? 'https://via.placeholder.com/150'),
                ),
                title: Text(userName, style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                subtitle: Text(chat['lastMessage'] ?? 'No messages yet', maxLines: 1, overflow: TextOverflow.ellipsis),
                trailing: Text(_formatTimestamp(chat['lastMessageTime']), style: GoogleFonts.poppins(fontSize: 12)),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatDetailScreen(
                        chatId: chat['id'],
                        otherUserName: userName,
                        otherUserId: otherUserId,
                      ),
                    ),
                  );
                },
              );
            },
          );
        }

        Map<String, dynamic>? mentorData = snapshot.data!.data() as Map<String, dynamic>?;
        if (mentorData == null) return SizedBox.shrink();

        String mentorName = mentorData['name'] ?? 'Unknown Mentor';

        return ListTile(
          leading: CircleAvatar(
            backgroundImage: NetworkImage(mentorData['profileImageUrl'] ?? 'https://via.placeholder.com/150'),
          ),
          title: Text(mentorName, style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
          subtitle: Text(chat['lastMessage'] ?? 'No messages yet', maxLines: 1, overflow: TextOverflow.ellipsis),
          trailing: Text(_formatTimestamp(chat['lastMessageTime']), style: GoogleFonts.poppins(fontSize: 12)),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatDetailScreen(
                  chatId: chat['id'],
                  otherUserName: mentorName,
                  otherUserId: otherUserId,
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
