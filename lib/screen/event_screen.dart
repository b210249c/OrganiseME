import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:organise_me/components/auth_service.dart';
import 'package:organise_me/components/notification_api.dart';
import 'package:organise_me/components/reminder_switch.dart';
import 'package:organise_me/screen/list_screen.dart';
import 'package:organise_me/components/event_manager.dart';
import 'package:organise_me/screen/home_screen.dart';
import 'package:organise_me/components/loading.dart';
import 'package:organise_me/components/profile_picture.dart';
import 'package:organise_me/screen/statistics_screen.dart';
import 'package:organise_me/screen/success_screen.dart';
import 'package:organise_me/screen/transaction_screen.dart';
import 'package:organise_me/components/utils.dart';
import 'package:organise_me/screen/welcome_screen.dart';
import 'package:organise_me/components/reusable_button.dart';
import 'package:timezone/timezone.dart' as tz;

class EventScreen extends StatefulWidget {
  static String id = 'event_screen';

  const EventScreen({super.key});

  @override
  State<EventScreen> createState() => _EventScreenState();
}

class _EventScreenState extends State<EventScreen> {
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
  final TextEditingController _eventNameController = TextEditingController();
  final TextEditingController _eventDescriptionController =
      TextEditingController();
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();
  final TextEditingController _startTimeController = TextEditingController();
  final TextEditingController _endTimeController = TextEditingController();

  late EventManager _eventManager;

  @override
  void initState() {
    super.initState();
    // NotificationApi.init();
    _selectedDay = _focusedDay;
    _startDateController.text = DateFormat('dd MMM yyyy').format(DateTime.now());
    _endDateController.text = DateFormat('dd MMM yyyy').format(DateTime.now());
    _startTimeController.text = _formatTimeOfDay(TimeOfDay.now());
    _endTimeController.text = _formatTimeOfDay(TimeOfDay.now());
    _eventManager = EventManager();
    _profilePicture.setUpdateCallback(() {
      setState(() {});
    });
    _profilePicture.loadProfilePicture(isLoading);
    _loadUsername();
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    final format = DateFormat.jm();
    return format.format(dt);
  }

  @override
  void dispose() {
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }

  bool _isReminderOn = false;
  void _handleReminderChange(bool value) {
    setState(() {
      _isReminderOn = value;
    });
  }

  final List<String> regular = [
    'Day',
    'Week',
    'Fortnight',
    'Month',
    'Year',
    'None',
  ];
  String? selectedRegular;

