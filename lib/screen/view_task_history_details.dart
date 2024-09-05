import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:organise_me/components/task.dart';
import 'package:organise_me/screen/task_history.dart';
import 'package:organise_me/components/task_manager.dart';
import 'package:organise_me/screen/task_screen.dart';
import 'package:organise_me/components/utils.dart';

class ViewTaskHistoryDetailsScreen extends StatefulWidget {
  static String id = 'viewTaskHistory_screen';
  final String listName;
  final String taskName;
  final bool isFromHomeScreen;

  const ViewTaskHistoryDetailsScreen(
      {super.key, required this.listName, required this.taskName, required this.isFromHomeScreen});

  @override
  State<ViewTaskHistoryDetailsScreen> createState() => _ViewTaskHistoryDetailsScreenState();
}

class _ViewTaskHistoryDetailsScreenState extends State<ViewTaskHistoryDetailsScreen> {
  late TaskManager _taskManager;
  late Future<void> _taskDetails;

  @override
  void initState() {
    super.initState();
    _taskManager = TaskManager();
    _taskDetails = _fetchTaskDetails();
    _fetchTasks();
  }

  Future<void> _fetchTaskDetails() async {
    await _taskManager.fetchHistoryDetails(widget.taskName);
  }

  Future<void> _fetchTasks() async {
    await _taskManager.fetchTaskName(widget.listName);
  }

