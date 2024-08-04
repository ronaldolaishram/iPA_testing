import 'package:flutter/material.dart';
import 'package:new_oviedu/mentor/screens/mentor_home_screen.dart';
import 'package:new_oviedu/mentor/screens/mentor_matches_screen.dart';
import 'package:new_oviedu/mentor/screens/mentor_swipe_screen.dart';
import 'package:new_oviedu/mentor/screens/mentor_profile_screen.dart';
import 'package:new_oviedu/mentor/screens/mentor_chats_list_screen.dart'; // Import the new screen

class MentorBottomNavBar extends StatelessWidget {
  final int currentIndex;
  
  MentorBottomNavBar({required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: currentIndex,
      selectedItemColor: Colors.purple[700],
      unselectedItemColor: Colors.grey,
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.people),
          label: 'Matches',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.swipe),
          label: 'Swipe',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.chat),
          label: 'Chat',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
      onTap: (index) {
        if (index != currentIndex) {
          switch (index) {
            case 0:
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MentorHomeScreen()));
              break;
            case 1:
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MentorMatchesScreen()));
              break;
            case 2:
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MentorSwipeScreen()));
              break;
            case 3:
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MentorChatsListScreen()));
              break;
            case 4:
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MentorProfileScreen()));
              break;
          }
        }
      },
    );
  }
}
