import 'package:flora/themes/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:google_fonts/google_fonts.dart';

class SearchBar extends StatelessWidget {
  final String hintText;
  const SearchBar({Key? key, required this.hintText}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      width: double.infinity,
      child: TextField(
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: GoogleFonts.raleway(
            color: AppColors.hinttextcolor,
            fontSize: 16,
          ),
          filled: true,
          fillColor: AppColors.grey2.withAlpha(100),
          border: InputBorder.none,
          prefixIcon: const Icon(FlutterIcons.search1_ant,
              size: 18, color: AppColors.grey2),
        ),
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }
}
