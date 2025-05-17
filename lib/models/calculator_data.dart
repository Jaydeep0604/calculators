import 'dart:math';
import 'package:flutter/foundation.dart';

enum CompoundPeriod {
  annually,
  semiAnnually,
  quarterly,
  monthly,
  daily
}

extension CompoundPeriodExtension on CompoundPeriod {
  String get displayName {
    switch (this) {
      case CompoundPeriod.annually:
        return 'Annually';
      case CompoundPeriod.semiAnnually:
        return 'Semi-annually';
      case CompoundPeriod.quarterly:
        return 'Quarterly';
      case CompoundPeriod.monthly:
        return 'Monthly';
      case CompoundPeriod.daily:
        return 'Daily';
    }
  }

  int get periodsPerYear {
    switch (this) {
      case CompoundPeriod.annually:
        return 1;
      case CompoundPeriod.semiAnnually:
        return 2;
      case CompoundPeriod.quarterly:
        return 4;
      case CompoundPeriod.monthly:
        return 12;
      case CompoundPeriod.daily:
        return 365;
    }
  }
  
  // Helper method to convert string to CompoundPeriod
  static CompoundPeriod fromString(String value) {
    switch (value.toLowerCase()) {
      case 'annually':
        return CompoundPeriod.annually;
      case 'semi-annually':
        return CompoundPeriod.semiAnnually;
      case 'quarterly':
        return CompoundPeriod.quarterly;
      case 'monthly':
        return CompoundPeriod.monthly;
      case 'daily':
        return CompoundPeriod.daily;
      default:
        return CompoundPeriod.annually;
    }
  }
}

enum ContributionTiming {
  beginning,
  end
}

class ScheduleEntry {
  final int period;
  final double deposit;
  final double interest;
  final double endingBalance;

  ScheduleEntry({
    required this.period,
    required this.deposit,
    required this.interest,
    required this.endingBalance,
  });
}

class CalculatorData with ChangeNotifier {
  double _initialInvestment = 50000;
  double _annualContribution = 5000;
  double _monthlyContribution = 0;
  double _interestRate = 5;
  CompoundPeriod _compoundPeriod = CompoundPeriod.annually;
  ContributionTiming _contributionTiming = ContributionTiming.beginning;
  int _yearsLength = 5;
  int _monthsLength = 0;
  double _taxRate = 0;
  double _inflationRate = 3;
  
  // Results
  double _endingBalance = 0;
  double _totalPrincipal = 0;
  double _totalContributions = 0;
  double _totalInterest = 0;
  double _initialInvestmentInterest = 0;
  double _contributionsInterest = 0;
  double _inflationAdjustedBalance = 0;
  List<ScheduleEntry> _yearlySchedule = [];
  List<ScheduleEntry> _monthlySchedule = [];
  bool _hasCalculated = false;

  // Getters
  double get initialInvestment => _initialInvestment;
  double get annualContribution => _annualContribution;
  double get monthlyContribution => _monthlyContribution;
  double get interestRate => _interestRate;
  CompoundPeriod get compoundPeriod => _compoundPeriod;
  ContributionTiming get contributionTiming => _contributionTiming;
  int get yearsLength => _yearsLength;
  int get monthsLength => _monthsLength;
  double get taxRate => _taxRate;
  double get inflationRate => _inflationRate;
  
  double get endingBalance => _endingBalance;
  double get totalPrincipal => _totalPrincipal;
  double get totalContributions => _totalContributions;
  double get totalInterest => _totalInterest;
  double get initialInvestmentInterest => _initialInvestmentInterest;
  double get contributionsInterest => _contributionsInterest;
  double get inflationAdjustedBalance => _inflationAdjustedBalance;
  List<ScheduleEntry> get yearlySchedule => _yearlySchedule;
  List<ScheduleEntry> get monthlySchedule => _monthlySchedule;
  bool get hasCalculated => _hasCalculated;

  // Helper methods for result summary
  double getTotalContributions() => _totalContributions;
  double getTotalInterest() => _totalInterest;
  
  double getTaxPaid() {
    if (_taxRate <= 0) return 0;
    
    final taxRateDecimal = _taxRate / 100;
    // Tax is applied to interest earnings
    return _totalInterest * taxRateDecimal / (1 - taxRateDecimal);
  }
  
  double getInflationAdjustment() {
    if (_inflationRate <= 0) return 0;
    
    final years = (_yearsLength * 12 + _monthsLength) / 12.0;
    return _endingBalance - _inflationAdjustedBalance;
  }

  // Setters
  set initialInvestment(double value) {
    if (_initialInvestment != value) {
      _initialInvestment = value;
      notifyListeners();
    }
  }

  set annualContribution(double value) {
    if (_annualContribution != value) {
      _annualContribution = value;
      notifyListeners();
    }
  }

  set monthlyContribution(double value) {
    if (_monthlyContribution != value) {
      _monthlyContribution = value;
      notifyListeners();
    }
  }

  set interestRate(double value) {
    if (_interestRate != value) {
      _interestRate = value;
      notifyListeners();
    }
  }

  set compoundPeriod(CompoundPeriod value) {
    if (_compoundPeriod != value) {
      _compoundPeriod = value;
      notifyListeners();
    }
  }

  // Helper method to set compound period from a string
  void setCompoundPeriodFromString(String value) {
    final period = value.toLowerCase();
    if (period == 'annually') {
      compoundPeriod = CompoundPeriod.annually;
    } else if (period == 'semi-annually') {
      compoundPeriod = CompoundPeriod.semiAnnually;
    } else if (period == 'quarterly') {
      compoundPeriod = CompoundPeriod.quarterly;
    } else if (period == 'monthly') {
      compoundPeriod = CompoundPeriod.monthly;
    } else if (period == 'daily') {
      compoundPeriod = CompoundPeriod.daily;
    }
  }

