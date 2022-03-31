import 'package:flora/themes/colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TextStyles {
  static TextStyle subtitle = GoogleFonts.abel(
    fontWeight: FontWeight.w600,
    fontSize: 18,
    color: Colors.black,
  );
  static TextStyle mainText = GoogleFonts.poppins(
    fontWeight: FontWeight.w600,
    fontSize: 16,
    color: AppColors.black,
  );
  static TextStyle logoText = GoogleFonts.poppins(
    fontWeight: FontWeight.w600,
    fontSize: 25,
    color: AppColors.maincolor,
  );
}
