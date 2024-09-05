import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:month_year_picker/month_year_picker.dart';
import 'package:organise_me/components/reusable_button.dart';
import 'package:organise_me/components/transaction.dart';
import 'package:organise_me/components/utils.dart';
import 'package:organise_me/components/main_category.dart';
import 'package:organise_me/screen/home_screen.dart';
import 'package:organise_me/screen/view_transaction_details.dart';

class AllTransactionScreen extends StatefulWidget {
  static String id = 'allTransaction_screen';

  const AllTransactionScreen({super.key});

  @override
  State<AllTransactionScreen> createState() => _AllTransactionScreenState();
}

class _AllTransactionScreenState extends State<AllTransactionScreen> {
  late final TextEditingController _nameController = TextEditingController();
  late final TextEditingController _amountController = TextEditingController();
  late final TextEditingController _dateController = TextEditingController();
  late final TextEditingController _toController = TextEditingController();
  late final TextEditingController _descriptionController = TextEditingController();

  DateTime? _selected;

  List<String> determineCategory(String group) {
    if (group == "Expenses") {
      return _mainCategory.expensesCategory;
    } else if (group == "Income") {
      return _mainCategory.incomeCategory;
    } else if (group == "Debt") {
      return _mainCategory.debtCategory;
    } else if (group == "Savings") {
      return _mainCategory.savingsCategory;
    } else if (group == "Investment") {
      return _mainCategory.investmentCategory;
    } else {
      return [];
    }
  }


  late MainCategory _mainCategory;
  String? selectedCategory;
  String? selectedSubcategory;

  @override
  void initState() {
    super.initState();
    _dateController.text = DateFormat('MMM yyyy').format(DateTime.now());
    fetchTransactions(_dateController.text);
    _searchController.addListener(_filterTransactions);
  }

  Future<void> _fetchCategories() async {
    await _mainCategory.fetchCategories();
    setState(() {});
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dateController.dispose();
    _toController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    _searchController.removeListener(_filterTransactions);
    _searchController.dispose();
    super.dispose();
  }

  final List<String> group = [
    'Expenses',
    'Income',
    'Debt',
    'Savings',
    'Investment',
  ];
  String? selectedGroup;

  List<String> selectedList = [];

