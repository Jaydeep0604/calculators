import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/currency_data.dart';

class CurrencySelector extends StatelessWidget {
  const CurrencySelector({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currencyData = Provider.of<CurrencyData>(context);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 0),
      constraints: const BoxConstraints(maxWidth: 200),
      child: DropdownButtonHideUnderline(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 2,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: DropdownButton<String>(
            value: currencyData.selectedCurrency.code,
            isDense: true,
            isExpanded: false,
            icon: const Icon(Icons.arrow_drop_down, size: 24),
            items: currencyData.availableCurrencies.map((Currency currency) {
              return DropdownMenuItem<String>(
                value: currency.code,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      currency.flag,
                      style: const TextStyle(fontSize: 18),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      currency.code,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
            onChanged: (String? newValue) {
              if (newValue != null) {
                final selectedCurrency = currencyData.availableCurrencies
                    .firstWhere((currency) => currency.code == newValue);
                currencyData.selectedCurrency = selectedCurrency;
              }
            },
          ),
        ),
      ),
    );
  }
}
