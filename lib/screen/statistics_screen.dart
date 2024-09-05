import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:month_year_picker/month_year_picker.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:organise_me/components/auth_service.dart';
import 'package:organise_me/screen/list_screen.dart';
import 'package:organise_me/screen/event_screen.dart';
import 'package:organise_me/screen/home_screen.dart';
import 'package:organise_me/components/profile_picture.dart';
import 'package:organise_me/components/reusable_button.dart';
import 'package:organise_me/components/statistics_manager.dart';
import 'package:organise_me/screen/transaction_screen.dart';
import 'package:organise_me/components/utils.dart';
import 'package:organise_me/screen/welcome_screen.dart';
import 'package:pie_chart/pie_chart.dart' as pc;

class StatisticsScreen extends StatefulWidget {
  static String id = 'statistics_screen';

  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  String? username;
  final AuthService _authService = AuthService();

  final ProfilePicture _profilePicture = ProfilePicture();
  bool isLoading = false;

  int currentPageIndex = 2;
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
  final TextEditingController _yearController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();
  final TextEditingController _startTimeController = TextEditingController();
  final TextEditingController _endTimeController = TextEditingController();

  double? totalExpenses;
  double? totalIncome;
  double? totalDebt;
  double? totalSavings;
  double? totalInvestment;

  DateTime? _selected;

  Map<String, double> groupDataMap = {};
  Map<String, double> expensesDataMap = {};
  Map<String, double> incomeDataMap = {};
  Map<String, double> debtDataMap = {};
  Map<String, double> savingsDataMap = {};
  Map<String, double> investmentDataMap = {};

  final groupColorList = <Color>[
    Colors.deepOrangeAccent,
    Colors.greenAccent,
    const Color(0xFFF6A5FF),
    Colors.lightBlue,
    Colors.yellow,
  ];

  final expensesColorList = <Color>[];
  final incomeColorList = <Color>[];
  final debtColorList = <Color>[];
  final savingsColorList = <Color>[];
  final investmentColorList = <Color>[];

  List<Color> generateColorList(String selectedGroup) {
    List<Color> colorList;
    Map<String, double> dataMap;

    switch (selectedGroup) {
      case 'Expenses':
        colorList = expensesColorList;
        dataMap = expensesDataMap;
        break;
      case 'Income':
        colorList = incomeColorList;
        dataMap = incomeDataMap;
        break;
      case 'Debt':
        colorList = debtColorList;
        dataMap = debtDataMap;
        break;
      case 'Savings':
        colorList = savingsColorList;
        dataMap = savingsDataMap;
        break;
      case 'Investments':
        colorList = investmentColorList;
        dataMap = investmentDataMap;
        break;
      default:
        colorList = expensesColorList;
        dataMap = expensesDataMap;
    }

    if (dataMap.isEmpty) {
      dataMap = {'No Data': 0.0}; // Default value to indicate no data
    }

    while (colorList.length < dataMap.length) {
      Color newColor = getRandomColor();
      while (!isSuitableForBlackText(newColor) || isSimilarToExistingColors(newColor, colorList)) {
        newColor = getRandomColor();
      }
      colorList.add(newColor);
    }

    return colorList;
  }

