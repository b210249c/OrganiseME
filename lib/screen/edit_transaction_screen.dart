import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:organise_me/components/loading.dart';
import 'package:organise_me/screen/manage_category.dart';
import 'package:organise_me/screen/success_screen.dart';
import 'package:organise_me/components/transaction_manager.dart';
import 'package:organise_me/components/utils.dart';
import 'package:organise_me/components/reusable_text.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:organise_me/components/main_category.dart';
import 'package:organise_me/screen/view_transaction_details.dart';

class EditTransactionScreen extends StatefulWidget {
  static String id = 'editTransaction_screen';
  final String name;
  final bool isFromHomeScreen;

  const EditTransactionScreen({super.key, required this.name, required this.isFromHomeScreen});

  @override
  State<EditTransactionScreen> createState() => _EditTransactionScreenState();
}

class _EditTransactionScreenState extends State<EditTransactionScreen> {

  late TextEditingController _nameController = TextEditingController();
  late TextEditingController _amountController = TextEditingController();
  late TextEditingController _dateController = TextEditingController();
  late TextEditingController _toController = TextEditingController();
  late TextEditingController _descriptionController = TextEditingController();

  late TransactionManager _transactionManager;

  List<String> determineCategory (String group) {
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

  Future<void> _fetchTransactionDetails() async {
    await _transactionManager.fetchTransactionDetails(widget.name);
    await _mainCategory.fetchCategories().then((_){
      selectedList = determineCategory(_transactionManager.group);
    });
    setState(() {
      _nameController.text = _transactionManager.name;
      _amountController.text = double.parse(_transactionManager.amount).toStringAsFixed(2);
      _dateController.text = _transactionManager.date;
      _toController.text = _transactionManager.to;
      _descriptionController.text = _transactionManager.description;
      selectedGroup = _transactionManager.group;
      selectedCategory = _transactionManager.category;
      if (!group.contains(selectedGroup)) {
        selectedGroup = null;
      }
    });
  }

  late Future<void> _transactionDetails;

  late MainCategory _mainCategory;
  String? selectedCategory;
  String? selectedSubcategory;

  @override
  void initState() {
    super.initState();
    _transactionManager = TransactionManager();
    _nameController = TextEditingController();
    _amountController = TextEditingController();
    _toController = TextEditingController();
    _dateController = TextEditingController();
    _descriptionController = TextEditingController();
    _mainCategory = MainCategory();
    _transactionDetails = _fetchTransactionDetails();
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

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: PopScope(
        canPop: false,
        onPopInvoked: ((didpop) {
          if (!didpop) {
            if(widget.isFromHomeScreen == true){
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ViewTransactionDetailsScreen(name: _nameController.text, isFromHomeScreen: true,),
                ),
              );
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ViewTransactionDetailsScreen(name: _nameController.text, isFromHomeScreen: false,),
                ),
              );
            }
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
                if(widget.isFromHomeScreen == true){
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ViewTransactionDetailsScreen(name: _nameController.text, isFromHomeScreen: true,),
                    ),
                  );
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ViewTransactionDetailsScreen(name: _nameController.text, isFromHomeScreen: false,),
                    ),
                  );
                }
              },
            ),
            title: Center(
              child: AutoSizeText(
                'Edit',
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
                child: Icon(Icons.edit, color: Colors.white,),
              ),
            ],
          ),
          body: FutureBuilder(
              future: _transactionDetails,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (snapshot.hasError) {
                  return const Center(
                    child: Text('Error fetching transactions'),
                  );
                } else {
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  children: [
                    AutoSizeText(
                      'Transaction Details',
                      textScaleFactor: 1.5.sp,
                      style: TextStyle(
                        fontFamily: 'Comfortaa',
                        fontWeight: FontWeight.w700,
                        fontSize: 17.sp,
                        color: const Color(0xFF285430),
                      ),
                    ),
                    SizedBox(
                      height: SizeConfig.heightSize(10) * 0.8,
                    ),
                          Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  SizedBox(
                                    width:
                                    MediaQuery.of(context).size.width *
                                        0.2,
                                    child: AutoSizeText(
                                      'Group:',
                                      textScaleFactor: 1.2.sp,
                                      style: TextStyle(
                                        fontFamily: 'Comfortaa',
                                        fontWeight: FontWeight.w700,
                                        fontSize: 8.sp,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width:
                                    MediaQuery.of(context).size.width *
                                        0.7,
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton2<String>(
                                        isExpanded: true,
                                        items: group
                                            .map((String item) =>
                                            DropdownMenuItem<String>(
                                              value: item,
                                              child: AutoSizeText(
                                                item,
                                                textScaleFactor: 1.0.sp,
                                                style: TextStyle(
                                                  fontFamily:
                                                  'Comfortaa',
                                                  fontWeight:
                                                  FontWeight.w700,
                                                  fontSize: 8.sp,
                                                  color: Colors.black,
                                                ),
                                                overflow: TextOverflow
                                                    .ellipsis,
                                              ),
                                            ))
                                            .toList(),
                                        value: selectedGroup,
                                        onChanged: (String? value) {
                                          setState(() {
                                            selectedGroup = value;
                                            selectedCategory = null;
                                            selectedList = determineCategory(selectedGroup!);
                                          });
                                        },
                                        buttonStyleData: ButtonStyleData(
                                          width: double.infinity,
                                          padding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 15),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                            BorderRadius.circular(
                                                SizeConfig.widthSize(
                                                    11) *
                                                    0.8),
                                            border: Border.all(
                                              color: Colors.black26,
                                            ),
                                            color: const Color(0xFFE5D9B6),
                                          ),
                                          elevation: 2,
                                        ),
                                        iconStyleData: const IconStyleData(
                                          icon: Icon(
                                            Icons
                                                .arrow_forward_ios_outlined,
                                          ),
                                          iconSize: 14,
                                          iconEnabledColor: Colors.black,
                                          iconDisabledColor: Colors.grey,
                                        ),
                                        dropdownStyleData:
                                        DropdownStyleData(
                                          maxHeight: 200,
                                          width: MediaQuery.of(context)
                                              .size
                                              .width *
                                              0.7,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                            BorderRadius.circular(
                                                SizeConfig.widthSize(
                                                    11) *
                                                    0.8),
                                            color: const Color(0xFFFEF1CC),
                                          ),
                                          offset: const Offset(0, 0),
                                          scrollbarTheme:
                                          ScrollbarThemeData(
                                            radius:
                                            const Radius.circular(40),
                                            thickness: WidgetStateProperty
                                                .all<double>(6),
                                            thumbVisibility:
                                            WidgetStateProperty.all<
                                                bool>(true),
                                          ),
                                        ),
                                        menuItemStyleData:
                                        const MenuItemStyleData(
                                          height: 40,
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 15),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: SizeConfig.heightSize(10) * 0.8,
                              ),
                              Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  SizedBox(
                                    width:
                                    MediaQuery.of(context).size.width *
                                        0.28,
                                    child: AutoSizeText(
                                      'Category:',
                                      textScaleFactor: 1.2.sp,
                                      style: TextStyle(
                                        fontFamily: 'Comfortaa',
                                        fontWeight: FontWeight.w700,
                                        fontSize: 8.sp,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      showMenu(
                                        context: context,
                                        position:
                                        const RelativeRect.fromLTRB(
                                            100.0, 250.0, 0.0, 0.0),
                                        items: [
                                          PopupMenuItem<int>(
                                            value: 0,
                                            child: ReusableText(
                                              text: 'Add Category',
                                              fontSize:
                                              SizeConfig.widthSize(15) *
                                                  0.8,
                                              color: Colors.black,
                                              decoration:
                                              TextDecoration.none,
                                            ),
                                          ),
                                          PopupMenuItem<int>(
                                            value: 1,
                                            child: ReusableText(
                                              text: 'Manage Category',
                                              fontSize:
                                              SizeConfig.widthSize(15) *
                                                  0.8,
                                              color: Colors.black,
                                              decoration:
                                              TextDecoration.none,
                                            ),
                                          ),
                                        ],
                                      ).then((value) {
                                        if (value == 0) {
                                          if (selectedGroup == null) {
                                            return showDialog<void>(
                                              context: context,
                                              barrierDismissible: false,
                                              builder:
                                                  (BuildContext context) {
                                                return AlertDialog(
                                                  title: AutoSizeText(
                                                    'Alert',
                                                    textScaleFactor: 1.5.sp,
                                                    style: TextStyle(
                                                      fontFamily:
                                                      'Comfortaa',
                                                      fontWeight:
                                                      FontWeight.w700,
                                                      fontSize: 17.sp,
                                                    ),
                                                  ),
                                                  content:
                                                  SingleChildScrollView(
                                                    child: AutoSizeText(
                                                      'You have not chosen any group. Try choosing a group before adding a new category.',
                                                      textScaleFactor:
                                                      1.5.sp,
                                                      style: TextStyle(
                                                        fontFamily:
                                                        'Comfortaa',
                                                        fontWeight:
                                                        FontWeight.w700,
                                                        fontSize: 12.sp,
                                                      ),
                                                      textAlign:
                                                      TextAlign.justify,
                                                    ),
                                                  ),
                                                  actions: <Widget>[
                                                    TextButton(
                                                      child: AutoSizeText(
                                                        'Ok',
                                                        textScaleFactor:
                                                        1.4.sp,
                                                        style: TextStyle(
                                                          fontFamily:
                                                          'Comfortaa',
                                                          fontWeight:
                                                          FontWeight
                                                              .w700,
                                                          fontSize: 12.sp,
                                                          color: const Color(
                                                              0xFF285430),
                                                        ),
                                                      ),
                                                      onPressed: () {
                                                        Navigator.of(
                                                            context)
                                                            .pop();
                                                      },
                                                    ),
                                                  ],
                                                );
                                              },
                                            );
                                          } else {
                                            _showAddMainCategoryDialog();
                                          }
                                        } else if (value == 1) {
                                          if (selectedGroup == null) {
                                            return showDialog<void>(
                                              context: context,
                                              barrierDismissible: false,
                                              builder:
                                                  (BuildContext context) {
                                                return AlertDialog(
                                                  title: AutoSizeText(
                                                    'Alert',
                                                    textScaleFactor: 1.5.sp,
                                                    style: TextStyle(
                                                      fontFamily:
                                                      'Comfortaa',
                                                      fontWeight:
                                                      FontWeight.w700,
                                                      fontSize: 17.sp,
                                                    ),
                                                  ),
                                                  content:
                                                  SingleChildScrollView(
                                                    child: AutoSizeText(
                                                      'You have not chosen any group. Try choosing a group before managing the category.',
                                                      textScaleFactor:
                                                      1.5.sp,
                                                      style: TextStyle(
                                                        fontFamily:
                                                        'Comfortaa',
                                                        fontWeight:
                                                        FontWeight.w700,
                                                        fontSize: 12.sp,
                                                      ),
                                                      textAlign:
                                                      TextAlign.justify,
                                                    ),
                                                  ),
                                                  actions: <Widget>[
                                                    TextButton(
                                                      child: AutoSizeText(
                                                        'Ok',
                                                        textScaleFactor:
                                                        1.4.sp,
                                                        style: TextStyle(
                                                          fontFamily:
                                                          'Comfortaa',
                                                          fontWeight:
                                                          FontWeight
                                                              .w700,
                                                          fontSize: 12.sp,
                                                          color: const Color(
                                                              0xFF285430),
                                                        ),
                                                      ),
                                                      onPressed: () {
                                                        Navigator.of(
                                                            context)
                                                            .pop();
                                                      },
                                                    ),
                                                  ],
                                                );
                                              },
                                            );
                                          } else {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      ManageCategoryScreen(group: selectedGroup!)),
                                            );
                                          }
                                        }
                                      });
                                    },
                                    icon: const Icon(Icons.more_horiz),
                                  ),
                                ],
                              ),
                              DropdownButtonHideUnderline(
                                child: DropdownButton2<String>(
                                  isExpanded: true,
                                  value: selectedCategory,
                                  items: selectedList
                                      .map((String item) =>
                                      DropdownMenuItem<String>(
                                        value: item,
                                        child: AutoSizeText(
                                          item,
                                          textScaleFactor: 1.0.sp,
                                          style: TextStyle(
                                            fontFamily: 'Comfortaa',
                                            fontWeight: FontWeight.w700,
                                            fontSize: 8.sp,
                                            color: Colors.black,
                                          ),
                                          overflow:
                                          TextOverflow.ellipsis,
                                        ),
                                      ))
                                      .toList(),
                                  onChanged: (String? value) {
                                    setState(() {
                                      selectedCategory = value;
                                    });
                                  },
                                  buttonStyleData: ButtonStyleData(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 15),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(
                                          SizeConfig.widthSize(11) * 0.8),
                                      border: Border.all(
                                        color: Colors.black26,
                                      ),
                                      color: const Color(0xFFE5D9B6),
                                    ),
                                    elevation: 2,
                                  ),
                                  iconStyleData: const IconStyleData(
                                    icon: Icon(
                                      Icons.arrow_forward_ios_outlined,
                                    ),
                                    iconSize: 14,
                                    iconEnabledColor: Colors.black,
                                    iconDisabledColor: Colors.grey,
                                  ),
                                  dropdownStyleData: DropdownStyleData(
                                    maxHeight: 200,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(
                                          SizeConfig.widthSize(11) * 0.8),
                                      color: const Color(0xFFFEF1CC),
                                    ),
                                    offset: const Offset(0, 0),
                                    scrollbarTheme: ScrollbarThemeData(
                                      radius: const Radius.circular(40),
                                      thickness:
                                      WidgetStateProperty.all<double>(
                                          6),
                                      thumbVisibility:
                                      WidgetStateProperty.all<bool>(
                                          true),
                                    ),
                                  ),
                                  menuItemStyleData:
                                  const MenuItemStyleData(
                                    height: 40,
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 15),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: SizeConfig.heightSize(20) * 0.8,
                              ),
                              MediaQuery(
                                data: MediaQuery.of(context).copyWith(
                                    textScaler: TextScaler.linear(1.3.sp)),
                                child: TextField(
                                  controller: _nameController,
                                  decoration: InputDecoration(
                                    labelText: 'Name',
                                    hintText: 'Enter name',
                                    border: const OutlineInputBorder(),
                                    labelStyle: TextStyle(
                                      fontFamily: 'Comfortaa',
                                      fontSize: 9.sp,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  style: TextStyle(
                                    fontFamily: 'Comfortaa',
                                    fontSize: 9.sp,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: SizeConfig.heightSize(10) * 0.8,
                              ),
                              MediaQuery(
                                data: MediaQuery.of(context).copyWith(
                                    textScaler: TextScaler.linear(1.3.sp)),
                                child: TextField(
                                  controller: _amountController,
                                  decoration: InputDecoration(
                                    labelText: 'Amount (RM)',
                                    hintText: 'Enter amount',
                                    border: const OutlineInputBorder(),
                                    labelStyle: TextStyle(
                                      fontFamily: 'Comfortaa',
                                      fontSize: 9.sp,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  style: TextStyle(
                                    fontFamily: 'Comfortaa',
                                    fontSize: 9.sp,
                                    fontWeight: FontWeight.w700,
                                  ),
                                  keyboardType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true),
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(
                                        RegExp(r'^\d*\.?\d{0,2}')),
                                    TextInputFormatter.withFunction(
                                            (oldValue, newValue) {
                                          if (newValue.text.contains(',')) {
                                            return oldValue;
                                          }
                                          if (newValue.text.contains('.')) {
                                            final parts =
                                            newValue.text.split('.');
                                            if (parts.length > 1 &&
                                                parts[1].length > 2) {
                                              return oldValue;
                                            }
                                          }
                                          return newValue;
                                        }),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: SizeConfig.heightSize(10) * 0.8,
                              ),
                              MediaQuery(
                                data: MediaQuery.of(context).copyWith(
                                    textScaler: TextScaler.linear(1.3.sp)),
                                child: TextField(
                                  onTap: () => _selectDate(context),
                                  controller: _dateController,
                                  readOnly: true,
                                  decoration: InputDecoration(
                                    labelText: 'Date',
                                    hintText: 'Select date',
                                    border: const OutlineInputBorder(),
                                    labelStyle: TextStyle(
                                      fontFamily: 'Comfortaa',
                                      fontSize: 9.sp,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  style: TextStyle(
                                    fontFamily: 'Comfortaa',
                                    fontSize: 9.sp,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: SizeConfig.heightSize(10) * 0.8,
                              ),
                              MediaQuery(
                                data: MediaQuery.of(context).copyWith(
                                    textScaler: TextScaler.linear(1.3.sp)),
                                child: TextField(
                                  controller: _toController,
                                  decoration: InputDecoration(
                                    labelText: 'To',
                                    hintText: 'To...',
                                    border: const OutlineInputBorder(),
                                    labelStyle: TextStyle(
                                      fontFamily: 'Comfortaa',
                                      fontSize: 9.sp,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  style: TextStyle(
                                    fontFamily: 'Comfortaa',
                                    fontSize: 9.sp,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: SizeConfig.heightSize(10) * 0.8,
                              ),
                              MediaQuery(
                                data: MediaQuery.of(context).copyWith(
                                    textScaler: TextScaler.linear(1.3.sp)),
                                child: TextField(
                                  maxLines: null,
                                  controller: _descriptionController,
                                  decoration: InputDecoration(
                                    labelText: 'Description',
                                    hintText: 'Enter description',
                                    border: const OutlineInputBorder(),
                                    labelStyle: TextStyle(
                                      fontFamily: 'Comfortaa',
                                      fontSize: 9.sp,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  style: TextStyle(
                                    fontFamily: 'Comfortaa',
                                    fontSize: 9.sp,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: SizeConfig.heightSize(20) * 0.8,
                              ),
                              Container(
                                width: SizeConfig.scaleSize(187),
                                height: SizeConfig.scaleSize(52),
                                decoration: BoxDecoration(boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.45),
                                    blurRadius: 10.0,
                                    offset: const Offset(0, 4),
                                  ),
                                ]),
                                child: ElevatedButton(
                                  onPressed: () async {
                                    try {
                                      if (_nameController.text.isNotEmpty && _amountController.text.isNotEmpty) {
                                        showLoadingDialog(context);
                                        Map<String, dynamic> updatedFields = {
                                          'group': selectedGroup,
                                          'category': selectedCategory,
                                          'name': _nameController.text,
                                          'amount':
                                          _amountController.text,
                                          'date':
                                          _dateController.text,
                                          'to': _toController.text.isEmpty ? 'None' : _toController.text,
                                          'description': _descriptionController.text.isEmpty ? 'None' : _descriptionController.text,
                                        };
                                        await _transactionManager.updateTransactionDetails(
                                            widget.name, updatedFields);

                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder:
                                                  (context) => SuccessScreen(
                                                text: 'Save',
                                                onPress: () {
                                                  if(widget.isFromHomeScreen == true){
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) => ViewTransactionDetailsScreen(name: _nameController.text, isFromHomeScreen: true,),
                                                      ),
                                                    );
                                                  } else {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) => ViewTransactionDetailsScreen(name: _nameController.text, isFromHomeScreen: false,),
                                                      ),
                                                    );
                                                  }
                                                },
                                              )),
                                        );
                                      } else {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                              content: Text('Name, Amount, and Group should not be empty')),
                                        );
                                      }
                                    } catch (e) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(content: Text(e.toString())),
                                      );
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF282828),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                          SizeConfig.widthSize(11) * 0.8),
                                    ),
                                  ),
                                  child: AutoSizeText(
                                    'Save',
                                    textScaleFactor: 1.3.sp,
                                    style: TextStyle(
                                      fontFamily: 'Comfortaa',
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                      fontSize: 8.sp,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                  ],
                ),
              ),
            );
  }
}
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        _dateController.text = DateFormat('dd MMM yyyy').format(picked);
      });
    }
  }
}
