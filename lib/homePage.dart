// ignore_for_file: prefer_const_literals_to_create_immutables

import 'dart:async';
import 'dart:io';

import 'package:battery_plus/battery_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:countdown_flutter/countdown_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:url_launcher/url_launcher.dart';
import 'package:wsa/authPage.dart';
import 'package:wsa/settings.dart';
import 'package:wsa/speechRecognition.dart';

import 'drivingModeDetector.dart';
import 'googleMaps.dart';
import 'notification.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var battery = Battery();
  int percentage = 0;
  late Timer timer;
  int _secondsRemaining = 5; // The number of seconds to count down
  bool _isDialogOpen = false;

  final nameController = TextEditingController();

  @override
  void initState() {
    super.initState();

    Timer.periodic(const Duration(seconds: 10), (timer) {
      getBatteryPerentage();
    });
    var initializationSettingsAndroid =
        const AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  void getBatteryPerentage() async {
    final level = await battery.batteryLevel;
    if (percentage != level) {
      FirebaseFirestore.instance
          .collection('users')
          .doc(fullUserId())
          .update({"battery": level});
    }
  }

  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  Future onSelectNotification(String payload) {
    return showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text("Payload"),
          content: Text("Payload : $payload"),
        );
      },
    );
  }

  Future<void> _showNotification(String body) async {
    var androidDetails = const AndroidNotificationDetails(
        "channelId", "Local Notification",
        importance: Importance.high);
    var generalNotificationDetails =
        NotificationDetails(android: androidDetails);
    await flutterLocalNotificationsPlugin.show(
        0, "SoS Alert", body, generalNotificationDetails,
        payload: "Welcome to the Local Notification demo");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 10, top: 5),
                  child: ShaderMask(
                    shaderCallback: (Rect bounds) {
                      return RadialGradient(
                        center: Alignment.topLeft,
                        radius: 1.0,
                        colors: <Color>[
                          Colors.yellow,
                          Colors.deepOrange.shade900
                        ],
                        tileMode: TileMode.mirror,
                      ).createShader(bounds);
                    },
                    child: const Text(
                      'WS App',
                      style: TextStyle(
                          fontSize: 30,
                          color: Colors.white,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
                const Spacer(),
                InkWell(
                  child: const Icon(
                    Icons.settings,
                    color: Colors.grey,
                    size: 30,
                  ),
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => settings()));
                  },
                ),
                const SizedBox(
                  width: 20,
                )
              ],
            ),
            Expanded(
                child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20)),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            const Text(
                              "Smart Band",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 25),
                            ),
                            const Spacer(),
                            if (false)
                              const Text(
                                "Not Conected",
                                style: TextStyle(color: Colors.red),
                              )
                            else
                              const Text(
                                "Conected",
                                style: TextStyle(color: Colors.greenAccent),
                              )
                          ],
                        ),
                      ),
                    ),
                  ),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: InkWell(
                        child: Container(
                          height: 100,
                          width: 100,
                          decoration: BoxDecoration(
                            color: Colors.pink,
                            borderRadius: BorderRadius.circular(50),
                            boxShadow: [
                              const BoxShadow(
                                  blurRadius: 25.0, color: Colors.white)
                            ],
                          ),
                          child: const Center(
                              child: Text(
                            "SOS",
                            style: TextStyle(color: Colors.white, fontSize: 35),
                          )),
                        ),
                        onTap: () {
                          if (!_isDialogOpen) {
                            _isDialogOpen = true;
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return Scaffold(
                                  backgroundColor: Colors.transparent,
                                  body: Center(
                                    child: Container(
                                      height: 250,
                                      width: 250,
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.9),
                                        borderRadius:
                                            BorderRadius.circular(125),
                                        boxShadow: [
                                          const BoxShadow(
                                              blurRadius: 25.0,
                                              color: Colors.white)
                                        ],
                                      ),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          const Text(
                                            "SOS",
                                            style: TextStyle(
                                                color: Colors.red,
                                                fontSize: 25,
                                                fontWeight: FontWeight.w700),
                                          ),
                                          const Text(
                                            "Is",
                                            style: TextStyle(
                                                color: Colors.red,
                                                fontSize: 25,
                                                fontWeight: FontWeight.w700),
                                          ),
                                          const Text(
                                            "Activited",
                                            style: TextStyle(
                                                color: Colors.greenAccent,
                                                fontSize: 25,
                                                fontWeight: FontWeight.w700),
                                          ),
                                          CountdownFormatted(
                                            duration: Duration(
                                                seconds: _secondsRemaining),
                                            onFinish: () {
                                              _showNotification(
                                                  "SoS button was pressed by ${fullUserId().split("@")[0]}");
                                              Navigator.of(context).pop();
                                            },
                                            builder: (BuildContext ctx,
                                                String remaining) {
                                              return Text(
                                                "Remaining Time : $remaining",
                                                style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 18,
                                                    fontWeight:
                                                        FontWeight.w700),
                                              );
                                            },
                                          ),
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          InkWell(
                                            child: Container(
                                              decoration: BoxDecoration(
                                                  color: Colors.black,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          100),
                                                  border: Border.all(
                                                      color: Colors.white54)),
                                              child: const Padding(
                                                padding: EdgeInsets.all(5.0),
                                                child: Text(
                                                  "Activate",
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 25,
                                                      fontWeight:
                                                          FontWeight.w700),
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 5,
                                          ),
                                          InkWell(
                                            child: Container(
                                              decoration: BoxDecoration(
                                                  color: Colors.black,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          100),
                                                  border: Border.all(
                                                      color: Colors.white54)),
                                              child: const Padding(
                                                padding: EdgeInsets.all(5.0),
                                                child: Text(
                                                  "Cancel",
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 25,
                                                      fontWeight:
                                                          FontWeight.w700),
                                                ),
                                              ),
                                            ),
                                            onTap: () {
                                              Navigator.pop(context);
                                            },
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ).then((_) {
                              _isDialogOpen = false;
                            });
                          }
                        },
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                          color: Colors.deepPurple,
                          borderRadius: BorderRadius.circular(20)),
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Row(
                          children: [
                            const Text(
                              "Family",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 25),
                            ),
                            const Spacer(),
                            InkWell(
                              child: Container(
                                decoration: BoxDecoration(
                                    color: Colors.blue,
                                    borderRadius: BorderRadius.circular(20)),
                                child: const Padding(
                                  padding: EdgeInsets.all(5.0),
                                  child: Text(
                                    "Create",
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 20),
                                  ),
                                ),
                              ),
                              onTap: () {
                                _isDialogOpen = true;
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return Scaffold(
                                      backgroundColor: Colors.transparent,
                                      body: Center(
                                        child: Container(
                                          height: 250,
                                          width: 300,
                                          decoration: BoxDecoration(
                                            color:
                                                Colors.black.withOpacity(0.6),
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            boxShadow: [
                                              BoxShadow(
                                                  blurRadius: 25.0,
                                                  color: Colors.white
                                                      .withOpacity(0.3))
                                            ],
                                          ),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const Padding(
                                                padding: EdgeInsets.only(
                                                    left: 15, top: 15),
                                                child: Text(
                                                  "Name",
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 35,
                                                      fontWeight:
                                                          FontWeight.w500),
                                                ),
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 25,
                                                        vertical: 10),
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    color: Colors.white54,
                                                    border: Border.all(
                                                        color: Colors.white
                                                            .withOpacity(0.8)),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            18),
                                                  ),
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 20),
                                                    child: TextField(
                                                      controller:
                                                          nameController,
                                                      textInputAction:
                                                          TextInputAction.next,
                                                      decoration:
                                                          const InputDecoration(
                                                        border:
                                                            InputBorder.none,
                                                        hintText:
                                                            'Enter Family Name',
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 60, right: 60),
                                                child: Row(
                                                  children: [
                                                    InkWell(
                                                      child: Container(
                                                        decoration: BoxDecoration(
                                                            color: Colors.black,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        100),
                                                            border: Border.all(
                                                                color: Colors
                                                                    .white54)),
                                                        child: const Padding(
                                                          padding:
                                                              EdgeInsets.all(
                                                                  5.0),
                                                          child: Text(
                                                            "Cancel",
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 25,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w700),
                                                          ),
                                                        ),
                                                      ),
                                                      onTap: () {
                                                        Navigator.pop(context);
                                                      },
                                                    ),
                                                    const Spacer(),
                                                    InkWell(
                                                      child: Container(
                                                        decoration: BoxDecoration(
                                                            color: Colors.black,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        100),
                                                            border: Border.all(
                                                                color: Colors
                                                                    .white54)),
                                                        child: const Padding(
                                                          padding:
                                                              EdgeInsets.all(
                                                                  5.0),
                                                          child: Text(
                                                            "Create",
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .lightBlueAccent,
                                                                fontSize: 25,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w700),
                                                          ),
                                                        ),
                                                      ),
                                                      onTap: () async {
                                                        await FirebaseFirestore.instance.collection("users").doc(fullUserId()).collection("family").doc("${fullUserId()}${nameController.text.trim()}").set({"id":"${fullUserId()}${nameController.text.trim()}","familyName":nameController.text.trim()});

                                                        await FirebaseFirestore
                                                            .instance
                                                            .collection(
                                                                "Family")
                                                            .doc(
                                                                "${fullUserId()}${nameController.text.trim()}")
                                                            .set({
                                                          "id":
                                                              "${fullUserId()}${nameController.text.trim()}",
                                                          "familyName":
                                                              nameController
                                                                  .text
                                                                  .trim()
                                                        });
                                                        showToast(
                                                            "${nameController.text.trim()}'s family created");
                                                        Navigator.pop(context);
                                                      },
                                                    )
                                                  ],
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ).then((_) {
                                  _isDialogOpen = false;
                                });
                              },
                            ),
                            const SizedBox(
                              width: 5,
                            ),
                            InkWell(
                              child: Container(
                                decoration: BoxDecoration(
                                    color: Colors.blue,
                                    borderRadius: BorderRadius.circular(20)),
                                child: Padding(
                                  padding: const EdgeInsets.all(5.0),
                                  child: Row(
                                    children: const[
                                       Text(
                                        " Add",
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 20),
                                      ),
                                       Icon(
                                        Icons.add,
                                        color: Colors.red,
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              onTap: () async {
                                _isDialogOpen = true;
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return Scaffold(
                                      backgroundColor: Colors.transparent,
                                      body: Center(
                                        child: Container(
                                          height: 250,
                                          width: 300,
                                          decoration: BoxDecoration(
                                            color:
                                                Colors.black.withOpacity(0.6),
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            boxShadow: [
                                              BoxShadow(
                                                  blurRadius: 25.0,
                                                  color: Colors.white
                                                      .withOpacity(0.3))
                                            ],
                                          ),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const Padding(
                                                padding: EdgeInsets.only(
                                                    left: 15, top: 15),
                                                child: Text(
                                                  "Add Family",
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 35,
                                                      fontWeight:
                                                          FontWeight.w500),
                                                ),
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 25,
                                                        vertical: 10),
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    color: Colors.white54,
                                                    border: Border.all(
                                                        color: Colors.white
                                                            .withOpacity(0.8)),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            18),
                                                  ),
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 20),
                                                    child: TextField(
                                                      controller:
                                                          nameController,
                                                      textInputAction:
                                                          TextInputAction.next,
                                                      decoration:
                                                          const InputDecoration(
                                                        border:
                                                            InputBorder.none,
                                                        hintText:
                                                            'Enter family token',
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 60, right: 60),
                                                child: Row(
                                                  children: [
                                                    InkWell(
                                                      child: Container(
                                                        decoration: BoxDecoration(
                                                            color: Colors.black,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        100),
                                                            border: Border.all(
                                                                color: Colors
                                                                    .white54)),
                                                        child: const Padding(
                                                          padding:
                                                              EdgeInsets.all(
                                                                  5.0),
                                                          child: Text(
                                                            "Cancel",
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 25,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w700),
                                                          ),
                                                        ),
                                                      ),
                                                      onTap: () {
                                                        Navigator.pop(context);
                                                      },
                                                    ),
                                                    const Spacer(),
                                                    InkWell(
                                                      child: Container(
                                                        decoration: BoxDecoration(
                                                            color: Colors.black,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        100),
                                                            border: Border.all(
                                                                color: Colors
                                                                    .white54)),
                                                        child: const Padding(
                                                          padding:
                                                              EdgeInsets.all(
                                                                  5.0),
                                                          child: Text(
                                                            "Create",
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .lightBlueAccent,
                                                                fontSize: 25,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w700),
                                                          ),
                                                        ),
                                                      ),
                                                      onTap: () async {
                                                        final out =
                                                            nameController.text
                                                                .split(",");
                                                        await FirebaseFirestore
                                                            .instance
                                                            .collection("users")
                                                            .doc(fullUserId())
                                                            .collection(
                                                                "family")
                                                            .doc(out[0])
                                                            .set({
                                                          "familyName": out[1],
                                                          "id": out[0]
                                                        });
                                                        showToast(
                                                            "${nameController.text.trim()}'s family created");
                                                        Navigator.pop(context);
                                                      },
                                                    )
                                                  ],
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ).then((_) {
                                  _isDialogOpen = false;
                                });
                              },
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 10, right: 10),
                    child: StreamBuilder<List<familyConvertor>>(
                        stream: readFamily(),
                        builder: (context, snapshot) {
                          final user1 = snapshot.data;
                          switch (snapshot.connectionState) {
                            case ConnectionState.waiting:
                              return const Center(
                                  child: CircularProgressIndicator(
                                strokeWidth: 0.3,
                                color: Colors.cyan,
                              ));
                            default:
                              if (snapshot.hasError) {
                                return const Center(
                                    child: Text(
                                        'Error with TextBooks Data or\n Check Internet Connection'));
                              } else {
                                return Container(
                                  decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(20)),
                                  child: ListView.separated(
                                      physics: const BouncingScrollPhysics(),
                                      shrinkWrap: true,
                                      itemCount: user1!.length,
                                      itemBuilder: (context, int index) {
                                        final SubjectsData1 = user1[index];
                                        return Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            InkWell(
                                              child: Row(
                                                children: [
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 15, top: 5),
                                                    child: Text(
                                                      SubjectsData1.familyName,
                                                      style: const TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 30),
                                                    ),
                                                  ),
                                                  const Spacer(),
                                                  InkWell(
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              right: 20,
                                                              top: 10,
                                                              bottom: 3),
                                                      child: Container(
                                                        decoration: BoxDecoration(
                                                            color: Colors.blue,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        20)),
                                                        child: const Padding(
                                                          padding:
                                                              EdgeInsets.all(
                                                                  5.0),
                                                          child: Text(
                                                            "Add Member",
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 17),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    onTap: () {
                                                      _isDialogOpen = true;
                                                      showDialog(
                                                        context: context,
                                                        builder: (BuildContext
                                                            context) {
                                                          return Scaffold(
                                                            backgroundColor:
                                                                Colors
                                                                    .transparent,
                                                            body: Center(
                                                              child: Container(
                                                                height: 250,
                                                                width: 300,
                                                                decoration:
                                                                    BoxDecoration(
                                                                  color: Colors
                                                                      .black
                                                                      .withOpacity(
                                                                          0.6),
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              20),
                                                                  boxShadow: [
                                                                    BoxShadow(
                                                                        blurRadius:
                                                                            25.0,
                                                                        color: Colors
                                                                            .white
                                                                            .withOpacity(0.3))
                                                                  ],
                                                                ),
                                                                child: Column(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .start,
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    const Padding(
                                                                      padding: EdgeInsets.only(
                                                                          left:
                                                                              15,
                                                                          top:
                                                                              15),
                                                                      child:
                                                                          Text(
                                                                        "Enter Token",
                                                                        style: TextStyle(
                                                                            color: Colors
                                                                                .white,
                                                                            fontSize:
                                                                                35,
                                                                            fontWeight:
                                                                                FontWeight.w500),
                                                                      ),
                                                                    ),
                                                                    Padding(
                                                                      padding: const EdgeInsets
                                                                              .symmetric(
                                                                          horizontal:
                                                                              25,
                                                                          vertical:
                                                                              10),
                                                                      child:
                                                                          Container(
                                                                        decoration:
                                                                            BoxDecoration(
                                                                          color:
                                                                              Colors.white54,
                                                                          border:
                                                                              Border.all(color: Colors.white.withOpacity(0.8)),
                                                                          borderRadius:
                                                                              BorderRadius.circular(18),
                                                                        ),
                                                                        child:
                                                                            Padding(
                                                                          padding:
                                                                              const EdgeInsets.only(left: 20),
                                                                          child:
                                                                              TextField(
                                                                            controller:
                                                                                nameController,
                                                                            textInputAction:
                                                                                TextInputAction.next,
                                                                            decoration:
                                                                                const InputDecoration(
                                                                              border: InputBorder.none,
                                                                              hintText: 'Enter Member Token here',
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    Padding(
                                                                      padding: const EdgeInsets
                                                                              .only(
                                                                          left:
                                                                              60,
                                                                          right:
                                                                              60),
                                                                      child:
                                                                          Row(
                                                                        children: [
                                                                          InkWell(
                                                                            child:
                                                                                Container(
                                                                              decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(100), border: Border.all(color: Colors.white54)),
                                                                              child: const Padding(
                                                                                padding: EdgeInsets.all(5.0),
                                                                                child: Text(
                                                                                  "Cancel",
                                                                                  style: TextStyle(color: Colors.white, fontSize: 25, fontWeight: FontWeight.w700),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                            onTap:
                                                                                () {
                                                                              Navigator.pop(context);
                                                                            },
                                                                          ),
                                                                          const Spacer(),
                                                                          InkWell(
                                                                            child:
                                                                                Container(
                                                                              decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(100), border: Border.all(color: Colors.white54)),
                                                                              child: const Padding(
                                                                                padding: EdgeInsets.all(5.0),
                                                                                child: Text(
                                                                                  "Create",
                                                                                  style: TextStyle(color: Colors.lightBlueAccent, fontSize: 25, fontWeight: FontWeight.w700),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                            onTap:
                                                                                () async {
                                                                                  // await FirebaseFirestore.instance.collection("users").doc(nameController.text.trim()).collection("family").doc().set({
                                                                                  //   "id": nameController.text.trim(),
                                                                                  //   "userId": nameController.text.trim()
                                                                                  // });
                                                                              await FirebaseFirestore.instance.collection("Family").doc(SubjectsData1.id).collection("members").doc(nameController.text.trim()).set({
                                                                                "id": nameController.text.trim(),
                                                                                "userId": nameController.text.trim()
                                                                              });
                                                                              showToast("${nameController.text.trim()}'s member Added");
                                                                              Navigator.pop(context);
                                                                            },
                                                                          )
                                                                        ],
                                                                      ),
                                                                    )
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                      ).then((_) {
                                                        _isDialogOpen = false;
                                                      });
                                                    },
                                                  ),
                                                ],
                                              ),
                                              onLongPress: () async {
                                                _isDialogOpen = true;
                                                showDialog(
                                                  context: context,
                                                  builder:
                                                      (BuildContext context) {
                                                    return Scaffold(
                                                      backgroundColor:
                                                          Colors.transparent,
                                                      body: Center(
                                                        child: Container(
                                                          height: 100,
                                                          width: 300,
                                                          decoration:
                                                              BoxDecoration(
                                                            color: Colors.black
                                                                .withOpacity(
                                                                    0.6),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        20),
                                                            boxShadow: [
                                                              BoxShadow(
                                                                  blurRadius:
                                                                      25.0,
                                                                  color: Colors
                                                                      .white
                                                                      .withOpacity(
                                                                          0.3))
                                                            ],
                                                          ),
                                                          child: Column(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .start,
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              const Padding(
                                                                padding: EdgeInsets
                                                                    .only(
                                                                        left:
                                                                            15,
                                                                        top:
                                                                            15),
                                                                child: Text(
                                                                  "Do you want delete family",
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .white,
                                                                      fontSize:
                                                                          25,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500),
                                                                ),
                                                              ),
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .only(
                                                                        left:
                                                                            60,
                                                                        right:
                                                                            60,
                                                                        top: 8),
                                                                child: Row(
                                                                  children: [
                                                                    InkWell(
                                                                      child:
                                                                          Container(
                                                                        decoration: BoxDecoration(
                                                                            color:
                                                                                Colors.black,
                                                                            borderRadius: BorderRadius.circular(100),
                                                                            border: Border.all(color: Colors.white54)),
                                                                        child:
                                                                            const Padding(
                                                                          padding:
                                                                              EdgeInsets.all(5.0),
                                                                          child:
                                                                              Text(
                                                                            "Cancel",
                                                                            style: TextStyle(
                                                                                color: Colors.white,
                                                                                fontSize: 25,
                                                                                fontWeight: FontWeight.w700),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      onTap:
                                                                          () {
                                                                        Navigator.pop(
                                                                            context);
                                                                      },
                                                                    ),
                                                                    const Spacer(),
                                                                    InkWell(
                                                                      child:
                                                                          Container(
                                                                        decoration: BoxDecoration(
                                                                            color:
                                                                                Colors.black,
                                                                            borderRadius: BorderRadius.circular(100),
                                                                            border: Border.all(color: Colors.white54)),
                                                                        child:
                                                                            const Padding(
                                                                          padding:
                                                                              EdgeInsets.all(5.0),
                                                                          child:
                                                                              Text(
                                                                            "Delete",
                                                                            style: TextStyle(
                                                                                color: Colors.lightBlueAccent,
                                                                                fontSize: 25,
                                                                                fontWeight: FontWeight.w700),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      onTap:
                                                                          () async {
                                                                        await FirebaseFirestore
                                                                            .instance
                                                                            .collection("Family")
                                                                            .doc(SubjectsData1.id)
                                                                            .delete();
                                                                        showToast(
                                                                            "${nameController.text.trim()}'s family created");
                                                                        Navigator.pop(
                                                                            context);
                                                                      },
                                                                    )
                                                                  ],
                                                                ),
                                                              )
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                ).then((_) {
                                                  _isDialogOpen = false;
                                                });
                                              },
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: StreamBuilder<
                                                      List<
                                                          familyMemberConvertor>>(
                                                  stream: readFamilyMember(
                                                      SubjectsData1.id),
                                                  builder: (context, snapshot) {
                                                    final user1 = snapshot.data;
                                                    switch (snapshot
                                                        .connectionState) {
                                                      case ConnectionState
                                                          .waiting:
                                                        return const Center(
                                                            child:
                                                                CircularProgressIndicator(
                                                          strokeWidth: 0.3,
                                                          color: Colors.cyan,
                                                        ));
                                                      default:
                                                        if (snapshot.hasError) {
                                                          return const Center(
                                                              child: Text(
                                                                  'Error with TextBooks Data or\n Check Internet Connection'));
                                                        } else {
                                                          return ListView
                                                              .separated(
                                                                  physics:
                                                                      const BouncingScrollPhysics(),
                                                                  shrinkWrap:
                                                                      true,
                                                                  itemCount:
                                                                      user1!
                                                                          .length,
                                                                  itemBuilder:
                                                                      (context,
                                                                          int
                                                                              index) {
                                                                    final SubjectsData2 =
                                                                        user1[
                                                                            index];
                                                                    return StreamBuilder<
                                                                            DocumentSnapshot>(
                                                                        stream: FirebaseFirestore
                                                                            .instance
                                                                            .collection(
                                                                                "users")
                                                                            .doc(SubjectsData2
                                                                                .userId)
                                                                            .snapshots(),
                                                                        builder:
                                                                            (context,
                                                                                mainsnapshot) {
                                                                          switch (
                                                                              mainsnapshot.connectionState) {
                                                                            case ConnectionState.waiting:
                                                                              return const Center(
                                                                                  child: CircularProgressIndicator(
                                                                                strokeWidth: 0.3,
                                                                                color: Colors.cyan,
                                                                              ));
                                                                            default:
                                                                              if (mainsnapshot.data!.exists && fullUserId() != "SubjectsData2.userId") {
                                                                                return InkWell(
                                                                                  child: Padding(
                                                                                    padding: const EdgeInsets.all(8.0),
                                                                                    child: Row(
                                                                                      children: [
                                                                                        Container(
                                                                                          height: 60,
                                                                                          width: 60,
                                                                                          decoration: BoxDecoration(color: Colors.white, image: const DecorationImage(image: NetworkImage("https://pub.dev/static/hash-aps7rpf8/img/ff-banner-mobile-2x.png"), fit: BoxFit.cover), borderRadius: BorderRadius.circular(35)),
                                                                                          child: Align(
                                                                                              alignment: Alignment.bottomCenter,
                                                                                              child: Container(
                                                                                                decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(10)),
                                                                                                child: Row(
                                                                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                                                                  children: [
                                                                                                    const SizedBox(
                                                                                                      width: 3,
                                                                                                    ),
                                                                                                    if (mainsnapshot.data!["battery"] < 10)
                                                                                                      Transform.rotate(
                                                                                                          angle: -1.575,
                                                                                                          child: const Icon(
                                                                                                            Icons.battery_0_bar,
                                                                                                            size: 20,
                                                                                                            color: Colors.red,
                                                                                                          ))
                                                                                                    else if (mainsnapshot.data!["battery"] < 20)
                                                                                                      Transform.rotate(
                                                                                                          angle: -1.575,
                                                                                                          child: const Icon(
                                                                                                            Icons.battery_1_bar,
                                                                                                            size: 20,
                                                                                                            color: Colors.redAccent,
                                                                                                          ))
                                                                                                    else if (mainsnapshot.data!["battery"] < 35)
                                                                                                      Transform.rotate(
                                                                                                          angle: -1.575,
                                                                                                          child: Icon(
                                                                                                            Icons.battery_2_bar,
                                                                                                            size: 20,
                                                                                                            color: Colors.orangeAccent.shade400,
                                                                                                          ))
                                                                                                    else if (mainsnapshot.data!["battery"] < 50)
                                                                                                      Transform.rotate(
                                                                                                          angle: -1.575,
                                                                                                          child: const Icon(
                                                                                                            Icons.battery_3_bar,
                                                                                                            size: 20,
                                                                                                            color: Colors.orangeAccent,
                                                                                                          ))
                                                                                                    else if (mainsnapshot.data!["battery"] < 65)
                                                                                                      Transform.rotate(
                                                                                                          angle: -1.575,
                                                                                                          child: const Icon(
                                                                                                            Icons.battery_4_bar,
                                                                                                            size: 20,
                                                                                                            color: Colors.orange,
                                                                                                          ))
                                                                                                    else if (mainsnapshot.data!["battery"] < 80)
                                                                                                      Transform.rotate(
                                                                                                          angle: -1.575,
                                                                                                          child: Icon(
                                                                                                            Icons.battery_5_bar,
                                                                                                            size: 20,
                                                                                                            color: Colors.greenAccent.shade400,
                                                                                                          ))
                                                                                                    else if (mainsnapshot.data!["battery"] < 90)
                                                                                                      Transform.rotate(
                                                                                                          angle: -1.575,
                                                                                                          child: const Icon(
                                                                                                            Icons.battery_6_bar,
                                                                                                            size: 20,
                                                                                                            color: Colors.greenAccent,
                                                                                                          ))
                                                                                                    else
                                                                                                      Transform.rotate(
                                                                                                          angle: -1.575,
                                                                                                          child: const Icon(
                                                                                                            Icons.battery_full,
                                                                                                            size: 20,
                                                                                                            color: Colors.green,
                                                                                                          )),
                                                                                                    Text(
                                                                                                      "${mainsnapshot.data!["battery"]}% ",
                                                                                                      style: const TextStyle(color: Colors.white, fontSize: 15),
                                                                                                    ),
                                                                                                  ],
                                                                                                ),
                                                                                              )),
                                                                                        ),
                                                                                        Padding(
                                                                                          padding: const EdgeInsets.only(left: 10, right: 10),
                                                                                          child: Column(
                                                                                            mainAxisAlignment: MainAxisAlignment.start,
                                                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                                                            children: [
                                                                                              Text(
                                                                                                mainsnapshot.data!["name"],
                                                                                                style: const TextStyle(color: Colors.orangeAccent, fontSize: 20),
                                                                                              ),
                                                                                              Padding(
                                                                                                padding: const EdgeInsets.only(top: 3, left: 5),
                                                                                                child: Text(
                                                                                                  "Location : ${mainsnapshot.data!["location"]}",
                                                                                                  style: const TextStyle(color: Colors.lightBlueAccent, fontSize: 15),
                                                                                                ),
                                                                                              ),
                                                                                              Padding(
                                                                                                padding: const EdgeInsets.only(top: 3, left: 5),
                                                                                                child: Text(
                                                                                                  "Last Updated : {SubjectsData2.location}",
                                                                                                  style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 10),
                                                                                                ),
                                                                                              ),
                                                                                            ],
                                                                                          ),
                                                                                        ),
                                                                                      ],
                                                                                    ),
                                                                                  ),
                                                                                  onTap: () {
                                                                                    Navigator.push(
                                                                                        context,
                                                                                        MaterialPageRoute(
                                                                                            builder: (context) => MyMapWidget(
                                                                                                  lat: mainsnapshot.data!["lat"],
                                                                                                  lng: mainsnapshot.data!["lng"],
                                                                                                  name: mainsnapshot.data!["name"],
                                                                                                )));
                                                                                  },
                                                                                );
                                                                              } else {
                                                                                return Container();
                                                                              }
                                                                          }
                                                                        });
                                                                  },
                                                                  separatorBuilder:
                                                                      (context,
                                                                              index) =>
                                                                          const SizedBox(
                                                                            height:
                                                                                1,
                                                                          ));
                                                        }
                                                    }
                                                  }),
                                            ),
                                            Center(
                                              child: CopyTextButton(
                                                  textToCopy:
                                                      "${SubjectsData1.id},${SubjectsData1.familyName}"),
                                            ),
                                            const SizedBox(
                                              height: 10,
                                            )
                                          ],
                                        );
                                      },
                                      separatorBuilder: (context, index) =>
                                          const SizedBox(
                                            height: 1,
                                          )),
                                );
                              }
                          }
                        }),
                  ),
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      "Our Live Location",
                      style: TextStyle(color: Colors.white, fontSize: 30),
                    ),
                  ),
                  // MyMap(),
                  Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: SizedBox(
                      height: 200,
                      width: double.infinity,
                      child: ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30),
                          bottomRight: Radius.circular(30),
                          bottomLeft: Radius.circular(30),
                        ),
                        child: MyMap(),
                      ),
                    ),
                  ),
                ],
              ),
            ))
          ],
        ),
      ),
    );
  }
}

