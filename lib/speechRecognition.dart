import 'dart:async';

import 'package:flutter/material.dart';
import 'package:battery_plus/battery_plus.dart';




class MyHomePage1 extends StatefulWidget {
  const MyHomePage1({
    Key? key,
  }) : super(key: key);

  @override
  State<MyHomePage1> createState() => _MyHomePage1State();
}

class _MyHomePage1State extends State<MyHomePage1> {
  var battery = Battery();
  int percentage = 0;
  late Timer timer;



  @override
  void initState() {
    super.initState();

    Timer.periodic(const Duration(seconds: 5), (timer) {
      getBatteryPerentage();

    });


  }
  void getBatteryPerentage() async {
    final level = await battery.batteryLevel;
    percentage = level;

    setState(() {});
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('Battery Percentage: $percentage',
          style: const TextStyle(fontSize: 24),),
      ),
    );
  }
}
