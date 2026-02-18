import '../models/wallet_card_model.dart';

class WalletMockData {
  static final List<WalletCard> _cards = [];

  static void initialize() {
    if (_cards.isEmpty) {
      _initializeCards();
    }
  }

  static void _initializeCards() {
    _cards.addAll([
      WalletCard(
        id: 'card1',
        cardHolderName: 'Carlos García',
        cardNumber: '4532',
        expiryDate: '12/25',
        cardType: CardType.visa,
        isDefault: true,
        cardColor: '#1A1F71',
      ),
      WalletCard(
        id: 'card2',
        cardHolderName: 'Carlos García',
        cardNumber: '5412',
        expiryDate: '08/26',
        cardType: CardType.mastercard,
        isDefault: false,
        cardColor: '#EB001B',
      ),
    ]);
  }

  static List<WalletCard> getAllCards() {
    initialize();
    return List.unmodifiable(_cards);
  }

  static WalletCard? getCardById(String id) {
    initialize();
    try {
      return _cards.firstWhere((card) => card.id == id);
    } catch (e) {
      return null;
    }
  }

  static WalletCard? getDefaultCard() {
    initialize();
    try {
      return _cards.firstWhere((card) => card.isDefault);
    } catch (e) {
      return _cards.isNotEmpty ? _cards.first : null;
    }
  }

  static void addCard(WalletCard card) {
    initialize();
    _cards.add(card);
  }

  static void updateCard(WalletCard card) {
    initialize();
    final index = _cards.indexWhere((c) => c.id == card.id);
    if (index != -1) {
      _cards[index] = card;
    }
  }

  static void deleteCard(String id) {
    initialize();
    _cards.removeWhere((card) => card.id == id);
  }

  static void setDefaultCard(String id) {
    initialize();
    for (int i = 0; i < _cards.length; i++) {
      _cards[i] = _cards[i].copyWith(isDefault: _cards[i].id == id);
    }
  }

  static double getCurrentBalance() {
    // Mock balance
    return 1250.50;
  }
}
