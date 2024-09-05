import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:organise_me/components/notification_api.dart';
import 'package:organise_me/screen/add_task_screen.dart';
import 'package:organise_me/screen/all_events.dart';
import 'package:organise_me/screen/all_transactions.dart';
import 'package:organise_me/screen/list_screen.dart';
import 'package:organise_me/screen/edit_event_screen.dart';
import 'package:organise_me/screen/edit_task_screen.dart';
import 'package:organise_me/screen/edit_transaction_screen.dart';
import 'package:organise_me/screen/event_screen.dart';
import 'package:organise_me/screen/home_screen.dart';
import 'package:organise_me/screen/manage_category.dart';
import 'package:organise_me/screen/register_screen.dart';
import 'package:organise_me/screen/statistics_screen.dart';
import 'package:organise_me/screen/success_screen.dart';
import 'package:organise_me/screen/task_history.dart';
import 'package:organise_me/screen/task_screen.dart';
import 'package:organise_me/screen/transaction_screen.dart';
import 'package:organise_me/screen/view_event_details.dart';
import 'package:organise_me/screen/view_task_details.dart';
import 'package:organise_me/screen/view_task_history_details.dart';
import 'package:organise_me/screen/view_transaction_details.dart';
import 'package:organise_me/screen/welcome_screen.dart';
import 'package:flutter/services.dart';
import 'package:organise_me/screen/login_screen.dart';
import 'package:month_year_picker/month_year_picker.dart';

void requestNotificationPermission() async {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>()
      ?.requestNotificationsPermission();
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  NotificationApi.init();
  requestNotificationPermission();
  await Firebase.initializeApp();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((_) {
    runApp(const OrganiseME());
  });
}

class OrganiseME extends StatelessWidget {
  const OrganiseME({super.key});

  get listName => null;
  get taskName => null;
  get text => null;
  get onPress => null;
  get eventName => null;
  get name => null;
  get group => null;
  get isFromHomeScreen => null;
  get className => null;
  get payload => null;

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 800),
      minTextAdapt: true,
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          localizationsDelegates: const [
            MonthYearPickerLocalizations.delegate,
          ],
          //This defines the route it should start with
          initialRoute: WelcomeScreen.id,
          //This defines the available named routes and the widgets to build when navigating to those routes
          routes: {
            WelcomeScreen.id: (context) => const WelcomeScreen(),
            LoginScreen.id: (context) => const LoginScreen(),
            RegisterScreen.id: (context) => const RegisterScreen(),
            HomeScreen.id: (context) => const HomeScreen(),
            ListScreen.id: (context) => const ListScreen(),
            TaskScreen.id: (context) => TaskScreen(listName: listName),
            AddTaskScreen.id: (context) => AddTaskScreen(listName: taskName),
            EventScreen.id: (context) => const EventScreen(),
            TransactionScreen.id: (context) => const TransactionScreen(),
            ManageCategoryScreen.id: (context) =>
                 ManageCategoryScreen(group: group,),
            StatisticsScreen.id: (context) => const StatisticsScreen(),
            ViewTaskDetailsScreen.id: (context) => ViewTaskDetailsScreen(listName: listName, taskName: taskName, isFromHomeScreen: false,),
            ViewEventDetailsScreen.id: (context) => ViewEventDetailsScreen(eventName: eventName, isFromHomeScreen: isFromHomeScreen,),
            ViewTransactionDetailsScreen.id: (context) =>
                 ViewTransactionDetailsScreen(name: name, isFromHomeScreen: isFromHomeScreen,),
            EditTaskScreen.id: (context) => EditTaskScreen(listName: listName, taskName: taskName,isFromHomeScreen: isFromHomeScreen,),
            EditEventScreen.id: (context) => EditEventScreen(eventName: eventName, isFromHomeScreen: isFromHomeScreen,),
            EditTransactionScreen.id: (context) => EditTransactionScreen(name: name, isFromHomeScreen: isFromHomeScreen,),
            SuccessScreen.id: (context) => SuccessScreen(text: text, onPress: onPress,),
            TaskHistoryScreen.id: (context) => TaskHistoryScreen(listName: listName),
            ViewTaskHistoryDetailsScreen.id: (context) => ViewTaskHistoryDetailsScreen(listName: listName, taskName: taskName, isFromHomeScreen: false,),
            AllTransactionScreen.id: (context) => const AllTransactionScreen(),
            AllEventScreen.id: (context) => const AllEventScreen(),
          },
        );
      }
    );
  }
}
