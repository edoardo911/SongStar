import 'package:flutter/material.dart';
import 'package:song_star/utils/custom_widgets.dart';
import 'package:bcrypt/bcrypt.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../home/home.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final pwdController = TextEditingController();
  final pwdConfirmController = TextEditingController();
  String? errorMessage;

  final RegExp emailRegex = RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
  final RegExp pwdRegex = RegExp(r"^(?=.*[A-Z])(?=.*\d).{8,}$");

  Future<bool> emailExists(String email) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection("users")
        .where("email", isEqualTo: email)
        .get();
    return querySnapshot.docs.isNotEmpty;
  }

  Future<bool> usernameExists(String username) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection("users")
        .where("username", isEqualTo: username)
        .get();
    return querySnapshot.docs.isNotEmpty;
  }

  String getCountryCode() { return WidgetsBinding.instance.platformDispatcher.locale.countryCode ?? "US"; }

  Future<void> register() async {
    if(usernameController.text.isNotEmpty &&
        emailController.text.isNotEmpty &&
        pwdController.text.isNotEmpty &&
        pwdConfirmController.text.isNotEmpty) {
      if(await usernameExists(usernameController.text)) {
        setState(() {
          errorMessage = "The username is already in use";
        });
      }
      else if(!emailRegex.hasMatch(emailController.text)) {
        setState(() {
          errorMessage = "Invalid email";
        });
      }
      else if(await emailExists(emailController.text)) {
        setState(() {
          errorMessage = "The email is already in use";
        });
      }
      else if(!pwdRegex.hasMatch(pwdController.text)) {
        setState(() {
          errorMessage = "Password must be at least 8 characters long, contain a number and an upper case letter";
          pwdConfirmController.text = "";
        });
      }
      else if(pwdController.text != pwdConfirmController.text) {
        setState(() {
          errorMessage = "Passwords don't match";
        });
      }
      else {
        setState(() {
          errorMessage = null;
        });
        final String hashedPwd = BCrypt.hashpw(pwdController.text, BCrypt.gensalt());

        final user = await FirebaseFirestore.instance.collection("users").add({
          "username": usernameController.text,
          "email": emailController.text,
          "password": hashedPwd,
          "sc": "",
          "spotify": "",
          "am": "",
          "cc": getCountryCode()
        });

        _storage.write(key: "userid", value: user.id);
        Navigator.pop(context);
        Navigator.pushReplacement(context, MaterialPageRoute(
            builder: (_) => Home()
        ));
      }
    }
    else {
      setState(() {
        errorMessage = "Fill all the inputs";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Register",
                  style: TextStyle(fontSize: 50),
                ),
                const SizedBox(height: 24),
                SSTextField(
                  controller: usernameController,
                  type: TextInputType.name,
                  hintText: "Username",
                ),
                const SizedBox(height: 16),
                SSTextField(
                  controller: emailController,
                  type: TextInputType.emailAddress,
                  hintText: "Email",
                ),
                const SizedBox(height: 16),
                SSTextField(
                  controller: pwdController,
                  hintText: "Password",
                  obscureText: true,
                ),
                const SizedBox(height: 16),
                SSTextField(
                  controller: pwdConfirmController,
                  hintText: "Confirm Password",
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
                  onPressed: register,
                  text: "Register",
                ),
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Login")
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
