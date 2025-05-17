import 'package:flutter/foundation.dart';

class Currency {
  final String code;
  final String name;
  final String symbol;
  final String flag;

  Currency({
    required this.code,
    required this.name,
    required this.symbol,
    required this.flag,
  });
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Currency && other.code == code;
  }

  @override
  int get hashCode => code.hashCode;
}

class CurrencyData with ChangeNotifier {
  final List<Currency> _availableCurrencies = [
    Currency(code: 'USD', name: 'US Dollar', symbol: '\$', flag: '🇺🇸'),
    Currency(code: 'EUR', name: 'Euro', symbol: '€', flag: '🇪🇺'),
    Currency(code: 'GBP', name: 'British Pound', symbol: '£', flag: '🇬🇧'),
    Currency(code: 'JPY', name: 'Japanese Yen', symbol: '¥', flag: '🇯🇵'),
    Currency(code: 'INR', name: 'Indian Rupee', symbol: '₹', flag: '🇮🇳'),
    Currency(code: 'CNY', name: 'Chinese Yuan', symbol: '¥', flag: '🇨🇳'),
    Currency(code: 'CAD', name: 'Canadian Dollar', symbol: 'C\$', flag: '🇨🇦'),
    Currency(code: 'AUD', name: 'Australian Dollar', symbol: 'A\$', flag: '🇦🇺'),
    Currency(code: 'CHF', name: 'Swiss Franc', symbol: 'CHF', flag: '🇨🇭'),
    Currency(code: 'SGD', name: 'Singapore Dollar', symbol: 'S\$', flag: '🇸🇬'),
  ];

  Currency _selectedCurrency = Currency(code: 'USD', name: 'US Dollar', symbol: '\$', flag: '🇺🇸');

  List<Currency> get availableCurrencies => _availableCurrencies;
  Currency get selectedCurrency => _selectedCurrency;

  set selectedCurrency(Currency currency) {
    _selectedCurrency = currency;
    notifyListeners();
  }

  // Get the formatted currency string
  String formatAmount(double amount, {int decimalPlaces = 2}) {
    if (amount >= 1000000) {
      return '${_selectedCurrency.symbol}${(amount / 1000000).toStringAsFixed(decimalPlaces)}M';
    } else if (amount >= 1000) {
      return '${_selectedCurrency.symbol}${(amount / 1000).toStringAsFixed(decimalPlaces)}K';
    } else {
      return '${_selectedCurrency.symbol}${amount.toStringAsFixed(decimalPlaces)}';
    }
  }
}
