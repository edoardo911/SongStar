import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';

import 'utils.dart';

class Album extends StatefulWidget {
  const Album({super.key});

  @override
  State<Album> createState() => _AlbumState();
}

class _AlbumState extends State<Album> {
  Map<String, dynamic> songRatings = {};
  Map<String, dynamic> songs = {};
  Map<String, dynamic> album = {};
  bool loading = true;
  String token = "";
  double rating = -1;

  Future<void> getSongs(String albumid) async {
    final response = await http.get(
      Uri.parse("https://api.spotify.com/v1/albums/$albumid"),
      headers: {
        "Authorization": "Bearer $token"
      }
    );
    if(response.statusCode == 200) {
      album = jsonDecode(response.body);

      final query = await FirebaseFirestore.instance
          .collection("ratings")
          .where("albumid", isEqualTo: albumid)
          .get();
      if(query.docs.isNotEmpty) {
        double sum = 0;
        for(var d in query.docs) {
          double r = d.data()["rating"];
          if(songRatings[d["songid"]] == null) {
            songRatings[d["songid"]] = { "sum": r, "count": 1 };
          } else {
            songRatings[d["songid"]] = { "sum": songRatings[d["songid"]]["sum"] + r, "count": songRatings[d["songid"]]["count"] + 1 };
          }
          sum += r;
        }
        rating = sum / query.docs.length;
      }

      final response2 = await http.get(
          Uri.parse("https://api.spotify.com/v1/albums/$albumid/tracks"),
          headers: {
            "Authorization": "Bearer $token"
          }
      );
      if(response2.statusCode == 200) {
        songs = jsonDecode(response2.body);
        setState(() {
          loading = false;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      token = args["token"];
      await getSongs(args["album"]);
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
          title: Text("Album Page"),
        ),
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Text(
                  album["name"],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 36
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.pushNamed(
                    context,
                    "/artist",
                    arguments: {
                      "artist": album["artists"][0]["id"],
                      "token": token
                    }
                  ),
                  child: Text(
                    album["artists"][0]["name"],
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.deepPurpleAccent
                    ),
                  ),
                ),
                SizedBox(height: 16),
                Image.network(
                  album["images"][0]["url"]
                ),
                SizedBox(height: 16),
                getFormattedRating(rating, true),
                SizedBox(height: 16),
                for(var song in songs["items"])
                  SongAlbum(data: song, rating: songRatings[song["id"]], token: token)
              ],
            ),
          ),
        ),
      );
    }
  }
}

class SongAlbum extends StatelessWidget {
  final Map<String, dynamic>? data;
  final Map<String, dynamic>? rating;
  final String? token;

  const SongAlbum({
    super.key,
    this.data,
    this.rating,
    this.token
  });

  String formatMinutes(int millis) {
    double secD = millis / 1000;
    int mins = (secD / 60).toInt();
    int sec = (secD - mins * 60).toInt();
    int digitsMinusOne = 0;
    if(sec != 0) {
      digitsMinusOne = (log(sec) / log(10)).toInt();
    }
    if(digitsMinusOne == 0) {
      return "$mins:0$sec";
    } else {
      return "$mins:$sec";
    }
  }

  @override
  Widget build(BuildContext context) {
    double r = -1;
    if(rating != null) {
      r = rating?["sum"] / rating?["count"];
    }

    return TextButton(
      onPressed: () => Navigator.pushNamed(
        context,
        "/song",
        arguments: {
          "song": data?["id"],
          "token": token
        }
      ),
      style: TextButton.styleFrom(
          padding: EdgeInsets.symmetric(horizontal: 5, vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadiusGeometry.zero,
          )
      ),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.height * 0.3,
            child: Text(
              data?["name"],
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontSize: 16,
                  color: Colors.white
              ),
            ),
          ),
          Row(
            children: [
              getFormattedRating(r, false),
              SizedBox(width: 32),
              Text(
                formatMinutes(data?["duration_ms"]),
                style: TextStyle(
                  color: Colors.white
                ),
              )
            ],
          )
        ],
      )
    );
  }
}
