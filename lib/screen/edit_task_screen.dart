import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:organise_me/components/loading.dart';
import 'package:organise_me/components/notification_api.dart';
import 'package:organise_me/components/reminder_switch.dart';
import 'package:organise_me/screen/success_screen.dart';
import 'package:organise_me/components/task_manager.dart';
import 'package:organise_me/components/utils.dart';
import 'package:organise_me/screen/view_task_details.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:timezone/timezone.dart' as tz;

class EditTaskScreen extends StatefulWidget {
  static String id = 'editTask_screen';
  final String taskName;
  final String listName;
  final bool isFromHomeScreen;

  const EditTaskScreen(
      {super.key, required this.taskName,
      required this.listName,
      required this.isFromHomeScreen});

  @override
  State<EditTaskScreen> createState() => _EditTaskScreenState();
}

class _EditTaskScreenState extends State<EditTaskScreen> {
  final List<String> tasks = [];

  final List<String> priorities = [
    'Urgent And Important',
    'Important But Not Urgent',
    'Urgent But Not Important',
    'Neither Urgent Nor Important',
    'None',
  ];
  String? selectedPriority;

  bool _isReminderOn = false;
  void _handleReminderChange(bool value) {
    setState(() {
      _isReminderOn = value;
    });
  }

  late TextEditingController _taskNameController;
  late TextEditingController _taskDescriptionController;
  late TextEditingController _startDateController;
  late TextEditingController _endDateController;
  late TextEditingController _startTimeController;
  late TextEditingController _endTimeController;

  late TaskManager _taskManager;

  Future<void> _fetchTaskDetails() async {
    await _taskManager.fetchTaskDetails(widget.taskName);
    setState(() {
      _taskNameController.text = _taskManager.taskName;
      _taskDescriptionController.text = _taskManager.taskDescription;
      _startDateController.text = _taskManager.startDate;
      _endDateController.text = _taskManager.endDate;
      _startTimeController.text = _taskManager.startTime;
      _endTimeController.text = _taskManager.endTime;
      selectedPriority = _taskManager.priority;
      if (!priorities.contains(selectedPriority)) {
        selectedPriority = null;
      }
      // _isReminderOn = _taskManager.isReminderOn;
    });
  }

  late Future<void> _taskDetails;

  @override
  void initState() {
    super.initState();
    _taskManager = TaskManager();
    _taskNameController = TextEditingController();
    _taskDescriptionController = TextEditingController();
    _startDateController = TextEditingController();
    _endDateController = TextEditingController();
    _startTimeController = TextEditingController();
    _endTimeController = TextEditingController();
    _taskDetails = _fetchTaskDetails();
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    final format = DateFormat.jm();
    return format.format(dt);
  }

