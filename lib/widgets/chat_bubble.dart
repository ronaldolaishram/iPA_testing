import 'package:flutter/material.dart';

class ChatBubble extends StatelessWidget {
  final String name;
  final String lastMessage;
  final String imageUrl;
  final String time;
  final VoidCallback onTap;

  ChatBubble({
    required this.name,
    required this.lastMessage,
    required this.imageUrl,
    required this.time,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: NetworkImage(imageUrl),
        radius: 25,
      ),
      title: Text(
        name,
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        lastMessage,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Text(
        time,
        style: TextStyle(color: Colors.grey[600]),
      ),
      onTap: onTap,
    );
  }
}