import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/calculator_data.dart';
import '../models/currency_data.dart';

class BarChartWidget extends StatefulWidget {
  const BarChartWidget({Key? key}) : super(key: key);

  @override
  State<BarChartWidget> createState() => _BarChartWidgetState();
}

class _BarChartWidgetState extends State<BarChartWidget> {
  // Default scale mode is auto
  String _selectedScaleMode = 'auto';

  @override
  Widget build(BuildContext context) {
    final calculatorData = Provider.of<CalculatorData>(context);
    final currencyData = Provider.of<CurrencyData>(context);
    
    // Adjust the data for the chart
    final yearlyData = calculatorData.yearlySchedule;
    
    if (yearlyData.isEmpty) {
      return const Center(
        child: Text('No data available for chart'),
      );
    }
    
    // Calculate max value for graph scaling
    double maxValue = 0;
    for (var entry in yearlyData) {
      final totalValue = entry.endingBalance;
      if (totalValue > maxValue) {
        maxValue = totalValue;
      }
    }
    
    // Calculate a more appropriate Y-axis range based on actual data and selected scale mode
    double yAxisMax = calculateAppropriateYAxisMax(maxValue, _selectedScaleMode);
    
    // We'll display at most 5 years of data for mobile view
    final displayLimit = yearlyData.length <= 10 ? yearlyData.length : 5;
    final dataLength = yearlyData.length;
    
    final List<ScheduleEntry> displayData;
    
    // If we have too many data points, select representative samples
    if (dataLength <= displayLimit) {
      displayData = yearlyData;
    } else {
      displayData = [];
      // Add first entry
      displayData.add(yearlyData[0]);
      
      // Add intermediate points evenly spaced
      final step = (dataLength - 2) / (displayLimit - 2);
      for (int i = 1; i < displayLimit - 1; i++) {
        final index = (step * i).round();
        displayData.add(yearlyData[index]);
      }
      
      // Add last entry
      displayData.add(yearlyData[dataLength - 1]);
    }
    
    // Generate appropriate tick marks for the Y-axis
    final yAxisTicks = generateYAxisTicks(yAxisMax, _selectedScaleMode);
    
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.show_chart,
                      size: 20,
                      color: Theme.of(context).primaryColor,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Investment Growth',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ],
                ),
                // Scale selector dropdown
                DropdownButton<String>(
                  isDense: true,
                  value: _selectedScaleMode,
                  icon: const Icon(Icons.arrow_drop_down, size: 20),
                  underline: Container(height: 0),
                  items: [
                    DropdownMenuItem(
                      value: 'auto',
                      child: Text('Auto Scale', style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
                    ),
                    DropdownMenuItem(
                      value: 'compact',
                      child: Text('Compact View', style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
                    ),
                    DropdownMenuItem(
                      value: 'detailed',
                      child: Text('Detailed View', style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
                    ),
                  ],
                  onChanged: (String? value) {
                    if (value != null) {
                      setState(() {
                        _selectedScaleMode = value;
                      });
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            AspectRatio(
              aspectRatio: 1.5,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: yAxisMax,
                  minY: 0,
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      tooltipBgColor: Colors.blueGrey.shade800,
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final year = displayData[groupIndex].period;
                        final value = displayData[groupIndex].endingBalance;
                        
                        // Calculate growth compared to previous period or initial
                        final double previousValue = groupIndex > 0 
                            ? displayData[groupIndex - 1].endingBalance 
                            : calculatorData.initialInvestment;
                        final growth = value - previousValue;
                        final growthPercent = previousValue > 0 
                            ? (growth / previousValue * 100).toStringAsFixed(1) 
                            : '0';
                            
                        return BarTooltipItem(
                          'Year ${year}: ${currencyData.formatAmount(value)}\n',
                          const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          children: <TextSpan>[
                            TextSpan(
                              text: 'Growth: ${currencyData.formatAmount(growth)} ($growthPercent%)',
                              style: TextStyle(color: Colors.green.shade300, fontSize: 12),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index >= 0 && index < displayData.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                '${displayData[index].period}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            );
                          }
                          return const SizedBox();
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 60,
                        getTitlesWidget: (value, meta) {
                          // Display Y-axis labels based on calculated ticks
                          if (yAxisTicks.contains(value)) {
                            // Format the number based on size
                            String formattedValue;
                            if (value >= 1000000) {
                              formattedValue = '${(value / 1000000).toStringAsFixed(value % 1000000 == 0 ? 0 : 1)}M';
                            } else if (value >= 1000) {
                              formattedValue = '${(value / 1000).toStringAsFixed(value % 1000 == 0 ? 0 : 1)}K';
                            } else {
                              formattedValue = value.toStringAsFixed(0);
                            }
                            
                            return Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: Text(
                                '${currencyData.selectedCurrency.symbol}$formattedValue',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                ),
                              ),
                            );
                          }
                          return const SizedBox();
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (value) {
                      if (yAxisTicks.contains(value)) {
                        return FlLine(
                          color: Colors.grey.shade300,
                          strokeWidth: 1,
                        );
                      }
                      return FlLine(
                        color: Colors.transparent,
                        strokeWidth: 0,
                      );
                    },
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: List.generate(displayData.length, (index) {
                    final entry = displayData[index];
                    
                    // Calculate bar width based on number of bars
                    double barWidth = calculateBarWidth(displayData.length);
                    
                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: entry.endingBalance,
                          width: barWidth,
                          color: Theme.of(context).primaryColor,
                          borderRadius: BorderRadius.circular(4),
                          backDrawRodData: BackgroundBarChartRodData(
                            show: true,
                            toY: yAxisMax,
                            color: Colors.grey.shade200,
                          ),
                        ),
                      ],
                    );
                  }),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                'Years',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // Calculate an appropriate maximum for the Y-axis based on the data and scale mode
  double calculateAppropriateYAxisMax(double maxValue, String scaleMode) {
    // If the value is zero or negative, return a minimum positive value
    if (maxValue <= 0) return 100;
    
    // Determine the magnitude (log base 10) of the max value
    final magnitude = (maxValue == 0) ? 0 : (logBase10(maxValue)).floor();
    
    // Use this to get an appropriate scale factor based on selected mode
    double scaleFactor;
    
    switch (scaleMode) {
      case 'compact':
        // For compact view, round up to larger values for cleaner display
        scaleFactor = pow(10, magnitude);
        break;
      case 'detailed':
        // For detailed view, use smaller scale to show more detail
        scaleFactor = pow(10, magnitude - 1);
        if (scaleFactor < 1) scaleFactor = 1;
        break;
      case 'auto':
      default:
        // Auto scale based on the magnitude
        scaleFactor = pow(10, magnitude);
        if (maxValue < scaleFactor * 0.1) {
          scaleFactor = pow(10, magnitude - 1);
        }
    }
    
    // Calculate a rounded max value
    double roundedMax = (maxValue / scaleFactor).ceil() * scaleFactor;
    
    // Add some buffer (more for compact, less for detailed)
    double buffer;
    switch (scaleMode) {
      case 'compact':
        buffer = 1.2; // 20% buffer
        break;
      case 'detailed':
        buffer = 1.05; // 5% buffer
        break;
      default:
        buffer = 1.1; // 10% buffer
    }
    
    return roundedMax * buffer;
  }
  
  // Generate appropriate tick marks for the Y-axis
  List<double> generateYAxisTicks(double maxY, String scaleMode) {
    List<double> ticks = [];
    
    // Always include 0
    ticks.add(0);
    
    int numTicks;
    switch (scaleMode) {
      case 'compact':
        numTicks = 3; // Few ticks for compact view
        break;
      case 'detailed':
        numTicks = 8; // More ticks for detailed view
        break;
      case 'auto':
      default:
        numTicks = 5; // Default number of ticks
    }
    
    // For very small values, adjust accordingly
    if (maxY <= 10) {
      final step = maxY / numTicks;
      for (int i = 1; i <= numTicks; i++) {
        ticks.add(step * i);
      }
      return ticks;
    }
    
    // For special case of small values
    if (maxY <= 100) {
      switch (scaleMode) {
        case 'detailed':
          // For detailed, show ticks at 10, 20, 30, etc.
          final step = 10.0;
          int count = (maxY / step).ceil();
          for (int i = 1; i <= count; i++) {
            ticks.add(step * i);
          }
          break;
        case 'compact':
          // For compact, just show 25, 50, 75, 100
          ticks.addAll([25.0, 50.0, 75.0, 100.0].where((t) => t <= maxY));
          break;
        default:
          // For auto, show 20, 40, 60, 80, 100
          ticks.addAll([20.0, 40.0, 60.0, 80.0, 100.0].where((t) => t <= maxY));
      }
      return ticks;
    }
    
    // For larger values
    // Determine appropriate step size based on the magnitude
    final magnitude = (logBase10(maxY)).floor();
    double step;
    
    switch (scaleMode) {
      case 'detailed':
        // Smaller steps for detailed view
        step = pow(10, magnitude - 1);
        if (maxY / step > 20) {
          step = step * 5;
        } else if (maxY / step > 10) {
          step = step * 2;
        }
        break;
      case 'compact':
        // Larger steps for compact view
        step = pow(10, magnitude) / 2;
        if (step < 1) step = 1;
        break;
      default:
        // Default step calculation
        step = pow(10, magnitude - 1);
        if (maxY / step > 20) {
          step = step * 5;
        } else if (maxY / step > 10) {
          step = step * 2;
        }
    }
    
    // Generate evenly spaced ticks
    double currentTick = step;
    while (currentTick < maxY && ticks.length < 20) {  // Limit to 20 ticks for performance
      ticks.add(currentTick);
      currentTick += step;
    }
    
    return ticks;
  }
  
  // Helper function to calculate logarithm base 10
  double logBase10(double value) {
    return log(value) / log(10);
  }
  
  // Helper for natural logarithm
  double log(double x) {
    // A simple approximation using the fact that ln(x) = log10(x) / log10(e)
    return logBaseTaylor(x, 2.718281828459045);
  }
  
  // Taylor series approximation of logarithm
  double logBaseTaylor(double x, double base) {
    if (x <= 0) return 0; // Avoid invalid inputs
    
    // For x near 1, use Taylor series
    double y = (x - 1) / (x + 1);
    double y2 = y * y;
    double result = 2 * (y + y * y2 / 3 + y * y2 * y2 / 5);
    
    // Convert to the desired base
    double baseLog = 0.693147180559945; // ln(2) approximation 
    if (base != 2.718281828459045) {
      baseLog = logBaseTaylor(base, 2.718281828459045);
    }
    
    return result / baseLog;
  }
  
  // Calculate appropriate bar width based on number of bars
  double calculateBarWidth(int barCount) {
    if (barCount <= 3) return 40;
    if (barCount <= 5) return 30;
    if (barCount <= 8) return 22;
    if (barCount <= 12) return 16;
    return 12;
  }
  
  double pow(double x, int exponent) {
    if (exponent < 0) {
      x = 1 / x;
      exponent = -exponent;
    }
    
    double result = 1.0;
    for (int i = 0; i < exponent; i++) {
      result *= x;
    }
    return result;
  }
}