  @override
  void dispose() {
    _taskNameController.dispose();
    _taskDescriptionController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    _startTimeController.dispose();
    _endTimeController.dispose();
    super.dispose();
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
                  builder: (context) => ViewTaskDetailsScreen(
                        listName: widget.listName,
                        taskName: widget.taskName,
                    isFromHomeScreen: widget.isFromHomeScreen,
                      ),
              ),
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
                  MaterialPageRoute(
                      builder: (context) => ViewTaskDetailsScreen(
                        listName: widget.listName,
                        taskName: widget.taskName,
                        isFromHomeScreen: widget.isFromHomeScreen,
                      )),
                );
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
                child: Icon(
                  Icons.edit,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          body: FutureBuilder(
              future: _taskDetails,
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
                            'Task Details',
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
                              SizedBox(
                                height: SizeConfig.heightSize(10) * 0.8,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  AutoSizeText(
                                    'List Name:',
                                    textScaleFactor: 0.75.sp,
                                    style: TextStyle(
                                      fontFamily: 'Comfortaa',
                                      fontWeight: FontWeight.w700,
                                      fontSize: 11.sp,
                                      color: Colors.black,
                                    ),
                                  ),
                                  Container(
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFDAD9D9),
                                      borderRadius: BorderRadius.circular(
                                          SizeConfig.widthSize(5) * 0.8),
                                      border:
                                      Border.all(color: Colors.black54),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(15.0),
                                      child: AutoSizeText(
                                        widget.listName,
                                        textScaleFactor: 1.0.sp,
                                        style: TextStyle(
                                          fontFamily: 'Comfortaa',
                                          fontWeight: FontWeight.w700,
                                          fontSize: 11.sp,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: SizeConfig.heightSize(10) * 0.8,
                              ),
                              MediaQuery(
                                data: MediaQuery.of(context).copyWith(
                                    textScaler: TextScaler.linear(1.3.sp)),
                                child: TextField(
                                  controller: _taskNameController,
                                  decoration: InputDecoration(
                                    labelText: 'Task Name',
                                    hintText: 'Enter task name',
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
                                  controller: _taskDescriptionController,
                                  decoration: InputDecoration(
                                    labelText: 'Task Description',
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width * 0.2,
                                    child: AutoSizeText(
                                      'Priority:',
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
                                        MediaQuery.of(context).size.width * 0.7,
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton2<String>(
                                        isExpanded: true,
                                        hint: Row(
                                          children: [
                                            Expanded(
                                              child: AutoSizeText(
                                                _taskManager.priority,
                                                textScaleFactor: 1.0.sp,
                                                style: TextStyle(
                                                  fontFamily: 'Comfortaa',
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 8.sp,
                                                  color: Colors.black,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                        items: priorities
                                            .map((String item) =>
                                                DropdownMenuItem<String>(
                                                  value: item,
                                                  child: AutoSizeText(
                                                    item,
                                                    textScaleFactor: 1.0.sp,
                                                    style: TextStyle(
                                                      fontFamily: 'Comfortaa',
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      fontSize: 8.sp,
                                                      color: Colors.black,
                                                    ),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ))
                                            .toList(),
                                        value: selectedPriority,
                                        onChanged: (String? value) {
                                          setState(() {
                                            selectedPriority = value;
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
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.7,
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
                                        menuItemStyleData: const MenuItemStyleData(
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
                                height: SizeConfig.heightSize(20) * 0.8,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width *
                                        0.43,
                                    child: MediaQuery(
                                      data: MediaQuery.of(context).copyWith(
                                          textScaler:
                                              TextScaler.linear(1.3.sp)),
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
                                    width: MediaQuery.of(context).size.width *
                                        0.43,
                                    child: MediaQuery(
                                      data: MediaQuery.of(context).copyWith(
                                          textScaler:
                                              TextScaler.linear(1.3.sp)),
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
                                height: SizeConfig.heightSize(20) * 0.8,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width *
                                        0.43,
                                    child: MediaQuery(
                                      data: MediaQuery.of(context).copyWith(
                                          textScaler:
                                              TextScaler.linear(1.3.sp)),
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
                                    width: MediaQuery.of(context).size.width *
                                        0.43,
                                    child: MediaQuery(
                                      data: MediaQuery.of(context).copyWith(
                                          textScaler:
                                              TextScaler.linear(1.3.sp)),
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
                              // SizedBox(
                              //   height: SizeConfig.heightSize(10) * 0.8,
                              // ),
                              ReminderSwitch(
                                initialValue: _taskManager.isReminderOn,
                                onChanged: _handleReminderChange,
                                activeColor: const Color(0xFF799F56),
                              ),
                              SizedBox(
                                height: SizeConfig.heightSize(20) * 0.8,
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
                                      if (_taskNameController.text.isNotEmpty) {
                                        showLoadingDialog(context);
                                        Map<String, dynamic> updatedFields = {
                                          'taskName': _taskNameController.text,
                                          'taskDescription':
                                              _taskDescriptionController.text.isEmpty ? 'None' : _taskDescriptionController.text,
                                          'priority': selectedPriority ?? 'None',
                                          'startDate':
                                              _startDateController.text,
                                          'endDate': _endDateController.text,
                                          'startTime':
                                              _startTimeController.text,
                                          'endTime': _endTimeController.text,
                                          // 'isReminderOn': _isReminderOn,
                                        };
                                        await _taskManager.updateTaskDetails(
                                            widget.taskName, updatedFields);

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
                                            'Task Reminder',
                                            'You have task for today.',
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
                                                          Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                                builder: (context) => ViewTaskDetailsScreen(
                                                                    listName: widget
                                                                        .listName,
                                                                    taskName: _taskNameController.text, isFromHomeScreen: widget.isFromHomeScreen,)),
                                                          );
                                                        },
                                                      )),
                                        );
                                      } else {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                              content: Text(
                                                  'Task name should not be empty')),
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
              }),
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
