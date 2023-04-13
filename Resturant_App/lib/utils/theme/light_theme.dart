import 'package:flutter/material.dart';
import 'package:resturantapp/constant/color.dart';

ThemeData lightTheme = ThemeData(
  // scaffoldBackgroundColor: kSeoulColor2,
  scaffoldBackgroundColor: Colors.white,
  // fontFamily: GoogleFonts.poppins().fontFamily,
  appBarTheme: const AppBarTheme(
    elevation: 3,
    backgroundColor: kPrimaryColor,
  ),
  splashColor: kPrimaryColor.withOpacity(0.10),
  highlightColor: kPrimaryColor.withOpacity(0.10),
  colorScheme: ColorScheme.fromSwatch().copyWith(
    secondary: kSecondaryColor.withOpacity(0.1),
  ),
  textSelectionTheme: const TextSelectionThemeData(
    cursorColor: kSecondaryColor,
  ),
);
