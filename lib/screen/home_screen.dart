import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:badges/badges.dart' as badges;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:organise_me/components/auth_service.dart';
import 'package:organise_me/screen/all_events.dart';
import 'package:organise_me/screen/all_transactions.dart';
import 'package:organise_me/screen/list_screen.dart';
import 'package:organise_me/components/event.dart';
import 'package:organise_me/screen/event_screen.dart';
import 'package:organise_me/components/profile_picture.dart';
import 'package:organise_me/screen/statistics_screen.dart';
import 'package:organise_me/components/task.dart';
import 'package:organise_me/screen/transaction_screen.dart';
import 'package:organise_me/components/utils.dart';
import 'package:organise_me/screen/view_event_details.dart';
import 'package:organise_me/screen/view_task_details.dart';
import 'package:organise_me/screen/view_transaction_details.dart';
import 'package:organise_me/screen/welcome_screen.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:organise_me/components/transaction.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  static String id = 'home_screen';

  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  bool isLoading = false;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String get _userId => _auth.currentUser!.uid;
  CollectionReference get _list =>
      _firestore.collection('users').doc(_userId).collection('lists');
  CollectionReference get _event =>
      _firestore.collection('users').doc(_userId).collection('events');
  CollectionReference get _transaction =>
      _firestore.collection('users').doc(_userId).collection('transactions');
  final ProfilePicture _profilePicture = ProfilePicture();

  String? username;
  final AuthService _authService = AuthService();

  int currentPageIndex = 0;
  NavigationDestinationLabelBehavior labelBehavior =
      NavigationDestinationLabelBehavior.alwaysShow;
  final List<Widget> destinations = [];

  DateTime now = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  late Future<void> _tasks;

  String dropdownValue = 'Today\'s Tasks';
  final List<String> options = [
    'Today\'s Tasks',
    'Today\'s Events',
    'Today\'s Transactions'
  ];

  void _previousOption() {
    if(dropdownValue == 'Today\'s Tasks'){
      setState(() {
        dropdownValue = 'Today\'s Transactions';
      });
    } else if (dropdownValue == 'Today\'s Events'){
      setState(() {
        dropdownValue = 'Today\'s Tasks';
      });
    } else {
      setState(() {
        dropdownValue = 'Today\'s Events';
      });
    }
  }

  void _nextOption() {
    if(dropdownValue == 'Today\'s Tasks'){
      setState(() {
        dropdownValue = 'Today\'s Events';
      });
    } else if (dropdownValue == 'Today\'s Events'){
      setState(() {
        dropdownValue = 'Today\'s Transactions';
      });
    } else {
      setState(() {
        dropdownValue = 'Today\'s Tasks';
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    _selectedDay = _focusedDay;
    String selectedDate = DateFormat('dd MMM yyyy').format(_selectedDay!);
    _tasks = fetchTasks(selectedDate);
    fetchUncompletedTask();
    fetchEvents(selectedDate);
    fetchTransactions(selectedDate);
    _loadUsername();
    _profilePicture.setUpdateCallback(() {
      setState(() {});
    });
    _profilePicture.loadProfilePicture(isLoading);
    _resetDialogPreference(_userId);
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) async {
    isLoading = true;
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
        tasks.clear();
        events.clear();
        transactions.clear();
      });
      String selectedDate = DateFormat('dd MMM yyyy').format(selectedDay);
      await fetchTasks(selectedDate);
      await fetchEvents(selectedDate);
      await fetchTransactions(selectedDate);
    }
  }

  List<Tasks> tasks = [];
  List<Tasks> allTasks = [];
  int taskCount = 0;
  bool showNotifiDialog = true;

  Future<void> fetchTasks(String selectedDate) async {
    int count = 0;

    setState(() {
      tasks.clear();
      isLoading = true;
    });

    try {
      QuerySnapshot listSnapshot = await _list.get();
      for (var listDoc in listSnapshot.docs) {
        CollectionReference tasksCollection =
            listDoc.reference.collection('tasks');

        QuerySnapshot tasksSnapshot = await tasksCollection
            .where('startDate', isLessThanOrEqualTo: selectedDate)
            .where('endDate', isGreaterThanOrEqualTo: selectedDate)
            .get();

        for (QueryDocumentSnapshot taskDoc in tasksSnapshot.docs) {
          DocumentSnapshot snapshot =
              await tasksCollection.doc(taskDoc.id).get();
          Tasks task = Tasks(
            taskName: snapshot['taskName'] as String,
            taskDescription: snapshot['taskDescription'] as String,
            priority: snapshot['priority'] as String,
            startDate: snapshot['startDate'] as String,
            endDate: snapshot['endDate'] as String,
            startTime: snapshot['startTime'] as String,
            endTime: snapshot['endTime'] as String,
            isReminderOn: snapshot['isReminderOn'] as bool,
            listName: snapshot['listName'] as String,
          );
          setState(() {
            tasks.add(task);
          });

          count += 1;
        }
      }

      setState(() {
        taskCount = count;
        isLoading = false;
      });

      if (allTasks.isEmpty) {
        setState(() {
          allTasks.clear();
          isLoading = true;
        });

        for (var listDoc in listSnapshot.docs) {
          CollectionReference tasksCollection =
              listDoc.reference.collection('tasks');
          QuerySnapshot tasksSnapshot = await tasksCollection.get();

          for (QueryDocumentSnapshot taskDoc in tasksSnapshot.docs) {
            DocumentSnapshot snapshot =
                await tasksCollection.doc(taskDoc.id).get();
            Tasks task = Tasks(
              taskName: snapshot['taskName'] as String,
              taskDescription: snapshot['taskDescription'] as String,
              priority: snapshot['priority'] as String,
              startDate: snapshot['startDate'] as String,
              endDate: snapshot['endDate'] as String,
              startTime: snapshot['startTime'] as String,
              endTime: snapshot['endTime'] as String,
              isReminderOn: snapshot['isReminderOn'] as bool,
              listName: snapshot['listName'] as String,
            );
            setState(() {
              allTasks.add(task);
            });
          }
        }

        setState(() {
          isLoading = false;
        });
      }

      String currentDate = DateFormat('dd MMM yyyy').format(DateTime.now());
      if (showNotifiDialog == true && selectedDate == currentDate) {
        showNotifiDialog = false;
        _showTaskDialog(_userId, taskCount, eventCount, countUncompletedTask);
      }
    } catch (e) {
      print("Error fetching tasks: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  int countUncompletedTask = 0;
  Future<void> fetchUncompletedTask() async {
    countUncompletedTask = 0;
    String formattedDate = DateFormat('dd MMM yyyy').format(DateTime.now());
    QuerySnapshot listSnapshot = await _list.get();
    for (var listDoc in listSnapshot.docs) {
      CollectionReference tasksCollection =
          listDoc.reference.collection('tasks');
      QuerySnapshot tasksSnapshot = await tasksCollection
          .where('startDate', isLessThan: formattedDate)
          .get();

      for (QueryDocumentSnapshot taskDoc in tasksSnapshot.docs) {
        countUncompletedTask += 1;
      }
    }
  }

  List<Event> events = [];
  List<Event> allEvents = [];
  int eventCount = 0;
  Future<void> fetchEvents(String selectedDate) async {
    int count = 0;
    setState(() {
      events.clear();
      isLoading = true;
    });

    try {
      QuerySnapshot eventSnapshot = await _event
          .where('startDate', isLessThanOrEqualTo: selectedDate)
          .where('endDate', isGreaterThanOrEqualTo: selectedDate)
          .get();
      for (QueryDocumentSnapshot eventDoc in eventSnapshot.docs) {
        DocumentSnapshot snapshot = await _event.doc(eventDoc.id).get();
        Event event = Event(
          eventName: snapshot['eventName'] as String,
          eventDescription: snapshot['eventDescription'] as String,
          startDate: snapshot['startDate'] as String,
          endDate: snapshot['endDate'] as String,
          startTime: snapshot['startTime'] as String,
          endTime: snapshot['endTime'] as String,
          // repeatsEvery: snapshot['repeatsEvery'] as String,
          // repeatsOn: snapshot['repeatsOn'] as String,
          isReminderOn: snapshot['isReminderOn'] as bool,
        );
        setState(() {
          events.add(event);
        });

        count += 1;
      }
      setState(() {
        eventCount = count;
        isLoading = false;
      });

      if (allEvents.isEmpty) {
        setState(() {
          allEvents.clear();
          isLoading = true;
        });

        QuerySnapshot eventSnapShot = await _event.get();
        for (QueryDocumentSnapshot eventDoc in eventSnapShot.docs) {
          DocumentSnapshot snapshot = await _event.doc(eventDoc.id).get();
          Event event = Event(
            eventName: snapshot['eventName'] as String,
            eventDescription: snapshot['eventDescription'] as String,
            startDate: snapshot['startDate'] as String,
            endDate: snapshot['endDate'] as String,
            startTime: snapshot['startTime'] as String,
            endTime: snapshot['endTime'] as String,
            // repeatsEvery: snapshot['repeatsEvery'] as String,
            // repeatsOn: snapshot['repeatsOn'] as String,
            isReminderOn: snapshot['isReminderOn'] as bool,
          );
          setState(() {
            allEvents.add(event);
          });
        }
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching events: $e");
    }
  }

  List<Transactions> transactions = [];
  List<Transactions> allTransactions = [];
  Future<void> fetchTransactions(String selectedDate) async {
    setState(() {
      transactions.clear();
      isLoading = true;
    });

    try {
      QuerySnapshot transactionSnapshot =
          await _transaction.where('date', isEqualTo: selectedDate).get();
      for (QueryDocumentSnapshot transactionDoc in transactionSnapshot.docs) {
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
        });
      }
      setState(() {
        isLoading = false;
      });

      if (allTransactions.isEmpty) {
        setState(() {
          allTransactions.clear();
          isLoading = true;
        });

        QuerySnapshot transactionSnapshot = await _transaction.get();
        for (QueryDocumentSnapshot transactionDoc in transactionSnapshot.docs) {
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
            allTransactions.add(transaction);
          });
        }
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching transactions: $e");
    }
  }

  Future<void> _loadUsername() async {
    String? fetchedUsername = await _authService.getUsername();
    setState(() {
      username = fetchedUsername;
    });
  }

  List<Event> _getEventsForDay(DateTime day) {
    final DateFormat format = DateFormat('dd MMM yyyy');
    return allEvents.where((event) {
      DateTime startDate = format.parse(event.startDate);
      DateTime endDate = format.parse(event.endDate);
      for (DateTime date = startDate;
          date.isBefore(endDate.add(const Duration(days: 1)));
          date = date.add(const Duration(days: 1))) {
        if (date.year == day.year &&
            date.month == day.month &&
            date.day == day.day) {
          return true;
        }
      }
      return false;
    }).toList();
  }

  List<Tasks> _getTasksForDay(DateTime day) {
    final DateFormat format = DateFormat('dd MMM yyyy');
    return allTasks.where((task) {
      DateTime startDate = format.parse(task.startDate);
      DateTime endDate = format.parse(task.endDate);
      for (DateTime date = startDate;
          date.isBefore(endDate.add(const Duration(days: 1)));
          date = date.add(const Duration(days: 1))) {
        if (date.year == day.year &&
            date.month == day.month &&
            date.day == day.day) {
          return true;
        }
      }
      return false;
    }).toList();
  }

  List<Transactions> _getTransactionsForDay(DateTime day) {
    final DateFormat format = DateFormat('dd MMM yyyy');
    return allTransactions.where((transaction) {
      DateTime eventDate = format.parse(transaction.date);
      return eventDate.year == day.year &&
          eventDate.month == day.month &&
          eventDate.day == day.day;
    }).toList();
  }

  List<dynamic> _getForDay(DateTime day) {
    if (dropdownValue == 'Today\'s Events') {
      return _getEventsForDay(day);
    } else if (dropdownValue == 'Today\'s Tasks') {
      return _getTasksForDay(day);
    } else if (dropdownValue == 'Today\'s Transactions') {
      return _getTransactionsForDay(day);
    } else {
      return [];
    }
  }

  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _resetDialogPreference(_userId);
    }
  }

  // Future<void> _resetDialogPreference() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   await prefs.setBool('dontShowTaskDialog', false);
  // }

  Future<void> _resetDialogPreference(String userId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String lastShownDateKey = 'lastShownDate_$userId';
    String dontShowTaskDialogKey = 'dontShowTaskDialog_$userId';

    String lastShownDate = prefs.getString(lastShownDateKey) ?? '';
    String todayDate = DateFormat('dd MMM yyyy').format(DateTime.now());

    // Reset the preference if the last shown date is not today
    if (lastShownDate != todayDate) {
      await prefs.setBool(dontShowTaskDialogKey, false);
      await prefs.setString(lastShownDateKey, todayDate);
    }
  }

  Future<void> _showTaskDialog(String userId, int taskCount, int eventCount,
      int countUncompletedTask) async {
    String selectedDate = DateFormat('dd MMM yyyy').format(_selectedDay!);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String dontShowTaskDialogKey = 'dontShowTaskDialog_$userId';

    bool dontShowAgain = prefs.getBool(dontShowTaskDialogKey) ?? false;

    if (dontShowAgain) {
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: AutoSizeText(
            textScaleFactor: 1.3.sp,
            'Notifications',
            style: TextStyle(
              fontFamily: 'Comfortaa',
              fontWeight: FontWeight.w700,
              fontSize: 15.sp,
              decoration: TextDecoration.underline,
            ),
          ),
          content: AutoSizeText(
            textScaleFactor: 1.1.sp,
            'Today Date: $selectedDate\n\nYou have $taskCount task(s) for today.\nYou have $eventCount event(s) for today.\n\n\n${countUncompletedTask == 0
                    ? 'You do not have uncompleted task.'
                    : 'You still have $countUncompletedTask uncompleted task.'}',
            style: TextStyle(
              fontFamily: 'Comfortaa',
              fontWeight: FontWeight.w700,
              fontSize: 12.sp,
            ),
          ),
          actions: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                TextButton(
                  child: AutoSizeText(
                    textScaleFactor: 1.1.sp,
                    'Don\'t show again today',
                    style: TextStyle(
                      fontFamily: 'Comfortaa',
                      fontWeight: FontWeight.w700,
                      fontSize: 12.sp,
                    ),
                  ),
                  onPressed: () async {
                    await prefs.setBool(dontShowTaskDialogKey, true);
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: AutoSizeText(
                    textScaleFactor: 1.1.sp,
                    'OK',
                    style: TextStyle(
                      fontFamily: 'Comfortaa',
                      fontWeight: FontWeight.w700,
                      fontSize: 12.sp,
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ],
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    String formattedDate = DateFormat('EEEE, dd MMM yyyy').format(now);
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
                'Home',
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
                            fontFamily: 'Comfortaa',
                            fontWeight: FontWeight.w700,
                            fontSize: 12.sp,
                          ),
                        ),
                        content: AutoSizeText(
                          textScaleFactor: 1.3.sp,
                          'Are you sure you want to logout?',
                          style: TextStyle(
                            fontFamily: 'Comfortaa',
                            fontWeight: FontWeight.w700,
                            fontSize: 12.sp,
                          ),
                        ),
                        actions: <Widget>[
                          TextButton(
                            child: AutoSizeText(
                              textScaleFactor: 1.2.sp,
                              'Cancel',
                              style: TextStyle(
                                fontFamily: 'Comfortaa',
                                fontWeight: FontWeight.w700,
                                fontSize: 12.sp,
                              ),
                            ),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                          TextButton(
                            child: AutoSizeText(
                              textScaleFactor: 1.2.sp,
                              'Logout',
                              style: TextStyle(
                                fontFamily: 'Comfortaa',
                                fontWeight: FontWeight.w700,
                                fontSize: 12.sp,
                              ),
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
          floatingActionButton: SpeedDial(
              backgroundColor: const Color(0xFFE5D9B6),
              tooltip: 'Expand more',
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(SizeConfig.scaleSize(20) * 0.8),
              ),
              children: [
                SpeedDialChild(
                  backgroundColor: const Color(0xFFA4BE7B),
                  child: const Icon(
                    Icons.task_outlined,
                    color: Color(0xFF285430),
                  ),
                  label: 'Add Task',
                  labelStyle: const TextStyle(
                    fontFamily: 'Comfortaa',
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF285430),
                  ),
                  labelBackgroundColor: const Color(0xFFA4BE7B),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ListScreen()),
                    );
                  },
                ),
                SpeedDialChild(
                  backgroundColor: const Color(0xFFA4BE7B),
                  child: const Icon(
                    Icons.calendar_month_outlined,
                    color: Color(0xFF285430),
                  ),
                  label: 'Add Event',
                  labelStyle: const TextStyle(
                    fontFamily: 'Comfortaa',
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF285430),
                  ),
                  labelBackgroundColor: const Color(0xFFA4BE7B),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const EventScreen()),
                    );
                  },
                ),
                SpeedDialChild(
                  backgroundColor: const Color(0xFFA4BE7B),
                  child: const Icon(
                    Icons.monetization_on_outlined,
                    color: Color(0xFF285430),
                  ),
                  label: 'Add Transaction',
                  labelStyle: const TextStyle(
                    fontFamily: 'Comfortaa',
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF285430),
                  ),
                  labelBackgroundColor: const Color(0xFFA4BE7B),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const TransactionScreen()),
                    );
                  },
                ),
              ],
              child: const Icon(Icons.keyboard_double_arrow_up_outlined)),
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
              destinations: [
                NavigationDestination(
                  selectedIcon: badges.Badge(
                    badgeContent: AutoSizeText(
                      textScaleFactor: 1.0.sp,
                      '${taskCount + eventCount}',
                      style: TextStyle(
                        fontFamily: 'Comfortaa',
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        fontSize: 9.sp,
                      ),
                    ),
                    badgeStyle: const badges.BadgeStyle(badgeColor: Colors.red),
                    child: const Icon(
                      Icons.home,
                      color: Colors.white,
                    ),
                  ),
                  icon: badges.Badge(
                    badgeContent: AutoSizeText(
                      textScaleFactor: 1.0.sp,
                      '${taskCount + eventCount}',
                      style: TextStyle(
                        fontFamily: 'Comfortaa',
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        fontSize: 9.sp,
                      ),
                    ),
                    badgeStyle: const badges.BadgeStyle(badgeColor: Colors.red),
                    child: const Icon(
                      Icons.home_outlined,
                      color: Colors.white,
                    ),
                  ),
                  label: 'Home',
                ),
                const NavigationDestination(
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
                const NavigationDestination(
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
                            const Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                            ),
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
                            style: TextStyle(
                              fontFamily: 'Comfortaa',
                              fontWeight: FontWeight.w700,
                              fontSize: 18.sp,
                              color: Colors.white,
                            ),
                            textScaleFactor: 1.3.sp,
                          ),
                          IconButton(
                              tooltip: 'Edit Username',
                              onPressed: () {
                                _displayNameEditDialog(context, 'username');
                              },
                              icon: const Icon(
                                Icons.edit,
                                color: Colors.white,
                              )),
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
                    style: TextStyle(
                      fontFamily: 'Comfortaa',
                      fontWeight: FontWeight.w700,
                      fontSize: 12.sp,
                    ),
                    textScaleFactor: 1.3.sp,
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
                    style: TextStyle(
                      fontFamily: 'Comfortaa',
                      fontWeight: FontWeight.w700,
                      fontSize: 12.sp,
                    ),
                    textScaleFactor: 1.3.sp,
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
                          style: TextStyle(
                            fontFamily: 'Comfortaa',
                            fontWeight: FontWeight.w700,
                            fontSize: 12.sp,
                          ),
                          textScaleFactor: 1.3.sp,
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
                          style: TextStyle(
                            fontFamily: 'Comfortaa',
                            fontWeight: FontWeight.w700,
                            fontSize: 12.sp,
                          ),
                          textScaleFactor: 1.3.sp,
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
                          style: TextStyle(
                            fontFamily: 'Comfortaa',
                            fontWeight: FontWeight.w700,
                            fontSize: 12.sp,
                          ),
                          textScaleFactor: 1.3.sp,
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
                    style: TextStyle(
                      fontFamily: 'Comfortaa',
                      fontWeight: FontWeight.w700,
                      fontSize: 12.sp,
                    ),
                    textScaleFactor: 1.3.sp,
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
                    style: TextStyle(
                      fontFamily: 'Comfortaa',
                      fontWeight: FontWeight.w700,
                      fontSize: 12.sp,
                    ),
                    textScaleFactor: 1.3.sp,
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
                              fontFamily: 'Comfortaa',
                              fontWeight: FontWeight.w700,
                              fontSize: 12.sp,
                            ),
                          ),
                          content: AutoSizeText(
                            textScaleFactor: 1.3.sp,
                            'Are you sure you want to logout?',
                            style: TextStyle(
                              fontFamily: 'Comfortaa',
                              fontWeight: FontWeight.w700,
                              fontSize: 12.sp,
                            ),
                          ),
                          actions: <Widget>[
                            TextButton(
                              child: AutoSizeText(
                                textScaleFactor: 1.2.sp,
                                'Cancel',
                                style: TextStyle(
                                  fontFamily: 'Comfortaa',
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12.sp,
                                ),
                              ),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                            TextButton(
                              child: AutoSizeText(
                                textScaleFactor: 1.2.sp,
                                'Logout',
                                style: TextStyle(
                                  fontFamily: 'Comfortaa',
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12.sp,
                                ),
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
              future: _tasks,
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
                        Row(
                          children: [
                            AutoSizeText(
                              'Hello, $username',
                              style: TextStyle(
                                fontFamily: 'Comfortaa',
                                fontWeight: FontWeight.w700,
                                fontSize: 11.sp,
                              ),
                              textScaleFactor: 1.5.sp,
                            ),
                            IconButton(
                                tooltip: 'Edit Username',
                                onPressed: () {
                                  _displayNameEditDialog(context, 'username');
                                },
                                icon: const Icon(Icons.edit)),
                          ],
                        ),
                        AutoSizeText(
                          formattedDate,
                          style: TextStyle(
                            fontFamily: 'Comfortaa',
                            fontWeight: FontWeight.w700,
                            fontSize: 11.sp,
                          ),
                          textScaleFactor: 1.5.sp,
                        ),
                        const Divider(
                          thickness: 1,
                          color: Color(0xFF747474),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 20.0),
                          child: MediaQuery(
                            data: MediaQuery.of(context).copyWith(
                                textScaler: TextScaler.linear(1.3.sp)),
                            child: TableCalendar(
                              daysOfWeekHeight: 40,
                              calendarFormat: CalendarFormat.twoWeeks,
                              rowHeight: 52,
                              headerStyle: HeaderStyle(
                                formatButtonVisible: false,
                                titleCentered: true,
                                titleTextStyle: TextStyle(
                                  fontFamily: 'Comfortaa',
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              daysOfWeekStyle: DaysOfWeekStyle(
                                weekdayStyle: TextStyle(
                                  fontFamily: 'Comfortaa',
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.w700,
                                ),
                                weekendStyle: TextStyle(
                                  fontFamily: 'Comfortaa',
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              startingDayOfWeek: StartingDayOfWeek.monday,
                              availableGestures: AvailableGestures.all,
                              selectedDayPredicate: (day) =>
                                  isSameDay(day, _focusedDay),
                              focusedDay: _focusedDay,
                              firstDay: DateTime.utc(2010, 10, 16),
                              lastDay: DateTime.utc(2030, 3, 14),
                              onDaySelected: _onDaySelected,
                              eventLoader: _getForDay,
                              calendarStyle: CalendarStyle(
                                cellMargin: const EdgeInsets.all(1.0),
                                defaultTextStyle: TextStyle(
                                  fontFamily: 'Comfortaa',
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w700,
                                ),
                                todayTextStyle: TextStyle(
                                  fontFamily: 'Comfortaa',
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w700,
                                ),
                                todayDecoration: const BoxDecoration(
                                  color: Color(0xFFE6E5A3),
                                  shape: BoxShape.circle,
                                ),
                                selectedTextStyle: TextStyle(
                                  fontFamily: 'Comfortaa',
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                                selectedDecoration: const BoxDecoration(
                                  color: Color(0xFF5F8D4E),
                                  shape: BoxShape.circle,
                                ),
                                weekendTextStyle: TextStyle(
                                  fontFamily: 'Comfortaa',
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w700,
                                ),
                                outsideTextStyle: TextStyle(
                                  fontFamily: 'Comfortaa',
                                  color: const Color(0xFFAEAEAE),
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w700,
                                ),
                                markerDecoration: const BoxDecoration(
                                  color: Color(0xFF285430),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          ),
                        ),
                        // Padding(
                        //   padding: const EdgeInsets.all(8.0),
                        //   child: DropdownButtonHideUnderline(
                        //     child: DropdownButton2<String>(
                        //       isExpanded: true,
                        //       value: dropdownValue,
                        //       onChanged: (String? newValue) {
                        //         setState(() {
                        //           dropdownValue = newValue!;
                        //         });
                        //       },
                        //       items: options.map<DropdownMenuItem<String>>(
                        //           (String value) {
                        //         return DropdownMenuItem<String>(
                        //           value: value,
                        //           child: AutoSizeText(
                        //             textScaleFactor: 1.0.sp,
                        //             value,
                        //             style: TextStyle(
                        //               fontFamily: 'Comfortaa',
                        //               fontWeight: FontWeight.w700,
                        //               fontSize: 8.sp,
                        //             ),
                        //           ),
                        //         );
                        //       }).toList(),
                        //       buttonStyleData: ButtonStyleData(
                        //         width: double.infinity,
                        //         padding:
                        //             const EdgeInsets.symmetric(horizontal: 15),
                        //         decoration: BoxDecoration(
                        //           borderRadius: BorderRadius.circular(
                        //               SizeConfig.widthSize(11) * 0.8),
                        //           border: Border.all(
                        //             color: Colors.black26,
                        //           ),
                        //           color: const Color(0xFFA4BE7B),
                        //         ),
                        //         elevation: 2,
                        //       ),
                        //       iconStyleData: const IconStyleData(
                        //         icon: Icon(
                        //           Icons.expand_more,
                        //         ),
                        //         iconSize: 18,
                        //         iconEnabledColor: Colors.black,
                        //         iconDisabledColor: Colors.grey,
                        //       ),
                        //       dropdownStyleData: DropdownStyleData(
                        //         maxHeight: 200,
                        //         decoration: BoxDecoration(
                        //           borderRadius: BorderRadius.circular(
                        //               SizeConfig.widthSize(11) * 0.8),
                        //           color: const Color(0xFFFEF1CC),
                        //         ),
                        //         offset: const Offset(0, 0),
                        //         scrollbarTheme: ScrollbarThemeData(
                        //           radius: const Radius.circular(40),
                        //           thickness: WidgetStateProperty.all<double>(6),
                        //           thumbVisibility:
                        //               WidgetStateProperty.all<bool>(true),
                        //         ),
                        //       ),
                        //       menuItemStyleData: const MenuItemStyleData(
                        //         height: 40,
                        //         padding: EdgeInsets.symmetric(horizontal: 15),
                        //       ),
                        //     ),
                        //   ),
                        // ),

                        SizedBox(height: SizeConfig.heightSize(10) * 0.8,),

                          Container(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.symmetric(
                                    vertical: SizeConfig.heightSize(5) * 0.8,
                                    horizontal:
                                    SizeConfig.heightSize(10) * 0.8),
                                minimumSize: const Size(0, 0),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              onPressed: () {
                                if (dropdownValue == 'Today\'s Tasks'){
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                        const ListScreen()),
                                  );
                                } else if (dropdownValue == 'Today\'s Events') {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                        const AllEventScreen()),
                                  );
                                } else if (dropdownValue ==
                                    'Today\'s Transactions') {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                        const AllTransactionScreen()),
                                  );
                                }
                              },
                              child: AutoSizeText(
                                'View More',
                                textScaleFactor: 1.0.sp,
                                style: TextStyle(
                                  fontSize: 8.sp,
                                  fontFamily: 'Comfortaa',
                                  color: const Color(0xFF501C1F),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        Container(
                          decoration: const BoxDecoration(color: Color(0xFFA4BE7B)),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                icon: Icon(Icons.arrow_back_ios, size: 11, color: Colors.black),
                                onPressed: _previousOption,
                              ),
                              Expanded(
                                child: Center(
                                  child: AutoSizeText(
                                    dropdownValue,
                                    textScaleFactor: 1.1.sp,
                                    style: TextStyle(
                                      fontFamily: 'Comfortaa',
                                      fontWeight: FontWeight.w700,
                                      fontSize: 10.sp,
                                    ),
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.arrow_forward_ios, size: 11, color: Colors.black),
                                onPressed: _nextOption,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: SizeConfig.heightSize(5) * 0.8,),
                        if (dropdownValue == 'Today\'s Tasks')
                          isLoading
                              ? const Center(child: CircularProgressIndicator())
                              : tasks.isEmpty
                                  ? Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10.0),
                                      child: Center(
                                        child: Column(
                                          children: [
                                            SizedBox(
                                              height:
                                                  SizeConfig.heightSize(30) *
                                                      0.8,
                                            ),
                                            Image.asset(
                                              "images/image3.png",
                                              width: SizeConfig.widthSize(146) *
                                                  0.8,
                                              height:
                                                  SizeConfig.heightSize(118) *
                                                      0.8,
                                            ),
                                            AutoSizeText(
                                              'No Tasks',
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
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      itemCount: tasks.length,
                                      itemBuilder: (context, index) {
                                        tasks.sort((a, b) =>
                                            priorityValue(a.priority).compareTo(
                                                priorityValue(b.priority)));
                                        Tasks task = tasks[index];
                                        return InkWell(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    ViewTaskDetailsScreen(
                                                  listName: task.listName,
                                                  taskName: task.taskName,
                                                  isFromHomeScreen: true,
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
                                                color: getPriorityColor(
                                                    task.priority),
                                                borderRadius:
                                                    BorderRadius.circular(15),
                                              ),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(16.0),
                                                child: Column(
                                                  children: [
                                                    Row(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  right: 16.0),
                                                          child: getPriorityIcon(
                                                              task.priority),
                                                        ),
                                                        Expanded(
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              AutoSizeText(
                                                                "Task Name: ${task.taskName}",
                                                                style:
                                                                    TextStyle(
                                                                  fontFamily:
                                                                      'Comfortaa',
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w700,
                                                                  fontSize:
                                                                      8.sp,
                                                                ),
                                                                textScaleFactor:
                                                                    1.1.sp,
                                                                maxLines: 1,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                              ),
                                                              SizedBox(
                                                                height: SizeConfig
                                                                        .heightSize(
                                                                            4) *
                                                                    0.8,
                                                              ),
                                                              AutoSizeText(
                                                                "List Name: ${task.listName}",
                                                                style:
                                                                    TextStyle(
                                                                  fontFamily:
                                                                      'Comfortaa',
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                  fontSize:
                                                                      8.sp,
                                                                  color: Colors
                                                                      .black54,
                                                                ),
                                                                textScaleFactor:
                                                                    1.1.sp,
                                                                maxLines: 1,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                              ),
                                                              SizedBox(
                                                                height: SizeConfig
                                                                        .heightSize(
                                                                            4) *
                                                                    0.8,
                                                              ),
                                                              AutoSizeText(
                                                                "Date: ${task.startDate} - ${task.endDate}",
                                                                style:
                                                                    TextStyle(
                                                                  fontFamily:
                                                                      'Comfortaa',
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                  fontSize:
                                                                      8.sp,
                                                                  color: Colors
                                                                      .black54,
                                                                ),
                                                                textScaleFactor:
                                                                    1.1.sp,
                                                                maxLines: 1,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                              ),
                                                              SizedBox(
                                                                height: SizeConfig
                                                                        .heightSize(
                                                                            4) *
                                                                    0.8,
                                                              ),
                                                              AutoSizeText(
                                                                "Time: ${task.startTime} - ${task.endTime}",
                                                                style:
                                                                    TextStyle(
                                                                  fontFamily:
                                                                      'Comfortaa',
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                  fontSize:
                                                                      8.sp,
                                                                  color: Colors
                                                                      .black54,
                                                                ),
                                                                textScaleFactor:
                                                                    1.1.sp,
                                                                maxLines: 1,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                              ),
                                                              SizedBox(
                                                                height: SizeConfig
                                                                        .heightSize(
                                                                            15) *
                                                                    0.8,
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    Container(
                                                      decoration: BoxDecoration(
                                                        color: Colors.white,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8),
                                                      ),
                                                      width: double.infinity,
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8.0),
                                                        child: Center(
                                                          child: AutoSizeText(
                                                            "Priority: ${task.priority}",
                                                            style: TextStyle(
                                                              fontFamily:
                                                                  'Comfortaa',
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w700,
                                                              fontSize: 8.sp,
                                                            ),
                                                            textScaleFactor:
                                                                1.1.sp,
                                                            maxLines: 1,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          ),
                                                        ),
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
                        if (dropdownValue == 'Today\'s Events')
                          isLoading
                              ? const Center(child: CircularProgressIndicator())
                              : events.isEmpty
                                  ? Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10.0),
                                      child: Center(
                                        child: Column(
                                          children: [
                                            SizedBox(
                                              height:
                                                  SizeConfig.heightSize(30) *
                                                      0.8,
                                            ),
                                            Image.asset(
                                              "images/image3.png",
                                              width: SizeConfig.widthSize(146) *
                                                  0.8,
                                              height:
                                                  SizeConfig.heightSize(118) *
                                                      0.8,
                                            ),
                                            AutoSizeText(
                                              'No Events',
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
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      itemCount: events.length,
                                      itemBuilder: (context, index) {
                                        Event event = events[index];
                                        return InkWell(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    ViewEventDetailsScreen(
                                                  eventName: event.eventName, isFromHomeScreen: true,
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
                                                color: const Color(0xFFA9AF7E),
                                                borderRadius:
                                                    BorderRadius.circular(15),
                                              ),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(16.0),
                                                child: Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    const Padding(
                                                      padding: EdgeInsets.only(
                                                          right: 16.0),
                                                      child: Icon(Icons.event),
                                                    ),
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          AutoSizeText(
                                                            "Event Name: ${event.eventName}",
                                                            style: TextStyle(
                                                              fontFamily:
                                                                  'Comfortaa',
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w700,
                                                              fontSize: 8.sp,
                                                            ),
                                                            textScaleFactor:
                                                                1.1.sp,
                                                            maxLines: 1,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          ),
                                                          SizedBox(
                                                            height: SizeConfig
                                                                    .heightSize(
                                                                        4) *
                                                                0.8,
                                                          ),
                                                          AutoSizeText(
                                                            "Time: ${event.startTime} - ${event.endTime}",
                                                            textScaleFactor:
                                                            1.1.sp,
                                                            style: TextStyle(
                                                              fontFamily:
                                                              'Comfortaa',
                                                              fontWeight:
                                                              FontWeight
                                                                  .w600,
                                                              fontSize: 8.sp,
                                                              color: Colors
                                                                  .black54,
                                                            ),
                                                            maxLines: 1,
                                                            overflow:
                                                            TextOverflow
                                                                .ellipsis,
                                                          ),
                                                          SizedBox(
                                                            height: SizeConfig
                                                                    .heightSize(
                                                                        4) *
                                                                0.8,
                                                          ),
                                                          AutoSizeText(
                                                            "Date: ${event.startDate} - ${event.endDate}",
                                                            style: TextStyle(
                                                              fontFamily:
                                                              'Comfortaa',
                                                              fontWeight:
                                                              FontWeight
                                                                  .w600,
                                                              fontSize: 8.sp,
                                                              color: Colors
                                                                  .black54,
                                                            ),
                                                            textScaleFactor:
                                                            1.1.sp,
                                                            maxLines: 1,
                                                            overflow:
                                                            TextOverflow
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
                        if (dropdownValue == 'Today\'s Transactions')
                          isLoading
                              ? const Center(child: CircularProgressIndicator())
                              : transactions.isEmpty
                                  ? Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10.0),
                                      child: Center(
                                        child: Column(
                                          children: [
                                            SizedBox(
                                              height:
                                                  SizeConfig.heightSize(30) *
                                                      0.8,
                                            ),
                                            Image.asset(
                                              "images/image3.png",
                                              width: SizeConfig.widthSize(146) *
                                                  0.8,
                                              height:
                                                  SizeConfig.heightSize(118) *
                                                      0.8,
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
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      itemCount: transactions.length,
                                      itemBuilder: (context, index) {
                                        Transactions transaction =
                                            transactions[index];
                                        return InkWell(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    ViewTransactionDetailsScreen(
                                                  name: transaction.name,
                                                      isFromHomeScreen: true,
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
                                                padding:
                                                    const EdgeInsets.all(16.0),
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
                                                            textScaleFactor:
                                                                1.1.sp,
                                                            style: TextStyle(
                                                              fontFamily:
                                                                  'Comfortaa',
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w700,
                                                              fontSize: 8.sp,
                                                            ),
                                                            maxLines: 1,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          ),
                                                          SizedBox(
                                                            height: SizeConfig
                                                                    .heightSize(
                                                                        4) *
                                                                0.8,
                                                          ),
                                                          AutoSizeText(
                                                            "Group: ${transaction.group}",
                                                            textScaleFactor:
                                                                1.1.sp,
                                                            style: TextStyle(
                                                              fontFamily:
                                                                  'Comfortaa',
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              fontSize: 8.sp,
                                                              color: Colors
                                                                  .black54,
                                                            ),
                                                            maxLines: 1,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          ),
                                                          SizedBox(
                                                            height: SizeConfig
                                                                    .heightSize(
                                                                        4) *
                                                                0.8,
                                                          ),
                                                          AutoSizeText(
                                                            "Category: ${transaction.category}",
                                                            textScaleFactor:
                                                                1.1.sp,
                                                            style: TextStyle(
                                                              fontFamily:
                                                                  'Comfortaa',
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              fontSize: 8.sp,
                                                              color: Colors
                                                                  .black54,
                                                            ),
                                                            maxLines: 1,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          ),
                                                          SizedBox(
                                                            height: SizeConfig
                                                                    .heightSize(
                                                                        4) *
                                                                0.8,
                                                          ),
                                                          AutoSizeText(
                                                            "RM ${double.parse(transaction.amount).toStringAsFixed(2)}",
                                                            textScaleFactor:
                                                                1.1.sp,
                                                            style: TextStyle(
                                                              fontFamily:
                                                                  'Comfortaa',
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w700,
                                                              fontSize: 8.sp,
                                                            ),
                                                            maxLines: 1,
                                                            overflow:
                                                                TextOverflow
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
                        SizedBox(
                          height: SizeConfig.heightSize(15) * 0.8,
                        ),
                      ],
                    ),
                  );
                }
              }),
        ),
      ),
    );
  }

  int priorityValue(String priority) {
    switch (priority) {
      case 'Urgent And Important':
        return 0;
      case 'Urgent But Not Important':
        return 1;
      case 'Important But Not Urgent':
        return 2;
      case 'Neither Urgent Nor Important':
        return 3;
      case 'None':
      default:
        return 4;
    }
  }

  Color getPriorityColor(String priority) {
    switch (priority) {
      case 'Urgent And Important':
        return const Color(0xFFE6A3A3);
      case 'Urgent But Not Important':
        return const Color(0xFFE6BBA3);
      case 'Important But Not Urgent':
        return const Color(0xFFE6D7A3);
      case 'Neither Urgent Nor Important':
        return const Color(0xFFACE6A3);
      default:
        return const Color(0xFFDADBDA);
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

  Icon getPriorityIcon(String priority) {
    switch (priority) {
      case 'Urgent And Important':
        return const Icon(Icons.priority_high);
      case 'Urgent But Not Important':
        return const Icon(Icons.warning);
      case 'Important But Not Urgent':
        return const Icon(Icons.star);
      case 'Neither Urgent Nor Important':
        return const Icon(Icons.low_priority);
      case 'None':
      default:
        return const Icon(Icons.help_outline);
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
