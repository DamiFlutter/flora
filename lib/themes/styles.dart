import 'package:flora/themes/colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TextStyles {
  static TextStyle subtitle = GoogleFonts.abel(
    fontWeight: FontWeight.w600,
    fontSize: 14,
    color: Colors.black,
  );
  static TextStyle subtitl2 = GoogleFonts.abel(
    fontWeight: FontWeight.w600,
    fontSize: 12,
    color: Colors.grey,
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
  static TextStyle h2 = GoogleFonts.raleway(
    fontWeight: FontWeight.w600,
    fontSize: 22,
    color: AppColors.black,
  );
}
