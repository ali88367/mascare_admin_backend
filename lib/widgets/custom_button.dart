import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../colors.dart';


class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color color;
  final Color textColor;
  final double? width;
  final double? height;
  final double borderRadius;
  final double fontSize;
  final FontWeight fontWeight;
  final BoxBorder? border;
  final Widget? child; // Make the child optional

  CustomButton({
    required this.text,
    required this.onPressed,
    this.color = blackColor,
    this.textColor = Colors.white,
    this.width,
    this.height,
    this.borderRadius = 12,
    this.fontSize = 16,
    this.fontWeight = FontWeight.w500,
    this.border,
    this.child, // No required here
  });

  @override
  Widget build(BuildContext context) {

    return GestureDetector(
        onTap: onPressed,
        child: Container(
            margin: EdgeInsets.only(bottom: 21),
            width: width != null ? width! : null,
            height: height != null ? height! : null,
            decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(borderRadius),
                border: border),
            child: Center(
                child: child != null // Check for child first
                    ? child! // Use the child widget
                    : Text( // If no child, use the default Text
                  text,
                  style: TextStyle(
                    color: textColor,
                    fontSize: fontSize,
                    fontWeight: fontWeight,
                  ),
                )


            )

        )
    );
  }
}