import 'package:auto_size_text/auto_size_text.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:organise_me/components/auth_service.dart';
import 'package:organise_me/screen/list_screen.dart';
import 'package:organise_me/screen/event_screen.dart';
import 'package:organise_me/screen/home_screen.dart';
import 'package:organise_me/screen/manage_category.dart';
import 'package:organise_me/components/profile_picture.dart';
import 'package:organise_me/screen/statistics_screen.dart';
import 'package:organise_me/screen/success_screen.dart';
import 'package:organise_me/components/transaction_manager.dart';
import 'package:organise_me/components/utils.dart';
import 'package:organise_me/screen/welcome_screen.dart';
import 'package:organise_me/components/reusable_text.dart';
import 'package:organise_me/components/reusable_button.dart';
import 'package:organise_me/components/main_category.dart';

class TransactionScreen extends StatefulWidget {
  static String id = 'transaction_screen';

  const TransactionScreen({super.key});

  @override
  State<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  String? username;
  final AuthService _authService = AuthService();

  final ProfilePicture _profilePicture = ProfilePicture();
  bool isLoading = false;

  int currentPageIndex = 1;
  NavigationDestinationLabelBehavior labelBehavior =
      NavigationDestinationLabelBehavior.alwaysShow;
  final List<Widget> destinations = [];

  Future<void> _loadUsername() async {
    String? fetchedUsername = await _authService.getUsername();
    setState(() {
      username = fetchedUsername;
    });
  }