  set contributionTiming(ContributionTiming value) {
    if (_contributionTiming != value) {
      _contributionTiming = value;
      notifyListeners();
    }
  }

  set yearsLength(int value) {
    if (_yearsLength != value) {
      _yearsLength = value;
      notifyListeners();
    }
  }

  set monthsLength(int value) {
    if (_monthsLength != value) {
      _monthsLength = value;
      notifyListeners();
    }
  }

  set taxRate(double value) {
    if (_taxRate != value) {
      _taxRate = value;
      notifyListeners();
    }
  }

  set inflationRate(double value) {
    if (_inflationRate != value) {
      _inflationRate = value;
      notifyListeners();
    }
  }

  void reset() {
    _initialInvestment = 50000;
    _annualContribution = 5000;
    _monthlyContribution = 0;
    _interestRate = 5;
    _compoundPeriod = CompoundPeriod.annually;
    _contributionTiming = ContributionTiming.beginning;
    _yearsLength = 5;
    _monthsLength = 0;
    _taxRate = 0;
    _inflationRate = 3;
    calculate();
    notifyListeners();
  }

  void calculate() {
    // Convert all inputs to calculations
    final totalMonths = (_yearsLength * 12) + _monthsLength;
    final ratePerPeriod = _interestRate / 100 / _compoundPeriod.periodsPerYear;
    final periodsPerMonth = _compoundPeriod.periodsPerYear / 12;
    final taxRateDecimal = _taxRate / 100;
    final inflationRateDecimal = _inflationRate / 100;
    
    double balance = _initialInvestment;
    double initialInvestmentFutureValue = _initialInvestment;
    double totalContributions = 0;
    
    _yearlySchedule = [];
    _monthlySchedule = [];
    
    // Calculate monthly schedule
    for (int month = 1; month <= totalMonths; month++) {
      final isFullPeriod = month % (12 / _compoundPeriod.periodsPerYear) == 0;
      final periodFraction = periodsPerMonth;
      
      double thisMonthContribution = _monthlyContribution;
      if (month % 12 == 1) {
        thisMonthContribution += _annualContribution;
      }
      
      double periodDeposit = thisMonthContribution;
      double periodInterest = 0;
      
      if (_contributionTiming == ContributionTiming.beginning) {
        balance += periodDeposit;
        totalContributions += periodDeposit;
      }
      
      // Calculate interest for this period
      if (isFullPeriod) {
        periodInterest = balance * ratePerPeriod * (1 - taxRateDecimal);
      } else {
        periodInterest = balance * ratePerPeriod * periodFraction * (1 - taxRateDecimal);
      }
      
      balance += periodInterest;
      
      if (_contributionTiming == ContributionTiming.end) {
        balance += periodDeposit;
        totalContributions += periodDeposit;
      }
      
      // Track initial investment growth separately
      initialInvestmentFutureValue *= (1 + ratePerPeriod * periodFraction * (1 - taxRateDecimal));
      
      // Add to monthly schedule
      _monthlySchedule.add(ScheduleEntry(
        period: month,
        deposit: periodDeposit,
        interest: periodInterest,
        endingBalance: balance,
      ));
      
      // Add to yearly schedule on year boundaries
      if (month % 12 == 0) {
        _yearlySchedule.add(ScheduleEntry(
          period: month ~/ 12,
          deposit: _yearlySchedule.isEmpty 
              ? _initialInvestment + _annualContribution + (_monthlyContribution * 12) 
              : _annualContribution + (_monthlyContribution * 12),
          interest: _monthlySchedule
              .where((entry) => entry.period > (month - 12) && entry.period <= month)
              .fold(0, (sum, entry) => sum + entry.interest),
          endingBalance: balance,
        ));
      }
    }
    
    // If the investment period doesn't end on a year boundary, add the partial year
    if (totalMonths % 12 != 0 && (_yearlySchedule.isEmpty || _yearlySchedule.last.period != (totalMonths / 12).ceil())) {
      final lastFullYear = (totalMonths / 12).floor();
      final startMonth = lastFullYear * 12 + 1;
      
      _yearlySchedule.add(ScheduleEntry(
        period: lastFullYear + 1,
        deposit: _yearlySchedule.isEmpty 
            ? _initialInvestment + _annualContribution 
            : _annualContribution,
        interest: _monthlySchedule
            .where((entry) => entry.period >= startMonth && entry.period <= totalMonths)
            .fold(0, (sum, entry) => sum + entry.interest),
        endingBalance: balance,
      ));
    }
    
    // Ensure we have at least one yearly entry if the period is less than a year
    if (_yearlySchedule.isEmpty && totalMonths > 0) {
      _yearlySchedule.add(ScheduleEntry(
        period: 1,
        deposit: _initialInvestment + (_monthlyContribution * totalMonths),
        interest: _monthlySchedule.fold(0, (sum, entry) => sum + entry.interest),
        endingBalance: balance,
      ));
    }
    
    // Calculate results
    _endingBalance = balance;
    _totalPrincipal = _initialInvestment;
    _totalContributions = totalContributions;
    _totalInterest = _endingBalance - _totalPrincipal - _totalContributions;
    _initialInvestmentInterest = initialInvestmentFutureValue - _initialInvestment;
    _contributionsInterest = _totalInterest - _initialInvestmentInterest;
    
    // Calculate inflation adjusted value
    final years = totalMonths / 12.0;
    _inflationAdjustedBalance = _endingBalance / pow(1 + inflationRateDecimal, years);
    
    // Mark as calculated
    _hasCalculated = true;
    
    notifyListeners();
  }
}
