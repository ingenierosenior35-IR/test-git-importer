import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../../shared/widgets/custom_button.dart';
import '/../services/onboarding_service.dart';
import 'congratulations_screen.dart';

class PhotoUploadScreen extends StatefulWidget {
  final List<String> selectedSports;
  final String selectedGender;
  final Map<String, dynamic> height;
  final Map<String, dynamic> weight;

  const PhotoUploadScreen({
    Key? key,
    required this.selectedSports,
    required this.selectedGender,
    required this.height,
    required this.weight,
  }) : super(key: key);

  @override
  State<PhotoUploadScreen> createState() => _PhotoUploadScreenState();
}

class _PhotoUploadScreenState extends State<PhotoUploadScreen> {
  final OnboardingService _onboardingService = OnboardingService();
  final ImagePicker _picker = ImagePicker();
  File? _photo;
  bool _isLoading = false;

  Future<void> _checkAndRequestPermission(ImageSource source) async {
    Permission permission =
        source == ImageSource.camera ? Permission.camera : Permission.photos;

    PermissionStatus status = await permission.status;

    if (status.isDenied) {
      status = await permission.request();
    }

    if (status.isGranted) {
      _pickImage(source);
    } else if (status.isPermanentlyDenied) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Por favor habilita el permiso de ${source == ImageSource.camera ? 'cámara' : 'fotos'} en configuración'),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 3),
          ),
        );
      }
      await openAppSettings();
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No se puede acceder a ${source == ImageSource.camera ? 'cámara' : 'galería'}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _photo = File(image.path);
        });
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al seleccionar imagen: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _removePhoto() {
    setState(() {
      _photo = null;
    });
  }

  void _showImageSourceDialog() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Color(0xFF1E1E1E),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Agregar foto',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Color(0xFFCDFF4D)),
              title: const Text('Tomar foto', style: TextStyle(color: Colors.white)),
              onTap: () async {
                Get.back();
                // Add delay to allow bottom sheet to close before opening camera
                await Future.delayed(const Duration(milliseconds: 300));
                _checkAndRequestPermission(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Color(0xFFCDFF4D)),
              title: const Text('Elegir de galería', style: TextStyle(color: Colors.white)),
              onTap: () async {
                Get.back();
                // Add delay to allow bottom sheet to close before opening gallery
                await Future.delayed(const Duration(milliseconds: 300));
                _checkAndRequestPermission(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _finish() async {
    setState(() {
      _isLoading = true;
    });

    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception('No user logged in');
      }

      // Upload photo if any
      List<String> photoUrls = [];
      if (_photo != null) {
        photoUrls = await _onboardingService.uploadPhotos(
          uid: currentUser.uid,
          photos: [_photo!],
        );
      }

      // Save all onboarding data
      await _onboardingService.saveOnboardingData(
        uid: currentUser.uid,
        sports: widget.selectedSports,
        gender: widget.selectedGender,
        height: widget.height,
        weight: widget.weight,
        photoUrls: photoUrls,
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }

      // Navigate to congratulations screen
      Get.off(() => const CongratulationsScreen());
    } catch (e) {
      debugPrint('Error completing onboarding: $e');

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al completar configuración del perfil: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _skip() async {
    _finish(); // Just finish without photo
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Title
                      const Text(
                        'Hazlo más real',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 12),

                      // Subtitle
                      Text(
                        'Si subes una foto, tu avatar se parecerá más a ti.',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[400],
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 48),

                      // Photo preview area
                      Semantics(
                        label: _photo == null 
                            ? 'Agregar foto de perfil. Toca para subir.' 
                            : 'Foto de perfil subida. Toca para cambiar.',
                        button: true,
                        child: GestureDetector(
                          onTap: _photo == null ? _showImageSourceDialog : null,
                          child: Container(
                            width: 200,
                            height: 200,
                            decoration: BoxDecoration(
                              color: const Color(0xFF2C2C2C),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: const Color(0xFF3C3C3C),
                                width: 2,
                              ),
                            ),
                            child: _photo == null
                                ? Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.add_a_photo_outlined,
                                        size: 64,
                                        color: Color(0xFFCDFF4D),
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        'Agregar foto',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  )
                                : Stack(
                                    children: [
                                      // Image
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(16),
                                        child: Image.file(
                                          _photo!,
                                          width: double.infinity,
                                          height: double.infinity,
                                          fit: BoxFit.cover,
                                        ),
                                      ),

                                      // Remove button
                                      Positioned(
                                        top: 8,
                                        right: 8,
                                        child: Semantics(
                                          label: 'Eliminar foto',
                                          button: true,
                                          child: GestureDetector(
                                            onTap: _removePhoto,
                                            child: Container(
                                              padding: const EdgeInsets.all(6),
                                              decoration: BoxDecoration(
                                                // ignore: deprecated_member_use
                                                color: Colors.black.withOpacity(0.6),
                                                shape: BoxShape.circle,
                                              ),
                                              child: const Icon(
                                                Icons.close,
                                                size: 20,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Microcopy
                      Text(
                        'Tu avatar, tu estilo.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Action buttons
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  // Upload/Finish button
                  CustomButton(
                    text: _photo == null ? 'Subir foto' : 'Continuar',
                    onPressed: _photo == null ? _showImageSourceDialog : _finish,
                    isLoading: _isLoading,
                    height: 54,
                  ),

                  const SizedBox(height: 12),

                  // Skip button
                  TextButton(
                    onPressed: _isLoading ? null : _skip,
                    child: Text(
                      'Omitir',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
