enum CardType {
  visa,
  mastercard,
  amex,
  other,
}

class WalletCard {
  final String id;
  final String cardHolderName;
  final String cardNumber; // Last 4 digits only for display
  final String expiryDate; // Format: MM/YY
  final CardType cardType;
  final bool isDefault;
  final String? cardColor; // Hex color for card background

  WalletCard({
    required this.id,
    required this.cardHolderName,
    required this.cardNumber,
    required this.expiryDate,
    required this.cardType,
    this.isDefault = false,
    this.cardColor,
  });

  String get maskedCardNumber => '**** **** **** $cardNumber';

  String get cardTypeString {
    switch (cardType) {
      case CardType.visa:
        return 'Visa';
      case CardType.mastercard:
        return 'Mastercard';
      case CardType.amex:
        return 'American Express';
      case CardType.other:
        return 'Other';
    }
  }

  WalletCard copyWith({
    String? id,
    String? cardHolderName,
    String? cardNumber,
    String? expiryDate,
    CardType? cardType,
    bool? isDefault,
    String? cardColor,
  }) {
    return WalletCard(
      id: id ?? this.id,
      cardHolderName: cardHolderName ?? this.cardHolderName,
      cardNumber: cardNumber ?? this.cardNumber,
      expiryDate: expiryDate ?? this.expiryDate,
      cardType: cardType ?? this.cardType,
      isDefault: isDefault ?? this.isDefault,
      cardColor: cardColor ?? this.cardColor,
    );
  }
}
