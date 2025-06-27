import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../utils/custom_widgets.dart';
import '../../utils/models.dart';
import 'rating.dart';

class Profile extends StatefulWidget {
  final String userid;

  const Profile({super.key, required this.userid});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  bool isUserLogged = false;
  bool showMusic = false;
  bool follow = false;

  List<QueryDocumentSnapshot<Map<String, dynamic>>> followers = [];
  List<QueryDocumentSnapshot<Map<String, dynamic>>> following = [];
  List<Rating> ratings = [];
  User? user;

  Future<void> loadUser() async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection("users")
        .doc(widget.userid)
        .get();

    final userJson = querySnapshot.data();
    userJson?["userid"] = widget.userid;

    String userid = await _storage.read(key: "userid") ?? "";

    user = User.fromJson(userJson!);
    if(user != null) {
      user!.following = await getFollowings();
      user!.followers = await getFollowers();
      user!.ratings = await getRatings();
    }

    setState(() {
      isUserLogged = userid == widget.userid;
      showMusic = user!.spotify != "" || user!.sc != "" || user!.am != "";
      for(var user in followers) {
        if(user.data()["user1"] == userid) {
          follow = true;
          break;
        }
      }
    });
  }

  Future<int> getFollowings() async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection("followings")
        .where("user1", isEqualTo: user!.id)
        .get();

    following = querySnapshot.docs;
    return following.length;
  }
  
  Future<int> getFollowers() async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection("followings")
        .where("user2", isEqualTo: user!.id)
        .get();

    followers = querySnapshot.docs;
    return followers.length;
  }

  Future<int> getRatings() async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection("ratings")
        .where("userid", isEqualTo: widget.userid)
        .orderBy("date")
        .get();

    if(querySnapshot.docs.isNotEmpty) {
      for(var rating in querySnapshot.docs) {
        var json = rating.data();
        json["ratingid"] = rating.id;
        ratings.add(Rating.fromJson(json));
      }
    }

    return ratings.length;
  }

  Future<void> launchAppOrWebsite(String userid) async {
    final String appUrl = "spotify:://user/$userid";
    final String webUrl = "https://open.spotify.com/user/$userid";

    if(await canLaunchUrl(Uri.parse(appUrl))) {
    await launchUrl(Uri.parse(appUrl));
    } else {
    await launchUrl(Uri.parse(webUrl), mode: LaunchMode.externalApplication);
    }
  }
  
  String formatNumber(int number) {
    String result = "";
    if(number < 1000) {
      result = number.toString();
    } else if(number < 1000000) {
      final fraction = (number / 1000).toStringAsFixed(2);
      result = "${fraction}K";
    } else {
      final fraction = (number / 1000000).toStringAsFixed(2);
      result = "${fraction}M";
    }
    return result;
  }

  Future<void> logoutDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          actionsAlignment: MainAxisAlignment.spaceEvenly,
          content: const Text("Do you want to log out?"),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("No"),
            ),
            TextButton(
              onPressed: () {
                _storage.write(key: "userid", value: null);
                Navigator.of(context).pop();
                Navigator.pushReplacementNamed(context, "/");
              },
              child: const Text("Yes"),
            ),
          ],
        );
      }
    );
  }

  Future<void> followUser() async {
    String yourID = await _storage.read(key: "userid") ?? "";

    await FirebaseFirestore.instance.collection("followings").add({
      "user1": yourID,
      "user2": widget.userid
    });

    setState(() {
      follow = true;
      user!.followers++; //TODO add new doc to list
    });
  }

  Future<void> unfollowUser() async {
    String yourID = await _storage.read(key: "userid") ?? "";

    final followDoc = await FirebaseFirestore.instance
        .collection("followings")
        .where("user1", isEqualTo: yourID)
        .where("user2", isEqualTo: widget.userid)
        .get();
    await FirebaseFirestore.instance.collection("followings")
        .doc(followDoc.docs[0].id)
        .delete();
    setState(() {
      follow = false;
      followers.removeWhere((var e) => e.data()["user1"] == yourID && e.data()["user2"] == widget.userid);
      user!.followers--;
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => loadUser());
  }

  @override
  Widget build(BuildContext context) {
    return Builder(builder: (context) {
      if(user == null) {
        return Center(
          child: CircularProgressIndicator(),
        );
      } else {
        return Column(
          children: [
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row( //username
                  children: [
                    Text(
                      user!.username,
                      style: TextStyle(
                          fontSize: 50
                      ),
                    ),
                    SizedBox(width: 16),
                    Text(
                      user!.getCountryFlag(),
                      style: TextStyle(
                          fontSize: 30
                      ),
                    )
                  ],
                ),
                if(isUserLogged)
                  ElevatedButton(
                    onPressed: () => logoutDialog(context),
                    style: ElevatedButton.styleFrom(
                      fixedSize: Size(60, 60),
                      backgroundColor: Colors.deepPurpleAccent,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(500),
                          side: BorderSide(color: Colors.deepPurple.shade800, width: 3)
                      ),
                    ),
                    child: Icon(
                      Icons.logout,
                      color: Colors.white,
                    ),
                  ),
              ],
            ),
            Row( //infos
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                    onPressed: () => Navigator.pushNamed(
                        context,
                        "/following",
                        arguments: { "list": following }
                    ),
                  child: Column(
                    children: [
                      Text(
                        formatNumber(user!.following),
                        style: TextStyle(
                            fontSize: 40
                        ),
                      ),
                      Text("Following")
                    ],
                  )
                ),
                TextButton(
                    onPressed: () => Navigator.pushNamed(
                        context,
                        "/followers",
                        arguments: { "list": followers }
                    ),
                    child: Column(
                      children: [
                        Text(
                          formatNumber(user!.followers),
                          style: TextStyle(
                              fontSize: 40
                          ),
                        ),
                        Text("Followers")
                      ],
                    )
                ),
                TextButton(
                    onPressed: () {},
                    child: Column(
                      children: [
                        Text(
                          formatNumber(user!.ratings),
                          style: TextStyle(
                              fontSize: 40
                          ),
                        ),
                        Text("Ratings")
                      ],
                    )
                ),
              ],
            ),
            if(showMusic) ... [
              SizedBox(height: 16),
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  if(user!.spotify != "")
                    TextButton(
                      onPressed: () => launchAppOrWebsite(user!.spotify),
                      child: Icon(
                        FontAwesomeIcons.spotify,
                        size: 32,
                        color: Colors.green,
                      ),
                    ),
                  if(user!.sc != "")
                    TextButton(
                      onPressed: () => launchAppOrWebsite(user!.sc),
                      child: Icon(
                        FontAwesomeIcons.soundcloud,
                        size: 32,
                        color: Colors.orange.shade700,
                      ),
                    ),
                  if(user!.am != "")
                    TextButton(
                      onPressed: () => launchAppOrWebsite(user!.am),
                      child: Icon(
                        FontAwesomeIcons.apple,
                        size: 32,
                        color: Colors.white,
                      ),
                    ),
                ],
              ),
              SizedBox(height: 16),
            ],
            SizedBox(height: 16),
            Builder(builder: (context) {
              if(isUserLogged) {
                return SSButton(
                  onPressed: () => Navigator.pushNamed(
                    context,
                    "/editprofile",
                    arguments: {
                      "user": user
                    }
                  ),
                  text: "Edit Profile",
                );
              } else if(follow) {
                return SSButton(
                  onPressed: () => unfollowUser(),
                  text: "Unfollow",
                );
              } else {
                return SSButton(
                  onPressed: () => followUser(),
                  text: "Follow",
                );
              }
            }),
            SizedBox(height: 16),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Ratings:",
                style: TextStyle(
                  fontSize: 32,
                ),
              ),
            ),
            Builder(builder: (context) {
              if(ratings.isEmpty) {
                return SizedBox(
                  height: MediaQuery.of(context).size.height - 450,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.not_interested,
                        color: Colors.white24,
                      ),
                      Text(
                        "This user has no ratings yet",
                        style: TextStyle(
                            color: Colors.white24,
                            fontSize: 24
                        ),
                      ),
                    ],
                  ),
                );
              } else {
                return Column(
                  children: [
                    //TODO ratings list
                  ],
                );
              }
            }),
          ],
        );
      }
    });
  }
}