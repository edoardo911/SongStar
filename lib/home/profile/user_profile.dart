import 'package:flutter/material.dart';

import 'profile.dart';

class UserProfile extends StatefulWidget {
  const UserProfile({super.key});

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final String userid = args["userid"];

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 10),
        child: SingleChildScrollView(
          child: Profile(userid: userid),
        ),
      ),
    );
  }
}
