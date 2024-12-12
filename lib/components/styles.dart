import 'package:flutter/material.dart';

var primaryColor = Colors.blue;
var warningColor = const Color(0xFFE9C46A);
var dangerColor = const Color(0xFFE76F51);
var successColor = const Color(0xFF2A9D8F);
var greyColor = const Color(0xFFAFAFAF);

TextStyle headerStyle({int level = 1, bool dark = true}) {
  List<double> levelSize = [30, 24, 20, 14, 12];

  return TextStyle(
      fontSize: levelSize[level-1],
      fontWeight: FontWeight.bold,
      color: dark ? Colors.black : Colors.white);
}
TextStyle textStyle({int level = 1, bool bold = false, bool dark = true}) {
  List<double> levelSize = [30, 24, 20, 14, 12];
  return TextStyle(
      fontSize: levelSize[level-1],
      fontWeight: bold ? FontWeight.bold : FontWeight.normal,
      color: dark ? Colors.black : Colors.white);
}

var buttonStyle = ElevatedButton.styleFrom(
    padding: const EdgeInsets.symmetric(vertical: 15,horizontal: 20),
    backgroundColor: primaryColor);

InputDecoration boxInputDecoration(String label) {
  return InputDecoration(
      label: Text(label, style: headerStyle(level: 3)),
      floatingLabelBehavior: FloatingLabelBehavior.always,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)));
}
