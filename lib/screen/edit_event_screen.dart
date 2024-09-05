import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:organise_me/components/event_manager.dart';
import 'package:organise_me/components/loading.dart';
import 'package:organise_me/components/notification_api.dart';
import 'package:organise_me/components/reminder_switch.dart';
import 'package:organise_me/screen/success_screen.dart';
import 'package:organise_me/components/utils.dart';
import 'package:organise_me/screen/view_event_details.dart';
import 'package:timezone/timezone.dart' as tz;

class EditEventScreen extends StatefulWidget {
  static String id = 'editEvent_screen';
   final String eventName;
   final bool isFromHomeScreen;

  const EditEventScreen({super.key, required this.eventName, required this.isFromHomeScreen});

  @override
  State<EditEventScreen> createState() => _EditEventScreenState();
}

class _EditEventScreenState extends State<EditEventScreen> {
  bool _isReminderOn = false;
  void _handleReminderChange(bool value) {
    setState(() {
      _isReminderOn = value;
    });
  }

  late TextEditingController _eventController;
  late TextEditingController _descriptionController;
  late TextEditingController _startDateController;
  late TextEditingController _endDateController;
  late TextEditingController _startTimeController;
  late TextEditingController _endTimeController;

  late EventManager _eventManager;

  Future<void> _fetchEventDetails() async {
    await _eventManager.fetchEventDetails(widget.eventName);
    setState(() {
      _eventController.text = _eventManager.eventName;
      _descriptionController.text = _eventManager.eventDescription;
      _startDateController.text = _eventManager.startDate;
      _endDateController.text = _eventManager.endDate;
      _startTimeController.text = _eventManager.startTime;
      _endTimeController.text = _eventManager.endTime;
    });
  }

  late Future<void> _eventDetails;

  @override
  void initState() {
    super.initState();
    _eventManager = EventManager();
    _eventController = TextEditingController();
    _descriptionController = TextEditingController();
    _startDateController = TextEditingController();
    _endDateController = TextEditingController();
    _startTimeController = TextEditingController();
    _endTimeController = TextEditingController();
    _eventDetails = _fetchEventDetails();
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    final format = DateFormat.jm();
    return format.format(dt);
  }

  @override
  void dispose() {
    _eventController.dispose();
    _descriptionController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    _startTimeController.dispose();
    _endTimeController.dispose();
    super.dispose();
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
        onPopInvoked: ((didpop) {
          if (!didpop) {
            if(widget.isFromHomeScreen == true){
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ViewEventDetailsScreen(eventName: _eventController.text, isFromHomeScreen: true,),
                ),
              );
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ViewEventDetailsScreen(eventName: _eventController.text, isFromHomeScreen: false,),
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
                      builder: (context) => ViewEventDetailsScreen(eventName: _eventController.text, isFromHomeScreen: true,),
                    ),
                  );
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ViewEventDetailsScreen(eventName: _eventController.text, isFromHomeScreen: false,),
                    ),
                  );
                }
                // Navigator.pop(context);
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
            future: _eventDetails,
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
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  children: [
                    AutoSizeText(
                      'Event Details',
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
                          MediaQuery(
                            data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(1.3.sp)),
                            child: TextField(
                              controller: _eventController,
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
                            data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(1.3.sp)),
                            child: TextField(
                              controller: _descriptionController,
                              decoration: InputDecoration(
                                labelText: 'Event Description',
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
                            height: SizeConfig.heightSize(10) * 0.8,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.43,
                                child: MediaQuery(
                                  data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(1.3.sp)),
                                  child: TextField(
                                    onTap: () => _selectStartDate(context),
                                    controller: _startDateController,
                                    readOnly: true,
                                    decoration: InputDecoration(
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
                                  data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(1.3.sp)),
                                  child: TextField(
                                    onTap: () => _selectEndDate(context),
                                    controller: _endDateController,
                                    readOnly: true,
                                    decoration: InputDecoration(
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
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.43,
                                child: MediaQuery(
                                  data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(1.3.sp)),
                                  child: TextField(
                                    onTap: () => _selectStartTime(context),
                                    controller: _startTimeController,
                                    readOnly: true,
                                    decoration: InputDecoration(
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
                                  data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(1.3.sp)),
                                  child: TextField(
                                    onTap: () => _selectEndTime(context),
                                    controller: _endTimeController,
                                    readOnly: true,
                                    decoration: InputDecoration(
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
                            initialValue: _eventManager.isReminderOn,
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
                                try {
                                  if (_eventController.text.isNotEmpty) {
                                    showLoadingDialog(context);
                                    Map<String, dynamic> updatedFields = {
                                      'eventName': _eventController.text,
                                      'eventDescription':
                                      _descriptionController.text.isEmpty ? 'None' : _descriptionController.text,
                                      'startDate':
                                      _startDateController.text,
                                      'endDate': _endDateController.text,
                                      'startTime':
                                      _startTimeController.text,
                                      'endTime': _endTimeController.text,
                                      'isReminderOn': _isReminderOn,
                                    };
                                    await _eventManager.updateEventDetails(
                                        widget.eventName, updatedFields);

                                    if (_isReminderOn == true) {
                                      DateFormat dateFormat =
                                      DateFormat('dd MMM yyyy');
                                      DateFormat timeFormat = DateFormat.jm();
                                      DateTime parsedDate =
                                      dateFormat.parse(_startDateController.text);
                                      DateTime parsedTime =
                                      timeFormat.parse(_startTimeController.text);

                                      var location =
                                      tz.getLocation('Asia/Kuala_Lumpur');

                                      final scheduledDate = tz.TZDateTime(
                                          location,
                                          parsedDate.year,
                                          parsedDate.month,
                                          parsedDate.day,
                                          parsedTime.hour,
                                          parsedTime.minute);

                                      // Schedule the notification
                                      NotificationApi.scheduleNotification(
                                        'Event Reminder',
                                        'You have event for today.',
                                        scheduledDate,
                                      );
                                    }

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
                                                    builder: (context) => ViewEventDetailsScreen(eventName: _eventController.text, isFromHomeScreen: true,),
                                                  ),
                                                );
                                              } else {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        ViewEventDetailsScreen(eventName: _eventController.text, isFromHomeScreen: false,),
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
                                          content: Text(
                                              'Event name should not be empty')),
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
}          ),
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
}
