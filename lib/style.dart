import 'package:flutter/material.dart';

//テーマ
ThemeData darkTheme() {
  return ThemeData(
    brightness: Brightness.dark,
    elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white30,
        )),
    primaryIconTheme: IconThemeData(
      color: Colors.white,
    ),
    dividerTheme: DividerThemeData(
      color: Colors.white,
      indent: 8.0,
      endIndent: 8.0,
      thickness: 0.8,
    ),
    iconTheme: IconThemeData(
      color: Colors.white,
    ),
    dialogTheme: DialogTheme(
      backgroundColor: Colors.white,
      titleTextStyle: TextStyle(
        color: Colors.black,
        fontSize: 21.0,
        fontFamily: "Lanobe",
      ),
      contentTextStyle: TextStyle(
        color: Colors.black,
      ),
    ),
    fontFamily: "Lanobe",
  );
}


ThemeData lightTheme() {
  return ThemeData(
    primaryColor: Colors.white,
    brightness: Brightness.light,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.white,
      iconTheme: IconThemeData(
        color: Colors.black,
      ),
      titleTextStyle: TextStyle(
        color: Colors.black,
        fontSize: 21.0,
        fontFamily: "Lanobe",
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
        )),
    primaryIconTheme: IconThemeData(
      color: Colors.white,
    ),
    dividerTheme: DividerThemeData(
      color: Colors.black,
      indent: 8.0,
      endIndent: 8.0,
      thickness: 0.8,
    ),
    iconTheme: IconThemeData(
      color: Colors.black,
    ),
    dialogTheme: DialogTheme(
      backgroundColor: Colors.white,
      titleTextStyle: TextStyle(
        color: Colors.black,
        fontSize: 21.0,
        fontFamily: "Lanobe",
      ),
      contentTextStyle: TextStyle(
        color: Colors.black,
      ),
    ),
    fontFamily: "Lanobe",
  );
}
