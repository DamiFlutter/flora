import 'package:flutter/material.dart';

class CustomButtom extends StatefulWidget {
  final String text;
  final IconData? icon;
  final Color? color;
  final Color? textColor;
  final String? loadingText;
  bool isLoading;
  final VoidCallback onPressed;
  final double? height;
  CustomButtom(
      {Key? key,
      required this.onPressed,
      this.color,
      this.height,
      this.icon,
      this.loadingText,
      required this.isLoading,
      required this.text,
      this.textColor})
      : super(key: key);

  @override
  State<CustomButtom> createState() => _CustomButtomState();
}

class _CustomButtomState extends State<CustomButtom> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height ?? 50,
      width: double.infinity,
      child: ElevatedButton(
        child: widget.isLoading
            ? Text(widget.loadingText ?? 'Loading...')
            : Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (widget.icon != null)
                    Icon(
                      widget.icon,
                      color: widget.textColor ?? Colors.white,
                      size: widget.height ?? 20,
                    ),
                  const SizedBox(width: 10),
                  Text(widget.text),
                ],
              ),
        onPressed: widget.onPressed,
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(widget.color),
          elevation: MaterialStateProperty.all(0),
        ),
      ),
    );
  }
}
