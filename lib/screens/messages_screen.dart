import 'package:flutter/material.dart';
import 'package:new_oviedu/widgets/bottom_nav_bar.dart';
import 'package:new_oviedu/screens/home_screen.dart';
import 'package:new_oviedu/screens/chat_detail_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';

class MessagesScreen extends StatefulWidget {
  @override
  _MessagesScreenState createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late Stream<QuerySnapshot> _chatsStream;

  @override
  void initState() {
    super.initState();
    _initChatsStream();
  }

  void _initChatsStream() {
    String currentUserId = _auth.currentUser!.uid;
    _chatsStream = _firestore
        .collection('chats')
        .where('participants', arrayContains: currentUserId)
        .orderBy('lastMessageTime', descending: true)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Messages', style: GoogleFonts.poppins()),
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
      body: StreamBuilder<QuerySnapshot>(
        stream: _chatsStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Something went wrong: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No messages yet', style: GoogleFonts.poppins()));
          }

          return ListView.separated(
            itemCount: snapshot.data!.docs.length,
            separatorBuilder: (context, index) => Divider(height: 1),
            itemBuilder: (context, index) {
              var chatData = snapshot.data!.docs[index].data() as Map<String, dynamic>;
              return FutureBuilder<DocumentSnapshot>(
                future: _getOtherUserDoc(chatData['participants'] as List<dynamic>),
                builder: (context, userSnapshot) {
                  if (userSnapshot.connectionState == ConnectionState.waiting) {
                    return ListTile(title: Text('Loading...'));
                  }
                  if (userSnapshot.hasError || !userSnapshot.hasData) {
                    return ListTile(title: Text('Error loading user data'));
                  }
                  var userData = userSnapshot.data!.data() as Map<String, dynamic>;
                  return _buildChatListItem(chatData, userData, snapshot.data!.docs[index].id);
                },
              );
            },
          );
        },
      ),
      bottomNavigationBar: BottomNavBar(currentIndex: 3),
    );
  }

  Future<DocumentSnapshot> _getOtherUserDoc(List<dynamic> participants) async {
    String currentUserId = _auth.currentUser!.uid;
    String otherUserId = participants.firstWhere((id) => id != currentUserId, orElse: () => '');
    return await _firestore.collection('mentors').doc(otherUserId).get();
  }

  Widget _buildChatListItem(Map<String, dynamic> chatData, Map<String, dynamic> userData, String chatId) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: NetworkImage(userData['profileImageUrl'] ?? 'https://via.placeholder.com/150'),
        radius: 25,
      ),
      title: Text(
        userData['name'] ?? 'Unknown User',
        style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        chatData['lastMessage'] ?? 'No messages yet',
        style: GoogleFonts.poppins(),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Text(
        _formatTimestamp(chatData['lastMessageTime']),
        style: GoogleFonts.poppins(color: Colors.grey[600]),
      ),
      onTap: () => _navigateToChatDetail(chatId, userData['name'], userData['id']),
    );
  }

  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return '';
    DateTime dateTime = timestamp.toDate();
    DateTime now = DateTime.now();
    if (dateTime.day == now.day && dateTime.month == now.month && dateTime.year == now.year) {
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }

  void _navigateToChatDetail(String chatId, String otherUserName, String otherUserId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatDetailScreen(
          chatId: chatId,
          otherUserName: otherUserName,
          otherUserId: otherUserId,
        ),
      ),
    );
  }
}