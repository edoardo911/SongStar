import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../utils/models.dart';
import 'user.dart';

class Followers extends StatefulWidget {
  const Followers({super.key});

  @override
  State<Followers> createState() => _FollowersState();
}

class _FollowersState extends State<Followers> {
  List<QueryDocumentSnapshot<Map<String, dynamic>>> followings = [];

  List<User> users = [];

  Future<void> getUsers() async {
    for(var doc in followings) {
      final String id = doc.data()["user1"];
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
      appBar: AppBar(title: Text("Followers")),
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
    return Center(
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
                  "This user has no followers",
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
    );
  }
}
