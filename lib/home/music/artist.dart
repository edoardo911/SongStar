import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';

import 'utils.dart';

class Artist extends StatefulWidget {
  const Artist({super.key});

  @override
  State<Artist> createState() => _ArtistState();
}

class _ArtistState extends State<Artist> {
  Map<String, double> ratings = {};
  Map<String, dynamic> albums = {};
  Map<String, dynamic> artistData = {};
  bool loading = true;
  String token = "";

  Future<void> getArtistInfo(String id) async {
    final response = await http.get(
      Uri.parse("https://api.spotify.com/v1/artists/$id"),
      headers: {
        "Authorization": "Bearer $token"
      }
    );
    if(response.statusCode == 200) {
      artistData = jsonDecode(response.body);

      final response2 = await http.get(
        Uri.parse("https://api.spotify.com/v1/artists/$id/albums"),
        headers: {
          "Authorization": "Bearer $token"
        }
      );

      if(response2.statusCode == 200) {
        albums = jsonDecode(response2.body);

        for(var a in albums["items"]) {
          final querySnapshot = await FirebaseFirestore.instance
              .collection("ratings")
              .where("albumid", isEqualTo: a["id"])
              .get();

          if(querySnapshot.docs.isNotEmpty) {
            double sum = 0;
            for(var doc in querySnapshot.docs) {
              sum += doc.data()["rating"];
            }
            ratings[a["id"]] = sum / querySnapshot.docs.length;
          } else {
            ratings[a["id"]] = -1;
          }
        }

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
      await getArtistInfo(args["artist"]);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Builder(builder: (context) {
      if(loading) {
        return Center(child: CircularProgressIndicator());
      } else {
        return Scaffold(
          appBar: AppBar(
            title: Text("Artist Page"),
          ),
          body: Padding(
            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Text(
                    artistData["name"],
                    style: TextStyle(
                        fontSize: 40
                    ),
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(
                        width: 131,
                        height: 131,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: Colors.deepPurple,
                                width: 3
                            )
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(500),
                          child: Image.network(
                            artistData["images"][0]["url"],
                            width: 128,
                            height: 128,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Builder(builder: (context) {
                    final genres = artistData["genres"];
                    String concat = "";
                    for(var g in genres) {
                      concat += "$g, ";
                    }
                    concat = concat.substring(0, concat.length - 2);
                    return Text(
                      concat,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 24,
                          color: Colors.deepPurpleAccent
                      ),
                    );
                  }),
                  SizedBox(height: 16),
                  //TODO if
                  for(var a in albums["items"])
                    AlbumWidget(data: a, ratings: ratings, token: token)
                ],
              ),
            ),
          ),
        );
      }
    });
  }
}

class AlbumWidget extends StatelessWidget {
  final Map<String, dynamic>? data;
  final Map<String, double>? ratings;
  final String? token;

  const AlbumWidget({
    super.key,
    this.data,
    this.ratings,
    this.token
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextButton(
          onPressed: () => Navigator.pushNamed(
            context,
            "/album",
            arguments: {
              "album": data?["id"],
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Image.network(
                    data?["images"][0]["url"],
                    width: 100,
                    height: 100,
                  ),
                  SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.height * 0.2,
                        child: Text(
                          data?["name"],
                          maxLines: 1,
                          softWrap: false,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: 24,
                              color: Colors.white
                          ),
                        ),
                      ),
                      getFormattedRating(ratings?[data?["id"]] ?? 0.0, false)
                    ],
                  )
                ],
              ),
              Text(
                data?["release_date"],
                style: TextStyle(
                  color: Colors.white,
                  fontStyle: FontStyle.italic
                ),
              )
            ],
          )
        ),
      ],
    );
  }
}
