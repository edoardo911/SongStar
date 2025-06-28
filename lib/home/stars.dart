import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../utils/models.dart';
import 'profile/rating.dart';

class Stars extends StatefulWidget {
  const Stars({super.key});

  @override
  State<Stars> createState() => _StarsState();
}

class _StarsState extends State<Stars> {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  List<Rating> ratings = [];
  List<String> following = [];

  Future<void> getRatings() async {
    ratings.clear();
    following.clear();

    String userid = await _storage.read(key: "userid") ?? "";
    final followingQuery = await FirebaseFirestore.instance
        .collection("followings")
        .where("user1", isEqualTo: userid)
        .limit(10)
        .get();
    for(var doc in followingQuery.docs) {
      following.add(doc.data()["user2"]);
    }

    if(following.isNotEmpty) {
      final query = await FirebaseFirestore.instance
          .collection("ratings")
          .where("userid", whereIn: following)
          .get();
      setState(() {
        for(var doc in query.docs) {
          var json = doc.data();
          json["ratingid"] = doc.id;
          ratings.add(Rating.fromJson(json));
        }
      });
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await getRatings();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          "Feed",
          style: TextStyle(
            fontSize: 32
          ),
        ),
        for(var rating in ratings)
          RatingWidget(rating: rating)
      ],
    );
  }
}
