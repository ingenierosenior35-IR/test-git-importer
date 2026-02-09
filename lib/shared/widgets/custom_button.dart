import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isDisabled;
  final bool isLoading;
  final Color? backgroundColor;
  final Color? textColor;
  final double? height;
  final double? width;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;
  final bool isOutlined;

  const CustomButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.isDisabled = false,
    this.isLoading = false,
    this.backgroundColor,
    this.textColor,
    this.height,
    this.width,
    this.margin,
    this.padding,
    this.borderRadius = 12.0,
    this.isOutlined = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final defaultBackgroundColor = isOutlined 
        ? Colors.transparent 
        : const Color(0xFFCDFF4D); // Yellow/Lime
    final defaultTextColor = isOutlined 
        ? const Color(0xFFCDFF4D) 
        : Colors.black;

    return Container(
      height: height ?? 56.0,
      width: width ?? double.infinity,
      margin: margin,
      child: ElevatedButton(
        onPressed: (isDisabled || isLoading) ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? defaultBackgroundColor,
          foregroundColor: textColor ?? defaultTextColor,
          disabledBackgroundColor: Colors.grey[800],
          disabledForegroundColor: Colors.grey[600],
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            side: isOutlined 
                ? BorderSide(color: backgroundColor ?? const Color(0xFFCDFF4D), width: 2)
                : BorderSide.none,
          ),
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        ),
        child: isLoading
            ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    textColor ?? defaultTextColor,
                  ),
                ),
              )
            : Text(
                text,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: textColor ?? defaultTextColor,
                ),
              ),
      ),
    );
  }
}
