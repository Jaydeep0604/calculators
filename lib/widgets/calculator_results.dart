import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../models/calculator_data.dart';
import '../models/currency_data.dart';
import 'pie_chart_widget.dart';
import 'schedule_table.dart';

class CalculatorResults extends StatelessWidget {
  const CalculatorResults({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final calculatorData = Provider.of<CalculatorData>(context);
    final currencyData = Provider.of<CurrencyData>(context);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader("Results Summary", context)
              .animate().fadeIn(delay: 100.ms, duration: 500.ms)
              .shimmer(delay: 500.ms, duration: 1000.ms),
            
            const SizedBox(height: 24),
            _buildResultItem(
              label: "Ending balance",
              value: currencyData.formatAmount(calculatorData.endingBalance),
              isTotal: true,
              delay: 100,
              context: context,
            ),
            
            const Divider(height: 32),
            _buildResultItem(
              label: "Total principal",
              value: currencyData.formatAmount(calculatorData.totalPrincipal),
              delay: 200,
              context: context,
            ),
            
            _buildResultItem(
              label: "Total contributions",
              value: currencyData.formatAmount(calculatorData.totalContributions),
              delay: 300,
              context: context,
            ),
            
            _buildResultItem(
              label: "Total interest",
              value: currencyData.formatAmount(calculatorData.totalInterest),
              delay: 400,
              context: context,
              valueColor: Colors.green,
            ),
            
            const Divider(height: 32),
            _buildResultItem(
              label: "Interest on initial investment",
              value: currencyData.formatAmount(calculatorData.initialInvestmentInterest),
              delay: 500,
              context: context,
              valueColor: Colors.green,
            ),
            
            _buildResultItem(
              label: "Interest on contributions",
              value: currencyData.formatAmount(calculatorData.contributionsInterest),
              delay: 600,
              context: context,
              valueColor: Colors.green,
            ),
            
            if (calculatorData.inflationRate > 0) ...[
              const Divider(height: 32),
              _buildResultItem(
                label: "Inflation-adjusted ending balance",
                value: currencyData.formatAmount(calculatorData.inflationAdjustedBalance),
                delay: 700,
                context: context,
                valueColor: calculatorData.inflationAdjustedBalance < calculatorData.endingBalance 
                    ? Colors.red 
                    : Colors.green,
                tooltip: 'Real buying power after inflation',
              ),
            ],
            
            if (calculatorData.taxRate > 0) ...[
              _buildResultItem(
                label: "After-tax interest",
                value: currencyData.formatAmount(
                  calculatorData.totalInterest * (1 - calculatorData.taxRate / 100)),
                delay: 750,
                context: context,
                valueColor: Colors.orange,
                tooltip: 'Interest earned after tax has been deducted',
              ),
            ],
            
            const SizedBox(height: 32),
            PieChartWidget()
              .animate().fadeIn(delay: 800.ms, duration: 500.ms),
            
            const SizedBox(height: 32),
            _buildHeader("Growth Schedule", context)
              .animate().fadeIn(delay: 900.ms, duration: 500.ms),
            
            const SizedBox(height: 16),
            ScheduleTable()
              .animate().fadeIn(delay: 1000.ms, duration: 500.ms),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(String text, BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const Icon(
            Icons.insert_chart,
            color: Colors.white,
          ),
        ],
      ),
    );
  }

  Widget _buildResultItem({
    required String label,
    required String value,
    bool isTotal = false,
    required int delay,
    required BuildContext context,
    Color? valueColor,
    String? tooltip,
  }) {
    final textWidget = Text(
      value,
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: isTotal ? 22 : 16,
        color: valueColor ?? (isTotal 
            ? Theme.of(context).primaryColor 
            : Theme.of(context).textTheme.bodyLarge?.color),
      ),
    );
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
                    fontSize: isTotal ? 16 : 14,
                  ),
                ),
                if (tooltip != null) ...[
                  const SizedBox(width: 4),
                  Tooltip(
                    message: tooltip,
                    child: const Icon(Icons.info_outline, size: 16),
                  ),
                ],
              ],
            ),
          ),
          tooltip != null
              ? Tooltip(message: tooltip, child: textWidget)
              : textWidget,
        ],
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: delay), duration: 500.ms);
  }
}
