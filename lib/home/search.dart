import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../utils/custom_widgets.dart';
import '../utils/models.dart';
import 'profile/user.dart';

import '../utils/secret.dart';
import 'music/search_widgets.dart';

class Search extends StatefulWidget {
  const Search({super.key});

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  final typeController = TextEditingController();
  String spotifyToken = "";

  final List<User> users = [];
  List<dynamic> songs = [];
  List<dynamic> albums = [];
  List<dynamic> artists = [];
  int showIndex = -1;

  List<DropdownMenuEntry<String>> types = [ //69905d30f2ee4d2b80fb65241a331587
    DropdownMenuEntry(value: "Song", label: "Song"),
    DropdownMenuEntry(value: "Artist", label: "Artist"),
    DropdownMenuEntry(value: "Album", label: "Album"),
    DropdownMenuEntry(value: "User", label: "User")
  ];

  Future<String?> getSpotifyToken() async {
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
      return json["access_token"];
    } else {
      return null;
    }
  }

  Future<void> search(String value) async {
    songs.clear();
    albums.clear();
    artists.clear();
    users.clear();

    switch(typeController.text) {
      case "Song":
        final response = await http.get(
            Uri.parse("https://api.spotify.com/v1/search?q=$value&type=track"),
            headers: {
              "Authorization": "Bearer $spotifyToken"
            }
        );

        if(response.statusCode == 200) {
          final json = jsonDecode(response.body);
          songs = json["tracks"]["items"];
        }

        setState(() {
          showIndex = 0;
        });
        break;
      case "Artist":
        final response = await http.get(
          Uri.parse("https://api.spotify.com/v1/search?q=$value&type=artist"),
          headers: {
            "Authorization": "Bearer $spotifyToken"
          }
        );

        if(response.statusCode == 200) {
          final json = jsonDecode(response.body);
          artists = json["artists"]["items"];
        }
        
        setState(() {
          showIndex = 1;
        });
        break;
      case "Album":
        final response = await http.get(
            Uri.parse("https://api.spotify.com/v1/search?q=$value&type=album"),
            headers: {
              "Authorization": "Bearer $spotifyToken"
            }
        );

        if(response.statusCode == 200) {
          final json = jsonDecode(response.body);
          albums = json["albums"]["items"];
        }

        setState(() {
          showIndex = 2;
        });
        break;
      case "User":
        final query = await FirebaseFirestore.instance
            .collection("users")
            .where("username", isEqualTo: value)
            .get();

        for(var doc in query.docs) {
          var json = doc.data();
          json["userid"] = doc.id;
          users.add(User.fromJson(json));
        }

        setState(() {
          showIndex = 3;
        });
        break;
      default:
        break;
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      spotifyToken = await getSpotifyToken() ?? "";
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          SSTextField(
            hintText: "Search",
            onSubmitted: search,
          ),
          SizedBox(height: 16),
          SSDropdownMenu(
            controller: typeController,
            initialSelection: "Song",
            label: "",
            items: types,
          ),
          SizedBox(height: 16),
          Builder(builder: (context) {
            switch(showIndex) {
              case -1: //default
                return Column();
              case 0:
                if(songs.isNotEmpty) {
                  return Column(
                    children: [
                      for(var s in songs)
                        if(s != null)
                          SongSearch(data: s, token: spotifyToken)
                    ],
                  );
                } else {
                  return NoMatches();
                }
              case 1: //artists
                if(artists.isNotEmpty) {
                  return Column(
                    children: [
                      for(var a in artists)
                        if(a != null)
                          ArtistSearch(data: a, token: spotifyToken)
                    ],
                  );
                } else {
                  return NoMatches();
                }
              case 2: //albums
                if(albums.isNotEmpty) {
                  return Column(
                    children: [
                      for(var album in albums)
                        if(album != null)
                          AlbumSearch(data: album, token: spotifyToken)
                    ],
                  );
                } else {
                  return NoMatches();
                }
              case 3: //users
                if(users.isNotEmpty) {
                  return Column(
                    children: [
                      for(var user in users)
                        UserWidget(user: user, pop: false)
                    ],
                  );
                } else {
                  return NoMatches();
                }
              default:
                return Placeholder();
            }
          }),
        ],
      ),
    );
  }
}
