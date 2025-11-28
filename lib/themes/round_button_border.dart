import 'package:customer/themes/app_them_data.dart';
import 'package:customer/themes/responsive.dart';
import 'package:flutter/material.dart';

class RoundedButtonBorder extends StatelessWidget {
  final String title;
  final double? width;
  final double? height;
  final double? fontSizes;
  final Color? color;
  final Color? borderColor;
  final Color? textColor;
  final Widget? icon;
  final bool? isRight;
  final Function()? onPress;

  const RoundedButtonBorder({
    super.key,
    required this.title,
    this.height,
    required this.onPress,
    this.width,
    this.color,
    this.icon,
    this.fontSizes,
    this.textColor,
    this.isRight,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
        onPress!();
      },
      child: Container(
        width: Responsive.width(width ?? 100, context),
        height: Responsive.height(height ?? 6, context),
        decoration: ShapeDecoration(
          color: color ?? Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(200),
            side: BorderSide(color: borderColor ?? AppThemeData.primary300),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            (isRight == false) ? Padding(padding: const EdgeInsets.only(right: 10), child: icon) : const SizedBox(),
            Text(
              title.toString(),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: AppThemeData.semiBold,
                color: textColor ?? AppThemeData.grey800,
                fontSize: fontSizes ?? 14,
              ),
            ),
            (isRight == true) ? Padding(padding: const EdgeInsets.only(left: 10), child: icon) : const SizedBox(),
          ],
        ),
      ),
    );
  }
}
