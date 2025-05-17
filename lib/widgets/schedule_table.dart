import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../models/calculator_data.dart';
import '../models/currency_data.dart';

class ScheduleTable extends StatefulWidget {
  const ScheduleTable({Key? key}) : super(key: key);

  @override
  State<ScheduleTable> createState() => _ScheduleTableState();
}

class _ScheduleTableState extends State<ScheduleTable> with SingleTickerProviderStateMixin {
  bool _showYearly = true;
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {
          _showYearly = _tabController.index == 0;
        });
      }
    });
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final calculatorData = Provider.of<CalculatorData>(context);
    final currencyData = Provider.of<CurrencyData>(context);
    
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TabBar(
            controller: _tabController,
            labelColor: Theme.of(context).primaryColor,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold),
            unselectedLabelColor: Colors.grey,
            indicatorSize: TabBarIndicatorSize.tab,
            indicatorColor: Theme.of(context).primaryColor,
            dividerColor: Colors.transparent,
            tabs: const [
              Tab(text: "Annual Schedule"),
              Tab(text: "Monthly Schedule"),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _tabController.index == 0
          ? _buildScheduleTable(
              context: context,
              schedule: calculatorData.yearlySchedule,
              currencyData: currencyData,
              isYearly: true,
            )
          : _buildScheduleTable(
              context: context,
              schedule: calculatorData.monthlySchedule,
              currencyData: currencyData,
              isYearly: false,
            ),
      ],
    );
  }

  Widget _buildScheduleTable({
    required BuildContext context,
    required List<ScheduleEntry> schedule,
    required CurrencyData currencyData,
    required bool isYearly,
  }) {
    if (schedule.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            "No data available. Please check your investment parameters.",
            style: TextStyle(fontSize: 16),
          ),
        ),
      );
    }
    
    final scrollController = ScrollController();
    
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Scrollbar(
        controller: scrollController,
        thumbVisibility: true,
        trackVisibility: true,
        child: SingleChildScrollView(
          controller: scrollController,
          scrollDirection: Axis.horizontal,
          child: Theme(
            data: Theme.of(context).copyWith(
              dividerColor: Colors.grey.shade200,
              dataTableTheme: DataTableThemeData(
                headingTextStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                dataTextStyle: TextStyle(
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                  fontSize: 14,
                ),
              ),
            ),
            child: DataTable(
              headingRowColor: MaterialStateProperty.all(Theme.of(context).primaryColor),
              dataRowMaxHeight: 60,
              columnSpacing: 32,
              horizontalMargin: 16,
              columns: [
                DataColumn(
                  label: Text(
                    isYearly ? 'Year' : 'Month',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const DataColumn(
                  label: Text(
                    'Deposit',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const DataColumn(
                  label: Text(
                    'Interest',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const DataColumn(
                  label: Text(
                    'Ending balance',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
              rows: schedule.map((entry) {
                final rowIndex = schedule.indexOf(entry);
                return DataRow(
                  color: MaterialStateProperty.resolveWith<Color?>(
                    (Set<MaterialState> states) {
                      // Return alternating row colors
                      return rowIndex % 2 == 0 
                          ? Colors.grey.shade50
                          : Colors.white;
                    },
                  ),
                  cells: [
                    DataCell(AnimatedOpacity(
                      opacity: 1.0,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeIn,
                      child: Text(
                        entry.period.toString(),
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    )),
                    DataCell(AnimatedOpacity(
                      opacity: 1.0,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeIn,
                      child: Text(currencyData.formatAmount(entry.deposit)),
                    )),
                    DataCell(AnimatedOpacity(
                      opacity: 1.0,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeIn,
                      child: Text(
                        currencyData.formatAmount(entry.interest),
                        style: TextStyle(
                          color: entry.interest > 0 ? Colors.green : Colors.red,
                        ),
                      ),
                    )),
                    DataCell(AnimatedOpacity(
                      opacity: 1.0, 
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeIn,
                      child: Text(
                        currencyData.formatAmount(entry.endingBalance),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    )),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}
