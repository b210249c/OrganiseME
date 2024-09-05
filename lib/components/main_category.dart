import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MainCategory {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<String> defaultMainCategories = [
    'Food / Drinks',
    'Transportation',
    'Shopping',
    'Pets',
    'Income',
    'Other',
  ];
  List<String> mainCategories = [];

  List<String> defaultExpenseCategories = [
    'Food / Drinks',
    'Transportation',
    'Utilities',
    'Leisure',
    'Shopping',
    'Medical / Healthcare',
    'Insurance',
    'Household Items',
    'Gifts / Donations',
    'Pets',
    'Other',
  ];
  List<String> expensesCategory = [];

  List<String> defaultIncomeCategories = [
    'Salary',
    'Pension',
    'Reimbursement',
    'Benefits',
    'Financial',
    'Other',
  ];
  List<String> incomeCategory = [];

  List<String> defaultDebtCategories = [
    'Personal Loans',
    'Car Loans',
    'Education Loans',
    'Credit Cards',
    'Mortgage',
    'Other',
  ];
  List<String> debtCategory = [];

  List<String> defaultSavingsCategories = [
    'Emergency Fund',
    'Other',
  ];
  List<String> savingsCategory = [];

  List<String> defaultInvestmentCategories = [
    'Stock',
    'Rental House',
    'Other',
  ];
  List<String> investmentCategory = [];

  String get _userId => _auth.currentUser!.uid;

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


  Future<void> fetchCategories() async {
    QuerySnapshot expensesSnapshot = await _expenses.get();
    QuerySnapshot incomeSnapshot = await _income.get();
    QuerySnapshot debtSnapshot = await _debt.get();
    QuerySnapshot savingsSnapshot = await _savings.get();
    QuerySnapshot investmentSnapshot = await _investment.get();

    if (expensesSnapshot.docs.isEmpty) {
      for (String expenses in defaultExpenseCategories) {
        await _expenses.add({'expenses': expenses});
      }
    }
    expensesSnapshot = await _expenses.get();

    if (incomeSnapshot.docs.isEmpty) {
      for (String income in defaultIncomeCategories) {
        await _income.add({'income': income});
      }
    }
    incomeSnapshot = await _income.get();

    if (debtSnapshot.docs.isEmpty) {
      for (String debt in defaultDebtCategories) {
        await _debt.add({'debt': debt});
      }
    }
    debtSnapshot = await _debt.get();

    if (savingsSnapshot.docs.isEmpty) {
      for (String savings in defaultSavingsCategories) {
        await _savings.add({'savings': savings});
      }
    }
    savingsSnapshot = await _savings.get();

    if (investmentSnapshot.docs.isEmpty) {
      for (String investment in defaultInvestmentCategories) {
        await _investment.add({'investment': investment});
      }
    }
    investmentSnapshot = await _investment.get();

    expensesCategory =
        expensesSnapshot.docs.map((doc) => doc['expenses'] as String).toList();
    expensesCategory.remove('Other');
    expensesCategory.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    expensesCategory.add('Other');

    incomeCategory =
        incomeSnapshot.docs.map((doc) => doc['income'] as String).toList();
    incomeCategory.remove('Other');
    incomeCategory.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    incomeCategory.add('Other');

    debtCategory =
        debtSnapshot.docs.map((doc) => doc['debt'] as String).toList();
    debtCategory.remove('Other');
    debtCategory.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    debtCategory.add('Other');

    savingsCategory =
        savingsSnapshot.docs.map((doc) => doc['savings'] as String).toList();
    savingsCategory.remove('Other');
    savingsCategory.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    savingsCategory.add('Other');

    investmentCategory =
        investmentSnapshot.docs.map((doc) => doc['investment'] as String).toList();
    investmentCategory.remove('Other');
    investmentCategory.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    investmentCategory.add('Other');
  }

  Future<void> addExpensesCategory(String expenses) async {
    await _expenses.add({'expenses': expenses});
    await fetchCategories();
  }

  Future<void> addIncomeCategory(String income) async {
    await _income.add({'income': income});
    await fetchCategories();
  }

  Future<void> addDebtCategory(String debt) async {
    await _debt.add({'debt': debt});
    await fetchCategories();
  }

  Future<void> addSavingsCategory(String savings) async {
    await _savings.add({'savings': savings});
    await fetchCategories();
  }

  Future<void> addInvestmentCategory(String investment) async {
    await _investment.add({'investment': investment});
    await fetchCategories();
  }

  Future<void> updateExpensesCategory(String oldCategory, String newCategory) async {
    QuerySnapshot snapshot = await _expenses
        .where('expenses', isEqualTo: oldCategory)
        .get();
    for (var doc in snapshot.docs) {
      await doc.reference.update({'expenses': newCategory});
    }
    await fetchCategories();
  }

  Future<void> updateIncomeCategory(String oldCategory, String newCategory) async {
    QuerySnapshot snapshot = await _income
        .where('income', isEqualTo: oldCategory)
        .get();
    for (var doc in snapshot.docs) {
      await doc.reference.update({'income': newCategory});
    }
    await fetchCategories();
  }

  Future<void> updateDebtCategory(String oldCategory, String newCategory) async {
    QuerySnapshot snapshot = await _debt
        .where('debt', isEqualTo: oldCategory)
        .get();
    for (var doc in snapshot.docs) {
      await doc.reference.update({'debt': newCategory});
    }
    await fetchCategories();
  }

  Future<void> updateSavingsCategory(String oldCategory, String newCategory) async {
    QuerySnapshot snapshot = await _savings
        .where('savings', isEqualTo: oldCategory)
        .get();
    for (var doc in snapshot.docs) {
      await doc.reference.update({'savings': newCategory});
    }
    await fetchCategories();
  }

  Future<void> updateInvestmentCategory(String oldCategory, String newCategory) async {
    QuerySnapshot snapshot = await _investment
        .where('investment', isEqualTo: oldCategory)
        .get();
    for (var doc in snapshot.docs) {
      await doc.reference.update({'investment': newCategory});
    }
    await fetchCategories();
  }

  Future<void> deleteExpensesCategory(String expenses) async {
    QuerySnapshot snapshot = await _expenses
        .where('expenses', isEqualTo: expenses)
        .get();
    for (var doc in snapshot.docs) {
      await doc.reference.delete();
    }
    await fetchCategories();
  }

  Future<void> deleteIncomeCategory(String income) async {
    QuerySnapshot snapshot = await _income
        .where('income', isEqualTo: income)
        .get();
    for (var doc in snapshot.docs) {
      await doc.reference.delete();
    }
    await fetchCategories();
  }

  Future<void> deleteDebtCategory(String debt) async {
    QuerySnapshot snapshot = await _debt
        .where('debt', isEqualTo: debt)
        .get();
    for (var doc in snapshot.docs) {
      await doc.reference.delete();
    }
    await fetchCategories();
  }

  Future<void> deleteSavingsCategory(String savings) async {
    QuerySnapshot snapshot = await _savings
        .where('savings', isEqualTo: savings)
        .get();
    for (var doc in snapshot.docs) {
      await doc.reference.delete();
    }
    await fetchCategories();
  }

  Future<void> deleteInvestmentCategory(String investment) async {
    QuerySnapshot snapshot = await _investment
        .where('investment', isEqualTo: investment)
        .get();
    for (var doc in snapshot.docs) {
      await doc.reference.delete();
    }
    await fetchCategories();
  }
}