  final List<String> days = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
    'None',
  ];
  String? selectedDays;

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
                              fontFamily: 'Comfortaa',
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w700),
                        ),
                        content: AutoSizeText(
                          textScaleFactor: 1.3.sp,
                          'Are you sure you want to logout?',
                          style: TextStyle(
                              fontFamily: 'Comfortaa',
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w700),
                        ),
                        actions: <Widget>[
                          TextButton(
                            child: AutoSizeText(
                              textScaleFactor: 1.2.sp,
                              'Cancel',
                              style: TextStyle(
                                  fontFamily: 'Comfortaa',
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w700),
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
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w700),
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
                                fontFamily: 'Comfortaa',
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w700),
                          ),
                          content: AutoSizeText(
                            textScaleFactor: 1.3.sp,
                            'Are you sure you want to logout?',
                            style: TextStyle(
                                fontFamily: 'Comfortaa',
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w700),
                          ),
                          actions: <Widget>[
                            TextButton(
                              child: AutoSizeText(
                                textScaleFactor: 1.2.sp,
                                'Cancel',
                                style: TextStyle(
                                    fontFamily: 'Comfortaa',
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w700),
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
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w700),
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
          body: CustomScrollView(
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
                          backgroundColor: const Color(0xFF7D8F69),
                          textColor: Colors.white,
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
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15.0,
                      ),
                      child: Column(
                        children: [
                          Container(
                            alignment: Alignment.centerLeft,
                            child: AutoSizeText(
                              'Add New Event',
                              textScaleFactor: 1.5.sp,
                              style: TextStyle(
                                fontFamily: 'Comfortaa',
                                fontWeight: FontWeight.w700,
                                fontSize: 14.sp,
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
                              controller: _eventNameController,
                              decoration: InputDecoration(
                                labelText: 'Event Name',
                                hintText: 'Enter event name',
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
                              controller: _eventDescriptionController,
                              decoration: InputDecoration(
                                labelText: 'Event Description (Optional)',
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
                              maxLines: null,
                            ),
                          ),
                          SizedBox(
                            height: SizeConfig.heightSize(20) * 0.8,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.43,
                                child: MediaQuery(
                                  data: MediaQuery.of(context).copyWith(
                                      textScaler: TextScaler.linear(1.3.sp)),
                                  child: TextField(
                                    onTap: () => _selectStartDate(context),
                                    controller: _startDateController,
                                    readOnly: true,
                                    decoration: InputDecoration(
                                      prefixIcon:
                                          const Icon(Icons.calendar_month),
                                      labelText: 'Start Date',
                                      hintText: 'Select start date',
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
                              ),
                              AutoSizeText(
                                '-',
                                textScaleFactor: 1.5.sp,
                                style: TextStyle(
                                  fontFamily: 'Comfortaa',
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15.sp,
                                  color: Colors.black,
                                ),
                              ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.43,
                                child: MediaQuery(
                                  data: MediaQuery.of(context).copyWith(
                                      textScaler: TextScaler.linear(1.3.sp)),
                                  child: TextField(
                                    onTap: () => _selectEndDate(context),
                                    controller: _endDateController,
                                    readOnly: true,
                                    decoration: InputDecoration(
                                      prefixIcon:
                                          const Icon(Icons.calendar_month),
                                      labelText: 'End Date',
                                      hintText: 'Select end date',
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
                              ),
                            ],
                          ),
                          SizedBox(
                            height: SizeConfig.heightSize(10) * 0.8,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.43,
                                child: MediaQuery(
                                  data: MediaQuery.of(context).copyWith(
                                      textScaler: TextScaler.linear(1.3.sp)),
                                  child: TextField(
                                    onTap: () => _selectStartTime(context),
                                    controller: _startTimeController,
                                    readOnly: true,
                                    decoration: InputDecoration(
                                      prefixIcon: const Icon(Icons.access_time),
                                      labelText: 'Start Time',
                                      hintText: 'Select start time',
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
                              ),
                              AutoSizeText(
                                '-',
                                textScaleFactor: 1.5.sp,
                                style: TextStyle(
                                  fontFamily: 'Comfortaa',
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15.sp,
                                  color: Colors.black,
                                ),
                              ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.43,
                                child: MediaQuery(
                                  data: MediaQuery.of(context).copyWith(
                                      textScaler: TextScaler.linear(1.3.sp)),
                                  child: TextField(
                                    onTap: () => _selectEndTime(context),
                                    controller: _endTimeController,
                                    readOnly: true,
                                    decoration: InputDecoration(
                                      prefixIcon: const Icon(Icons.access_time),
                                      labelText: 'End Time',
                                      hintText: 'Select end time',
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
                              ),
                            ],
                          ),
                          ReminderSwitch(
                            initialValue: _isReminderOn,
                            onChanged: _handleReminderChange,
                            activeColor: const Color(0xFF799F56),
                          ),
                          SizedBox(
                            height: SizeConfig.heightSize(50) * 0.8,
                          ),
                          Container(
                            width: SizeConfig.scaleSize(167),
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
                                showLoadingDialog(context);
                                String eventName = _eventNameController.text;
                                String eventDescription =
                                    _eventDescriptionController.text.isEmpty
                                        ? 'None'
                                        : _eventDescriptionController.text;
                                String startDate = _startDateController.text;
                                String endDate = _endDateController.text;
                                String startTime = _startTimeController.text;
                                String endTime = _endTimeController.text;
                                bool isReminderOn = _isReminderOn;

                                if (eventName.isNotEmpty) {
                                  await _eventManager.addEvent(eventName, eventDescription, startDate, endDate, startTime, endTime, isReminderOn);

                                  if (_isReminderOn == true) {
                                    DateFormat dateFormat = DateFormat('dd MMM yyyy');
                                    DateFormat timeFormat = DateFormat.jm();
                                    DateTime parsedDate = dateFormat.parse(startDate);
                                    DateTime parsedTime = timeFormat.parse(startTime);
                                    
                                    var location = tz.getLocation('Asia/Kuala_Lumpur');

                                    final scheduledDate = tz.TZDateTime(location, parsedDate.year, parsedDate.month, parsedDate.day, parsedTime.hour, parsedTime.minute);

                                    NotificationApi.scheduleNotification(
                                      'Event Reminder',
                                      'You have event(s) for today.',
                                      scheduledDate,
                                    );
                                  }

                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => SuccessScreen(
                                          text: 'Event Added',
                                          onPress: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    const EventScreen(),
                                              ),
                                            );
                                          }),
                                    ),
                                  );
                                } else {
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text(
                                            'Event name should not be empty')),
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
                                'Add Event',
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
          ),
        ),
      ),
    );
  }

  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        _startDateController.text = DateFormat('dd MMM yyyy').format(picked);
      });
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        _endDateController.text = DateFormat('dd MMM yyyy').format(picked);
      });
    }
  }

  Future<void> _selectStartTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null && picked != TimeOfDay.now()) {
      setState(() {
        _startTimeController.text = _formatTimeOfDay(picked);
      });
    }
  }

  Future<void> _selectEndTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null && picked != TimeOfDay.now()) {
      setState(() {
        _endTimeController.text = _formatTimeOfDay(picked);
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