class familyConvertor {
  String id;
  String familyName;

  familyConvertor({this.id = "", required this.familyName});

  Map<String, dynamic> toJson() => {"id": id, "familyName": familyName};

  static familyConvertor fromJson(Map<String, dynamic> json) =>
      familyConvertor(id: json['id'], familyName: json["familyName"]);
}

Stream<List<familyConvertor>> readFamily() => FirebaseFirestore.instance
    .collection('users').doc(fullUserId()).collection("family")
    .snapshots()
    .map((snapshot) => snapshot.docs
        .map((doc) => familyConvertor.fromJson(doc.data()))
        .toList());

class familyMemberConvertor {
  String id;
  String userId;

  familyMemberConvertor({
    this.id = "",
    required this.userId,
  });

  Map<String, dynamic> toJson() => {
        "id": id,
        "userId": userId,
      };

  static familyMemberConvertor fromJson(Map<String, dynamic> json) =>
      familyMemberConvertor(
        id: json['id'],
        userId: json["userId"],
      );
}

Stream<List<familyMemberConvertor>> readFamilyMember(String id) =>
    FirebaseFirestore.instance
        .collection('Family')
        .doc(id)
        .collection("members")
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => familyMemberConvertor.fromJson(doc.data()))
            .toList());

class BatteryLevelScreen extends StatefulWidget {
  @override
  _BatteryLevelScreenState createState() => _BatteryLevelScreenState();
}

