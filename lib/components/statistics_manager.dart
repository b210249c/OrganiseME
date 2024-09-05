import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class StatisticsManager {

  StatisticsManager() {
    _initializeTransaction();
  }

  Map<String, double> expenses = {};
  Map<String, double> income = {};
  Map<String, double> debt = {};
  Map<String, double> savings = {};
  Map<String, double> investment = {};

  Map<String, List<double>> monthlyTotals = {};

  double totalExpenses = 0;
  double totalIncome = 0;
  double totalDebt = 0;
  double totalSavings = 0;
  double totalInvestment = 0;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<String> transactions = [];

  String get _userId => _auth.currentUser!.uid;

  CollectionReference get _transactions =>
      _firestore.collection('users').doc(_userId).collection('transactions');
  CollectionReference get _expenses =>
      _firestore.collection('users').doc(_userId).collection('expensesCategory');
  CollectionReference get _income =>
      _firestore.collection('users').doc(_userId).collection('incomeCategory');
  CollectionReference get _debt =>
      _firestore.collection('users').doc(_userId).collection('debtCategory');
  CollectionReference get _savings =>
      _firestore.collection('users').doc(_userId).collection('savingsCategory');
  CollectionReference get _investment =>
      _firestore.collection('users').doc(_userId).collection('investmentCategory');

  void _initializeTransaction() async {
    QuerySnapshot expensesSnapshot = await _expenses.get();
    QuerySnapshot incomeSnapshot = await _income.get();
    QuerySnapshot debtSnapshot = await _debt.get();
    QuerySnapshot savingsSnapshot = await _savings.get();
    QuerySnapshot investmentSnapshot = await _investment.get();

    expenses = {
      for (var doc in expensesSnapshot.docs) doc['expenses']: 0.0
    };
    income = {
      for (var doc in incomeSnapshot.docs) doc['income']: 0.0
    };
    debt = {
      for (var doc in debtSnapshot.docs) doc['debt']: 0.0
    };
    savings = {
      for (var doc in savingsSnapshot.docs) doc['savings']: 0.0
    };
    investment = {
      for (var doc in investmentSnapshot.docs) doc['investment']: 0.0
    };
  }

  Future<void> calcTotal(String selectedMonth, Function updateGroupPieChart, Function updateExpensesPieChart, Function updateIncomePieChart, Function updateDebtsPieChart, Function updateSavingsPieChart, Function updateInvestmentPieChart) async {
    totalExpenses = 0;
    totalIncome = 0;
    totalDebt = 0;
    totalSavings = 0;
    totalInvestment = 0;

    _initializeTransaction();

    QuerySnapshot snapshot = await _transactions.get();

    for (var doc in snapshot.docs) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      String date = data['date'];
      String month = '${date.split(' ')[1]} ${date.split(' ')[2]}';

      if (month == selectedMonth) {
        String group = data['group'];
        double amount = double.parse(data['amount']);
        String category = data['category'];

        if (group == 'Expenses') {
          totalExpenses += amount;

          if (expenses.containsKey(category)) {
            expenses[category] = (expenses[category] ?? 0) + amount;
          }
        } else if (group == 'Income') {
          totalIncome += amount;

          if (income.containsKey(category)) {
            income[category] = (income[category] ?? 0) + amount;
          }
        } else if (group == 'Debt') {
          totalDebt += amount;

          if (debt.containsKey(category)) {
            debt[category] = (debt[category] ?? 0) + amount;
          }
        } else if (group == 'Savings') {
          totalSavings += amount;

          if (savings.containsKey(category)) {
            savings[category] = (savings[category] ?? 0) + amount;
          }
        } else if (group == 'Investment') {
          totalInvestment += amount;

          if (investment.containsKey(category)) {
            investment[category] = (investment[category] ?? 0) + amount;
          }
        }
      }
    }

    updateGroupPieChart();
    updateExpensesPieChart();
    updateIncomePieChart();
    updateDebtsPieChart();
    updateSavingsPieChart();
    updateInvestmentPieChart();
  }

  Future<void> calcMonthlyTotals(String selectedYear, Function updateBarChart) async {
    monthlyTotals = {
      'Expenses': List<double>.filled(12, 0.0),
      'Income': List<double>.filled(12, 0.0),
      'Debt': List<double>.filled(12, 0.0),
      'Savings': List<double>.filled(12, 0.0),
      'Investment': List<double>.filled(12, 0.0),
    };


    QuerySnapshot snapshot = await _transactions.get();

    for (var doc in snapshot.docs) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      String date = data['date'];
      DateTime dateTime = DateFormat('dd MMM yyyy').parse(date);
      int year = dateTime.year;
      int month = dateTime.month - 1; // Month is 0-based for the list

      if (year.toString() == selectedYear) {
        String group = data['group'];
        double amount = double.parse(data['amount']);

        if (monthlyTotals.containsKey(group)) {
          monthlyTotals[group]![month] += amount;
        }
      }
    }

    updateBarChart();
  }

  Future<void> calcDailyTotals(String selectedMonth, String selectedGroup, Function updateLineChart) async {
    List<double> dailyTotals = List<double>.filled(31, 0.0); // Assuming max 31 days in a month

    QuerySnapshot snapshot = await _transactions.get();

    for (var doc in snapshot.docs) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      String date = data['date'];
      DateTime dateTime = DateFormat('dd MMM yyyy').parse(date);
      String monthYear = DateFormat('MMM yyyy').format(dateTime);
      int day = dateTime.day - 1; // Day is 0-based for the list

      if (monthYear == selectedMonth) {
        String group = data['group'];
        double amount = double.parse(data['amount']);

        if (group == selectedGroup) {
          dailyTotals[day] += amount;
        }
      }
    }

    updateLineChart(dailyTotals);
  }
}
