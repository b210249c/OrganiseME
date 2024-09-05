import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:organise_me/screen/all_transactions.dart';
import 'package:organise_me/screen/edit_transaction_screen.dart';
import 'package:organise_me/screen/home_screen.dart';
import 'package:organise_me/screen/success_screen.dart';
import 'package:organise_me/components/transaction_manager.dart';
import 'package:organise_me/components/utils.dart';
import 'package:organise_me/components/reusable_text.dart';

class ViewTransactionDetailsScreen extends StatefulWidget {
  static String id = 'viewTransaction_screen';
  final String name;
  final bool isFromHomeScreen;

  const ViewTransactionDetailsScreen({super.key, required this.name, required this.isFromHomeScreen});

  @override
  State<ViewTransactionDetailsScreen> createState() =>
      _ViewTransactionDetailsScreenState();
}

class _ViewTransactionDetailsScreenState
    extends State<ViewTransactionDetailsScreen> {
  late TransactionManager _transactionManager;
  late Future<void> _transactionDetails;

  @override
  void initState() {
    super.initState();
    _transactionManager = TransactionManager();
    _transactionDetails = _fetchTransactionDetails();
  }

  Future<void> _fetchTransactionDetails() async {
    await _transactionManager.fetchTransactionDetails(widget.name);
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
                  builder: (context) => const AllTransactionScreen(),
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
                      builder: (context) => const AllTransactionScreen(),
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
                      text: 'Edit Transaction',
                      fontSize: SizeConfig.heightSize(15) * 0.8,
                      color: Colors.black,
                      decoration: TextDecoration.none,
                    ),
                  ),
                  // popupmenu item 2
                  PopupMenuItem(
                    value: 1,
                    child: ReusableText(
                      text: 'Delete Transaction',
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
                          builder: (context) => EditTransactionScreen(name: widget.name, isFromHomeScreen: true,),
                        ),
                      );
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              EditTransactionScreen(name: widget.name, isFromHomeScreen: false,),
                        ),
                      );
                    }
                  } else if (menu == 1) {
                    _showDeleteConfirmationDialog(context, widget.name);
                  }
                },
              ),
            ],
          ),
          body: FutureBuilder(
              future: _transactionDetails,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (snapshot.hasError) {
                  return const Center(
                    child: Text('Error fetching transactions'),
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
                                    'Transaction Details',
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
                                  'Name:',
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
                                    border: Border.all(color: Colors.black54),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(15.0),
                                    child: AutoSizeText(
                                      widget.name,
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
                                      width: MediaQuery.of(context).size.width *
                                          0.16,
                                      child: AutoSizeText(
                                        'Group:',
                                        textScaleFactor: 1.0.sp,
                                        style: TextStyle(
                                          fontFamily: 'Comfortaa',
                                          fontWeight: FontWeight.w700,
                                          fontSize: 11.sp,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          0.74,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFDAD9D9),
                                          borderRadius: BorderRadius.circular(
                                              SizeConfig.widthSize(11) * 0.8),
                                          border:
                                              Border.all(color: Colors.black54),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Center(
                                            child: AutoSizeText(
                                              _transactionManager.group,
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
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          0.2,
                                      child: AutoSizeText(
                                        'Category:',
                                        textScaleFactor: 1.0.sp,
                                        style: TextStyle(
                                          fontFamily: 'Comfortaa',
                                          fontWeight: FontWeight.w700,
                                          fontSize: 11.sp,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          0.7,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFDAD9D9),
                                          borderRadius: BorderRadius.circular(
                                              SizeConfig.widthSize(11) * 0.8),
                                          border:
                                              Border.all(color: Colors.black54),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Center(
                                            child: AutoSizeText(
                                              _transactionManager.category,
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
                                  'Amount:',
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
                                    border: Border.all(color: Colors.black54),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(15.0),
                                    child: AutoSizeText(
                                      'RM ${double.parse(_transactionManager.amount).toStringAsFixed(2)}',
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
                                  'Date:',
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
                                    border: Border.all(color: Colors.black54),
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
                                          _transactionManager.date,
                                          textScaleFactor: 1.0.sp,
                                          style: TextStyle(
                                            fontFamily: 'Comfortaa',
                                            fontWeight: FontWeight.w700,
                                            fontSize: 11.sp,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: SizeConfig.heightSize(20) * 0.8,
                                ),
                                AutoSizeText(
                                  'To:',
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
                                    border: Border.all(color: Colors.black54),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(15.0),
                                    child: AutoSizeText(
                                      _transactionManager.to,
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
                                  'Description:',
                                  textScaleFactor: 1.0.sp,
                                  style: TextStyle(
                                    fontFamily: 'Comfortaa',
                                    fontWeight: FontWeight.w700,
                                    fontSize: 11.sp,
                                    color: Colors.black,
                                  ),
                                  textAlign: TextAlign.justify,
                                ),
                                Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFDAD9D9),
                                    borderRadius: BorderRadius.circular(
                                        SizeConfig.widthSize(5) * 0.8),
                                    border: Border.all(color: Colors.black54),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(15.0),
                                    child: AutoSizeText(
                                      _transactionManager.description,
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
      BuildContext context, String name) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: AutoSizeText(
            'Delete Transaction',
            textScaleFactor: 1.5.sp,
            style: TextStyle(
              fontFamily: 'Comfortaa',
              fontWeight: FontWeight.w700,
              fontSize: 15.sp,
            ),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                AutoSizeText(
                  'Are you sure you want to delete this transaction?',
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
                await _transactionManager.deleteTransaction(name);
                _fetchTransactionDetails();
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => SuccessScreen(
                          text: 'Transaction Deleted!',
                          onPress: () {
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
                                  builder: (context) => const AllTransactionScreen(),
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
