import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../routes/app_routes.dart';
import '../../widgets/custom_button.dart';

class CongratulationsScreen extends StatefulWidget {
  const CongratulationsScreen({Key? key}) : super(key: key);

  @override
  State<CongratulationsScreen> createState() => _CongratulationsScreenState();
}

class _CongratulationsScreenState extends State<CongratulationsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isCreatingAvatar = true;
  String? _userPhotoUrl;
  String _userInitials = '';

  @override
  void initState() {
    super.initState();
    
    // Setup animation for check icon
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.elasticOut,
      ),
    );
    
    // Get user info
    _getUserInfo();
    
    // Show loading animation for 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isCreatingAvatar = false;
        });
        // Start success animation
        _animationController.forward();
      }
    });
    
    // Auto-redirect after 5 seconds total (2s loading + 3s success)
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        _navigateToHome();
      }
    });
  }

  void _getUserInfo() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _userPhotoUrl = user.photoURL;
      
      // Generate initials from display name or email
      if (user.displayName != null && user.displayName!.isNotEmpty) {
        final names = user.displayName!.split(' ');
        _userInitials = names.length >= 2 
            ? '${names[0][0]}${names[1][0]}'.toUpperCase()
            : names[0][0].toUpperCase();
      } else if (user.email != null && user.email!.isNotEmpty) {
        _userInitials = user.email![0].toUpperCase();
      } else {
        _userInitials = 'R'; // Default to 'R' for Rival
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _navigateToHome() {
    Get.offAllNamed(AppRoutes.mainContainerScreen);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.8),
      body: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: _isCreatingAvatar 
              ? _buildLoadingView() 
              : _buildSuccessView(),
        ),
      ),
    );
  }

  Widget _buildLoadingView() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Loading spinner
        const SizedBox(
          width: 80,
          height: 80,
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFCDFF4D)),
            strokeWidth: 4,
          ),
        ),
        
        const SizedBox(height: 32),
        
        // Loading text
        const Text(
          'Creando tu avatar...',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
        
        const SizedBox(height: 16),
        
        // Subtext
        Text(
          'Esto solo tomará un momento',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[400],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildSuccessView() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Avatar (photo or initials)
        if (_userPhotoUrl != null && _userPhotoUrl!.isNotEmpty)
          ClipRRect(
            borderRadius: BorderRadius.circular(60),
            child: Image.network(
              _userPhotoUrl!,
              width: 120,
              height: 120,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return _buildInitialsAvatar();
              },
            ),
          )
        else
          _buildInitialsAvatar(),
        
        const SizedBox(height: 24),
        
        // Animated Check Icon
        ScaleTransition(
          scale: _scaleAnimation,
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFFCDFF4D),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFCDFF4D).withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: const Icon(
              Icons.check,
              size: 48,
              color: Colors.black,
            ),
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Title
        const Text(
          '¡Felicitaciones!',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
        
        const SizedBox(height: 16),
        
        // Message
        Text(
          'Tu avatar ha sido creado.\nSerás llevado a la página principal en breve.',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[400],
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
        
        const SizedBox(height: 32),
        
        // Back to Home Button
        CustomButton(
          text: 'Volver al inicio',
          onPressed: _navigateToHome,
          height: 54,
        ),
      ],
    );
  }

  Widget _buildInitialsAvatar() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: const Color(0xFFCDFF4D),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFCDFF4D).withOpacity(0.3),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Center(
        child: Text(
          _userInitials,
          style: const TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}
