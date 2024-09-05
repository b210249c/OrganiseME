import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:month_year_picker/month_year_picker.dart';
import 'package:organise_me/components/event.dart';
import 'package:organise_me/components/reusable_button.dart';
import 'package:organise_me/components/utils.dart';
import 'package:organise_me/components/main_category.dart';
import 'package:organise_me/screen/home_screen.dart';
import 'package:organise_me/screen/view_event_details.dart';

class AllEventScreen extends StatefulWidget {
  static String id = 'allEvent_screen';

  const AllEventScreen({super.key});

  @override
  State<AllEventScreen> createState() => _AllEventScreenState();
}

class _AllEventScreenState extends State<AllEventScreen> {
  late final TextEditingController _nameController = TextEditingController();
  late final TextEditingController _amountController = TextEditingController();
  late final TextEditingController _dateController = TextEditingController();
  late final TextEditingController _toController = TextEditingController();
  late final TextEditingController _descriptionController = TextEditingController();

  DateTime? _selected;

  List<String> determineCategory(String group) {
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


  late MainCategory _mainCategory;
  String? selectedCategory;
  String? selectedSubcategory;

  @override
  void initState() {
    super.initState();
    _dateController.text = DateFormat('MMM yyyy').format(DateTime.now());
    fetchEvents(_dateController.text);
    _searchController.addListener(_filterEvents);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dateController.dispose();
    _toController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    _searchController.removeListener(_filterEvents);
    _searchController.dispose();
    super.dispose();
  }

  List<String> selectedList = [];

  bool isLoading = false;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String get _userId => _auth.currentUser!.uid;
  CollectionReference get _event =>
      _firestore.collection('users').doc(_userId).collection('events');

  final TextEditingController _searchController = TextEditingController();
  List<Event> events = [];
  List<Event> filteredEvents = [];
  Future<void> fetchEvents(String selectedMonth) async {
    setState(() {
      events.clear();
      filteredEvents.clear();
      isLoading = true;
    });

    try {
      QuerySnapshot eventSnapshot = await _event.get();

      for (QueryDocumentSnapshot eventDoc in eventSnapshot.docs) {
        Map<String, dynamic> data =
        eventDoc.data() as Map<String, dynamic>;
        String date = data['startDate'];
        String month = '${date.split(' ')[1]} ${date.split(' ')[2]}';

        if (month == selectedMonth) {
          DocumentSnapshot snapshot =
          await _event.doc(eventDoc.id).get();
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
        }
      }

      final dateFormat = DateFormat('dd MMM yyyy');
      events.sort((a, b) => dateFormat.parse(b.startDate).compareTo(dateFormat.parse(a.startDate)));

      setState(() {
        filteredEvents = events;
        isLoading = false;
        _filterEvents();
      });
    } catch (e) {
      print("Error fetching events: $e");
    }
  }

  bool _isTextFieldVisible = false;

  void _filterEvents() {
    if (_searchController.text.isEmpty) {
      setState(() {
        filteredEvents = events;
      });
    } else {
      setState(() {
        filteredEvents = events
            .where((event) => event.eventName
            .toLowerCase()
            .contains(_searchController.text.toLowerCase()))
            .toList();
      });
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
              MaterialPageRoute(builder: (context) => const HomeScreen()),
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
                  MaterialPageRoute(builder: (context) => const HomeScreen()),
                );
                // Navigator.pop(context);
              },
            ),
            title: Center(
              child: AutoSizeText(
                'Events',
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
                  Icons.calendar_month_outlined,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ReusableButton(
                      text: _dateController.text,
                      backgroundColor: const Color(0xFFFEF1CC),
                      textColor: Colors.black,
                      onPress: () async => _onPressed(context: context),
                    ),
                  ),
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          AutoSizeText(
                            'This month events:',
                            textScaleFactor: 1.0.sp,
                            style: TextStyle(
                              fontFamily: 'Comfortaa',
                              fontWeight: FontWeight.w700,
                              fontSize: 8.sp,
                            ),
                          ),
                          IconButton(
                            tooltip: 'Search',
                            icon: const Icon(Icons.search),
                            onPressed: () {
                              setState(() {
                                _isTextFieldVisible = !_isTextFieldVisible;
                              });
                            },
                          ),
                        ],
                      ),
                      if (_isTextFieldVisible)
                        SizedBox(
                          height: SizeConfig.heightSize(50) * 0.8,
                          child: MediaQuery(
                            data: MediaQuery.of(context).copyWith(
                                textScaler: TextScaler.linear(1.3.sp)),
                            child: TextField(
                              controller: _searchController,
                              decoration: InputDecoration(
                                labelText: 'Search',
                                labelStyle: TextStyle(
                                  fontFamily: 'Comfortaa',
                                  fontSize: 9.sp,
                                  fontWeight: FontWeight.w700,
                                ),
                                border: const OutlineInputBorder(),
                              ),
                              style: TextStyle(
                                fontFamily: 'Comfortaa',
                                fontSize: 9.sp, // Adjust the font size as needed
                              ),
                            ),
                          ),
                        ),
                      SizedBox(
                        height: SizeConfig.heightSize(10) * 0.8,
                      ),
                      isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : filteredEvents.isEmpty
                          ? Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10.0),
                        child: Center(
                          child: Column(
                            children: [
                              SizedBox(
                                height:
                                SizeConfig.heightSize(30) * 0.8,
                              ),
                              Image.asset(
                                "images/image3.png",
                                width:
                                SizeConfig.widthSize(146) * 0.8,
                                height:
                                SizeConfig.heightSize(118) * 0.8,
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
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: filteredEvents.length,
                        itemBuilder: (context, index) {
                          Event event =
                          filteredEvents[index];
                          return InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      ViewEventDetailsScreen(
                                        eventName: event.eventName,
                                        isFromHomeScreen: false,
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
                                  padding: const EdgeInsets.all(16.0),
                                  child: Row(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      const Padding(
                                        padding:
                                        EdgeInsets.only(
                                            right: 16.0),
                                        child: Icon(Icons.calendar_month),
                                      ),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                          CrossAxisAlignment
                                              .start,
                                          children: [
                                            AutoSizeText(
                                              "Name: ${event.eventName}",
                                              textScaleFactor: 1.1.sp,
                                              style: TextStyle(
                                                fontFamily:
                                                'Comfortaa',
                                                fontWeight:
                                                FontWeight.w700,
                                                fontSize: 8.sp,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow
                                                  .ellipsis,
                                            ),
                                            SizedBox(
                                              height: SizeConfig
                                                  .heightSize(4) *
                                                  0.8,
                                            ),
                                            AutoSizeText(
                                              "Date: ${event.startTime} - ${event.endTime}",
                                              textScaleFactor: 1.1.sp,
                                              style: TextStyle(
                                                fontFamily:
                                                'Comfortaa',
                                                fontWeight:
                                                FontWeight.w600,
                                                fontSize: 8.sp,
                                                color: Colors.black54,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow
                                                  .ellipsis,
                                            ),
                                            SizedBox(
                                              height: SizeConfig
                                                  .heightSize(4) *
                                                  0.8,
                                            ),
                                            AutoSizeText(
                                              "Time: ${event.startDate} - ${event.endDate}",
                                              textScaleFactor: 1.1.sp,
                                              style: TextStyle(
                                                fontFamily:
                                                'Comfortaa',
                                                fontWeight:
                                                FontWeight.w600,
                                                fontSize: 8.sp,
                                                color: Colors.black54,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow
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
                    ],
                  ),
                ],
              ),
            ),
          ),
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
        fetchEvents(_dateController.text);
      });
    }
  }
}
