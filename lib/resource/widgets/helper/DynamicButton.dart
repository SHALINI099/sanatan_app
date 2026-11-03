import 'package:flutter/material.dart';

import '../../values/BharatDimension.dart';


class DynamicButton extends StatelessWidget {
  final double? width;
  final double height;
  final Color? backgroundColor;
  final Color? color;
  final IconData? leadingIcon;
  final Color? iconColor;
  final bool? showLeading;
  final String? text;
  final double? size;
  final void Function()? onTap;
  final paddingOnly;
  final double? fontSize;
  final FontWeight;
  final bool? radius;

  /// Swaps the label for a spinner and blocks taps while work is in flight.
  final bool isLoading;

  const DynamicButton({
    super.key,
    this.width,
    this.backgroundColor,
    this.leadingIcon,
    required this.text,
    this.showLeading,
    this.iconColor,
    this.onTap,
    required this.height,
    this.size,
    this.paddingOnly,
    this.fontSize, this.FontWeight, this.color, this.radius,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: width,

      child: ElevatedButton(
        onPressed: isLoading ? null : onTap,
        style: ElevatedButton.styleFrom(
            backgroundColor: backgroundColor,
            // Keep the button looking live while it spins — a greyed-out button reads
            // as "broken", not "working".
            disabledBackgroundColor: isLoading ? backgroundColor : null,

              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(radius == true ? 35 : 8)),),
        child: Center(
          child: isLoading
              ? SizedBox(
                  height: 22,
                  width: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(
                        color ?? Colors.white),
                  ),
                )
              : (showLeading ?? false)
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      leadingIcon,
                      color: iconColor,
                      size: size,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      text ?? " ",
                      style:   BharatDimension.fontFamily(
                          color: color,
                          fontSize: fontSize ?? 16,fontWeight: FontWeight
                      ),
                    )
                  ],
                )
              : Text(
                  text ?? " ",
                  style: BharatDimension.fontFamily(

                      color: color,
                      fontSize: fontSize ?? 16),
                ),
        ),
      ),
    );
  }
}
