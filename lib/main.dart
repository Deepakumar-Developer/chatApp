import 'package:expends_money/functions.dart';
import 'package:expends_money/screens/my_main_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    customStatusBar(const Color(0xff7895CB).withOpacity(0.5525),
        const Color(0xfff2f2f2), Brightness.dark, Brightness.dark);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primaryColor: const Color(0xff7895CB),
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xff7895CB),
            shadow: const Color(0xfff2f2f2),
            primary: const Color(0xff4A55A2),
            secondary: const Color(0xff7895CB),
            tertiary: const Color(0xff0f0f0f)),
        useMaterial3: true,
      ),
      home: const MyMainPage(),
    );
  }
}
