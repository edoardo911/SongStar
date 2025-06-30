import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../utils/models.dart';
import 'user.dart';

class Following extends StatefulWidget {
  const Following({super.key});

  @override
  State<Following> createState() => _FollowingState();
}

class _FollowingState extends State<Following> {
  List<QueryDocumentSnapshot<Map<String, dynamic>>> followings = [];
  List<User> users = [];

  Future<void> getUsers() async {
    for(var doc in followings) {
      final String id = doc.data()["user2"];
      final data = await FirebaseFirestore.instance.collection("users").doc(id).get();
      var json = data.data();
      json?["userid"] = id;
      users.add(User.fromJson(json!));
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await getUsers();
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    followings = args["list"];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Following"),
      ),
      body: SingleChildScrollView(
        child: Builder(builder: (context) {
          if(users.isEmpty) {
            return EmptyWidget();
          } else {
            return Column(
              children: [
                for(var user in users) UserWidget(user: user)
              ],
            );
          }
        }),
      ),
    );
  }
}

class EmptyWidget extends StatelessWidget {
  const EmptyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: Center(
        child: Column(
          children: [
            SizedBox(height: MediaQuery.of(context).size.height / 2 - 120),
            Column(
                children: [
                  Icon(
                    Icons.not_interested,
                    size: 32,
                    color: Colors.white24,
                  ),
                  Text(
                    "This user is not following anyone",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 30,
                        color: Colors.white24
                    ),
                  )
                ]
            ),
          ],
        ),
      ),
    );
  }
}
