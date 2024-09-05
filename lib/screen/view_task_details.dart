import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:organise_me/screen/edit_task_screen.dart';
import 'package:organise_me/screen/home_screen.dart';
import 'package:organise_me/components/task.dart';
import 'package:organise_me/components/task_manager.dart';
import 'package:organise_me/screen/task_screen.dart';
import 'package:organise_me/components/utils.dart';
import 'package:organise_me/components/reusable_text.dart';

class ViewTaskDetailsScreen extends StatefulWidget {
  static String id = 'viewTask_screen';
  final String listName;
  final String taskName;
  final bool isFromHomeScreen;

  const ViewTaskDetailsScreen(
      {super.key, required this.listName, required this.taskName, required this.isFromHomeScreen});

  @override
  State<ViewTaskDetailsScreen> createState() => _ViewTaskDetailsScreenState();
}

class _ViewTaskDetailsScreenState extends State<ViewTaskDetailsScreen> {
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
    await _taskManager.fetchTaskDetails(widget.taskName);
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
            if(widget.isFromHomeScreen == true){
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const HomeScreen(),
                ),
              );
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TaskScreen(
                      listName: widget.listName),
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
                      builder: (context) => const HomeScreen(),
                    ),
                  );
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TaskScreen(
                          listName: widget.listName),
                    ),
                  );
                }

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
            actions: [
              PopupMenuButton<int>(
                icon: const Icon(Icons.more_vert, color: Colors.white),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 0,
                    child: ReusableText(
                      text: 'Edit Task',
                      fontSize: SizeConfig.heightSize(15) * 0.8,
                      color: Colors.black,
                      decoration: TextDecoration.none,
                    ),
                  ),
                  // popupmenu item 2
                  PopupMenuItem(
                    value: 1,
                    child: ReusableText(
                      text: 'Delete Task',
                      fontSize: SizeConfig.heightSize(15) * 0.8,
                      color: Colors.black,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ],
                offset: const Offset(0, 56),
                elevation: 2,
                onSelected: (int menu) {
                  if (menu == 0) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditTaskScreen(
                          listName: widget.listName,
                          taskName: widget.taskName,
                          isFromHomeScreen: widget.isFromHomeScreen,
                        ),
                      ),
                    );
                  } else if (menu == 1){
                      // String taskID = _taskManager.taskIDs[widget.index];
                      _showDeleteConfirmationDialog(context, widget.taskName);
                  }
                },
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
                                  'Task Details',
                                  textScaleFactor: 1.5.sp,
                                  style: TextStyle(
                                    fontFamily: 'Comfortaa',
                                    fontWeight: FontWeight.w700,
                                    fontSize: 17.sp,
                                    color: const Color(0xFF285430),
                                  ),
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
                                    // SizedBox(
                                    //   height: SizeConfig.heightSize(20) * 0.8,
                                    // ),
                                    // AutoSizeText(
                                    //   'Reminder:',
                                    //   textScaleFactor: 1.0.sp,
                                    //   style: TextStyle(
                                    //     fontFamily: 'Comfortaa',
                                    //     fontWeight: FontWeight.w700,
                                    //     fontSize: 11.sp,
                                    //     color: Colors.black,
                                    //   ),
                                    // ),
                                    // Container(
                                    //   width: double.infinity,
                                    //   decoration: BoxDecoration(
                                    //     color: const Color(0xFFDAD9D9),
                                    //     borderRadius: BorderRadius.circular(
                                    //         SizeConfig.widthSize(5) * 0.8),
                                    //     border:
                                    //         Border.all(color: Colors.black54),
                                    //   ),
                                    //   child: Padding(
                                    //     padding: const EdgeInsets.all(15.0),
                                    //     child: AutoSizeText(
                                    //       '${_taskManager.isReminderOn}',
                                    //       textScaleFactor: 1.0.sp,
                                    //       style: TextStyle(
                                    //         fontFamily: 'Comfortaa',
                                    //         fontWeight: FontWeight.w700,
                                    //         fontSize: 11.sp,
                                    //         color: Colors.black,
                                    //       ),
                                    //     ),
                                    //   ),
                                    // ),
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
                                        await _taskManager.fetchTaskDetails(widget.taskName).then((_) {
                                          String taskName = _taskManager.taskName;
                                          String taskDescription = _taskManager.taskDescription;
                                          String priority = _taskManager.priority;
                                          String startDate = _taskManager.startDate;
                                          String endDate = _taskManager.endDate;
                                          String startTime = _taskManager.startTime;
                                          String endTime = _taskManager.endTime;
                                          bool isReminderOn = _taskManager.isReminderOn;
                                          String listName = widget.listName;

                                          _taskManager.addTaskHistory(taskName, taskDescription, priority, startDate, endDate, startTime, endTime, isReminderOn, listName);

                                          _taskManager.deleteTask(widget.taskName);

                                          setState(() {
                                            _fetchTasks();
                                          });

                                        }).then((_){
                                          if (widget.isFromHomeScreen) {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(builder: (context) => const HomeScreen()),
                                            );
                                          } else {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(builder: (context) => TaskScreen(listName: widget.listName)),
                                            );
                                          }
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
                                        'Complete Task',
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

  Future<void> _showDeleteConfirmationDialog(
      BuildContext context, String taskName) async {
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
                await _taskManager.deleteTask(taskName);
                _fetchTasks();

                Navigator.of(context).pop();
                if (widget.isFromHomeScreen == true) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const HomeScreen()),
                  );
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => TaskScreen(listName: widget.listName)),
                  );
                }


              },
            ),
          ],
        );
      },
    );
  }
}
