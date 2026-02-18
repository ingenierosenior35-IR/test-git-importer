import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/colors.dart';
import '../../data/models/wallet_card_model.dart';
import '../../data/datasources/wallet_mock_data.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({Key? key}) : super(key: key);

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  List<WalletCard> cards = [];
  double balance = 0.0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() {
      cards = WalletMockData.getAllCards();
      balance = WalletMockData.getCurrentBalance();
    });
  }

  void _setDefaultCard(String cardId) {
    setState(() {
      WalletMockData.setDefaultCard(cardId);
      cards = WalletMockData.getAllCards();
    });
    Get.snackbar(
      'Éxito',
      'Tarjeta configurada como predeterminada',
      backgroundColor: AppColors.kGreen.withOpacity(0.8),
      colorText: AppColors.kWhite,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void _addNewCard() {
    Get.toNamed('/add_card_screen')?.then((_) => _loadData());
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
          'Billetera',
          style: TextStyle(
            color: AppColors.kWhite,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: AppColors.kYellowAccent),
            onPressed: _addNewCard,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Balance Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.kYellowAccent.withOpacity(0.8),
                      AppColors.kYellowAccent,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Saldo disponible',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.kBlack.withOpacity(0.7),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '\$${balance.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 36,
                        color: AppColors.kBlack,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              // Cards Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Mis Tarjetas',
                    style: TextStyle(
                      color: AppColors.kWhite,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: _addNewCard,
                    icon: const Icon(Icons.add, color: AppColors.kYellowAccent, size: 20),
                    label: const Text(
                      'Agregar',
                      style: TextStyle(color: AppColors.kYellowAccent),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (cards.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(40.0),
                    child: Column(
                      children: [
                        Icon(
                          Icons.credit_card_off,
                          size: 64,
                          color: AppColors.kGrey.withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No tienes tarjetas agregadas',
                          style: TextStyle(
                            color: AppColors.kGrey,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ...cards.map((card) => _buildCardItem(card)).toList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardItem(WalletCard card) {
    final cardColor = card.cardColor != null
        ? Color(int.parse(card.cardColor!.replaceAll('#', '0xFF')))
        : AppColors.kDarkCard;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            cardColor,
            cardColor.withOpacity(0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.kBlack.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                card.cardTypeString,
                style: const TextStyle(
                  color: AppColors.kWhite,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (card.isDefault)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.kYellowAccent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'PREDETERMINADA',
                    style: TextStyle(
                      color: AppColors.kBlack,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            card.maskedCardNumber,
            style: const TextStyle(
              color: AppColors.kWhite,
              fontSize: 18,
              fontWeight: FontWeight.w600,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'TITULAR',
                    style: TextStyle(
                      color: AppColors.kWhite.withOpacity(0.7),
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    card.cardHolderName,
                    style: const TextStyle(
                      color: AppColors.kWhite,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'VENCE',
                    style: TextStyle(
                      color: AppColors.kWhite.withOpacity(0.7),
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    card.expiryDate,
                    style: const TextStyle(
                      color: AppColors.kWhite,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              if (!card.isDefault)
                IconButton(
                  icon: const Icon(Icons.check_circle_outline, color: AppColors.kWhite),
                  onPressed: () => _setDefaultCard(card.id),
                  tooltip: 'Establecer como predeterminada',
                ),
            ],
          ),
        ],
      ),
    );
  }
}
