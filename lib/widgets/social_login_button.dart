import 'package:flutter/material.dart';

enum SocialLoginProvider {
  google,
  facebook,
  apple,
}

class SocialLoginButton extends StatelessWidget {
  final SocialLoginProvider provider;
  final VoidCallback onPressed;
  final bool isLoading;

  const SocialLoginButton({
    Key? key,
    required this.provider,
    required this.onPressed,
    this.isLoading = false,
  }) : super(key: key);

  String get _buttonText {
    switch (provider) {
      case SocialLoginProvider.google:
        return 'Continue with Google';
      case SocialLoginProvider.facebook:
        return 'Continue with Facebook';
      case SocialLoginProvider.apple:
        return 'Continue with Apple';
    }
  }

  IconData get _icon {
    switch (provider) {
      case SocialLoginProvider.google:
        return Icons.g_mobiledata; // Using built-in icon as placeholder
      case SocialLoginProvider.facebook:
        return Icons.facebook;
      case SocialLoginProvider.apple:
        return Icons.apple;
    }
  }

  Color get _iconColor {
    switch (provider) {
      case SocialLoginProvider.google:
        return Colors.white;
      case SocialLoginProvider.facebook:
        return const Color(0xFF1877F2);
      case SocialLoginProvider.apple:
        return Colors.white;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2C2C2C), // Dark gray
          foregroundColor: Colors.white,
          disabledBackgroundColor: Colors.grey[800],
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: const Color(0xFF3C3C3C),
              width: 1,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        child: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _icon,
                    size: 24,
                    color: _iconColor,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    _buttonText,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
