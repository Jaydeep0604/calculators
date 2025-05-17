import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/calculator_data.dart';
import '../models/currency_data.dart';

class ResultSummaryWidget extends StatelessWidget {
  const ResultSummaryWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final calculatorData = Provider.of<CalculatorData>(context);
    final currencyData = Provider.of<CurrencyData>(context);
    
    if (!calculatorData.hasCalculated) {
      return const SizedBox.shrink();
    }
    
    final lastEntry = calculatorData.yearlySchedule.last;
    
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
            Row(
              children: [
                Icon(
                  Icons.insights,
                  size: 20,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 8),
                Text(
                  'Investment Summary',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildSummaryItem(
                    context,
                    title: 'Total Value',
                    value: currencyData.formatAmount(lastEntry.endingBalance),
                    color: Theme.of(context).primaryColor,
                    icon: Icons.account_balance,
                  ),
                ),
                Expanded(
                  child: _buildSummaryItem(
                    context,
                    title: 'Initial Investment',
                    value: currencyData.formatAmount(calculatorData.initialInvestment),
                    color: Colors.blue,
                    icon: Icons.arrow_downward,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildSummaryItem(
                    context,
                    title: 'Total Contributions',
                    value: currencyData.formatAmount(calculatorData.getTotalContributions()),
                    color: Colors.green,
                    icon: Icons.add_circle_outline,
                  ),
                ),
                Expanded(
                  child: _buildSummaryItem(
                    context,
                    title: 'Total Interest',
                    value: currencyData.formatAmount(calculatorData.getTotalInterest()),
                    color: Colors.deepPurple,
                    icon: Icons.trending_up,
                  ),
                ),
              ],
            ),
            if (calculatorData.taxRate > 0) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildSummaryItem(
                      context,
                      title: 'Tax Paid (${calculatorData.taxRate}%)',
                      value: currencyData.formatAmount(calculatorData.getTaxPaid()),
                      color: Colors.red,
                      icon: Icons.receipt_long,
                    ),
                  ),
                  Expanded(
                    child: _buildSummaryItem(
                      context,
                      title: 'After-Tax Value',
                      value: currencyData.formatAmount(lastEntry.endingBalance - calculatorData.getTaxPaid()),
                      color: Colors.teal,
                      icon: Icons.account_balance_wallet,
                    ),
                  ),
                ],
              ),
            ],
            if (calculatorData.inflationRate > 0) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildSummaryItem(
                      context,
                      title: 'Inflation (${calculatorData.inflationRate}%)',
                      value: currencyData.formatAmount(calculatorData.getInflationAdjustment()),
                      color: Colors.amber.shade800,
                      icon: Icons.trending_down,
                    ),
                  ),
                  Expanded(
                    child: _buildSummaryItem(
                      context,
                      title: 'Inflation-Adjusted Value',
                      value: currencyData.formatAmount(
                        lastEntry.endingBalance - calculatorData.getInflationAdjustment()
                      ),
                      color: Colors.indigo,
                      icon: Icons.attach_money,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(
    BuildContext context, {
    required String title,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  size: 18,
                  color: color,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
