import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:Rival/core/app_export.dart';
import 'package:Rival/core/constants/colors.dart';
import '../../data/repositories/polls_firebase_repository.dart';

class JoinPollScreen extends StatefulWidget {
  const JoinPollScreen({Key? key}) : super(key: key);

  @override
  State<JoinPollScreen> createState() => _JoinPollScreenState();
}

class _JoinPollScreenState extends State<JoinPollScreen> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  final _repository = PollsFirebaseRepository();
  bool _joining = false;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _joinPoll() async {
    if (!_formKey.currentState!.validate()) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      Get.snackbar(
        'Inicia sesión',
        'Debes estar autenticado para unirte a una polla.',
        backgroundColor: AppColors.kDarkCard,
        colorText: AppColors.kWhite,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
      return;
    }

    setState(() => _joining = true);
    try {
      final poll = await _repository.getPollByJoinCode(_codeController.text.trim());
      if (poll == null) {
        if (!mounted) return;
        Get.snackbar(
          'Código inválido',
          'No se encontró ninguna polla con ese código.',
          backgroundColor: AppColors.kError,
          colorText: AppColors.kWhite,
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
        );
        return;
      }

      await _repository.joinPoll(pollId: poll.id, userId: user.uid);

      if (!mounted) return;
      Get.snackbar(
        '¡Te uniste!',
        'Ahora eres parte de "${poll.name}"',
        backgroundColor: AppColors.kYellowAccent.withOpacity(0.95),
        colorText: AppColors.kBlack,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      Get.snackbar(
        'Error',
        'No se pudo unir a la polla. Inténtalo de nuevo.',
        backgroundColor: AppColors.kError,
        colorText: AppColors.kWhite,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
    } finally {
      if (mounted) setState(() => _joining = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.kDarkBackground,
      appBar: AppBar(
        backgroundColor: AppColors.kDarkCard,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.kWhite),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'UNIRSE A POLLA',
          style: TextStyle(
            color: AppColors.kWhite,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Icon
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.kDarkCard,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.qr_code_scanner,
                  color: AppColors.kYellowAccent,
                  size: 64,
                ),
              ),
              const SizedBox(height: 32),
              
              // Info text
              Text(
                'Ingresa el código de invitación',
                style: TextStyle(
                  color: AppColors.kWhite,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Pídele el código al creador de la polla',
                style: TextStyle(
                  color: AppColors.kGreyLight,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              
              // Code input
              TextFormField(
                controller: _codeController,
                style: TextStyle(
                  color: AppColors.kWhite,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 4,
                ),
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  hintText: 'XXXXXX',
                  hintStyle: TextStyle(
                    color: AppColors.kGrey,
                    fontSize: 24,
                    letterSpacing: 4,
                  ),
                  filled: true,
                  fillColor: AppColors.kDarkCard,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: AppColors.kDarkSurface,
                      width: 2,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: AppColors.kYellowAccent,
                      width: 2,
                    ),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa el código';
                  }
                  if (value.length < 6) {
                    return 'El código debe tener al menos 6 caracteres';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              
              // Join button
              ElevatedButton(
                onPressed: _joining ? null : _joinPoll,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.kYellowAccent,
                  disabledBackgroundColor: AppColors.kDarkSurface,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _joining
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.kBlack,
                        ),
                      )
                    : Text(
                        'UNIRSE',
                        style: TextStyle(
                          color: AppColors.kBlack,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
              ),
              const SizedBox(height: 16),
              
              // Or text
              Row(
                children: [
                  Expanded(child: Divider(color: AppColors.kGrey)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'O',
                      style: TextStyle(
                        color: AppColors.kGrey,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  Expanded(child: Divider(color: AppColors.kGrey)),
                ],
              ),
              const SizedBox(height: 16),
              
              // QR scan button
              OutlinedButton.icon(
                onPressed: () {
                  // TODO: Implement QR code scanning
                  Get.snackbar(
                    'Próximamente',
                    'Función de escaneo QR en desarrollo',
                    backgroundColor: AppColors.kDarkCard,
                    colorText: AppColors.kWhite,
                    snackPosition: SnackPosition.BOTTOM,
                    margin: const EdgeInsets.all(16),
                  );
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(color: AppColors.kYellowAccent, width: 2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: Icon(
                  Icons.qr_code_scanner,
                  color: AppColors.kYellowAccent,
                ),
                label: Text(
                  'ESCANEAR CÓDIGO QR',
                  style: TextStyle(
                    color: AppColors.kYellowAccent,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
