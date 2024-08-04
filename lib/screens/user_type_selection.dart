import 'package:flutter/material.dart';
import 'package:new_oviedu/screens/auth_screen.dart';
import 'package:new_oviedu/mentor/screens/mentor_auth_screen.dart';
import 'package:google_fonts/google_fonts.dart';

class UserTypeSelectionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.purple[700]!, Colors.purple[500]!],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'I am a...',
                style: GoogleFonts.poppins(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 40),
              _buildUserTypeButton(context, 'Mentee', Icons.school),
              SizedBox(height: 20),
              _buildUserTypeButton(context, 'Mentor', Icons.person),
              SizedBox(height: 20),
              _buildUserTypeButton(context, 'Job Seeker', Icons.work_outline),
              SizedBox(height: 20),
              _buildUserTypeButton(context, 'Job Provider', Icons.business),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserTypeButton(BuildContext context, String title, IconData icon) {
    return ElevatedButton.icon(
      icon: Icon(icon, size: 28),
      label: Text(
        title,
        style: GoogleFonts.poppins(fontSize: 18),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.purple[700],
        padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        elevation: 5,
      ),
      onPressed: () {
        if (title == 'Mentor') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => MentorAuthScreen()),
          );
        } else if (title == 'Mentee') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AuthScreen(userType: title)),
          );
        } else {
          _showDevelopmentMessage(context, title);
        }
      },
    );
  }

  void _showDevelopmentMessage(BuildContext context, String userType) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10.0,
                  offset: const Offset(0.0, 10.0),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  width: double.infinity,
                  height: 150,
                  decoration: BoxDecoration(
                    color: Colors.purple[100],
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(
                    Icons.engineering,
                    size: 80,
                    color: Colors.purple[700],
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  "Coming Soon!",
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple[700],
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  "We're working hard to bring you an amazing $userType experience. Stay tuned for updates!",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  child: Text(
                    "Can't wait!",
                    style: GoogleFonts.poppins(fontSize: 16),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple[700],
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}