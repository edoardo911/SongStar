import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String id;
  final String username;
  final String email;
  final String am;
  final String spotify;
  final String sc;
  final String cc;
  int ratings = 0;
  int following = 0;
  int followers = 0;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.am,
    required this.spotify,
    required this.sc,
    required this.cc
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json["userid"],
    username: json["username"],
    email: json["email"],
    am: json["am"],
    spotify: json["spotify"],
    sc: json["sc"],
    cc: json["cc"]
  );

  String getCountryFlag() {
    final base = 0x1F1E6;
    final offset = "A".codeUnitAt(0);
    return String.fromCharCodes(
        cc.toUpperCase().codeUnits.map((c) => base + (c - offset))
    );
  }
}

class Rating {
  final String ratingid;
  final String songid;
  final String userid;
  final String comment;
  final double rating;
  final Timestamp timestamp;

  Rating({
    required this.ratingid,
    required this.songid,
    required this.userid,
    required this.comment,
    required this.rating,
    required this.timestamp
  });

  factory Rating.fromJson(Map<String, dynamic> json) => Rating(
    ratingid: json["ratingid"],
    songid: json["songid"],
    userid: json["userid"],
    comment: json["comment"],
    rating: json["rating"],
    timestamp: json["date"]
  );
}