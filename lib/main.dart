import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:song_star/home/profile/editprofile.dart';
import 'utils/firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'user_flux/login.dart';
import 'home/home.dart';
import 'user_flux/register.dart';
import 'splash.dart';
import 'home/profile/following.dart';
import 'home/profile/followers.dart';
import 'home/profile/user_profile.dart';

import 'home/music/song.dart';
import 'home/music/album.dart';
import 'home/music/artist.dart';

import 'utils/secret.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: fireAuth["email"]!,
      password: fireAuth["password"]!
  );

  runApp(MaterialApp(
    theme: ThemeData(
    brightness: Brightness.dark
    ),
    initialRoute: "/",
    routes: {
      '/': (context) => SplashScreen(),
      '/home': (context) => Home(),
      '/login': (context) => Login(),
      '/register': (context) => Register(),
      '/profile': (context) => UserProfile(),
      '/editprofile': (context) => EditProfile(),
      '/following': (context) => Following(),
      '/followers': (context) => Followers(),
      '/song': (context) => Song(),
      '/album': (context) => Album(),
      '/artist': (context) => Artist()
    },
  ));
}