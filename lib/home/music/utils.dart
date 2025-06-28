import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Widget getFormattedRating(double num, bool big) {
  String rating = "";
  Color color = Colors.white24;
  if(num < 0) {
    rating = "/";
  } else {
    int numInt = num.toInt();
    double dec = num - numInt;
    String rate = "";
    if(dec == 0.25) {
      rate = "$numInt+";
    } else if(dec == 0.5) {
      rate = "$numInt.5";
    } else if(dec == 0.75) {
      rate = "${numInt + 1}-";
    } else {
      rate = numInt.toString();
    }

    rating = "$rate/10";

    if(num < 6) {
      color = Colors.red;
    } else if(num < 7) {
      color = Colors.yellow;
    } else if(num < 9) {
      color = Colors.green;
    } else {
      color = Colors.deepPurpleAccent;
    }
  }

  double fontSize = big ? 42 : 14;
  return Text(
    rating,
    style: TextStyle(
      color: color,
      fontSize: fontSize
    ),
  );
}

String timestampToString(Timestamp ts) {
  DateTime dt = ts.toDate();
  return "${dt.day}-${dt.month}-${dt.year}";
}