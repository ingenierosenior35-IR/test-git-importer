import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../../core/constants/colors.dart';
import '../../data/models/wallet_card_model.dart';
import '../../data/datasources/wallet_mock_data.dart';

class AddCardScreen extends StatefulWidget {
  const AddCardScreen({Key? key}) : super(key: key);

  @override
  State<AddCardScreen> createState() => _AddCardScreenState();
}

class _AddCardScreenState extends State<AddCardScreen> {
  final _formKey = GlobalKey<FormState>();
  final _cardNumberController = TextEditingController();
  final _cardHolderController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();
  
  CardType _selectedCardType = CardType.visa;
  bool _setAsDefault = false;

  @override
  void dispose() {
    _cardNumberController.dispose();
    _cardHolderController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  void _saveCard() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Get last 4 digits
    final last4Digits = _cardNumberController.text.replaceAll(' ', '').substring(
      _cardNumberController.text.replaceAll(' ', '').length - 4
    );

    final newCard = WalletCard(
      id: 'card${DateTime.now().millisecondsSinceEpoch}',
      cardHolderName: _cardHolderController.text.trim(),
      cardNumber: last4Digits,
      expiryDate: _expiryController.text.trim(),
      cardType: _selectedCardType,
      isDefault: _setAsDefault,
      cardColor: _getCardColor(),
    );

    WalletMockData.addCard(newCard);
    
    if (_setAsDefault) {
      WalletMockData.setDefaultCard(newCard.id);
    }

    Get.back();
    Get.snackbar(
      'Éxito',
      'Tarjeta agregada correctamente',
      backgroundColor: AppColors.kGreen.withOpacity(0.8),
      colorText: AppColors.kWhite,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  String _getCardColor() {
    switch (_selectedCardType) {
      case CardType.visa:
        return '#1A1F71';
      case CardType.mastercard:
        return '#EB001B';
      case CardType.amex:
        return '#006FCF';
      case CardType.other:
        return '#2C3E50';
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
          icon: const Icon(Icons.arrow_back_ios_rounded, color: AppColors.kWhite),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Agregar Tarjeta',
          style: TextStyle(
            color: AppColors.kWhite,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Card Type Selection
                const Text(
                  'Tipo de Tarjeta',
                  style: TextStyle(
                    color: AppColors.kWhite,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  children: [
                    _buildCardTypeChip(CardType.visa, 'Visa'),
                    _buildCardTypeChip(CardType.mastercard, 'Mastercard'),
                    _buildCardTypeChip(CardType.amex, 'Amex'),
                    _buildCardTypeChip(CardType.other, 'Otra'),
                  ],
                ),
                const SizedBox(height: 24),
                
                // Card Number
                TextFormField(
                  controller: _cardNumberController,
                  style: const TextStyle(color: AppColors.kWhite),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(16),
                    _CardNumberInputFormatter(),
                  ],
                  decoration: InputDecoration(
                    labelText: 'Número de Tarjeta',
                    labelStyle: const TextStyle(color: AppColors.kGrey),
                    hintText: '0000 0000 0000 0000',
                    hintStyle: TextStyle(color: AppColors.kGrey.withOpacity(0.5)),
                    filled: true,
                    fillColor: AppColors.kDarkCard,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: const Icon(Icons.credit_card, color: AppColors.kYellowAccent),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Ingrese el número de tarjeta';
                    }
                    final digitsOnly = value.replaceAll(' ', '');
                    if (digitsOnly.length < 13) {
                      return 'Número de tarjeta inválido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // Card Holder Name
                TextFormField(
                  controller: _cardHolderController,
                  style: const TextStyle(color: AppColors.kWhite),
                  textCapitalization: TextCapitalization.characters,
                  decoration: InputDecoration(
                    labelText: 'Titular de la Tarjeta',
                    labelStyle: const TextStyle(color: AppColors.kGrey),
                    hintText: 'NOMBRE APELLIDO',
                    hintStyle: TextStyle(color: AppColors.kGrey.withOpacity(0.5)),
                    filled: true,
                    fillColor: AppColors.kDarkCard,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: const Icon(Icons.person_outline, color: AppColors.kYellowAccent),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Ingrese el nombre del titular';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // Expiry and CVV
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _expiryController,
                        style: const TextStyle(color: AppColors.kWhite),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(4),
                          _ExpiryDateInputFormatter(),
                        ],
                        decoration: InputDecoration(
                          labelText: 'Vencimiento',
                          labelStyle: const TextStyle(color: AppColors.kGrey),
                          hintText: 'MM/YY',
                          hintStyle: TextStyle(color: AppColors.kGrey.withOpacity(0.5)),
                          filled: true,
                          fillColor: AppColors.kDarkCard,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Requerido';
                          }
                          if (!value.contains('/') || value.length != 5) {
                            return 'Formato MM/YY';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _cvvController,
                        style: const TextStyle(color: AppColors.kWhite),
                        keyboardType: TextInputType.number,
                        obscureText: true,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(4),
                        ],
                        decoration: InputDecoration(
                          labelText: 'CVV',
                          labelStyle: const TextStyle(color: AppColors.kGrey),
                          hintText: '123',
                          hintStyle: TextStyle(color: AppColors.kGrey.withOpacity(0.5)),
                          filled: true,
                          fillColor: AppColors.kDarkCard,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Requerido';
                          }
                          if (value.length < 3) {
                            return 'CVV inválido';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                
                // Set as Default
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.kDarkCard,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: CheckboxListTile(
                    value: _setAsDefault,
                    onChanged: (value) {
                      setState(() {
                        _setAsDefault = value ?? false;
                      });
                    },
                    title: const Text(
                      'Establecer como predeterminada',
                      style: TextStyle(color: AppColors.kWhite),
                    ),
                    activeColor: AppColors.kYellowAccent,
                    checkColor: AppColors.kBlack,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                ),
                const SizedBox(height: 32),
                
                // Save Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _saveCard,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.kYellowAccent,
                      foregroundColor: AppColors.kBlack,
                      padding: const EdgeInsets.all(16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Guardar Tarjeta',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCardTypeChip(CardType type, String label) {
    final isSelected = _selectedCardType == type;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedCardType = type;
        });
      },
      selectedColor: AppColors.kYellowAccent,
      backgroundColor: AppColors.kDarkCard,
      labelStyle: TextStyle(
        color: isSelected ? AppColors.kBlack : AppColors.kWhite,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }
}

class _CardNumberInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll(' ', '');
    final buffer = StringBuffer();
    
    for (int i = 0; i < text.length; i++) {
      if (i > 0 && i % 4 == 0) {
        buffer.write(' ');
      }
      buffer.write(text[i]);
    }
    
    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.length),
    );
  }
}

class _ExpiryDateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll('/', '');
    final buffer = StringBuffer();
    
    for (int i = 0; i < text.length; i++) {
      if (i == 2) {
        buffer.write('/');
      }
      buffer.write(text[i]);
    }
    
    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.length),
    );
  }
}