  late StatisticsManager _statisticsManager;
  late Future<void> _statistics;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _dateController.text = DateFormat('MMM yyyy').format(DateTime.now());
    _yearController.text = DateFormat('yyyy').format(DateTime.now());
    _endDateController.text = DateFormat('dd MMM yyyy').format(DateTime.now());
    _startTimeController.text = _formatTimeOfDay(TimeOfDay.now());
    _endTimeController.text = _formatTimeOfDay(TimeOfDay.now());
    _profilePicture.setUpdateCallback(() {
      setState(() {});
    });
    _profilePicture.loadProfilePicture(isLoading);
    _loadUsername();
    _statisticsManager = StatisticsManager();
    _statistics = _statisticsManager.calcTotal(
        _dateController.text,
        updateGroupPieChart,
        updateExpensesPieChart,
        updateIncomePieChart,
        updateDebtPieChart,
        updateSavingsPieChart,
        updateInvestmentPieChart);
  }

  void updateGroupPieChart() {
    setState(() {
      groupDataMap = {
        if (_statisticsManager.totalExpenses != 0.0)
          "Expenses": _statisticsManager.totalExpenses,
        if (_statisticsManager.totalIncome != 0.0)
          "Income": _statisticsManager.totalIncome,
        if (_statisticsManager.totalDebt != 0.0)
          "Debt": _statisticsManager.totalDebt,
        if (_statisticsManager.totalSavings != 0.0)
          "Savings": _statisticsManager.totalSavings,
        if (_statisticsManager.totalInvestment != 0.0)
          "Investment": _statisticsManager.totalInvestment,
      };
    });
  }

  void updateExpensesPieChart() {
    setState(() {
      final filteredExpenses = _statisticsManager.expenses.entries
          .where((entry) => entry.value != 0.0)
          .toList();

      if (filteredExpenses.isNotEmpty) {
        expensesDataMap = Map.fromEntries(filteredExpenses);
      } else {
        expensesDataMap = {'No Data': 0.0};
      }
    });
  }

  void updateIncomePieChart() {
    setState(() {
      final filteredIncome = _statisticsManager.income.entries
          .where((entry) => entry.value != 0.0)
          .toList();

      if (filteredIncome.isNotEmpty) {
        incomeDataMap = Map.fromEntries(filteredIncome);
      } else {
        incomeDataMap = {'No Data': 0.0};
      }
    });
  }

  void updateDebtPieChart() {
    setState(() {
      final filteredDebt = _statisticsManager.debt.entries
          .where((entry) => entry.value != 0.0)
          .toList();

      if (filteredDebt.isNotEmpty) {
        debtDataMap = Map.fromEntries(filteredDebt);
      } else {
        debtDataMap = {'No Data': 0.0};
      }
    });
  }

  void updateSavingsPieChart() {
    setState(() {
      final filteredSavings = _statisticsManager.savings.entries
          .where((entry) => entry.value != 0.0)
          .toList();

      if (filteredSavings.isNotEmpty) {
        savingsDataMap = Map.fromEntries(filteredSavings);
      } else {
        savingsDataMap = {'No Data': 0.0};
      }
    });
  }

  void updateInvestmentPieChart() {
    setState(() {
      final filteredInvestment = _statisticsManager.investment.entries
          .where((entry) => entry.value != 0.0)
          .toList();

      if (filteredInvestment.isNotEmpty) {
        investmentDataMap = Map.fromEntries(filteredInvestment);
      } else {
        investmentDataMap = {'No Data': 0.0};
      }
    });
  }

  Map<String, double> updateSelectedPieChart(String selectedGroup) {
    Map<String, double> selectedDataMap;

    switch (selectedGroup) {
      case 'Expenses':
        selectedDataMap = expensesDataMap;
        break;
      case 'Income':
        selectedDataMap = incomeDataMap;
        break;
      case 'Debt':
        selectedDataMap = debtDataMap;
        break;
      case 'Savings':
        selectedDataMap = savingsDataMap;
        break;
      case 'Investment':
        selectedDataMap = investmentDataMap;
        break;
      default:
        selectedDataMap = {'No Data': 0.0}; // Default value to indicate no data
    }

    if (selectedDataMap.isEmpty) {
      selectedDataMap = {'No Data': 0.0}; // Default value to indicate no data
    }

    return selectedDataMap;
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    final format = DateFormat.jm();
    return format.format(dt);
  }

  @override
  void dispose() {
    _dateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }

  String? selectedMainCategory;

  String? selectedSubcategories;

  Color getRandomColor() {
    final Random random = Random();
    return Color.fromARGB(
      255,
      random.nextInt(256),
      random.nextInt(256),
      random.nextInt(256),
    );
  }

  bool isSuitableForBlackText(Color color) {
    // Using relative luminance to check brightness
    double luminance =
        (0.299 * color.red + 0.587 * color.green + 0.114 * color.blue) / 255;
    return luminance > 0.5; // Bright enough for black text
  }

  bool isSimilarToExistingColors(Color newColor, List<Color> existingColors) {
    const double threshold = 100.0;
    for (Color color in existingColors) {
      if (colorDifference(newColor, color) < threshold) {
        return true;
      }
    }
    return false;
  }

  double colorDifference(Color c1, Color c2) {
    // Using Euclidean distance in RGB space
    return sqrt(pow(c1.red - c2.red, 2) +
        pow(c1.green - c2.green, 2) +
        pow(c1.blue - c2.blue, 2));
  }

  final List<String> group = [
    'Expenses',
    'Income',
    'Debt',
    'Savings',
    'Investment',
  ];
  String? selectedGroup;

  String? selectedGroupForMonth;

  DateTime? _selectedYear;

  List<BarChartGroupData> barChartData = [];

  void updateBarChart() {
    setState(() {
      barChartData = [];
      if (selectedGroupForMonth != null) {
        List<double>? monthlyData =
            _statisticsManager.monthlyTotals[selectedGroupForMonth];
        if (monthlyData != null) {
          for (int i = 0; i < 12; i++) {
            barChartData.add(BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: double.parse(monthlyData[i].toStringAsFixed(2)),
                  color: const Color(0xFF5F8D4E),
                  width: 16,
                ),
              ],
            ));
          }
        }
      }
    });
  }

  void _onYearGroupChanged() {
    if (selectedGroupForMonth != null) {
      _statisticsManager.calcMonthlyTotals(
          _yearController.text, updateBarChart);
    }
  }

  List<double> dailyTotals = [];

  void updateLineChart(List<double> newDailyTotals) {
    setState(() {
      dailyTotals = newDailyTotals;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Color> pieChartColors = generateColorList(selectedGroup ?? 'default');
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
                'Statistics',
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
              future: _statistics,
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
                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: AutoSizeText(
                            'Summary',
                            textScaleFactor: 1.5.sp,
                            style: TextStyle(
                              fontFamily: 'Comfortaa',
                              fontWeight: FontWeight.w700,
                              fontSize: 14.sp,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: double.infinity,
                          child: ReusableButton(
                            text: _dateController.text,
                            backgroundColor: const Color(0xFFFEF1CC),
                            textColor: Colors.black,
                            onPress: () async => _onPressed(context: context),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFFAF7F5),
                              borderRadius: BorderRadius.circular(
                                  SizeConfig.widthSize(11) * 0.8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.5),
                                  spreadRadius: 5,
                                  blurRadius: 7,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: SizedBox(
                                width: double.infinity,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    AutoSizeText(
                                      'Total Expenses: RM ${_statisticsManager.totalExpenses
                                              .toStringAsFixed(2)}',
                                      textScaleFactor: 1.1.sp,
                                      style: TextStyle(
                                        fontFamily: 'Comfortaa',
                                        fontWeight: FontWeight.w700,
                                        fontSize: 10.sp,
                                      ),
                                    ),
                                    SizedBox(
                                        height:
                                            SizeConfig.heightSize(10) * 0.8),
                                    AutoSizeText(
                                      'Total Income: RM ${_statisticsManager.totalIncome
                                              .toStringAsFixed(2)}',
                                      textScaleFactor: 1.1.sp,
                                      style: TextStyle(
                                        fontFamily: 'Comfortaa',
                                        fontWeight: FontWeight.w700,
                                        fontSize: 10.sp,
                                      ),
                                    ),
                                    SizedBox(
                                        height:
                                            SizeConfig.heightSize(10) * 0.8),
                                    AutoSizeText(
                                      'Total Debt: RM ${_statisticsManager.totalDebt
                                              .toStringAsFixed(2)}',
                                      textScaleFactor: 1.1.sp,
                                      style: TextStyle(
                                        fontFamily: 'Comfortaa',
                                        fontWeight: FontWeight.w700,
                                        fontSize: 10.sp,
                                      ),
                                    ),
                                    SizedBox(
                                        height:
                                            SizeConfig.heightSize(10) * 0.8),
                                    AutoSizeText(
                                      'Total Savings: RM ${_statisticsManager.totalSavings
                                              .toStringAsFixed(2)}',
                                      textScaleFactor: 1.1.sp,
                                      style: TextStyle(
                                        fontFamily: 'Comfortaa',
                                        fontWeight: FontWeight.w700,
                                        fontSize: 10.sp,
                                      ),
                                    ),
                                    SizedBox(
                                        height:
                                            SizeConfig.heightSize(10) * 0.8),
                                    AutoSizeText(
                                      'Total Investment: RM ${_statisticsManager.totalInvestment
                                              .toStringAsFixed(2)}',
                                      textScaleFactor: 1.1.sp,
                                      style: TextStyle(
                                        fontFamily: 'Comfortaa',
                                        fontWeight: FontWeight.w700,
                                        fontSize: 10.sp,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFFAF7F5),
                              borderRadius: BorderRadius.circular(
                                  SizeConfig.widthSize(11) * 0.8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.5),
                                  spreadRadius: 5,
                                  blurRadius: 7,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                SizedBox(
                                    height: SizeConfig.heightSize(30) * 0.8),
                                MediaQuery(
                                  data: MediaQuery.of(context).copyWith(
                                      textScaler: TextScaler.linear(1.3.sp)),
                                  child: pc.PieChart(
                                    dataMap: groupDataMap.isNotEmpty ? groupDataMap : {'No Data': 0.0},
                                    animationDuration: const Duration(seconds: 1),
                                    chartLegendSpacing: 40,
                                    chartRadius:
                                        MediaQuery.of(context).size.width / 2.0,
                                    colorList: groupColorList,
                                    initialAngleInDegree: 0,
                                    chartType: pc.ChartType.ring,
                                    ringStrokeWidth: 32,
                                    centerText: "Total (RM)",
                                    centerTextStyle: const TextStyle(
                                      fontFamily: 'Comfortaa',
                                      color: Colors.black,
                                      fontWeight: FontWeight.w700,
                                    ),
                                    legendOptions: pc.LegendOptions(
                                      showLegendsInRow: true,
                                      legendPosition: pc.LegendPosition.bottom,
                                      showLegends: true,
                                      legendTextStyle: TextStyle(
                                        fontFamily: 'Comfortaa',
                                        fontWeight: FontWeight.w700,
                                        fontSize: 11.sp,
                                      ),
                                      legendShape: BoxShape.rectangle,
                                    ),
                                    chartValuesOptions: pc.ChartValuesOptions(
                                      showChartValueBackground: true,
                                      chartValueBackgroundColor: Colors.white38,
                                      showChartValues: true,
                                      showChartValuesInPercentage: false,
                                      showChartValuesOutside: true,
                                      decimalPlaces: 2,
                                      chartValueStyle: TextStyle(
                                        fontFamily: 'Comfortaa',
                                        fontWeight: FontWeight.w700,
                                        fontSize: 15.sp,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFFAF7F5),
                              borderRadius: BorderRadius.circular(
                                  SizeConfig.widthSize(11) * 0.8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.5),
                                  spreadRadius: 5,
                                  blurRadius: 7,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                DropdownButtonHideUnderline(
                                  child: DropdownButton2<String>(
                                    isExpanded: true,
                                    hint: AutoSizeText(
                                      'Select Category',
                                      textScaleFactor: 1.0.sp,
                                      style: TextStyle(
                                        fontFamily: 'Comfortaa',
                                        fontWeight: FontWeight.w700,
                                        fontSize: 8.sp,
                                        color: Colors.black,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    value: selectedGroup,
                                    onChanged: (String? newValue) {
                                      setState(() {
                                        selectedGroup = newValue!;
                                        _statisticsManager.calcTotal(
                                            _dateController.text,
                                            updateGroupPieChart,
                                            updateExpensesPieChart,
                                            updateIncomePieChart,
                                            updateDebtPieChart,
                                            updateSavingsPieChart,
                                            updateInvestmentPieChart);
                                        _statisticsManager.calcDailyTotals(
                                            _dateController.text,
                                            selectedGroup!,
                                            updateLineChart);
                                      });
                                    },
                                    items: group.map<DropdownMenuItem<String>>(
                                        (String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: AutoSizeText(
                                          textScaleFactor: 1.0.sp,
                                          value,
                                          style: TextStyle(
                                              fontFamily: 'Comfortaa',
                                              fontSize: 8.sp, fontWeight: FontWeight.w700),
                                        ),
                                      );
                                    }).toList(),
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
                                        color: const Color(0xFFA4BE7B),
                                      ),
                                      elevation: 2,
                                    ),
                                    iconStyleData: const IconStyleData(
                                      icon: Icon(
                                        Icons.expand_more,
                                      ),
                                      iconSize: 18,
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
                                            WidgetStateProperty.all<double>(6),
                                        thumbVisibility:
                                            WidgetStateProperty.all<bool>(true),
                                      ),
                                    ),
                                    menuItemStyleData: const MenuItemStyleData(
                                      height: 40,
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 15),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                    height: SizeConfig.heightSize(30) * 0.8),
                                MediaQuery(
                                  data: MediaQuery.of(context).copyWith(
                                      textScaler: TextScaler.linear(1.3.sp)),
                                  child: pc.PieChart(
                                    dataMap: updateSelectedPieChart(
                                        selectedGroup ?? 'default').isNotEmpty ? updateSelectedPieChart(
                                        selectedGroup ?? 'default') : {'No Data': 0.0},
                                    animationDuration: const Duration(seconds: 1),
                                    chartLegendSpacing: 40,
                                    chartRadius:
                                        MediaQuery.of(context).size.width / 2.0,
                                    colorList: pieChartColors,
                                    initialAngleInDegree: 0,
                                    chartType: pc.ChartType.ring,
                                    ringStrokeWidth: 32,
                                    centerText: "Total (RM)",
                                    centerTextStyle: const TextStyle(
                                      fontFamily: 'Comfortaa',
                                      color: Colors.black,
                                      fontWeight: FontWeight.w700,
                                    ),
                                    legendOptions: pc.LegendOptions(
                                      showLegendsInRow: true,
                                      legendPosition: pc.LegendPosition.bottom,
                                      showLegends: true,
                                      legendTextStyle: TextStyle(
                                        fontFamily: 'Comfortaa',
                                        fontWeight: FontWeight.w700,
                                        fontSize: 11.sp,
                                      ),
                                      legendShape: BoxShape.rectangle,
                                    ),
                                    chartValuesOptions: pc.ChartValuesOptions(
                                      showChartValueBackground: true,
                                      chartValueBackgroundColor: Colors.white38,
                                      showChartValues: true,
                                      showChartValuesInPercentage: false,
                                      showChartValuesOutside: true,
                                      decimalPlaces: 2,
                                      chartValueStyle: TextStyle(
                                        fontFamily: 'Comfortaa',
                                        fontWeight: FontWeight.w700,
                                        fontSize: 15.sp,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFFAF7F5),
                              borderRadius: BorderRadius.circular(
                                  SizeConfig.widthSize(11) * 0.8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.5),
                                  spreadRadius: 5,
                                  blurRadius: 7,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                SizedBox(
                                    height: SizeConfig.heightSize(10) * 0.8),
                                AutoSizeText(
                                  textScaleFactor: 1.1.sp,
                                  '${_dateController.text}\'s Summary For $selectedGroup',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontFamily: 'Comfortaa',
                                    fontSize: 12.sp,
                                  ),
                                ),
                                SizedBox(
                                    height: SizeConfig.heightSize(30) * 0.8),
                                Container(
                                  height: 300,
                                  padding: const EdgeInsets.all(10.0),
                                  child: LineChart(
                                    LineChartData(
                                      lineBarsData: [
                                        LineChartBarData(
                                          spots: dailyTotals
                                              .asMap()
                                              .entries
                                              .map((e) {
                                            return FlSpot(
                                                e.key.toDouble(),
                                                double.parse(e.value
                                                    .toStringAsFixed(2)));
                                          }).toList(),
                                          color: const Color(0xFF5F8D4E),
                                          dotData: const FlDotData(show: true),
                                        ),
                                      ],
                                      titlesData: FlTitlesData(
                                        leftTitles: AxisTitles(
                                          sideTitles: SideTitles(
                                            showTitles: true,
                                            reservedSize: 32,
                                            getTitlesWidget: (value, meta) {
                                              return SideTitleWidget(
                                                axisSide: meta.axisSide,
                                                space: 8.0,
                                                child: AutoSizeText(
                                                  textScaleFactor: 0.75.sp,
                                                  value.toStringAsFixed(
                                                      0),
                                                  style: TextStyle(
                                                      fontSize: 8.sp,
                                                      color: Colors.black,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      fontFamily: 'Comfortaa'),
                                                ),
                                              );
                                            },
                                          ),
                                          axisNameWidget: Padding(
                                            padding: const EdgeInsets.only(
                                                left: 8.0),
                                            child: AutoSizeText(
                                              textScaleFactor: 0.75.sp,
                                              'Total (RM)',
                                              style: TextStyle(
                                                  fontSize: 10.sp,
                                                  fontWeight: FontWeight.w700,
                                                  fontFamily: 'Comfortaa'),
                                            ),
                                          ),
                                          axisNameSize: 10,
                                        ),
                                        bottomTitles: AxisTitles(
                                          sideTitles: SideTitles(
                                            showTitles: true,
                                            interval: 2,
                                            reservedSize: 22,
                                            getTitlesWidget: (value, meta) {
                                              final day = value.toInt() + 1;
                                              return SideTitleWidget(
                                                axisSide: meta.axisSide,
                                                space: 8.0,
                                                child: AutoSizeText(
                                                  textScaleFactor: 0.5.sp,
                                                  day.toString(),
                                                  style: TextStyle(
                                                      fontSize: 8.sp,
                                                      color: Colors.black,
                                                      fontFamily: 'Comfortaa',
                                                      fontWeight:
                                                          FontWeight.w700),
                                                ),
                                              );
                                            },
                                          ),
                                          axisNameWidget: AutoSizeText(
                                            textScaleFactor: 0.75.sp,
                                            'Day',
                                            style: TextStyle(
                                                fontSize: 10.sp,
                                                fontWeight: FontWeight.w700,
                                                fontFamily: 'Comfortaa'),
                                          ),
                                          axisNameSize: 16,
                                        ),
                                        rightTitles: const AxisTitles(
                                            sideTitles:
                                                SideTitles(showTitles: false)),
                                        topTitles: const AxisTitles(
                                            sideTitles:
                                                SideTitles(showTitles: false)),
                                      ),
                                      borderData: FlBorderData(
                                        show: true,
                                        border: const Border(
                                          left: BorderSide(
                                              color: Colors.black, width: 1),
                                          bottom: BorderSide(
                                              color: Colors.black, width: 1),
                                        ),
                                      ),
                                      gridData: const FlGridData(show: true),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        SizedBox(height: SizeConfig.heightSize(20) * 0.8),

                        Center(
                          child: AutoSizeText(
                            'Year Summary',
                            textScaleFactor: 1.5.sp,
                            style: TextStyle(
                              fontFamily: 'Comfortaa',
                              fontWeight: FontWeight.w700,
                              fontSize: 14.sp,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: double.infinity,
                          child: ReusableButton(
                            text: _yearController.text,
                            backgroundColor: const Color(0xFFFEF1CC),
                            textColor: Colors.black,
                            onPress: () async =>
                                _onPressedYearPicker(context: context),
                          ),
                        ),
                        DropdownButtonHideUnderline(
                          child: DropdownButton2<String>(
                            isExpanded: true,
                            hint: AutoSizeText(
                              'Select Category',
                              textScaleFactor: 1.0.sp,
                              style: TextStyle(
                                fontFamily: 'Comfortaa',
                                fontWeight: FontWeight.w700,
                                fontSize: 8.sp,
                                color: Colors.black,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            value: selectedGroupForMonth,
                            onChanged: (String? newValue) {
                              setState(() {
                                selectedGroupForMonth = newValue!;
                                _onYearGroupChanged();
                              });
                            },
                            items: group
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: AutoSizeText(
                                  textScaleFactor: 1.0.sp,
                                  value,
                                  style: TextStyle(
                                      fontFamily: 'Comfortaa', fontSize: 8.sp, fontWeight: FontWeight.w700),
                                ),
                              );
                            }).toList(),
                            buttonStyleData: ButtonStyleData(
                              width: double.infinity,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 15),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(
                                    SizeConfig.widthSize(11) * 0.8),
                                border: Border.all(
                                  color: Colors.black26,
                                ),
                                color: const Color(0xFFA4BE7B),
                              ),
                              elevation: 2,
                            ),
                            iconStyleData: const IconStyleData(
                              icon: Icon(
                                Icons.expand_more,
                              ),
                              iconSize: 18,
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
                                thickness: WidgetStateProperty.all<double>(6),
                                thumbVisibility:
                                    WidgetStateProperty.all<bool>(true),
                              ),
                            ),
                            menuItemStyleData: const MenuItemStyleData(
                              height: 40,
                              padding: EdgeInsets.symmetric(horizontal: 15),
                            ),
                          ),
                        ),

                        SizedBox(
                          height: SizeConfig.heightSize(10) * 0.8,
                        ),

                        if (barChartData.isNotEmpty &&
                            selectedGroupForMonth != null)
                          Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFFAF7F5),
                              borderRadius: BorderRadius.circular(
                                  SizeConfig.widthSize(11) * 0.8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.5),
                                  spreadRadius: 5,
                                  blurRadius: 7,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                SizedBox(
                                  height: SizeConfig.heightSize(10) * 0.8,
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: SizedBox(
                                      height: 300,
                                      child: BarChart(
                                        BarChartData(
                                          alignment:
                                              BarChartAlignment.spaceAround,
                                          maxY: barChartData
                                                  .map((data) =>
                                                      data.barRods[0].toY)
                                                  .reduce(
                                                      (a, b) => a > b ? a : b) *
                                              1.0,
                                          barGroups: barChartData,
                                          titlesData: FlTitlesData(
                                            show: true,
                                            leftTitles: AxisTitles(
                                              sideTitles: SideTitles(
                                                showTitles: true,
                                                reservedSize: 35,
                                                getTitlesWidget: (value, meta) {
                                                  return SideTitleWidget(
                                                    axisSide: meta.axisSide,
                                                    space: 8.0,
                                                    child: AutoSizeText(
                                                      textScaleFactor: 0.75.sp,
                                                      value.toInt().toString(),
                                                      style: TextStyle(
                                                        fontSize: 8.sp,
                                                        color: Colors.black,
                                                        fontFamily: 'Comfortaa',
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ),
                                              axisNameWidget: Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 8.0),
                                                child: AutoSizeText(
                                                  textScaleFactor: 1.0.sp,
                                                  'Total (RM)',
                                                  style: const TextStyle(
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.w700,
                                                    fontFamily: 'Comfortaa',
                                                  ),
                                                ),
                                              ),
                                              axisNameSize: 14,
                                            ),
                                            bottomTitles: AxisTitles(
                                              sideTitles: SideTitles(
                                                showTitles: true,
                                                reservedSize: 28,
                                                getTitlesWidget: (value, meta) {
                                                  final month =
                                                      DateFormat('MMM').format(
                                                          DateTime(
                                                              0,
                                                              value.toInt() +
                                                                  1));
                                                  return SideTitleWidget(
                                                    axisSide: meta.axisSide,
                                                    space: 8.0,
                                                    child: AutoSizeText(
                                                      textScaleFactor: 0.75.sp,
                                                      month,
                                                      style: TextStyle(
                                                        fontSize: 8.sp,
                                                        color: Colors.black,
                                                        fontFamily: 'Comfortaa',
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ),
                                              axisNameWidget: Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 1.0),
                                                child: AutoSizeText(
                                                  textScaleFactor: 1.0.sp,
                                                  'Month',
                                                  style: TextStyle(
                                                    fontSize: 10.sp,
                                                    fontWeight: FontWeight.w700,
                                                    fontFamily: 'Comfortaa',
                                                  ),
                                                ),
                                              ),
                                              axisNameSize: 16,
                                            ),
                                            rightTitles: const AxisTitles(
                                              sideTitles:
                                                  SideTitles(showTitles: false),
                                            ),
                                            topTitles: const AxisTitles(
                                              sideTitles:
                                                  SideTitles(showTitles: false),
                                            ),
                                          ),
                                          borderData: FlBorderData(
                                            show: true,
                                            border: const Border(
                                              left: BorderSide(
                                                  color: Colors.black,
                                                  width: 1),
                                              bottom: BorderSide(
                                                  color: Colors.black,
                                                  width: 1),
                                            ),
                                          ),
                                          gridData: const FlGridData(show: true),
                                        ),
                                      )),
                                ),
                              ],
                            ),
                          ),

                        SizedBox(height: SizeConfig.heightSize(20) * 0.8),
                      ],
                    ),
                  );
                }
              }),
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
        _statisticsManager.calcTotal(
            _dateController.text,
            updateGroupPieChart,
            updateExpensesPieChart,
            updateIncomePieChart,
            updateDebtPieChart,
            updateSavingsPieChart,
            updateInvestmentPieChart);
      });
    }
  }

  Future<void> _onPressedYearPicker({
    required BuildContext context,
    String? locale,
  }) async {
    final localeObj = locale != null ? Locale(locale) : null;
    final selected = await showMonthYearPicker(
      context: context,
      initialDate: _selectedYear ?? DateTime.now(),
      firstDate: DateTime(2019),
      lastDate: DateTime(2030),
      locale: localeObj,
    );
    if (selected != null) {
      setState(() {
        _selectedYear = selected;
        _yearController.text = DateFormat('yyyy').format(selected);
        selectedGroupForMonth = null;
        _onYearGroupChanged();
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

