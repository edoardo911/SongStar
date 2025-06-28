import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:song_star/home/music/utils.dart';
import 'package:song_star/utils/secret.dart';

import '../../utils/models.dart';

class RatingWidget extends StatefulWidget {
  final Rating? rating;
  final User? user;

  const RatingWidget({
    super.key,
    this.rating,
    this.user
  });

  @override
  State<RatingWidget> createState() => _RatingWidgetState();
}

class _RatingWidgetState extends State<RatingWidget> {
  User? user;
  Map<String, dynamic> song = {};
  String token = "";
  bool buttonWorks = true;

  Future<void> getUser() async {
    final query = await FirebaseFirestore.instance
        .collection("users")
        .doc(widget.rating?.userid)
        .get();
    if(query.data() != null) {
      setState(() {
        var json = query.data();
        json?["userid"] = query.id;
        user = User.fromJson(json!);
      });
    }
  }

  Future<void> getSong() async {
    final spotifyCredentials = base64Encode(utf8.encode("${spotifyAuth['client']}:${spotifyAuth['secret']}"));
    final response = await http.post(
        Uri.parse("https://accounts.spotify.com/api/token"),
        headers: {
          'Authorization': 'Basic $spotifyCredentials',
          'Content-Type': 'application/x-www-form-urlencoded'
        },
        body: { "grant_type": "client_credentials" }
    );

    if(response.statusCode == 200) {
      final json = jsonDecode(response.body);
      token = json["access_token"];

      final songResponse = await http.get(
        Uri.parse("https://api.spotify.com/v1/tracks/${widget.rating?.songid}"),
        headers: {
          "Authorization": "Bearer $token"
        }
      );

      if(songResponse.statusCode == 200) {
        song = jsonDecode(songResponse.body);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await getSong();
      if(song == {}) {
        return;
      }
      if(widget.user == null) {
        await getUser();
      } else {
        setState(() {
          user = widget.user;
          buttonWorks = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if(user == null) {
      return Center(
        child: CircularProgressIndicator(),
      );
    } else {
      return Column(
        children: [
          Divider(),
          TextButton(
            onPressed: () {
              if(buttonWorks) {
                Navigator.pushNamed(
                    context,
                    "/profile",
                    arguments: {
                      "userid": user!.id
                    }
                );
              }
            },
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
                    Container(
                      constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.6
                      ),
                      child: Text(
                        user!.username,
                        maxLines: 1,
                        softWrap: false,
                        overflow: TextOverflow.fade,
                        style: TextStyle(
                            fontSize: 24,
                            color: Colors.white
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    Text(
                      user!.getCountryFlag(),
                      style: TextStyle(
                          fontSize: 22
                      ),
                    )
                  ],
                ),
                Text(
                  timestampToString(widget.rating!.timestamp),
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    color: Colors.white,
                  ),
                ),
              ],
            )
          ),
          Row(
            children: [
              Image.network(
                song["album"]["images"][0]["url"],
                width: 150,
                height: 150,
              ),
              SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pushNamed(
                      context,
                      "/song",
                      arguments: {
                        "song": song["id"],
                        "token": token
                      }
                    ),
                    child: Container(
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.8 - 150
                      ),
                      child: Text(
                        song["name"],
                        maxLines: 1,
                        softWrap: false,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white
                        ),
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pushNamed(
                      context,
                      "/album",
                      arguments: {
                        "album": song["album"]["id"],
                        "token": token
                      }
                    ),
                    child: Container(
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.8 - 150
                      ),
                      child: Text(
                        song["album"]["name"],
                        maxLines: 1,
                        softWrap: false,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 16,
                            color: Colors.white
                        ),
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pushNamed(
                      context,
                      "/artist",
                      arguments: {
                        "artist": song["album"]["artists"][0]["id"],
                        "token": token
                      }
                    ),
                    child: Container(
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.8 - 150
                      ),
                      child: Text(
                        song["album"]["artists"][0]["name"],
                        maxLines: 1,
                        softWrap: false,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 16,
                            color: Colors.white
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Builder(builder: (context) {
                if(widget.rating!.comment != "") {
                  return Text(
                    widget.rating!.comment,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 20
                    ),
                  );
                } else {
                  return Text(
                    "No comment",
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white24
                    ),
                  );
                }
              }),
              getFormattedRating(widget.rating!.rating, true),
            ],
          ),
          SizedBox(height: 16),
        ],
      );
    }
  }
}
