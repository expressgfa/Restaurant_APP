import 'package:flutter/material.dart';

class CustomListTile extends StatelessWidget {
  final Widget leading;
  final Widget title;
  final Widget? subtitle;
  final Widget? trailing;
  final EdgeInsetsGeometry contentPadding;
  final double? trailingTopPadding;
  final GestureTapCallback? onTap;

  const CustomListTile({
    Key? key,
    required this.leading,
    required this.title,
    this.subtitle,
    this.trailing,
    this.trailingTopPadding,
    this.contentPadding = const EdgeInsets.only(
      top: 10.0,
      right: 16.0,
      left: 16.0,
    ),
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: contentPadding,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (leading != null) ...[
              leading,
              const SizedBox(width: 16.0),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  title,
                  if (subtitle != null) ...[
                    const SizedBox(height: 4.0),
                    subtitle!,
                  ],
                ],
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: 16.0,),
              Padding(
                padding: EdgeInsets.only(top: trailingTopPadding ?? 15),
                child: trailing!,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
