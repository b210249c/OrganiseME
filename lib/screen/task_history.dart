import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:organise_me/components/auth_service.dart';
import 'package:organise_me/screen/list_screen.dart';
import 'package:organise_me/screen/event_screen.dart';
import 'package:organise_me/screen/home_screen.dart';
import 'package:organise_me/components/profile_picture.dart';
import 'package:organise_me/screen/statistics_screen.dart';
import 'package:organise_me/components/task.dart';
import 'package:organise_me/components/task_manager.dart';
import 'package:organise_me/screen/task_screen.dart';
import 'package:organise_me/screen/transaction_screen.dart';
import 'package:organise_me/components/utils.dart';
import 'package:organise_me/screen/view_task_history_details.dart';
import 'package:organise_me/screen/welcome_screen.dart';
import 'package:organise_me/components/reusable_button.dart';

class TaskHistoryScreen extends StatefulWidget {
  static String id = 'taskHistory_screen';
  final String listName;

  const TaskHistoryScreen({super.key, required this.listName});

  @override
  State<TaskHistoryScreen> createState() => _TaskHistoryScreenState();
}

class _TaskHistoryScreenState extends State<TaskHistoryScreen>
    with SingleTickerProviderStateMixin {
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

  String selectedValue = "All Tasks";

  late TaskManager _taskManager;
  late Future<void> _tasks;

  @override
  void initState() {
    super.initState();
    _taskManager = TaskManager();
    _tasks = _fetchTasks();
    _profilePicture.setUpdateCallback(() {
      setState(() {});
    });
    _profilePicture.loadProfilePicture(isLoading);
    _loadUsername();
  }

  Future<void> _fetchTasks() async {
    isLoading = true;
    await _taskManager.fetchTaskHistory(widget.listName);
    setState(() {
      isLoading = false;
    });
  }

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String get _userId => _auth.currentUser!.uid;
  CollectionReference get _list =>
      _firestore.collection('users').doc(_userId).collection('lists');

  final List<TaskName> _task = [];
  Future<void> fetchTasks([String? priority]) async {
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _task.clear();
    });

    try {
      QuerySnapshot listSnapshot = await _list.get();
      for (var listDoc in listSnapshot.docs) {
        CollectionReference tasksCollection =
            listDoc.reference.collection('tasks');
        QuerySnapshot tasksSnapshot;

        if (priority != null) {
          tasksSnapshot = await tasksCollection
              .where('priority', isEqualTo: priority)
              .get();
        } else {
          tasksSnapshot = await tasksCollection.get();
        }

        for (QueryDocumentSnapshot taskDoc in tasksSnapshot.docs) {
          DocumentSnapshot snapshot =
              await tasksCollection.doc(taskDoc.id).get();
          TaskName task = TaskName(
            taskName: snapshot['taskName'] as String,
            priority: snapshot['priority'] as String,
          );
          setState(() {
            _task.add(task);
            isLoading = false;
          });
        }
      }
    } catch (e) {
      print("Error fetching tasks: $e");
    }
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
              MaterialPageRoute(
                  builder: (context) => TaskScreen(listName: widget.listName)),
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
                                  backgroundColor: const Color(0xFF7D8F69),
                                  textColor: Colors.white,
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
                                  backgroundColor: const Color(0xFFE5D9B6),
                                  textColor: Colors.black,
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
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 15.0),
                              child: Container(
                                alignment: Alignment.centerLeft,
                                child: Row(
                                  children: [
                                    AutoSizeText(
                                      'List Name:',
                                      textScaleFactor: 1.3.sp,
                                      style: TextStyle(
                                        fontFamily: 'Comfortaa',
                                        fontWeight: FontWeight.w700,
                                        fontSize: 17.sp,
                                        color: const Color(0xFF285430),
                                      ),
                                    ),
                                    ConstrainedBox(
                                      constraints: BoxConstraints(
                                        maxWidth:
                                            MediaQuery.of(context).size.width *
                                                0.5,
                                      ),
                                      child: Tooltip(
                                        message: 'View Task Name',
                                        child: TextButton(
                                          onPressed: () {
                                            _displayListNameDialog(context);
                                          },
                                          child: AutoSizeText(
                                            widget.listName,
                                            textScaleFactor: 1.3.sp,
                                            style: TextStyle(
                                              fontFamily: 'Comfortaa',
                                              fontWeight: FontWeight.w700,
                                              fontSize: 17.sp,
                                              color: const Color(0xFF285430),
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 15.0),
                              child: Row(
                                children: [
                                  AutoSizeText(
                                    'Completed Tasks',
                                    textScaleFactor: 1.3.sp,
                                    style: TextStyle(
                                      fontFamily: 'Comfortaa',
                                      fontWeight: FontWeight.w700,
                                      fontSize: 15.sp,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            isLoading
                                ? const Center(child: CircularProgressIndicator())
                                : SizedBox(
                                    width: double.infinity,
                                    child: _taskManager.taskHistory.isEmpty
                                        ? Padding(
                                            padding: const EdgeInsets.only(
                                                top: 70.0,
                                                left: 15.0,
                                                right: 15.0),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Image.asset(
                                                  "images/image3.png",
                                                  width: SizeConfig.widthSize(
                                                          196) *
                                                      0.8,
                                                  height: SizeConfig.heightSize(
                                                          168) *
                                                      0.8,
                                                ),
                                                AutoSizeText(
                                                  'No Completed Tasks Yet.',
                                                  textScaleFactor: 1.0.sp,
                                                  style: TextStyle(
                                                    fontFamily: 'Comfortaa',
                                                    fontWeight: FontWeight.w700,
                                                    fontSize: 10.sp,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ],
                                            ),
                                          )
                                        : ListView.builder(
                                      shrinkWrap: true,
                                      physics: const NeverScrollableScrollPhysics(),
                                      itemCount: _taskManager.taskHistory.length,
                                      itemBuilder: (context, index) {
                                        return Card(
                                          elevation: 3,
                                          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                                          child: ListTile(
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => ViewTaskHistoryDetailsScreen(
                                                    listName: widget.listName,
                                                    taskName: _taskManager.taskHistory[index],
                                                    isFromHomeScreen: false,
                                                  ),
                                                ),
                                              );
                                            },
                                            title: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                ConstrainedBox(
                                                  constraints: BoxConstraints(
                                                    maxWidth: MediaQuery.of(context).size.width * 0.56,
                                                  ),
                                                  child: AutoSizeText(
                                                    '#   ${_taskManager.taskHistory[index]}',
                                                    textScaleFactor: 1.3.sp,
                                                    style: TextStyle(
                                                      fontFamily: 'Comfortaa',
                                                      fontWeight: FontWeight.w700,
                                                      fontSize: 14.sp,
                                                      color: const Color(0xFF6A6A6A),
                                                    ),
                                                    overflow: TextOverflow.ellipsis,
                                                    maxLines: 1,
                                                  ),
                                                ),
                                                Row(
                                                  children: [
                                                    IconButton(
                                                      onPressed: () async {
                                                        _displayConfirmationDialog(
                                                          context,
                                                          _taskManager.taskHistory[index],
                                                        );
                                                      },
                                                      icon: const Icon(Icons.restore),
                                                      tooltip: 'Restore Task',
                                                    ),
                                                    IconButton(
                                                      onPressed: () async {
                                                        _showDeleteConfirmationDialog(
                                                          context,
                                                          _taskManager.taskHistory[index],
                                                        );
                                                      },
                                                      icon: const Icon(Icons.delete),
                                                      tooltip: 'Delete Task',
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
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

  Future<void> _displayListNameDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button to close the dialog
      builder: (BuildContext context) {
        return AlertDialog(
          title: AutoSizeText(
            widget.listName,
            textScaleFactor: 1.5.sp,
            style: TextStyle(
              fontFamily: 'Comfortaa',
              fontWeight: FontWeight.w700,
              fontSize: 12.sp,
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: AutoSizeText(
                'Ok',
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
          ],
        );
      },
    );
  }

  Future<void> _displayConfirmationDialog(
      BuildContext context, String taskName) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: SingleChildScrollView(
            child: AutoSizeText(
              'Restore task?',
              textScaleFactor: 1.5.sp,
              style: TextStyle(
                fontFamily: 'Comfortaa',
                fontWeight: FontWeight.w700,
                fontSize: 12.sp,
              ),
            ),
          ),
          actions: <Widget>[
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
                'Restore',
                textScaleFactor: 1.4.sp,
                style: TextStyle(
                  fontFamily: 'Comfortaa',
                  fontWeight: FontWeight.w700,
                  fontSize: 12.sp,
                  color: const Color(0xFF285430),
                ),
              ),
              onPressed: () async {


                await _taskManager.fetchHistoryDetails(taskName).then((_) {
                  String taskName = _taskManager.taskName;
                  String taskDescription = _taskManager.taskDescription;
                  String priority = _taskManager.priority;
                  String startDate = _taskManager.startDate;
                  String endDate = _taskManager.endDate;
                  String startTime = _taskManager.startTime;
                  String endTime = _taskManager.endTime;
                  bool isReminderOn = _taskManager.isReminderOn;
                  String listName = widget.listName;

                  _taskManager.addTask(taskName, taskDescription, priority, startDate, endDate, startTime, endTime, isReminderOn, listName);

                  _taskManager.deleteTaskHistory(taskName);

                  _fetchTasks();
                }).then((_){
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => TaskScreen(listName: widget.listName)),
                  );
                });



              },
            ),
          ],
        );
      },
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

  Future<void> _showDeleteConfirmationDialog(
      BuildContext context, String taskID) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: AutoSizeText(
            'Delete Task',
            textScaleFactor: 1.5.sp,
            style: TextStyle(
              fontFamily: 'Comfortaa',
              fontWeight: FontWeight.w700,
              fontSize: 17.sp,
            ),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                AutoSizeText(
                  'Are you sure you want to delete this task?',
                  textScaleFactor: 1.5.sp,
                  style: TextStyle(
                    fontFamily: 'Comfortaa',
                    fontWeight: FontWeight.w700,
                    fontSize: 12.sp,
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
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
                await _taskManager.deleteTaskHistory(taskID);
                _fetchTasks();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
