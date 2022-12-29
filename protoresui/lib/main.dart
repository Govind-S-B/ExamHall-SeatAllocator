import 'package:flutter/material.dart';
import 'Screens/ScreenMaybe.dart';


void main()
{runApp(MyApp());}


class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(primaryColor: const Color(0xFFF5A8FA)),
      home:MaybeScreen(),
    );
  }
}