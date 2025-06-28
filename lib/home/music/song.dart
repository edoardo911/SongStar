import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../utils/custom_widgets.dart';
import '../../utils/models.dart';
import 'utils.dart';

class Song extends StatefulWidget {
  const Song({super.key});

  @override
  State<Song> createState() => _SongState();
}

class _SongState extends State<Song> {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final TextEditingController commentController = TextEditingController();
  Map<String, dynamic> song = {};
  Map<String, dynamic> myRating = {};
  List<QueryDocumentSnapshot> allRatings = [];
  String token = "";
  bool loading = true;
  bool rated = false;
  bool canRate = false;
  bool commentError = false;
  double avg = -1.0;
  double rate = 5.0;

  Future<void> getSong(String songid) async {
    allRatings = [];
    final response = await http.get(
      Uri.parse("https://api.spotify.com/v1/tracks/$songid"),
      headers: {
        "Authorization": "Bearer $token"
      }
    );

    String userid = await _storage.read(key: "userid") ?? "";
    if(response.statusCode == 200) {
      song = jsonDecode(response.body);

      final avgQuery = await FirebaseFirestore.instance
          .collection("ratings")
          .where("songid", isEqualTo: songid)
          .orderBy("date")
          .get();
      if(avgQuery.docs.isNotEmpty) {
        double sum = 0;
        for(var doc in avgQuery.docs) {
          if(doc.data()["userid"] == userid) {
            rated = true;
            myRating = doc.data();
            myRating["id"] = doc.id;
            commentController.text = myRating["comment"];
          }
          sum += doc.data()["rating"];
        }
        avg = sum / avgQuery.docs.length;
        allRatings = avgQuery.docs;
      }

      final userQuery = await FirebaseFirestore.instance
          .collection("users")
          .doc(userid)
          .get();
      if(userQuery.exists) {
        canRate = userQuery.data()?["spotify"] != "" ||
                  userQuery.data()?["sc"] != "" ||
                  userQuery.data()?["am"] != "";
        setState(() {
          loading = false;
        });
      }
    }
  }

  Future<void> addRating() async {
    if(rate < 6.0 && commentController.text.isEmpty) {
      setState(() {
        commentError = true;
      });
    } else {
      final rating = {
        "albumid": song["album"]["id"],
        "comment": commentController.text,
        "date": Timestamp.now(),
        "rating": rate,
        "songid": song["id"],
        "stars": 0,
        "userid": await _storage.read(key: "userid")
      };
      await FirebaseFirestore.instance
          .collection("ratings")
          .add(rating);

      setState(() {
        commentError = false;
        rated = true;
        myRating = rating;
      });
    }
  }