  List<Tasks> tasks = [];

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
                  builder: (context) => TaskHistoryScreen(
                      listName: widget.listName)),
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
                    builder: (context) => TaskHistoryScreen(
                        listName: widget.listName),
                  ),
                );
              },
            ),
            title: Center(
              child: AutoSizeText(
                'View',
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
                  Icons.history,
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
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: Container(
                            alignment: Alignment.centerLeft,
                            child: Column(
                              children: [
                                AutoSizeText(
                                  'Completed Task Details',
                                  textScaleFactor: 1.3.sp,
                                  style: TextStyle(
                                    fontFamily: 'Comfortaa',
                                    fontWeight: FontWeight.w700,
                                    fontSize: 17.sp,
                                    color: const Color(0xFF285430),
                                  ),
                                ),
                                SizedBox(
                                  height: SizeConfig.heightSize(20) * 0.8,
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      height: SizeConfig.heightSize(10) * 0.8,
                                    ),
                                    AutoSizeText(
                                      'List Name:',
                                      textScaleFactor: 1.0.sp,
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
                                    SizedBox(
                                      height: SizeConfig.heightSize(20) * 0.8,
                                    ),
                                    AutoSizeText(
                                      'Task Name:',
                                      textScaleFactor: 1.0.sp,
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
                                          _taskManager.taskName,
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
                                    SizedBox(
                                      height: SizeConfig.heightSize(20) * 0.8,
                                    ),
                                    AutoSizeText(
                                      'Task Description:',
                                      textScaleFactor: 1.0.sp,
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
                                          _taskManager.taskDescription,
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
                                    SizedBox(
                                      height: SizeConfig.heightSize(20) * 0.8,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                      children: [
                                        SizedBox(
                                          width: MediaQuery.of(context)
                                              .size
                                              .width *
                                              0.16,
                                          child: AutoSizeText(
                                            'Priority:',
                                            textScaleFactor: 1.0.sp,
                                            style: TextStyle(
                                              fontFamily: 'Comfortaa',
                                              fontWeight: FontWeight.w700,
                                              fontSize: 11.sp,
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          width: MediaQuery.of(context)
                                              .size
                                              .width *
                                              0.74,
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFDAD9D9),
                                              borderRadius:
                                              BorderRadius.circular(
                                                  SizeConfig.widthSize(11) *
                                                      0.8),
                                              border: Border.all(
                                                  color: Colors.black54),
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: Center(
                                                child: AutoSizeText(
                                                  _taskManager.priority,
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
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: SizeConfig.heightSize(20) * 0.8,
                                    ),
                                    AutoSizeText(
                                      'Date ( From - To ):',
                                      textScaleFactor: 1.0.sp,
                                      style: TextStyle(
                                        fontFamily: 'Comfortaa',
                                        fontWeight: FontWeight.w700,
                                        fontSize: 11.sp,
                                        color: Colors.black,
                                      ),
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                      children: [
                                        SizedBox(
                                          width: MediaQuery.of(context)
                                              .size
                                              .width *
                                              0.43,
                                          child: Container(
                                            width: double.infinity,
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFDAD9D9),
                                              borderRadius:
                                              BorderRadius.circular(
                                                  SizeConfig.widthSize(5) *
                                                      0.8),
                                              border: Border.all(
                                                  color: Colors.black54),
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.all(11.0),
                                              child: Row(
                                                children: [
                                                  const Icon(Icons.calendar_month),
                                                  const SizedBox(
                                                    width: 10,
                                                  ),
                                                  AutoSizeText(
                                                    _taskManager.startDate,
                                                    textScaleFactor: 1.0.sp,
                                                    style: TextStyle(
                                                      fontFamily: 'Comfortaa',
                                                      fontWeight:
                                                      FontWeight.w700,
                                                      fontSize: 11.sp,
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                ],
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
                                          width: MediaQuery.of(context)
                                              .size
                                              .width *
                                              0.43,
                                          child: Container(
                                            width: double.infinity,
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFDAD9D9),
                                              borderRadius:
                                              BorderRadius.circular(
                                                  SizeConfig.widthSize(5) *
                                                      0.8),
                                              border: Border.all(
                                                  color: Colors.black54),
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.all(11.0),
                                              child: Row(
                                                children: [
                                                  const Icon(Icons.calendar_month),
                                                  const SizedBox(
                                                    width: 10,
                                                  ),
                                                  AutoSizeText(
                                                    _taskManager.endDate,
                                                    textScaleFactor: 1.0.sp,
                                                    style: TextStyle(
                                                      fontFamily: 'Comfortaa',
                                                      fontWeight:
                                                      FontWeight.w700,
                                                      fontSize: 11.sp,
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: SizeConfig.heightSize(20) * 0.8,
                                    ),
                                    AutoSizeText(
                                      'Time ( From - To ):',
                                      textScaleFactor: 1.0.sp,
                                      style: TextStyle(
                                        fontFamily: 'Comfortaa',
                                        fontWeight: FontWeight.w700,
                                        fontSize: 11.sp,
                                        color: Colors.black,
                                      ),
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                      children: [
                                        SizedBox(
                                          width: MediaQuery.of(context)
                                              .size
                                              .width *
                                              0.43,
                                          child: Container(
                                            width: double.infinity,
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFDAD9D9),
                                              borderRadius:
                                              BorderRadius.circular(
                                                  SizeConfig.widthSize(5) *
                                                      0.8),
                                              border: Border.all(
                                                  color: Colors.black54),
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.all(11.0),
                                              child: Row(
                                                children: [
                                                  const Icon(Icons.access_time),
                                                  const SizedBox(
                                                    width: 10,
                                                  ),
                                                  AutoSizeText(
                                                    _taskManager.startTime,
                                                    textScaleFactor: 1.0.sp,
                                                    style: TextStyle(
                                                      fontFamily: 'Comfortaa',
                                                      fontWeight:
                                                      FontWeight.w700,
                                                      fontSize: 11.sp,
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                ],
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
                                          width: MediaQuery.of(context)
                                              .size
                                              .width *
                                              0.43,
                                          child: Container(
                                            width: double.infinity,
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFDAD9D9),
                                              borderRadius:
                                              BorderRadius.circular(
                                                  SizeConfig.widthSize(5) *
                                                      0.8),
                                              border: Border.all(
                                                  color: Colors.black54),
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.all(11.0),
                                              child: Row(
                                                children: [
                                                  const Icon(Icons.access_time),
                                                  const SizedBox(
                                                    width: 10,
                                                  ),
                                                  AutoSizeText(
                                                    _taskManager.endTime,
                                                    textScaleFactor: 1.0.sp,
                                                    style: TextStyle(
                                                      fontFamily: 'Comfortaa',
                                                      fontWeight:
                                                      FontWeight.w700,
                                                      fontSize: 11.sp,
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: SizeConfig.heightSize(30) * 0.8,
                                    ),
                                  ],
                                ),
                                Center(
                                  child: Container(
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
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (context) => TaskScreen(listName: widget.listName)),
                                        );

                                        await _taskManager.fetchHistoryDetails(widget.taskName).then((_) {
                                          String taskName = _taskManager.taskName;
                                          String taskDescription = _taskManager.taskDescription;
                                          String priority = _taskManager.priority;
                                          String startDate = _taskManager.startDate;
                                          String endDate = _taskManager.endDate;
                                          String startTime = _taskManager.startTime;
                                          String endTime = _taskManager.endTime;
                                          bool isReminderOn = _taskManager.isReminderOn;
                                          String listName = widget.listName;

                                          _taskManager.addTask(taskName, taskDescription, priority, startDate, endDate, startTime, endTime, isReminderOn,listName);

                                          _taskManager.deleteTaskHistory(taskName);

                                          _fetchTasks();
                                        });

                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF282828),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                              SizeConfig.widthSize(11) * 0.8),
                                        ),
                                      ),
                                      child: AutoSizeText(
                                        'Restore Task',
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
                                ),
                                SizedBox(
                                  height: SizeConfig.heightSize(20) * 0.8,
                                ),
                              ],
                            ),
                          ),
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
}
