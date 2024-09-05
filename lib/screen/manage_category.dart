import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:organise_me/components/auth_service.dart';
import 'package:organise_me/screen/list_screen.dart';
import 'package:organise_me/screen/event_screen.dart';
import 'package:organise_me/screen/home_screen.dart';
import 'package:organise_me/components/profile_picture.dart';
import 'package:organise_me/screen/statistics_screen.dart';
import 'package:organise_me/screen/transaction_screen.dart';
import 'package:organise_me/components/utils.dart';
import 'package:organise_me/screen/welcome_screen.dart';
import 'package:organise_me/components/reusable_button.dart';
import 'package:organise_me/components/main_category.dart';

class ManageCategoryScreen extends StatefulWidget {
  static String id = 'manageCategory_screen';
  final String group;

  const ManageCategoryScreen({super.key, required this.group});

  @override
  State<ManageCategoryScreen> createState() =>
      _ManageCategoryScreenState();
}

class _ManageCategoryScreenState extends State<ManageCategoryScreen> {
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

  late MainCategory _mainCategory;
  late Future<void> _categories;


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

  @override
  void initState() {
    super.initState();
    _mainCategory = MainCategory();
    _categories = _fetchCategories();
    determineCategory(widget.group);
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

  void _showEditCategoryDialog(int index) {
    TextEditingController editController = TextEditingController(text: determineCategory(widget.group)[index]);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: AutoSizeText(
            'Edit Category',
            textScaleFactor: 1.5.sp,
            style: TextStyle(
              fontFamily: 'Comfortaa',
              fontWeight: FontWeight.w700,
              fontSize: 14.sp,
            ),
          ),
          content: MediaQuery(
            data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(1.3.sp)),
            child: TextField(
              controller: editController,
              decoration: InputDecoration(
                  hintText: "Enter new category name",
                  hintStyle: TextStyle(
                    fontFamily: 'Comfortaa',
                    fontSize: 14.sp,
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
                'Save',
                textScaleFactor: 1.4.sp,
                style: TextStyle(
                  fontFamily: 'Comfortaa',
                  fontWeight: FontWeight.w700,
                  fontSize: 12.sp,
                  color: const Color(0xFF285430),
                ),
              ),
              onPressed: () async {
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ManageCategoryScreen(group: widget.group)),
                );
                if (widget.group == "Expenses") {
                  await _mainCategory.updateExpensesCategory(determineCategory(widget.group)[index], editController.text);
                  _fetchCategories();
                  setState(() {
                    determineCategory(widget.group);
                  });
                } else if (widget.group == "Income") {
                  await _mainCategory.updateIncomeCategory(determineCategory(widget.group)[index], editController.text);
                  _fetchCategories();
                  setState(() {
                    determineCategory(widget.group);
                  });
                } else if (widget.group == "Debt") {
                  await _mainCategory.updateDebtCategory(determineCategory(widget.group)[index], editController.text);
                  _fetchCategories();
                  setState(() {
                    determineCategory(widget.group);
                  });
                } else if (widget.group == "Savings") {
                  await _mainCategory.updateSavingsCategory(determineCategory(widget.group)[index], editController.text);
                  _fetchCategories();
                  setState(() {
                    determineCategory(widget.group);
                  });
                } else if (widget.group == "Investment") {
                  await _mainCategory.updateInvestmentCategory(determineCategory(widget.group)[index], editController.text);
                  _fetchCategories();
                  setState(() {
                    determineCategory(widget.group);
                  });
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _showDeleteCategoryDialog(int index) {

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: AutoSizeText(
            'Delete Category',
            textScaleFactor: 1.5.sp,
            style: TextStyle(
              fontFamily: 'Comfortaa',
              fontWeight: FontWeight.w700,
              fontSize: 14.sp,
            ),
          ),
          content: AutoSizeText(
            'Are you sure you want to delete this category?',
            textScaleFactor: 1.5.sp,
            style: TextStyle(
              fontFamily: 'Comfortaa',
              fontWeight: FontWeight.w700,
              fontSize: 12.sp,
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
                'Yes',
                textScaleFactor: 1.4.sp,
                style: TextStyle(
                  fontFamily: 'Comfortaa',
                  fontWeight: FontWeight.w700,
                  fontSize: 12.sp,
                  color: const Color(0xFF285430),
                ),
              ),
              onPressed: () async {
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ManageCategoryScreen(group: widget.group)),
                );
                if (widget.group == "Expenses") {
                  await _mainCategory.deleteExpensesCategory(determineCategory(widget.group)[index]);
                  _fetchCategories();
                  setState(() {
                    determineCategory(widget.group);
                  });
                } else if (widget.group == "Income") {
                  await _mainCategory.deleteIncomeCategory(determineCategory(widget.group)[index]);
                  _fetchCategories();
                  setState(() {
                    determineCategory(widget.group);
                  });
                } else if (widget.group == "Debt") {
                  await _mainCategory.deleteDebtCategory(determineCategory(widget.group)[index]);
                  _fetchCategories();
                  setState(() {
                    determineCategory(widget.group);
                  });
                } else if (widget.group == "Savings") {
                  await _mainCategory.deleteSavingsCategory(determineCategory(widget.group)[index]);
                  _fetchCategories();
                  setState(() {
                    determineCategory(widget.group);
                  });
                } else if (widget.group == "Investment") {
                  await _mainCategory.deleteInvestmentCategory(determineCategory(widget.group)[index]);
                  _fetchCategories();
                  setState(() {
                    determineCategory(widget.group);
                  });
                }

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
        onPopInvoked: ((didpop){
          if(!didpop) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const TransactionScreen()),
            );
          }
        }),
        child: Scaffold(
          backgroundColor: const Color(0xFFF8F2ED),
          appBar: AppBar(
            backgroundColor: const Color(0xFFA4BE7B),
            leading: Builder(
              builder: (context) {
                return IconButton(
                  color: Colors.white,
                  tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
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
                    child: Text('Error fetching categories'),
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
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ReusableButton(
                            text: 'Tasks',
                            backgroundColor: const Color(0xFFE5D9B6),
                            textColor: Colors.black,
                            onPress: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const ListScreen()),
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
                                    builder: (context) => const EventScreen()),
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
                                    builder: (context) => const TransactionScreen()),
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
                        child: Container(
                          alignment: Alignment.centerLeft,
                          child: AutoSizeText(
                            'Manage Category',
                            textScaleFactor: 1.5.sp,
                            style: TextStyle(
                              fontFamily: 'Comfortaa',
                              fontWeight: FontWeight.w700,
                              fontSize: 14.sp,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: SizeConfig.heightSize(10) * 0.8,
                      ),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: determineCategory(widget.group).length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: AutoSizeText(
                              '#   ${determineCategory(widget.group)[index]}',
                              textScaleFactor: 1.3.sp,
                              style: TextStyle(
                                fontFamily: 'Comfortaa',
                                fontWeight: FontWeight.w700,
                                fontSize: 12.sp,
                                color: Colors.black54,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () {
                                    _showEditCategoryDialog(index);
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () {
                                    _showDeleteCategoryDialog(index);
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            );
  }}
          ),
        ),
      ),
    );
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