  void _showAddMainCategoryDialog() {
    TextEditingController mainCategoryController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: AutoSizeText(
            'Add New Category',
            textScaleFactor: 1.5.sp,
            style: TextStyle(
              fontFamily: 'Comfortaa',
              fontWeight: FontWeight.w700,
              fontSize: 14.sp,
            ),
          ),
          content: MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: TextScaler.linear(1.3.sp)),
            child: TextField(
              controller: mainCategoryController,
              decoration: InputDecoration(
                  hintText: "Enter category name",
                  hintStyle: TextStyle(
                    fontFamily: 'Comfortaa',
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                  )),
            ),
          ),
          actions: [
            TextButton(
              child: AutoSizeText(
                'Cancel',
                textScaleFactor: 1.4.sp,
                style: TextStyle(
                  fontFamily: 'Comfortaa',
                  fontWeight: FontWeight.w700,
                  fontSize: 12.sp,
                  color: const Color(0xFF285430),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: AutoSizeText(
                'Add',
                textScaleFactor: 1.4.sp,
                style: TextStyle(
                  fontFamily: 'Comfortaa',
                  fontWeight: FontWeight.w700,
                  fontSize: 12.sp,
                  color: const Color(0xFF285430),
                ),
              ),
              onPressed: () async {
                if (selectedGroup == "Expenses") {
                  await _mainCategory
                      .addExpensesCategory(mainCategoryController.text);
                  _fetchCategories();
                  setState(() {
                    selectedList = _mainCategory.expensesCategory;
                  });
                } else if (selectedGroup == "Income") {
                  await _mainCategory
                      .addIncomeCategory(mainCategoryController.text);
                  _fetchCategories();
                  setState(() {
                    selectedList = _mainCategory.incomeCategory;
                  });
                } else if (selectedGroup == "Debt") {
                  await _mainCategory
                      .addDebtCategory(mainCategoryController.text);
                  _fetchCategories();
                  setState(() {
                    selectedList = _mainCategory.debtCategory;
                  });
                } else if (selectedGroup == "Savings") {
                  await _mainCategory
                      .addSavingsCategory(mainCategoryController.text);
                  _fetchCategories();
                  setState(() {
                    selectedList = _mainCategory.savingsCategory;
                  });
                } else if (selectedGroup == "Investment") {
                  await _mainCategory
                      .addInvestmentCategory(mainCategoryController.text);
                  _fetchCategories();
                  setState(() {
                    selectedList = _mainCategory.investmentCategory;
                  });
                }
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  bool isLoading = false;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String get _userId => _auth.currentUser!.uid;
  CollectionReference get _transaction =>
      _firestore.collection('users').doc(_userId).collection('transactions');

  final TextEditingController _searchController = TextEditingController();
  List<Transactions> transactions = [];
  List<Transactions> filteredTransactions = [];
  double totalExpenses = 0;
  double totalIncome = 0;
  double totalLeft = 0;
    Future<void> fetchTransactions(String selectedMonth) async {
      setState(() {
        transactions.clear();
        filteredTransactions.clear();
        totalExpenses = 0;
        totalIncome = 0;
        isLoading = true;
      });

      try {
        QuerySnapshot transactionSnapshot = await _transaction.get();

        for (QueryDocumentSnapshot transactionDoc in transactionSnapshot.docs) {
          Map<String, dynamic> data =
              transactionDoc.data() as Map<String, dynamic>;
          String date = data['date'];
          String month = '${date.split(' ')[1]} ${date.split(' ')[2]}';
          String group = data['group'];

          if (month == selectedMonth) {
            DocumentSnapshot snapshot =
                await _transaction.doc(transactionDoc.id).get();
            Transactions transaction = Transactions(
              group: snapshot['group'] as String,
              category: snapshot['category'] as String,
              name: snapshot['name'] as String,
              amount: snapshot['amount'] as String,
              date: snapshot['date'] as String,
              to: snapshot['to'] as String,
              description: snapshot['description'] as String,
            );
            setState(() {
              transactions.add(transaction);
              if (group == "Expenses") {
                totalExpenses += double.parse(data['amount']);
              } else if (group == "Income") {
                totalIncome += double.parse(data['amount']);
              }
            });
          }
        }

        final dateFormat = DateFormat('dd MMM yyyy');
        transactions.sort((a, b) => dateFormat.parse(b.date).compareTo(dateFormat.parse(a.date)));

        setState(() {
          filteredTransactions = transactions;
          isLoading = false;
          _filterTransactions();
        });
      } catch (e) {
        print("Error fetching transactions: $e");
      }
    }

  bool _isTextFieldVisible = false;

  void _filterTransactions() {
    if (_searchController.text.isEmpty) {
      setState(() {
        filteredTransactions = transactions;
        _calculateTotals();
      });
    } else {
      setState(() {
        filteredTransactions = transactions
            .where((transaction) => transaction.name
            .toLowerCase()
            .contains(_searchController.text.toLowerCase()))
            .toList();
        _calculateTotals();
      });
    }
  }

  void _calculateTotals() {
    double expenses = 0;
    double income = 0;

    for (var transaction in filteredTransactions) {
      if (transaction.group == 'Expenses') {
        expenses += double.parse(transaction.amount);
      } else if (transaction.group == 'Income') {
        income += double.parse(transaction.amount);
      }
    }

    setState(() {
      totalExpenses = expenses;
      totalIncome = income;
      totalLeft = totalIncome - totalExpenses;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: PopScope(
        canPop: false,
        onPopInvoked: ((didpop) {
          if (!didpop) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreen()),
            );
          }
        }),
        child: Scaffold(
          backgroundColor: const Color(0xFFF8F2ED),
          appBar: AppBar(
            backgroundColor: const Color(0xFFA4BE7B),
            leading: IconButton(
              color: Colors.white,
              tooltip: 'back',
              icon: const Icon(Icons.arrow_back_outlined),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const HomeScreen()),
                );
              },
            ),
            title: Center(
              child: AutoSizeText(
                'Transactions',
                textScaleFactor: 1.5.sp,
                style: TextStyle(
                  fontFamily: 'Comfortaa',
                  fontWeight: FontWeight.w700,
                  fontSize: 15.sp,
                  color: Colors.white,
                ),
              ),
            ),
            actions: const [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 15.0),
                child: Icon(
                  Icons.monetization_on_outlined,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ReusableButton(
                      text: _dateController.text,
                      backgroundColor: const Color(0xFFFEF1CC),
                      textColor: Colors.black,
                      onPress: () async => _onPressed(context: context),
                    ),
                  ),
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Card(
                            color: Colors.white,
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width * 0.43,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: AutoSizeText(
                                  textScaleFactor: 1.0.sp,
                                  "Money Out: \nRM ${totalExpenses.toStringAsFixed(2)}",
                                  style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontFamily: "Comfortaa",
                                      fontSize: 8.0.sp),
                                ),
                              ),
                            ),
                          ),
                          Card(
                            color: Colors.white,
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width * 0.43,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: AutoSizeText(
                                  textScaleFactor: 1.0.sp,
                                  "Money In: \nRM ${totalIncome.toStringAsFixed(2)}",
                                  style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontFamily: "Comfortaa",
                                      fontSize: 8.0.sp),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Card(
                        color: Colors.white,
                        child: SizedBox(
                          width: double.infinity,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: AutoSizeText(
                              textScaleFactor: 1.0.sp,
                              "Total(RM) : ${totalLeft.toStringAsFixed(2)}",
                              style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontFamily: "Comfortaa",
                                  fontSize: 8.0.sp),
                            ),
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          AutoSizeText(
                            'This month transactions:',
                            textScaleFactor: 1.0.sp,
                            style: TextStyle(
                              fontFamily: 'Comfortaa',
                              fontWeight: FontWeight.w700,
                              fontSize: 8.sp,
                            ),
                          ),
                          IconButton(
                            tooltip: 'Search',
                            icon: const Icon(Icons.search),
                            onPressed: () {
                              setState(() {
                                _isTextFieldVisible = !_isTextFieldVisible;
                              });
                            },
                          ),
                        ],
                      ),
                      if (_isTextFieldVisible)
                        SizedBox(
                          height: SizeConfig.heightSize(50) * 0.8,
                          child: MediaQuery(
                            data: MediaQuery.of(context).copyWith(
                                textScaler: TextScaler.linear(1.3.sp)),
                            child: TextField(
                              controller: _searchController,
                              decoration: InputDecoration(
                                labelText: 'Search',
                                labelStyle: TextStyle(
                                  fontFamily: 'Comfortaa',
                                  fontSize: 9.sp,
                                  fontWeight: FontWeight.w700,
                                ),
                                border: const OutlineInputBorder(),
                              ),
                              style: TextStyle(
                                fontFamily: 'Comfortaa',
                                fontSize: 9.sp, // Adjust the font size as needed
                              ),
                            ),
                          ),
                        ),
                      SizedBox(
                        height: SizeConfig.heightSize(10) * 0.8,
                      ),
                      isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : filteredTransactions.isEmpty
                              ? Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10.0),
                                  child: Center(
                                    child: Column(
                                      children: [
                                        SizedBox(
                                          height:
                                              SizeConfig.heightSize(30) * 0.8,
                                        ),
                                        Image.asset(
                                          "images/image3.png",
                                          width:
                                              SizeConfig.widthSize(146) * 0.8,
                                          height:
                                              SizeConfig.heightSize(118) * 0.8,
                                        ),
                                        AutoSizeText(
                                          'No Transactions',
                                          style: TextStyle(
                                            fontFamily: 'Comfortaa',
                                            fontWeight: FontWeight.w700,
                                            fontSize: 8.sp,
                                          ),
                                          textScaleFactor: 1.0.sp,
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              : ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: filteredTransactions.length,
                                  itemBuilder: (context, index) {
                                    Transactions transaction =
                                    filteredTransactions[index];
                                    return InkWell(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                ViewTransactionDetailsScreen(
                                                  name: transaction.name,
                                                  isFromHomeScreen: false,
                                                ),
                                          ),
                                        );
                                      },
                                      child: Card(
                                        elevation: 8,
                                        shadowColor: Colors.black54,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(15),
                                        ),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: getTransactionColor(
                                                transaction.group),
                                            borderRadius:
                                                BorderRadius.circular(15),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(16.0),
                                            child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          right: 16.0),
                                                  child: getTransactionIcon(
                                                      transaction.group),
                                                ),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      AutoSizeText(
                                                        "Name: ${transaction.name}",
                                                        textScaleFactor: 1.1.sp,
                                                        style: TextStyle(
                                                          fontFamily:
                                                              'Comfortaa',
                                                          fontWeight:
                                                              FontWeight.w700,
                                                          fontSize: 8.sp,
                                                        ),
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                      SizedBox(
                                                        height: SizeConfig
                                                                .heightSize(4) *
                                                            0.8,
                                                      ),
                                                      AutoSizeText(
                                                        "Group: ${transaction.group}",
                                                        textScaleFactor: 1.1.sp,
                                                        style: TextStyle(
                                                          fontFamily:
                                                              'Comfortaa',
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          fontSize: 8.sp,
                                                          color: Colors.black54,
                                                        ),
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                      SizedBox(
                                                        height: SizeConfig
                                                                .heightSize(4) *
                                                            0.8,
                                                      ),
                                                      AutoSizeText(
                                                        "Date: ${transaction.date}",
                                                        textScaleFactor: 1.1.sp,
                                                        style: TextStyle(
                                                          fontFamily:
                                                          'Comfortaa',
                                                          fontWeight:
                                                          FontWeight.w600,
                                                          fontSize: 8.sp,
                                                          color: Colors.black54,
                                                        ),
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                      SizedBox(
                                                        height: SizeConfig
                                                            .heightSize(4) *
                                                            0.8,
                                                      ),
                                                      AutoSizeText(
                                                        "RM ${double.parse(transaction.amount).toStringAsFixed(2)}",
                                                        textScaleFactor: 1.1.sp,
                                                        style: TextStyle(
                                                          fontFamily:
                                                          'Comfortaa',
                                                          fontWeight:
                                                          FontWeight.w700,
                                                          fontSize: 8.sp,
                                                        ),
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _onPressed({
    required BuildContext context,
    String? locale,
  }) async {
    final localeObj = locale != null ? Locale(locale) : null;
    final selected = await showMonthYearPicker(
      context: context,
      initialDate: _selected ?? DateTime.now(),
      firstDate: DateTime(2019),
      lastDate: DateTime(2030),
      locale: localeObj,
    );
    if (selected != null) {
      setState(() {
        _selected = selected;
        _dateController.text = DateFormat('MMM yyyy').format(selected);
        selectedGroup = null;
        fetchTransactions(_dateController.text);
      });
    }
  }

  Color getTransactionColor(String group) {
    switch (group) {
      case 'Expenses':
        return const Color(0xFFE6A3A3);
      case 'Debt':
        return const Color(0xFFE6BBA3);
      case 'Investment':
        return const Color(0xFFE6D7A3);
      case 'Income':
        return const Color(0xFFACE6A3);
      case 'Savings':
        return const Color(0xFF87FBF1);
      default:
        return const Color(0xFFA7A7A7);
    }
  }

  Icon getTransactionIcon(String group) {
    switch (group) {
      case 'Expenses':
        return const Icon(Icons.money_off);
      case 'Debt':
        return const Icon(Icons.trending_down);
      case 'Investment':
        return const Icon(Icons.trending_up);
      case 'Income':
        return const Icon(Icons.attach_money);
      case 'Savings':
        return const Icon(Icons.savings);
      default:
        return const Icon(Icons.help_outline);
    }
  }
}
