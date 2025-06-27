import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'user_flux/login.dart';
import 'home/home.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<void> checkUserLogged() async {
    final token = await _storage.read(key: 'userid');
    if(!mounted) return;
    Navigator.pushReplacement(context, MaterialPageRoute(
        builder: (_) => token != null ? const Home() : Login()
    ));
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => checkUserLogged() );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
