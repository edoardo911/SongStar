import 'package:flutter/material.dart';

class Top extends StatefulWidget {
  const Top({super.key});

  @override
  State<Top> createState() => _TopState();
}

class _TopState extends State<Top> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: MediaQuery.of(context).size.height / 2 - 80),
          Center(
            child: Text(
              "Work in progress...",
              style: TextStyle(
                  fontSize: 32
              ),
            ),
          )
        ],
      ),
    );
  }
}
