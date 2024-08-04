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
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          height: 80,
          decoration: BoxDecoration(
            color: Colors.purple,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: Offset(0, -5),
              ),
            ],
          ),
          child: BottomNavigationBar(
            currentIndex: currentIndex,
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.transparent,
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.white.withOpacity(0.6),
            selectedFontSize: 0,
            unselectedFontSize: 0,
            items: [
              _buildNavItem(Icons.home, 0),
              _buildNavItem(Icons.explore, 1),
              BottomNavigationBarItem(
                icon: SizedBox.shrink(),
                label: '',
              ),
              _buildNavItem(Icons.message, 3),
              _buildNavItem(Icons.person, 4),
            ],
            onTap: (index) => _onItemTapped(context, index),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 30,
          child: GestureDetector(
            onTap: () => _onItemTapped(context, 2),
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Icon(
                Icons.add,
                color: Colors.white,
                size: 30,
              ),
            ),
          ),
        ),
      ],
    );
  }

  BottomNavigationBarItem _buildNavItem(IconData icon, int index) {
    return BottomNavigationBarItem(
      icon: Icon(
        icon,
        color: currentIndex == index ? Colors.white : Colors.white.withOpacity(0.6),
        size: 24,
      ),
      label: '',
    );
  }

  void _onItemTapped(BuildContext context, int index) {
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
  }
}
