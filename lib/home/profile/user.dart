import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../utils/models.dart';

class UserWidget extends StatelessWidget {
  final User? user;
  final bool pop;

  const UserWidget({
    super.key,
    this.user,
    this.pop = true
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {
        if(pop) {
          Navigator.pop(context);
        }
        Navigator.pushNamed(context, "/profile", arguments: {
          "userid": user!.id
        });
      },
      style: TextButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.zero
        )
      ),
      child: Column(
        children: [
          Divider(color: Colors.white24, thickness: 1.5, radius: BorderRadius.circular(50)),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 16),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      "${user!.username} ${user!.getCountryFlag()}",
                      style: TextStyle(
                          fontSize: 24,
                          color: Colors.white
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    if(user!.spotify != "")
                      Icon(
                        FontAwesomeIcons.spotify,
                        color: Colors.green,
                        size: 20,
                      ),
                    SizedBox(width: 16),
                    if(user!.sc != "")
                      Icon(
                        FontAwesomeIcons.soundcloud,
                        color: Colors.orange.shade700,
                        size: 20,
                      ),
                    SizedBox(width: 16),
                    if(user!.am != "")
                      Icon(
                        FontAwesomeIcons.apple,
                        color: Colors.white,
                        size: 20,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
