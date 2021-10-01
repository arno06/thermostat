import 'dart:io';

import 'package:desktop_window/desktop_window.dart';
import 'package:flutter/material.dart';
import 'package:thermostat/widgets/MainApp.dart';
import 'package:window_size/window_size.dart';

void main() async {

  WidgetsFlutterBinding.ensureInitialized();

  if(Platform.isLinux){
    setWindowTitle('Thermostat');
    await DesktopWindow.setFullScreen(true);
  }
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Thermostat',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MainApp(),
    );
  }
}
