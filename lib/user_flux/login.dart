import 'package:flutter/material.dart';
import '../utils/custom_widgets.dart';
import 'package:bcrypt/bcrypt.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../home/home.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  String? errorMessage;

  Future<void> login() async {
    if(emailController.text.isNotEmpty &&
        passwordController.text.isNotEmpty) {
      final querySnapshot = await FirebaseFirestore.instance
          .collection("users")
          .where("email", isEqualTo: emailController.text)
          .get();
      if(querySnapshot.docs.isNotEmpty) {
        final String hashedPwd = querySnapshot.docs[0].data()["password"];
        if(BCrypt.checkpw(passwordController.text, hashedPwd)) {
          _storage.write(key: "userid", value: querySnapshot.docs[0].id);
          Navigator.pushReplacement(context, MaterialPageRoute(
              builder: (_) => Home()
          ));
        }
        else {
          setState(() {
            errorMessage = "Email or password incorrect";
          });
        }
      }
      else {
        setState(() {
          errorMessage = "Email or password incorrect";
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Login",
                  style: TextStyle(fontSize: 50),
                ),
                const SizedBox(height: 24),
                SSTextField(
                  controller: emailController,
                  type: TextInputType.emailAddress,
                  hintText: "Email",
                ),
                const SizedBox(height: 16),
                SSTextField(
                  controller: passwordController,
                  hintText: "Password",
                  obscureText: true,
                ),
                if(errorMessage != null) ... [
                  const SizedBox(height: 16),
                  Text(
                    errorMessage!,
                    style: const TextStyle(color: Colors.redAccent),
                  ),
                ],
                const SizedBox(height: 16),
                SSButton(
                  onPressed: login,
                  text: "Login",
                ),
                TextButton(
                    onPressed: () => Navigator.pushNamed(context, "/register"),
                    child: const Text("Register")
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
