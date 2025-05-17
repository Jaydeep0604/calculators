import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/calculator_data.dart';
import '../models/currency_data.dart';
import '../widgets/bar_chart_widget.dart';
import '../widgets/calculator_form.dart';
import '../widgets/currency_selector.dart';
import '../widgets/result_summary_widget.dart';

class CalculatorScreen extends StatelessWidget {
  const CalculatorScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // If app icon isn't available, use a text icon instead
            Icon(
              Icons.calculate_rounded,
              color: Theme.of(context).colorScheme.primary,
              size: 28,
            ),
            const SizedBox(width: 8),
            const Text('Interest Calculator'),
          ],
        ),
        actions: [
          // Currency selector in the app bar
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: CurrencySelector(),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Responsive layout - different layouts for different screen widths
          if (constraints.maxWidth > 900) {
            // Wide layout (desktop/tablet landscape)
            return _buildWideLayout(context);
          } else {
            // Narrow layout (mobile/tablet portrait)
            return _buildNarrowLayout(context);
          }
        },
      ),
    );
  }

  Widget _buildWideLayout(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left column - Calculator Form
        Expanded(
          flex: 4,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CalculatorForm(),
              ],
            ),
          ),
        ),
        
        // Right column - Results
        Expanded(
          flex: 6,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Consumer<CalculatorData>(
                  builder: (context, calculatorData, child) {
                    if (!calculatorData.hasCalculated) {
                      return _buildEmptyResultsMessage();
                    }
                    
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        ResultSummaryWidget(),
                        SizedBox(height: 24),
                        BarChartWidget(),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNarrowLayout(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Calculator Form
          const CalculatorForm(),
          
          const SizedBox(height: 16),
          
          // Results Section
          Consumer<CalculatorData>(
            builder: (context, calculatorData, child) {
              if (!calculatorData.hasCalculated) {
                return _buildEmptyResultsMessage();
              }
              
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: const [
                  ResultSummaryWidget(),
                  SizedBox(height: 16),
                  BarChartWidget(),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyResultsMessage() {
    return Container(
      padding: const EdgeInsets.all(24),
      margin: const EdgeInsets.only(top: 16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10),
      ),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.calculate_outlined,
            size: 48,
            color: Colors.grey.shade500,
          ),
          const SizedBox(height: 16),
          const Text(
            'Fill out the form and click "Calculate"',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About Interest Calculator'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'This calculator helps you estimate the growth of your investments over time.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            const Text(
              'Features:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            _buildFeatureItem('Multiple currency support', Icons.currency_exchange),
            _buildFeatureItem('Compound interest calculation', Icons.trending_up),
            _buildFeatureItem('Monthly and yearly contributions', Icons.calendar_today),
            _buildFeatureItem('Tax and inflation adjustments', Icons.account_balance),
            _buildFeatureItem('Visual charts and schedules', Icons.bar_chart),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(String text, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.blue),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
