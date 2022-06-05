import 'package:calendar_view/calendar_view.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'model/event.dart';
import 'pages/mobile/mobile_home_page.dart';
import 'pages/web/web_home_page.dart';
import 'widgets/responsive_widget.dart';
import 'login_app/login_refactor.dart';

DateTime get _now => DateTime.now();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(),
      home: ResponsiveWidget(
        mobileWidget: LogInRefac(),
        webWidget: WebHomePage(),
      )
    );
  }
}
