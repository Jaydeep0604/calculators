import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../models/calculator_data.dart';
import '../models/currency_data.dart';

class NumberInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) {
      return newValue;
    }
    
    if (newValue.text == '.') {
      return const TextEditingValue(
        text: '0.',
        selection: TextSelection.collapsed(offset: 2),
      );
    }
    
    // Allow numbers and one decimal point
    final RegExp regex = RegExp(r'^\d*\.?\d*$');
    if (!regex.hasMatch(newValue.text)) {
      return oldValue;
    }
    
    return newValue;
  }
}

class CalculatorForm extends StatefulWidget {
  const CalculatorForm({Key? key}) : super(key: key);

  @override
  State<CalculatorForm> createState() => _CalculatorFormState();
}

class _CalculatorFormState extends State<CalculatorForm> {
  final _initialInvestmentController = TextEditingController();
  final _monthlyContributionController = TextEditingController();
  final _interestRateController = TextEditingController();
  final _yearsController = TextEditingController();
  final _taxRateController = TextEditingController();
  final _inflationRateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize controllers with the default values
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final calculatorData = Provider.of<CalculatorData>(context, listen: false);
      _initialInvestmentController.text = calculatorData.initialInvestment.toString();
      _monthlyContributionController.text = calculatorData.monthlyContribution.toString();
      _interestRateController.text = calculatorData.interestRate.toString();
      _yearsController.text = calculatorData.yearsLength.toString();
      _taxRateController.text = calculatorData.taxRate.toString();
      _inflationRateController.text = calculatorData.inflationRate.toString();
    });
  }

  @override
  void dispose() {
    _initialInvestmentController.dispose();
    _monthlyContributionController.dispose();
    _interestRateController.dispose();
    _yearsController.dispose();
    _taxRateController.dispose();
    _inflationRateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final calculatorData = Provider.of<CalculatorData>(context, listen: false);
    final currencyData = Provider.of<CurrencyData>(context);
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Main inputs section
            Row(
              children: [
                Expanded(
                  child: _buildInputField(
                    label: 'Initial investment',
                    controller: _initialInvestmentController,
                    onChanged: (value) {
                      if (value.isNotEmpty) {
                        calculatorData.initialInvestment = double.parse(value);
                      }
                    },
                    prefixIcon: Text(
                      currencyData.selectedCurrency.symbol,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildInputField(
                    label: 'Monthly contribution',
                    controller: _monthlyContributionController,
                    onChanged: (value) {
                      if (value.isNotEmpty) {
                        calculatorData.monthlyContribution = double.parse(value);
                        // Calculate annual contribution based on monthly
                        calculatorData.annualContribution = double.parse(value) * 12;
                      }
                    },
                    prefixIcon: Text(
                      currencyData.selectedCurrency.symbol,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildInputField(
                    label: 'Interest rate (%)',
                    controller: _interestRateController,
                    onChanged: (value) {
                      if (value.isNotEmpty) {
                        calculatorData.interestRate = double.parse(value);
                      }
                    },
                    suffixText: '%',
                    color: Theme.of(context).colorScheme.tertiary.withOpacity(0.1),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildInputField(
                    label: 'Investment years',
                    controller: _yearsController,
                    onChanged: (value) {
                      if (value.isNotEmpty) {
                        calculatorData.yearsLength = int.parse(value);
                        calculatorData.monthsLength = int.parse(value) * 12;
                      }
                    },
                    suffixText: 'yrs',
                  ),
                ),
              ],
            ),
            
            // Advanced options - collapsible
            ExpansionTile(
              title: Row(
                children: [
                  Icon(
                    Icons.tune,
                    color: Theme.of(context).primaryColor,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Advanced Options',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              tilePadding: const EdgeInsets.symmetric(horizontal: 8),
              childrenPadding: EdgeInsets.zero,
              initiallyExpanded: false,
              children: [
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildInputField(
                        label: 'Tax rate (%)',
                        controller: _taxRateController,
                        onChanged: (value) {
                          if (value.isNotEmpty) {
                            calculatorData.taxRate = double.parse(value);
                          }
                        },
                        suffixText: '%',
                        color: Colors.red.shade50,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildInputField(
                        label: 'Inflation rate (%)',
                        controller: _inflationRateController,
                        onChanged: (value) {
                          if (value.isNotEmpty) {
                            calculatorData.inflationRate = double.parse(value);
                          }
                        },
                        suffixText: '%',
                        color: Colors.green.shade50,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
                _buildCompoundPeriodSelector(calculatorData),
              ],
            ),
            
            const SizedBox(height: 16),
            _buildCalculateButton(calculatorData),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required Function(String) onChanged,
    String? helperText,
    Widget? prefixIcon,
    String? suffixText,
    Color? color,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color ?? Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              if (prefixIcon != null)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: prefixIcon,
                ),
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [NumberInputFormatter()],
                  onChanged: onChanged,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    isDense: true,
                    filled: true,
                    fillColor: Colors.white,
                    suffixText: suffixText,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 1.5),
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (helperText != null) ...[
            const SizedBox(height: 4),
            Text(
              helperText,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCompoundPeriodSelector(CalculatorData calculatorData) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Compound frequency',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 8),
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: calculatorData.compoundPeriod.displayName,
              icon: const Icon(Icons.arrow_drop_down),
              items: ['Annually', 'Semi-annually', 'Quarterly', 'Monthly', 'Daily']
                  .map((String item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(item),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    calculatorData.setCompoundPeriodFromString(newValue);
                  });
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalculateButton(CalculatorData calculatorData) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          // Ensures keyboard is dismissed
          FocusScope.of(context).unfocus();
          calculatorData.calculate();
        },
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: const Text(
          'Calculate',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
