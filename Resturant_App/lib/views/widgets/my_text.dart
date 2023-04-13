import 'package:flutter/material.dart';
import 'package:resturantapp/constant/color.dart';

class MyText extends StatelessWidget {
  String? text;
  FontWeight? fontWeight;
  TextAlign? align;
  TextDecoration? decoration;
  Color? color;
  double? fontSize, height;
  String? fontFamily;
  int maxLines;
  TextOverflow? overFlow;
  TextOverflow? overFlow2;
  VoidCallback? onTap;
  FontStyle? fontStyle;
  double? paddingTop, paddingLeft, paddingRight, paddingBottom, letterSpacing;

  MyText({
    Key? key,
    this.text,
    this.fontSize,
    this.height,
    this.maxLines = 100,
    this.decoration = TextDecoration.none,
    this.color = kSecondaryColor,
    this.letterSpacing,
    this.fontWeight = FontWeight.w400,
    this.align,
    this.overFlow,
    this.overFlow2,
    this.fontFamily,
    this.paddingTop = 0,
    this.paddingRight = 0,
    this.paddingLeft = 0,
    this.paddingBottom = 0,
    this.fontStyle,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: paddingTop!,
        left: paddingLeft!,
        right: paddingRight!,
        bottom: paddingBottom!,
      ),
      child: GestureDetector(
        onTap: onTap,
        child: Text(
          text ?? "",
          style: TextStyle(
            fontSize: fontSize,
            color: color ?? Colors.black,
            fontWeight: fontWeight,
            decoration: decoration,
            fontFamily: fontFamily ?? 'poppins',
            height: height,
            letterSpacing: letterSpacing,
            fontStyle: fontStyle,
            overflow: overFlow2,
          ),
          textAlign: align,
          maxLines: maxLines,
          overflow: overFlow,
        ),
      ),
    );
  }
}
