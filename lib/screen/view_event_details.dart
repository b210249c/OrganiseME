import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:organise_me/screen/all_events.dart';
import 'package:organise_me/screen/edit_event_screen.dart';
import 'package:organise_me/components/event_manager.dart';
import 'package:organise_me/screen/home_screen.dart';
import 'package:organise_me/screen/success_screen.dart';
import 'package:organise_me/components/utils.dart';
import 'package:organise_me/components/reusable_text.dart';

class ViewEventDetailsScreen extends StatefulWidget {
  static String id = 'viewEvent_screen';
  final String eventName;
  final bool isFromHomeScreen;

  const ViewEventDetailsScreen(
      {super.key, required this.eventName, required this.isFromHomeScreen});

  @override
  State<ViewEventDetailsScreen> createState() => _ViewEventDetailsScreenState();
}

class _ViewEventDetailsScreenState extends State<ViewEventDetailsScreen> {
  late EventManager _eventManager;
  late Future<void> _eventDetails;

  @override
  void initState() {
    super.initState();
    _eventManager = EventManager();
    _eventDetails = _fetchEventDetails();
  }

  Future<void> _fetchEventDetails() async {
    await _eventManager.fetchEventDetails(widget.eventName);
  }

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
                  builder: (context) => const AllEventScreen(),
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
                      builder: (context) => const AllEventScreen(),
                    ),
                  );
                }
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(
                //     builder: (context) => const HomeScreen(),
                //   ),
                // );
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
                      text: 'Edit Event',
                      fontSize: SizeConfig.heightSize(15) * 0.8,
                      color: Colors.black,
                      decoration: TextDecoration.none,
                    ),
                  ),
                  // popupmenu item 2
                  PopupMenuItem(
                    value: 1,
                    child: ReusableText(
                      text: 'Delete Event',
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
                    if(widget.isFromHomeScreen == true){
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditEventScreen(eventName: widget.eventName, isFromHomeScreen: true,),
                        ),
                      );
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              EditEventScreen(eventName: widget.eventName, isFromHomeScreen: false,),
                        ),
                      );
                    }
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(builder: (context) => EditEventScreen(eventName: widget.eventName, isFromHomeScreen: false,)),
                    // );
                  } else if (menu == 1) {
                    _showDeleteConfirmationDialog(context, widget.eventName);
                  }
                },
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
                    child: Text('Error fetching events'),
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: AutoSizeText(
                              'Event Details',
                              textScaleFactor: 1.5.sp,
                              style: TextStyle(
                                fontFamily: 'Comfortaa',
                                fontWeight: FontWeight.w700,
                                fontSize: 17.sp,
                                color: const Color(0xFF285430),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: SizeConfig.heightSize(10) * 0.8,
                          ),
                          AutoSizeText(
                            'Event Name:',
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
                                widget.eventName,
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
                            'Event Description:',
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
                                _eventManager.eventDescription,
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
                                          _eventManager.startDate,
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
                                          _eventManager.endDate,
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
                                          _eventManager.startTime,
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
                                          _eventManager.endTime,
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
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
  }
}
          ),
        ),
      ),
    );
  }

  Future<void> _showDeleteConfirmationDialog(
      BuildContext context, String eventName) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button to close the dialog
      builder: (BuildContext context) {
        return AlertDialog(
          title: AutoSizeText(
            'Delete Event',
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
                  'Are you sure you want to delete this event?',
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
                await _eventManager.deleteEvent(eventName);
                _fetchEventDetails();
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SuccessScreen(text: 'Event Deleted!', onPress: () {
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
                          builder: (context) => const AllEventScreen(),
                        ),
                      );
                    }
                  })),
                );
              },
            ),
          ],
        );
      },
    );
  }
}