class _BatteryLevelScreenState extends State<BatteryLevelScreen> {
  final Battery _battery = Battery();
  late int _batteryLevel = 0;

  @override
  void initState() {
    super.initState();
    _getBatteryLevel();
  }

  _getBatteryLevel() async {
    final batteryLevel = await _battery.batteryLevel;
    showToast(batteryLevel as String);
    setState(() {
      _batteryLevel = batteryLevel;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Battery Level'),
      ),
      body: Center(
        child: Text('Battery level: $_batteryLevel%'),
      ),
    );
  }
}

showToast(String message) async {
  await Fluttertoast.cancel();
  Fluttertoast.showToast(msg: message, fontSize: 18);
}

class CopyTextButton extends StatelessWidget {
  final String textToCopy;

  const CopyTextButton({Key? key, required this.textToCopy}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Container(
        decoration: BoxDecoration(
            color: Colors.blueGrey, borderRadius: BorderRadius.circular(20)),
        child: const Padding(
          padding: EdgeInsets.all(5.0),
          child: Text(
            'Copy Token',
            style: TextStyle(
                color: Colors.white, fontSize: 18, fontWeight: FontWeight.w500),
          ),
        ),
      ),
      onTap: () {
        Clipboard.setData(ClipboardData(text: textToCopy));
        showToast(textToCopy);
      },
    );
  }
}