  final DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _toController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  late TransactionManager _transactionManager;
  late MainCategory _mainCategory;
  String? selectedCategory;
  String? selectedSubcategory;
  late Future<void> _categories;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _dateController.text = DateFormat('dd MMM yyyy').format(DateTime.now());
    _transactionManager = TransactionManager();
    _mainCategory = MainCategory();
    _categories = _fetchCategories();
    _profilePicture.setUpdateCallback(() {
      setState(() {});
    });
    _profilePicture.loadProfilePicture(isLoading);
    _loadUsername();
  }

  Future<void> _fetchCategories() async {
    await _mainCategory.fetchCategories();
    setState(() {});
  }

  @override
  void dispose() {
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

  List<String> selectedList = [];

  bool addCatLoading = false;

  void _showAddMainCategoryDialog() {
    TextEditingController mainCategoryController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
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
                child: addCatLoading
                    ? const Center(child: CircularProgressIndicator())
                    : TextField(
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
                    if (mainCategoryController.text != "") {
                      setState(() {
                        addCatLoading = true;
                      });

                      if (selectedGroup == "Expenses") {
                        await _mainCategory
                            .addExpensesCategory(mainCategoryController.text);
                        _fetchCategories();
                        this.setState(() {
                          selectedList = _mainCategory.expensesCategory;
                        });
                      } else if (selectedGroup == "Income") {
                        await _mainCategory
                            .addIncomeCategory(mainCategoryController.text);
                        _fetchCategories();
                        this.setState(() {
                          selectedList = _mainCategory.incomeCategory;
                        });
                      } else if (selectedGroup == "Debt") {
                        await _mainCategory
                            .addDebtCategory(mainCategoryController.text);
                        _fetchCategories();
                        this.setState(() {
                          selectedList = _mainCategory.debtCategory;
                        });
                      } else if (selectedGroup == "Savings") {
                        await _mainCategory
                            .addSavingsCategory(mainCategoryController.text);
                        _fetchCategories();
                        this.setState(() {
                          selectedList = _mainCategory.savingsCategory;
                        });
                      } else if (selectedGroup == "Investment") {
                        await _mainCategory
                            .addInvestmentCategory(mainCategoryController.text);
                        _fetchCategories();
                        this.setState(() {
                          selectedList = _mainCategory.investmentCategory;
                        });
                      }

                      setState(() {
                        addCatLoading = false;
                      });

                      Navigator.of(context).pop();
                    }else {
                      Navigator.of(context).pop();
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: PopScope(
        canPop: false,
        child: Scaffold(
          backgroundColor: const Color(0xFFF8F2ED),
          appBar: AppBar(
            backgroundColor: const Color(0xFFA4BE7B),
            leading: Builder(
              builder: (context) {
                return IconButton(
                  color: Colors.white,
                  tooltip:
                      MaterialLocalizations.of(context).openAppDrawerTooltip,
                  icon: const Icon(Icons.menu),
                  onPressed: () {
                    Scaffold.of(context).openDrawer();
                  },
                );
              },
            ),
            title: Center(
              child: AutoSizeText(
                'Add',
                textScaleFactor: 1.5.sp,
                style: TextStyle(
                  fontFamily: 'Comfortaa',
                  fontWeight: FontWeight.w700,
                  fontSize: 15.sp,
                  color: Colors.white,
                ),
              ),
            ),
            actions: [
              IconButton(
                tooltip: 'Logout',
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: AutoSizeText(
                          textScaleFactor: 1.4.sp,
                          'Logout',
                          style: TextStyle(
                              fontFamily: 'Comfortaa', fontSize: 12.sp, fontWeight: FontWeight.w700),
                        ),
                        content: AutoSizeText(
                          textScaleFactor: 1.3.sp,
                          'Are you sure you want to logout?',
                          style: TextStyle(fontFamily: 'Comfortaa', fontSize: 12.sp, fontWeight: FontWeight.w700),
                        ),
                        actions: <Widget>[
                          TextButton(
                            child: AutoSizeText(
                              textScaleFactor: 1.2.sp,
                              'Cancel',
                              style: TextStyle(fontFamily: 'Comfortaa', fontSize: 12.sp, fontWeight: FontWeight.w700),
                            ),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                          TextButton(
                            child: AutoSizeText(
                              textScaleFactor: 1.2.sp,
                              'Logout',
                              style: TextStyle(fontFamily: 'Comfortaa', fontSize: 12.sp, fontWeight: FontWeight.w700),
                            ),
                            onPressed: () async {
                              Navigator.of(context).pop();
                              await _authService.logout();
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                    const WelcomeScreen()),
                              );
                            },
                          ),
                        ],
                      );
                    },
                  );
                },
                icon: const Icon(Icons.logout, color: Colors.white),
              ),
            ],
          ),
          bottomNavigationBar: NavigationBarTheme(
            data: NavigationBarThemeData(
              labelTextStyle: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return const TextStyle(
                    fontFamily: 'Comfortaa',
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF285430),
                  );
                }
                return const TextStyle(
                  fontFamily: 'Comfortaa',
                  fontSize: 12,
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                );
              }),
            ),
            child: NavigationBar(
              labelBehavior: labelBehavior,
              selectedIndex: currentPageIndex,
              onDestinationSelected: (int index) {
                setState(() {
                  currentPageIndex = index;
                  switch (index) {
                    case 0:
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const HomeScreen()),
                      );
                      break;
                    case 1:
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const ListScreen()),
                      );
                      break;
                    case 2:
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const StatisticsScreen()),
                      );
                      break;
                  }
                });
              },
              indicatorColor: const Color(0xFF285430),
              backgroundColor: const Color(0xFFA4BE7B),
              destinations: const [
                NavigationDestination(
                  selectedIcon: Icon(
                    Icons.home,
                    color: Colors.white,
                  ),
                  icon: Icon(
                    Icons.home_outlined,
                    color: Colors.white,
                  ),
                  label: 'Home',
                ),
                NavigationDestination(
                  selectedIcon: Icon(
                    Icons.add_box,
                    color: Colors.white,
                  ),
                  icon: Icon(
                    Icons.add_box_outlined,
                    color: Colors.white,
                  ),
                  label: 'Add',
                ),
                NavigationDestination(
                  selectedIcon: Icon(
                    Icons.bar_chart,
                    color: Colors.white,
                  ),
                  icon: Icon(
                    Icons.bar_chart_outlined,
                    color: Colors.white,
                  ),
                  label: 'Statistics',
                ),
              ],
            ),
          ),
          drawer: Drawer(
            backgroundColor: const Color(0xFFF8F2ED),
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                DrawerHeader(
                  decoration: const BoxDecoration(
                    color: Color(0xFFA4BE7B),
                  ),
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          _profilePicture.showOptions(context, isLoading);
                        },
                        child: Stack(
                          alignment: AlignmentDirectional.bottomEnd,
                          children: [
                            CircleAvatar(
                              backgroundColor: Colors.grey,
                              radius: 40,
                              backgroundImage:
                              _profilePicture.profilePictureUrl == null
                                  ? null
                                  : NetworkImage(
                                  _profilePicture.profilePictureUrl!),
                              child: _profilePicture.profilePictureUrl == null
                                  ? const Icon(Icons.person_rounded,
                                  color: Colors.black38)
                                  : null,
                            ),
                            const Icon(Icons.camera_alt, color: Colors.white,),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: SizeConfig.heightSize(10) * 0.8,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AutoSizeText(
                            '$username',
                            textScaleFactor: 1.3.sp,
                            style: TextStyle(
                              fontFamily: 'Comfortaa',
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          IconButton(
                              tooltip: 'Edit Username',
                              onPressed: () {
                                _displayNameEditDialog(context, 'username');
                              },
                              icon: const Icon(Icons.edit, color: Colors.white,)),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: SizeConfig.heightSize(20) * 0.8,
                ),
                ListTile(
                  leading: const Icon(Icons.home_outlined),
                  title: AutoSizeText(
                    'Home',
                    textScaleFactor: 1.3.sp,
                    style: TextStyle(
                      fontFamily: 'Comfortaa',
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const HomeScreen()),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.add_box_outlined),
                  title: AutoSizeText(
                    'Add',
                    textScaleFactor: 1.3.sp,
                    style: TextStyle(
                      fontFamily: 'Comfortaa',
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  onTap: () {},
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40.0,
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.task),
                        title: AutoSizeText(
                          'Tasks',
                          textScaleFactor: 1.3.sp,
                          style: TextStyle(
                            fontFamily: 'Comfortaa',
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const ListScreen()),
                          );
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.calendar_month),
                        title: AutoSizeText(
                          'Events',
                          textScaleFactor: 1.3.sp,
                          style: TextStyle(
                            fontFamily: 'Comfortaa',
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const EventScreen()),
                          );
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.monetization_on),
                        title: AutoSizeText(
                          'Transactions',
                          textScaleFactor: 1.3.sp,
                          style: TextStyle(
                            fontFamily: 'Comfortaa',
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                const TransactionScreen()),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.bar_chart_outlined),
                  title: AutoSizeText(
                    'Statistics',
                    textScaleFactor: 1.3.sp,
                    style: TextStyle(
                      fontFamily: 'Comfortaa',
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const StatisticsScreen()),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.logout_outlined),
                  title: AutoSizeText(
                    'Logout',
                    textScaleFactor: 1.3.sp,
                    style: TextStyle(
                      fontFamily: 'Comfortaa',
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: AutoSizeText(
                            textScaleFactor: 1.4.sp,
                            'Logout',
                            style: TextStyle(
                                fontFamily: 'Comfortaa', fontSize: 12.sp, fontWeight: FontWeight.w700),
                          ),
                          content: AutoSizeText(
                            textScaleFactor: 1.3.sp,
                            'Are you sure you want to logout?',
                            style: TextStyle(fontFamily: 'Comfortaa', fontSize: 12.sp, fontWeight: FontWeight.w700),
                          ),
                          actions: <Widget>[
                            TextButton(
                              child: AutoSizeText(
                                textScaleFactor: 1.2.sp,
                                'Cancel',
                                style: TextStyle(fontFamily: 'Comfortaa', fontSize: 12.sp, fontWeight: FontWeight.w700),
                              ),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                            TextButton(
                              child: AutoSizeText(
                                textScaleFactor: 1.2.sp,
                                'Logout',
                                style: TextStyle(fontFamily: 'Comfortaa', fontSize: 12.sp, fontWeight: FontWeight.w700),
                              ),
                              onPressed: () async {
                                Navigator.of(context).pop();
                                await _authService.logout();
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                      const WelcomeScreen()),
                                );
                              },
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
          body: FutureBuilder(
              future: _categories,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (snapshot.hasError) {
                  return const Center(
                    child: Text('Error fetching lists'),
                  );
                } else {
                  return CustomScrollView(
                    slivers: [
                      SliverAppBar(
                        pinned: true,
                        backgroundColor: const Color(0xFFF8F2ED),
                        leading: Container(),
                        flexibleSpace: FlexibleSpaceBar(
                          background: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10.0),
                            child: Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceEvenly,
                              children: [
                                ReusableButton(
                                  text: 'Tasks',
                                  backgroundColor: const Color(0xFFE5D9B6),
                                  textColor: Colors.black,
                                  onPress: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const ListScreen()),
                                    );
                                  },
                                ),
                                ReusableButton(
                                  text: 'Events',
                                  backgroundColor: const Color(0xFFE5D9B6),
                                  textColor: Colors.black,
                                  onPress: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const EventScreen()),
                                    );
                                  },
                                ),
                                ReusableButton(
                                  text: 'Transactions',
                                  backgroundColor: const Color(0xFF7D8F69),
                                  textColor: Colors.white,
                                  onPress: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const TransactionScreen()),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SliverList(
                        delegate: SliverChildListDelegate(
                          [
                            SizedBox(
                              height: SizeConfig.heightSize(15) * 0.8,
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 15.0,
                              ),
                              child: Column(
                                children: [
                                  Container(
                                    alignment: Alignment.centerLeft,
                                    child: AutoSizeText(
                                      'Add New Transaction',
                                      textScaleFactor: 1.5.sp,
                                      style: TextStyle(
                                        fontFamily: 'Comfortaa',
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14.sp,
                                      ),
                                    ),
                                  ),
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
                                                selectedList =
                                                    determineCategory(
                                                        selectedGroup!);
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
                                                    100.0, 290.0, 0.0, 0.0),
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
                                                          ManageCategoryScreen(
                                                              group:
                                                                  selectedGroup!)),
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
                                      value: selectedCategory,
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
                                        prefixIcon:
                                            const Icon(Icons.calendar_month),
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
                                        labelText: 'To (Optional)',
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
                                      controller: _descriptionController,
                                      decoration: InputDecoration(
                                        labelText: 'Description (Optional)',
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
                                      maxLines: 3,
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
                                        String? group = selectedGroup;
                                        String? category = selectedCategory;
                                        String name = _nameController.text;
                                        String amount = _amountController.text;
                                        String date = _dateController.text;
                                        String to = _toController.text.isEmpty ? 'None' : _toController.text;
                                        String description = _descriptionController.text.isEmpty ? 'None' : _descriptionController.text;

                                        if (group != null && group.isNotEmpty && category != null && category.isNotEmpty && name.isNotEmpty && amount.isNotEmpty) {
                                          await _transactionManager
                                              .addTransaction(
                                                  group,
                                                  category,
                                                  name,
                                                  amount,
                                                  date,
                                                  to,
                                                  description);
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => SuccessScreen(text: 'Transaction Added',
                                                      onPress: () {
                                                        Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                            builder: (context) =>
                                                                const TransactionScreen(),
                                                          ),
                                                        );
                                                      }),
                                            ),
                                          );
                                        } else {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                                content: Text(
                                                    'Name, Amount, Group, and Category should not be empty')),
                                          );
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            const Color(0xFF282828),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                              SizeConfig.widthSize(11) * 0.8),
                                        ),
                                      ),
                                      child: AutoSizeText(
                                        'Add Transaction',
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
                                  SizedBox(
                                    height: SizeConfig.heightSize(30) * 0.8,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }
              }),
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

  Future<String?> _displayNameEditDialog(
      BuildContext context, String text) async {
    TextEditingController controller = TextEditingController(text: '$username');
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: AutoSizeText(
            'Edit Username',
            textScaleFactor: 1.1.sp,
            style: TextStyle(
              fontFamily: 'Comfortaa',
              fontWeight: FontWeight.w700,
              fontSize: 17.sp,
            ),
          ),
          content: MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: TextScaler.linear(1.1.sp)),
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: "Enter New Username",
                hintStyle: TextStyle(
                  fontFamily: 'Comfortaa',
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: AutoSizeText(
                'Cancel',
                textScaleFactor: 1.1.sp,
                style: TextStyle(
                  fontFamily: 'Comfortaa',
                  fontWeight: FontWeight.w700,
                  fontSize: 12.sp,
                  color: const Color(0xFF285430),
                ),
              ),
              onPressed: () {
                Navigator.pop(context, null);
              },
            ),
            TextButton(
              child: AutoSizeText(
                'Save Change',
                textScaleFactor: 1.1.sp,
                style: TextStyle(
                  fontFamily: 'Comfortaa',
                  fontWeight: FontWeight.w700,
                  fontSize: 12.sp,
                  color: const Color(0xFF285430),
                ),
              ),
              onPressed: () async {
                await _authService.updateUsername(controller.text);
                setState(() {
                  _loadUsername();
                });
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }
}
