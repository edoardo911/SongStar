import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'search.dart';
import 'stars.dart';
import 'top.dart';
import 'profile/profile.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  String? userid;
  int selectedIndex = 0;

  void navBarTap(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  Future<void> getUserID() async { userid = await _storage.read(key: "userid"); }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => getUserID());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 10),
          child: Builder(builder: (context) {
            switch(selectedIndex) {
              case 0:
                return Search();
              case 1:
                return Stars();
              case 2:
                return Top();
              case 3:
                return Profile(userid: userid ?? "");
              default:
                return Search();
            }
          }),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        iconSize: 32,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.black26,
        elevation: 0,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.star_border), label: "Stars"),
          BottomNavigationBarItem(icon: Icon(Icons.leaderboard_outlined), label: "Top"),
          BottomNavigationBarItem(icon: Icon(Icons.account_circle), label: "Profile"),
        ],
        currentIndex: selectedIndex,
        selectedItemColor: Colors.deepPurple,
        onTap: navBarTap,
      ),
    );
  }
}
