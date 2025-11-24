import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/cupertino.dart';
import '../auth/auth_Screen.dart';
import '../screen/feed_screen.dart';
import '../screen/upload_screen.dart';
import '../screen/profile_screen.dart';

class NavigationScreen extends StatefulWidget {
  final int initialPage;
  const NavigationScreen({this.initialPage = 0, super.key});

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

int _currentIndex = 0;

class _NavigationScreenState extends State<NavigationScreen> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.initialPage);
    _currentIndex = widget.initialPage;
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void navigationTapped(int page) {
    _pageController.jumpToPage(page);
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const AuthScreen();
    }

    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        onTap: navigationTapped,
        items: [
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.house, size: 30.sp),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.plus_app, size: 30.sp),
            label: 'Upload',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.person_alt_circle, size: 30.sp),
            label: 'Profile',
          ),
        ],
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: onPageChanged,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          const FeedScreen(),
          const UploadScreen(),
          ProfileScreen(user.uid),
        ],
      ),
    );
  }
}