  Future<void> updateRating() async {
    if(rate < 6.0 && commentController.text.isEmpty) {
      setState(() {
        commentError = true;
      });
    } else {
      final rating = {
        "albumid": song["album"]["id"],
        "comment": commentController.text,
        "date": Timestamp.now(),
        "rating": myRating["rating"],
        "songid": song["id"],
        "stars": 0,
        "userid": await _storage.read(key: "userid")
      };
      String docId = myRating["id"];
      await FirebaseFirestore.instance
          .collection("ratings")
          .doc(docId)
          .update(rating);

      setState(() {
        commentError = false;
        rated = true;
        myRating = rating;
        myRating["id"] = docId;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      token = args["token"];
      await getSong(args["song"]);
    });
  }

  @override
  Widget build(BuildContext context) {
    if(loading) {
      return Center(
        child: CircularProgressIndicator(),
      );
    } else {
      return Scaffold(
        appBar: AppBar(
          title: Text("Song Page"),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: Column(
              children: [
                Text(
                  song["name"] ?? "",
                  style: TextStyle(
                    fontSize: 40
                  ),
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pushNamed(
                        context,
                        "/album",
                        arguments: {
                          "album": song["album"]["id"] ?? "",
                          "token": token
                        }
                      ),
                      child: Text(
                        song["album"]["name"] ?? "",
                        style: TextStyle(
                            fontSize: 20,
                            color: Colors.deepPurpleAccent
                        ),
                      )
                    ),
                    Text(
                      "-",
                      style: TextStyle(
                          fontSize: 20,
                          color: Colors.deepPurpleAccent
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pushNamed(
                        context,
                        "/artist",
                        arguments: {
                          "artist": song["artists"][0]["id"] ?? "",
                          "token": token
                        }
                      ),
                      child: Text(
                        song["artists"][0]["name"] ?? "",
                        style: TextStyle(
                            fontSize: 20,
                            color: Colors.deepPurpleAccent
                        ),
                      )
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Image.network(song["album"]["images"][0]["url"]),
                SizedBox(height: 16),
                getFormattedRating(avg, true),
                SizedBox(height: 16),
                Divider(),
                SizedBox(height: 16),
                Builder(builder: (context) {
                  if(canRate) {
                    if(rated) {
                      return Column(
                        children: [
                          Text(
                            "Your rating:",
                            style: TextStyle(
                                fontSize: 24
                            ),
                          ),
                          getFormattedRating(myRating["rating"], true),
                          SSSlider(
                            value: myRating["rating"],
                            min: 0.0,
                            max: 10.0,
                            label: "Rating",
                            onChanged: (double newValue) {
                              setState(() {
                                myRating["rating"] = newValue;
                              });
                            },
                          ),
                          SSTextField(
                            controller: commentController,
                            hintText: "Comment (100 characters max)",
                            maxLines: 2,
                          ),
                          if(commentError)
                            SizedBox(height: 16),
                          if(commentError)
                            Text(
                              "You must provide a comment for ratings less than 6",
                              style: TextStyle(
                                  color: Colors.red
                              ),
                            ),
                          SizedBox(height: 16),
                          SSButton(
                              onPressed: () => updateRating(),
                              text: "Change"
                          ),
                        ],
                      );
                    } else {
                      return Column(
                        children: [
                          Text(
                            "Rate this song:",
                            style: TextStyle(
                                fontSize: 24
                            ),
                          ),
                          getFormattedRating(rate, true),
                          SSSlider(
                            value: rate,
                            min: 0.0,
                            max: 10.0,
                            label: "Rating",
                            onChanged: (double newValue) {
                              setState(() {
                                rate = newValue;
                              });
                            },
                          ),
                          SSTextField(
                            controller: commentController,
                            hintText: "Comment (100 characters max)",
                            maxLines: 2,
                          ),
                          if(commentError)
                            SizedBox(height: 16),
                          if(commentError)
                            Text(
                              "You must provide a comment for ratings less than 6",
                              style: TextStyle(
                                color: Colors.red
                              ),
                            ),
                          SizedBox(height: 16),
                          SSButton(
                              onPressed: () => addRating(),
                              text: "Send"
                          ),
                        ],
                      );
                    }
                  } else {
                    return Text(
                      "Insert at least one social link on your profile to start rating!",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24
                      ),
                    );
                  }
                }),
                SizedBox(height: 32),
                Divider(),
                for(var rating in allRatings)
                  RatingWidget(data: rating.data() as Map<String, dynamic>)
              ],
            ),
          ),
        ),
      );
    }
  }
}

class RatingWidget extends StatefulWidget {
  final Map<String, dynamic>? data;

  const RatingWidget({
    super.key,
    this.data
  });

  @override
  State<RatingWidget> createState() => _RatingWidgetState();
}

class _RatingWidgetState extends State<RatingWidget> {
  User? user;

  Future<void> getUser() async {
    final query = await FirebaseFirestore.instance
        .collection("users")
        .doc(widget.data?["userid"])
        .get();
    if(query.data() != null) {
      var json = query.data();
      json?["userid"] = query.id;
      setState(() {
        user = User.fromJson(json!);
      });
    }
  }

  String timestampToString(Timestamp ts) {
    DateTime dt = ts.toDate();
    return "${dt.day}-${dt.month}-${dt.year}";
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await getUser();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextButton(
          onPressed: () => Navigator.pushNamed(
            context,
            "/profile",
            arguments: {
              "userid": widget.data?["userid"]
            }
          ),
          style: TextButton.styleFrom(
            padding: EdgeInsets.symmetric(horizontal: 5, vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadiusGeometry.zero,
            )
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    user?.username ?? "",
                    style: TextStyle(
                        fontSize: 24,
                        color: Colors.white
                    ),
                  ),
                  SizedBox(width: 10),
                  Text(
                    user?.getCountryFlag() ?? "",
                    style: TextStyle(
                        fontSize: 20
                    ),
                  ),
                ],
              ),
              Text(
                timestampToString(widget.data?["date"]),
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  color: Colors.white
                ),
              )
            ],
          )
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.75,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 5),
                child: Text(
                  widget.data?["comment"],
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 20
                  ),
                ),
              ),
            ),
            getFormattedRating(widget.data?["rating"], false)
          ],
        ),
        SizedBox(height: 16),
        Divider()
      ],
    );
  }
}
