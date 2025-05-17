import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/calculator_data.dart';
import '../models/currency_data.dart';

class PieChartWidget extends StatelessWidget {
  final double chartRadius = 130;

  PieChartWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final calculatorData = Provider.of<CalculatorData>(context);
    final currencyData = Provider.of<CurrencyData>(context);
    
    // Calculate percentages for the chart
    final totalValue = calculatorData.totalPrincipal + 
                       calculatorData.totalContributions + 
                       calculatorData.totalInterest;
    
    final initialInvestmentPercentage = totalValue > 0 
        ? (calculatorData.totalPrincipal / totalValue * 100).toDouble() 
        : 0.0;
    
    final contributionsPercentage = totalValue > 0 
        ? (calculatorData.totalContributions / totalValue * 100).toDouble() 
        : 0.0;
    
    final interestPercentage = totalValue > 0 
        ? (calculatorData.totalInterest / totalValue * 100).toDouble() 
        : 0.0;
    
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWideLayout = constraints.maxWidth > 600;
        
        return Card(
          child: Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Row(
                    children: [
                      Icon(
                        Icons.pie_chart,
                        color: Theme.of(context).primaryColor,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Investment Breakdown',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
                isWideLayout 
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: chartRadius * 2,
                          width: chartRadius * 2,
                          child: _buildPieChart(
                            initialInvestmentPercentage,
                            contributionsPercentage,
                            interestPercentage,
                            context,
                          ),
                        ),
                        const SizedBox(width: 32),
                        Expanded(
                          child: _buildLegend(
                            calculatorData, 
                            currencyData,
                          ),
                        ),
                      ],
                    )
                  : Column(
                      children: [
                        SizedBox(
                          height: chartRadius * 2,
                          width: chartRadius * 2,
                          child: _buildPieChart(
                            initialInvestmentPercentage,
                            contributionsPercentage,
                            interestPercentage,
                            context,
                          ),
                        ),
                        const SizedBox(height: 24),
                        _buildLegend(
                          calculatorData, 
                          currencyData,
                        ),
                      ],
                    ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPieChart(
    double initialInvestmentPercentage,
    double contributionsPercentage,
    double interestPercentage,
    BuildContext context,
  ) {
    final chartColors = [
      Theme.of(context).primaryColor,
      Theme.of(context).colorScheme.secondary,
      Theme.of(context).colorScheme.tertiary,
    ];
    
    return PieChart(
      PieChartData(
        sectionsSpace: 2,
        centerSpaceRadius: 40,
        sections: [
          PieChartSectionData(
            color: chartColors[0],
            value: initialInvestmentPercentage,
            title: '${initialInvestmentPercentage.toStringAsFixed(1)}%',
            radius: chartRadius,
            titleStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            badgeWidget: initialInvestmentPercentage < 8 ? Container() : null,
            showTitle: initialInvestmentPercentage >= 8,
          ),
          PieChartSectionData(
            color: chartColors[1],
            value: contributionsPercentage,
            title: '${contributionsPercentage.toStringAsFixed(1)}%',
            radius: chartRadius,
            titleStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            badgeWidget: contributionsPercentage < 8 ? Container() : null,
            showTitle: contributionsPercentage >= 8,
          ),
          PieChartSectionData(
            color: chartColors[2],
            value: interestPercentage,
            title: '${interestPercentage.toStringAsFixed(1)}%',
            radius: chartRadius,
            titleStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            badgeWidget: interestPercentage < 8 ? Container() : null,
            showTitle: interestPercentage >= 8,
          ),
        ],
      ),
    );
  }

  Widget _buildLegend(
    CalculatorData calculatorData,
    CurrencyData currencyData,
  ) {
    final chartColors = [
      Colors.blue.shade700,
      Colors.green.shade600,
      Colors.orange.shade700,
    ];
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildLegendItem(
            'Initial investment', 
            chartColors[0],
            currencyData.formatAmount(calculatorData.totalPrincipal),
          ),
          const SizedBox(height: 16),
          _buildLegendItem(
            'Contributions', 
            chartColors[1],
            currencyData.formatAmount(calculatorData.totalContributions),
          ),
          const SizedBox(height: 16),
          _buildLegendItem(
            'Interest', 
            chartColors[2],
            currencyData.formatAmount(calculatorData.totalInterest),
          ),
          const Divider(height: 32),
          _buildLegendItem(
            'Total', 
            Colors.grey.shade800,
            currencyData.formatAmount(
              calculatorData.totalPrincipal + 
              calculatorData.totalContributions + 
              calculatorData.totalInterest
            ),
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color, String value, {bool isTotal = false}) {
    return Row(
      children: [
        if (!isTotal) ...[
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
        ],
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 16 : 14,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: isTotal ? 16 : 14,
            color: isTotal ? Colors.black : color,
          ),
        ),
      ],
    );
  }
}
