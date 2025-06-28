import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

import '../../utils/custom_widgets.dart';
import '../../utils/models.dart';
import '../../utils/country_codes.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final usernameController = TextEditingController();
  final scController = TextEditingController();
  final amController = TextEditingController();
  final spotifyController = TextEditingController();
  final countryController = TextEditingController();

  bool usernameError = false;
  bool spotifyError = false;
  bool scError = false;
  bool amError = false;

  User? user;

  Future<void> save() async {
    setState(() {
      usernameError = false;
      spotifyError = false;
      scError = false;
      amError = false;
    });

    String spotify = "";
    String sc = "";
    String am = "";

    //spotify
    if(spotifyController.text != "" &&
        !spotifyController.text.startsWith("https://open.spotify.com/user/") &&
        spotifyController.text.length > 30) {
      setState(() {
        spotifyError = true;
        return;
      });
    }
    if(spotifyController.text != "") {
      spotify = spotifyController.text.substring(30, spotifyController.text.length);
    }

    //soundcloud
    if(scController.text != "" &&
        !scController.text.startsWith("https://on.soundcloud.com/") &&
        scController.text.allMatches("/").length == 3 &&
        scController.text.length > 26) {
      setState(() {
        scError = true;
        return;
      });
    }
    if(scController.text != "") {
      sc = scController.text.substring(26, scController.text.length);
    }

    if(amController.text != "" &&
        !amController.text.startsWith("https://music.apple.com/profile/") &&
        amController.text.length > 32) {
      setState(() {
        amError = true;
        return;
      });
    }
    if(amController.text != "") {
      am = amController.text.substring(32, amController.text.length);
    }

    final querySnapshot = await FirebaseFirestore.instance
        .collection("users")
        .where("username", isEqualTo: usernameController.text)
        .where("")
        .get();

    if(usernameController.text == "" ||
      (querySnapshot.docs.isNotEmpty && querySnapshot.docs[0].id != user!.id)) {
      setState(() {
        usernameError = true;
      });
      return;
    }

    await FirebaseFirestore.instance
        .collection("users")
        .doc(user!.id)
        .update({
      "username": usernameController.text,
      "spotify": spotify,
      "am": am,
      "sc": sc,
      "cc": countryController.text.substring(0, 2)
    });
    Navigator.pop(context);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      usernameController.text = user!.username;
      if(user!.sc != "") {
        scController.text = "https://on.soundcloud.com/${user!.sc}";
      }
      if(user!.am != "") {
        amController.text = "https://music.apple.com/profile/${user!.am}";
      }
      if(user!.spotify != "") {
        spotifyController.text = "https://open.spotify.com/user/${user!.spotify}";
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    user = args["user"];

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
          child: Column(
            children: [
              SizedBox(height: 20),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Icon(
                      Icons.arrow_back,
                      size: 50,
                      color: Colors.white,
                    )
                ),
              ),
              SizedBox(height: 16),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Username:",
                  style: TextStyle(
                      fontSize: 20
                  ),
                ),
              ),
              SizedBox(height: 16),
              SSTextField(
                controller: usernameController,
              ),
              if(usernameError) ... [
                SizedBox(height: 16),
                Text(
                  "Invalid username",
                  style: TextStyle(
                      fontSize: 16,
                      color: Colors.red
                  ),
                ),
              ],
              SizedBox(height: 32),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Spotify Profile:",
                  style: TextStyle(
                      fontSize: 20
                  ),
                ),
              ),
              SizedBox(height: 16),
              MusicProfile(controller: spotifyController),
              if(spotifyError) ... [
                SizedBox(height: 16),
                Text(
                  "Invalid Spotify link",
                  style: TextStyle(
                      fontSize: 16,
                      color: Colors.red
                  ),
                ),
              ],
              SizedBox(height: 32),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "SoundCloud Profile:",
                  style: TextStyle(
                      fontSize: 20
                  ),
                ),
              ),
              SizedBox(height: 16),
              MusicProfile(controller: scController),
              if(scError) ... [
                SizedBox(height: 16),
                Text(
                  "Invalid SoundCloud link",
                  style: TextStyle(
                      fontSize: 16,
                      color: Colors.red
                  ),
                ),
              ],
              SizedBox(height: 32),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Apple Music Profile:",
                  style: TextStyle(
                      fontSize: 20
                  ),
                ),
              ),
              SizedBox(height: 16),
              MusicProfile(controller: amController),
              if(amError) ... [
                SizedBox(height: 16),
                Text(
                  "Invalid Apple Music link",
                  style: TextStyle(
                      fontSize: 16,
                      color: Colors.red
                  ),
                ),
              ],
              SizedBox(height: 32),
              SSDropdownMenu(
                controller: countryController,
                items: countryCodes.map((code) {
                  final base = 0x1F1E6;
                  final offset = "A".codeUnitAt(0);
                  final flag = String.fromCharCodes(
                      code.toUpperCase().codeUnits.map((c) => base + (c - offset))
                  );
                  return DropdownMenuEntry(value: code, label: "$code  $flag");
                }).toList(),
                label: "Country",
                initialSelection: user!.cc,
              ),
              SizedBox(height: 32),
              SSButton(
                onPressed: save,
                text: "Save",
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MusicProfile extends StatelessWidget {
  final TextEditingController? controller;

  const MusicProfile({
    super.key,
    this.controller
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        Expanded(
          child: SSTextField(
            controller: controller,
          ),
        ),
        SizedBox(width: 10),
        ElevatedButton(
          onPressed: () async {
            final data = await Clipboard.getData(Clipboard.kTextPlain);
            controller?.text = data?.text ?? "";
          },
          style: ElevatedButton.styleFrom(
            fixedSize: Size(60, 60),
            backgroundColor: Colors.deepPurpleAccent,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(500),
                side: BorderSide(color: Colors.deepPurple.shade800, width: 3)
            ),
          ),
          child: const Icon(
            Icons.paste,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}
