import 'package:flutter/material.dart';
import 'package:new_oviedu/screens/home_screen.dart';
//import 'package:new_oviedu/screens/messages_screen.dart';
import 'package:new_oviedu/screens/swipe_screen.dart';
import 'package:new_oviedu/screens/matches_screen.dart';
import 'package:new_oviedu/screens/user_account_screen.dart';
import 'package:new_oviedu/screens/chat_list_screen.dart';


class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  
  BottomNavBar({required this.currentIndex});

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
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeScreen()));
              break;
            case 1:
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MatchesScreen()));
              break;
            case 2:
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => SwipeScreen()));
              break;
            case 3:
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ChatListScreen()));
              break;
            case 4:
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => UserAccountScreen()));
              break;
          }
        }
      },
    );
  }
}

