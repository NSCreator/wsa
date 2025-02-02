// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors
import 'package:audioplayers/audioplayers.dart';
import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:convert';
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
import 'package:clay_containers/clay_containers.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var battery = Battery();
  int percentage = 0;
  late Timer timer;

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
    Color baseColor = Color(0xFFF2F2F2);
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color.fromRGBO(197, 222, 237, 1),
            Color.fromRGBO(149, 182, 201, 1),
            Color.fromRGBO(101, 137, 158, 1),
            Color.fromRGBO(55, 85, 102, 1),
            Color.fromRGBO(31, 49, 59, 1),
            Color.fromRGBO(17, 27, 33, 1),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          // stops: [0.0, 1.0],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            children: [
              Row(
                children: [
                  SizedBox(
                    width: 10,
                  ),
                  Icon(
                    Icons.menu,
                    size: 40,
                  ),
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
                  Padding(
                    padding: const EdgeInsets.only(top: 5, right: 8),
                    child: Container(
                      height: 35,
                      width: 75,
                      decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(10),
                          image: DecorationImage(
                              image: AssetImage(
                                "assets/webgl_codelab.png",
                              ),
                              fit: BoxFit.fill)),
                    ),
                  ),
                  InkWell(
                    child: const Icon(
                      Icons.settings,
                      color: Colors.black,
                      size: 35,
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
                physics: BouncingScrollPhysics(),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    smartBand(),
                    StreamBuilder<DocumentSnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection("users")
                            .doc(fullUserId())
                            .snapshots(),
                        builder: (context, mainsnapshot) {
                          switch (mainsnapshot.connectionState) {
                            case ConnectionState.waiting:
                              return const Center(
                                  child: CircularProgressIndicator(
                                strokeWidth: 0.3,
                                color: Colors.cyan,
                              ));
                            default:
                              if (mainsnapshot.data!.exists) {
                                return Padding(
                                  padding: const EdgeInsets.only(
                                      left: 10, right: 10),
                                  child: InkWell(
                                    child: Container(
                                      decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.5),
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Row(
                                          children: [
                                            Container(
                                              height: 60,
                                              width: 60,
                                              decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  image: const DecorationImage(
                                                      image: NetworkImage(
                                                          "https://pbs.twimg.com/media/Ey_wJ4mVcAEPH4K.jpg"),
                                                      fit: BoxFit.cover),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          35)),
                                              child: Align(
                                                  alignment:
                                                      Alignment.bottomCenter,
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                        color: Colors.black,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10)),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      children: [
                                                        const SizedBox(
                                                          width: 3,
                                                        ),
                                                        if (mainsnapshot.data![
                                                                "battery"] <
                                                            10)
                                                          Transform.rotate(
                                                              angle: -1.575,
                                                              child: const Icon(
                                                                Icons
                                                                    .battery_0_bar,
                                                                size: 20,
                                                                color:
                                                                    Colors.red,
                                                              ))
                                                        else if (mainsnapshot
                                                                    .data![
                                                                "battery"] <
                                                            20)
                                                          Transform.rotate(
                                                              angle: -1.575,
                                                              child: const Icon(
                                                                Icons
                                                                    .battery_1_bar,
                                                                size: 20,
                                                                color: Colors
                                                                    .redAccent,
                                                              ))
                                                        else if (mainsnapshot
                                                                    .data![
                                                                "battery"] <
                                                            35)
                                                          Transform.rotate(
                                                              angle: -1.575,
                                                              child: Icon(
                                                                Icons
                                                                    .battery_2_bar,
                                                                size: 20,
                                                                color: Colors
                                                                    .orangeAccent
                                                                    .shade400,
                                                              ))
                                                        else if (mainsnapshot
                                                                    .data![
                                                                "battery"] <
                                                            50)
                                                          Transform.rotate(
                                                              angle: -1.575,
                                                              child: const Icon(
                                                                Icons
                                                                    .battery_3_bar,
                                                                size: 20,
                                                                color: Colors
                                                                    .orangeAccent,
                                                              ))
                                                        else if (mainsnapshot
                                                                    .data![
                                                                "battery"] <
                                                            65)
                                                          Transform.rotate(
                                                              angle: -1.575,
                                                              child: const Icon(
                                                                Icons
                                                                    .battery_4_bar,
                                                                size: 20,
                                                                color: Colors
                                                                    .orange,
                                                              ))
                                                        else if (mainsnapshot
                                                                    .data![
                                                                "battery"] <
                                                            80)
                                                          Transform.rotate(
                                                              angle: -1.575,
                                                              child: Icon(
                                                                Icons
                                                                    .battery_5_bar,
                                                                size: 20,
                                                                color: Colors
                                                                    .greenAccent
                                                                    .shade400,
                                                              ))
                                                        else if (mainsnapshot
                                                                    .data![
                                                                "battery"] <
                                                            90)
                                                          Transform.rotate(
                                                              angle: -1.575,
                                                              child: const Icon(
                                                                Icons
                                                                    .battery_6_bar,
                                                                size: 20,
                                                                color: Colors
                                                                    .greenAccent,
                                                              ))
                                                        else
                                                          Transform.rotate(
                                                              angle: -1.575,
                                                              child: const Icon(
                                                                Icons
                                                                    .battery_full,
                                                                size: 20,
                                                                color: Colors
                                                                    .green,
                                                              )),
                                                        Text(
                                                          "${mainsnapshot.data!["battery"]}% ",
                                                          style:
                                                              const TextStyle(
                                                                  color: Colors
                                                                      .white,
                                                                  fontSize: 15),
                                                        ),
                                                      ],
                                                    ),
                                                  )),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 10, right: 10),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    "mainsnapshot.data!['name']",
                                                    style: const TextStyle(
                                                        color: Color.fromRGBO(
                                                            156, 35, 16, 1),
                                                        fontSize: 20,
                                                        fontWeight:
                                                            FontWeight.w500),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            top: 3, left: 5),
                                                    child: Text(
                                                      "Location : ${mainsnapshot.data!["location"]}",
                                                      style: const TextStyle(
                                                          color: Color.fromRGBO(
                                                              23, 89, 128, 1),
                                                          fontSize: 15),
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            top: 3, left: 5),
                                                    child: Text(
                                                      "Last Updated : {SubjectsData2.location}",
                                                      style: TextStyle(
                                                          color: Color.fromRGBO(
                                                              23, 128, 121, 1),
                                                          fontSize: 10),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => MyMapWidget(
                                                    lat: mainsnapshot
                                                        .data!["lat"],
                                                    lng: mainsnapshot
                                                        .data!["lng"],
                                                    name: mainsnapshot
                                                        .data!["name"],
                                                  )));
                                    },
                                  ),
                                );
                              } else {
                                return Container();
                              }
                          }
                        }),

                    Center(
                        child: Text(
                      "\nEmergency Help\n       Needed ?",
                      style: TextStyle(fontSize: 35, color: Colors.white),
                    )),

                    SizedBox(
                      height: 330,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: ZoomInZoomOutContainer(),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                              gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Color.fromRGBO(13, 140, 132, 1),
                                    Color.fromRGBO(104, 237, 229, 1),
                                    Color.fromRGBO(13, 140, 132, 0.3),
                                    Color.fromRGBO(104, 237, 229, 1),
                                    Color.fromRGBO(13, 140, 132, 1),
                                    Color.fromRGBO(199, 209, 208, 1),
                                  ]),
                              borderRadius: BorderRadius.circular(18)),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                Icon(Icons.message_outlined),
                                Text(
                                  " SOS Message",
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w800),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                              gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Color.fromRGBO(104, 237, 229, 1),
                                    Color.fromRGBO(13, 140, 132, 1),
                                    Color.fromRGBO(104, 237, 229, 1),
                                    Color.fromRGBO(13, 140, 132, 0.3),
                                    Color.fromRGBO(199, 209, 208, 1),
                                  ]),
                              borderRadius: BorderRadius.circular(18)),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                Icon(Icons.message_outlined),
                                Text(
                                  " SOS Video ",
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w800),
                                ),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Container(
                          height: 120,
                          width: 120,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10)),
                          child: Stack(children: [
                            Positioned(
                                top: 50,
                                left: 5,
                                right: 0,
                                child: Container(
                                  height: 70,
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10)),
                                )),
                            Positioned(
                                top: 98,
                                left: 15,
                                right: 0,
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.phone,
                                      color: Colors.red,
                                    ),
                                    Text(
                                      "Dial 108",
                                      style: TextStyle(
                                          color: Colors.blue,
                                          fontSize: 20,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ],
                                )),
                            Positioned(
                                top: 0,
                                left: -10,
                                right: 0,
                                child: SizedBox(
                                    height: 100,
                                    child: Image.network(
                                        "https://clipartix.com/wp-content/uploads/2016/11/Ambulance-clipart-image-ambulance-truck.png"))),
                            Positioned(
                                top: 75,
                                left: 15,
                                right: 0,
                                child: Container(
                                    decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.8),
                                        borderRadius: BorderRadius.circular(5)),
                                    child: Text(
                                      "Ambulance",
                                      style: TextStyle(
                                          color: Colors.red,
                                          fontSize: 20,
                                          fontWeight: FontWeight.w500),
                                    ))),
                          ]),
                        ),
                        Container(
                          height: 120,
                          width: 100,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10)),
                          child: Stack(children: [
                            Positioned(
                                top: 70,
                                left: 0,
                                right: 0,
                                child: Container(
                                  height: 50,
                                  width: 100,
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10)),
                                )),
                            Positioned(
                                top: 98,
                                left: 5,
                                right: 0,
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.phone,
                                      color: Colors.red,
                                    ),
                                    Text(
                                      "Dial 100",
                                      style: TextStyle(
                                          color: Colors.blue,
                                          fontSize: 20,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ],
                                )),
                            Positioned(
                                top: 0,
                                left: -10,
                                right: 0,
                                child: SizedBox(
                                    height: 100,
                                    child: Image.network(
                                        "https://icons.iconarchive.com/icons/aha-soft/free-large-boss/512/Policeman-icon.png"))),
                            Positioned(
                                top: 80,
                                left: 45,
                                right: 0,
                                child: Container(
                                    decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.8),
                                        borderRadius: BorderRadius.circular(5)),
                                    child: Text(
                                      "Police",
                                      style: TextStyle(
                                          color: Colors.red,
                                          fontSize: 20,
                                          fontWeight: FontWeight.w500),
                                    ))),
                          ]),
                        ),
                        Container(
                          height: 120,
                          width: 120,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10)),
                          child: Stack(children: [
                            Positioned(
                                top: 50,
                                left: 10,
                                right: 0,
                                child: Container(
                                  height: 70,
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10)),
                                )),
                            Positioned(
                                top: 98,
                                left: 15,
                                right: 0,
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.phone,
                                      color: Colors.red,
                                    ),
                                    Text(
                                      "Dial 104",
                                      style: TextStyle(
                                          color: Colors.blue,
                                          fontSize: 20,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ],
                                )),
                            Positioned(
                                top: 0,
                                left: 0,
                                right: 0,
                                child: SizedBox(
                                    height: 100,
                                    child:
                                        Image.asset("assets/fireTruck.png"))),
                            Positioned(
                                top: 75,
                                left: 15,
                                right: 0,
                                child: Container(
                                    decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.8),
                                        borderRadius: BorderRadius.circular(5)),
                                    child: Text(
                                      "Fire Truck",
                                      style: TextStyle(
                                          color: Colors.red,
                                          fontSize: 20,
                                          fontWeight: FontWeight.w500),
                                    ))),
                          ]),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                            color: Color.fromRGBO(10, 191, 176, 1),
                            borderRadius: BorderRadius.circular(20)),
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Row(
                            children: [
                              const Text(
                                "Family",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 25),
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
                                                  padding: const EdgeInsets
                                                          .symmetric(
                                                      horizontal: 25,
                                                      vertical: 10),
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      color: Colors.white54,
                                                      border: Border.all(
                                                          color: Colors.white
                                                              .withOpacity(
                                                                  0.8)),
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
                                                            TextInputAction
                                                                .next,
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
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 60, right: 60),
                                                  child: Row(
                                                    children: [
                                                      InkWell(
                                                        child: Container(
                                                          decoration: BoxDecoration(
                                                              color:
                                                                  Colors.black,
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
                                                          Navigator.pop(
                                                              context);
                                                        },
                                                      ),
                                                      const Spacer(),
                                                      InkWell(
                                                        child: Container(
                                                          decoration: BoxDecoration(
                                                              color:
                                                                  Colors.black,
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
                                                          await FirebaseFirestore
                                                              .instance
                                                              .collection(
                                                                  "users")
                                                              .doc(fullUserId())
                                                              .collection(
                                                                  "family")
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
                                      children: const [
                                        Text(
                                          " Add",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 20),
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
                                                  padding: const EdgeInsets
                                                          .symmetric(
                                                      horizontal: 25,
                                                      vertical: 10),
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      color: Colors.white54,
                                                      border: Border.all(
                                                          color: Colors.white
                                                              .withOpacity(
                                                                  0.8)),
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
                                                            TextInputAction
                                                                .next,
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
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 60, right: 60),
                                                  child: Row(
                                                    children: [
                                                      InkWell(
                                                        child: Container(
                                                          decoration: BoxDecoration(
                                                              color:
                                                                  Colors.black,
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
                                                          Navigator.pop(
                                                              context);
                                                        },
                                                      ),
                                                      const Spacer(),
                                                      InkWell(
                                                        child: Container(
                                                          decoration: BoxDecoration(
                                                              color:
                                                                  Colors.black,
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
                                                              nameController
                                                                  .text
                                                                  .split(",");
                                                          await FirebaseFirestore
                                                              .instance
                                                              .collection(
                                                                  "users")
                                                              .doc(fullUserId())
                                                              .collection(
                                                                  "family")
                                                              .doc(out[0])
                                                              .set({
                                                            "familyName":
                                                                out[1],
                                                            "id": out[0]
                                                          });
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
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding:
                          const EdgeInsets.only(left: 10, right: 10, top: 5),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: Colors.white.withOpacity(0.5),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Row(
                            children: [
                              Text(
                                "Sujith's Family",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 25),
                              ),
                              Spacer(),
                              Container(
                                height: 35,
                                width: 35,
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                      image: NetworkImage(
                                          "https://pbs.twimg.com/media/Ey_wJ4mVcAEPH4K.jpg")),
                                  borderRadius: BorderRadius.circular(15),
                                  color: Colors.white.withOpacity(0.5),
                                ),
                              ),
                              Container(
                                height: 35,
                                width: 35,
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                      image: NetworkImage(
                                          "https://pbs.twimg.com/media/Ey_wJ4mVcAEPH4K.jpg")),
                                  borderRadius: BorderRadius.circular(15),
                                  color: Colors.white.withOpacity(0.5),
                                ),
                              ),
                              Container(
                                height: 35,
                                width: 35,
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                      image: NetworkImage(
                                          "https://pbs.twimg.com/media/Ey_wJ4mVcAEPH4K.jpg")),
                                  borderRadius: BorderRadius.circular(15),
                                  color: Colors.white.withOpacity(0.5),
                                ),
                              ),
                              Container(
                                height: 35,
                                width: 35,
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                      image: NetworkImage(
                                          "https://pbs.twimg.com/media/Ey_wJ4mVcAEPH4K.jpg")),
                                  borderRadius: BorderRadius.circular(15),
                                  color: Colors.white.withOpacity(0.5),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding:
                          const EdgeInsets.only(left: 10, right: 10, top: 5),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: Colors.white.withOpacity(0.5),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Row(
                            children: [
                              Text(
                                "Sujith's Family",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 25),
                              ),
                              Spacer(),
                              Container(
                                height: 35,
                                width: 35,
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                      image: NetworkImage(
                                          "https://pbs.twimg.com/media/Ey_wJ4mVcAEPH4K.jpg")),
                                  borderRadius: BorderRadius.circular(15),
                                  color: Colors.white.withOpacity(0.5),
                                ),
                              ),
                              Container(
                                height: 35,
                                width: 35,
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                      image: NetworkImage(
                                          "https://pbs.twimg.com/media/Ey_wJ4mVcAEPH4K.jpg")),
                                  borderRadius: BorderRadius.circular(15),
                                  color: Colors.white.withOpacity(0.5),
                                ),
                              ),
                              Container(
                                height: 35,
                                width: 35,
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                      image: NetworkImage(
                                          "https://pbs.twimg.com/media/Ey_wJ4mVcAEPH4K.jpg")),
                                  borderRadius: BorderRadius.circular(15),
                                  color: Colors.white.withOpacity(0.5),
                                ),
                              ),
                              Container(
                                height: 35,
                                width: 35,
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                      image: NetworkImage(
                                          "https://pbs.twimg.com/media/Ey_wJ4mVcAEPH4K.jpg")),
                                  borderRadius: BorderRadius.circular(15),
                                  color: Colors.white.withOpacity(0.5),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Padding(
                    //   padding: const EdgeInsets.only(left: 10, right: 10),
                    //   child: StreamBuilder<List<familyConvertor>>(
                    //       stream: readFamily(),
                    //       builder: (context, snapshot) {
                    //         final user1 = snapshot.data;
                    //         switch (snapshot.connectionState) {
                    //           case ConnectionState.waiting:
                    //             return const Center(
                    //                 child: CircularProgressIndicator(
                    //               strokeWidth: 0.3,
                    //               color: Colors.cyan,
                    //             ));
                    //           default:
                    //             if (snapshot.hasError) {
                    //               return const Center(
                    //                   child: Text(
                    //                       'Error with TextBooks Data or\n Check Internet Connection'));
                    //             } else {
                    //               return Container(
                    //                 decoration: BoxDecoration(
                    //                     color: Colors.white.withOpacity(0.2),
                    //                     borderRadius:
                    //                         BorderRadius.circular(20)),
                    //                 child: ListView.separated(
                    //                     physics: const BouncingScrollPhysics(),
                    //                     shrinkWrap: true,
                    //                     itemCount: user1!.length,
                    //                     itemBuilder: (context, int index) {
                    //                       final SubjectsData1 = user1[index];
                    //                       return Column(
                    //                         mainAxisAlignment:
                    //                             MainAxisAlignment.start,
                    //                         crossAxisAlignment:
                    //                             CrossAxisAlignment.start,
                    //                         children: [
                    //                           InkWell(
                    //                             child: Row(
                    //                               children: [
                    //                                 Padding(
                    //                                   padding:
                    //                                       const EdgeInsets.only(
                    //                                           left: 15, top: 5),
                    //                                   child: Text(
                    //                                     SubjectsData1
                    //                                         .familyName,
                    //                                     style: const TextStyle(
                    //                                         color: Colors.white,
                    //                                         fontSize: 30),
                    //                                   ),
                    //                                 ),
                    //                                 const Spacer(),
                    //                                 InkWell(
                    //                                   child: Padding(
                    //                                     padding:
                    //                                         const EdgeInsets
                    //                                                 .only(
                    //                                             right: 20,
                    //                                             top: 10,
                    //                                             bottom: 3),
                    //                                     child: Container(
                    //                                       decoration: BoxDecoration(
                    //                                           color:
                    //                                               Colors.blue,
                    //                                           borderRadius:
                    //                                               BorderRadius
                    //                                                   .circular(
                    //                                                       20)),
                    //                                       child: const Padding(
                    //                                         padding:
                    //                                             EdgeInsets.all(
                    //                                                 5.0),
                    //                                         child: Text(
                    //                                           "Add Member",
                    //                                           style: TextStyle(
                    //                                               color: Colors
                    //                                                   .white,
                    //                                               fontSize: 17),
                    //                                         ),
                    //                                       ),
                    //                                     ),
                    //                                   ),
                    //                                   onTap: () {
                    //                                     _isDialogOpen = true;
                    //                                     showDialog(
                    //                                       context: context,
                    //                                       builder: (BuildContext
                    //                                           context) {
                    //                                         return Scaffold(
                    //                                           backgroundColor:
                    //                                               Colors
                    //                                                   .transparent,
                    //                                           body: Center(
                    //                                             child:
                    //                                                 Container(
                    //                                               height: 250,
                    //                                               width: 300,
                    //                                               decoration:
                    //                                                   BoxDecoration(
                    //                                                 color: Colors
                    //                                                     .black
                    //                                                     .withOpacity(
                    //                                                         0.6),
                    //                                                 borderRadius:
                    //                                                     BorderRadius.circular(
                    //                                                         20),
                    //                                                 boxShadow: [
                    //                                                   BoxShadow(
                    //                                                       blurRadius:
                    //                                                           25.0,
                    //                                                       color: Colors
                    //                                                           .white
                    //                                                           .withOpacity(0.3))
                    //                                                 ],
                    //                                               ),
                    //                                               child: Column(
                    //                                                 mainAxisAlignment:
                    //                                                     MainAxisAlignment
                    //                                                         .start,
                    //                                                 crossAxisAlignment:
                    //                                                     CrossAxisAlignment
                    //                                                         .start,
                    //                                                 children: [
                    //                                                   const Padding(
                    //                                                     padding: EdgeInsets.only(
                    //                                                         left:
                    //                                                             15,
                    //                                                         top:
                    //                                                             15),
                    //                                                     child:
                    //                                                         Text(
                    //                                                       "Enter Token",
                    //                                                       style: TextStyle(
                    //                                                           color: Colors.white,
                    //                                                           fontSize: 35,
                    //                                                           fontWeight: FontWeight.w500),
                    //                                                     ),
                    //                                                   ),
                    //                                                   Padding(
                    //                                                     padding: const EdgeInsets.symmetric(
                    //                                                         horizontal:
                    //                                                             25,
                    //                                                         vertical:
                    //                                                             10),
                    //                                                     child:
                    //                                                         Container(
                    //                                                       decoration:
                    //                                                           BoxDecoration(
                    //                                                         color:
                    //                                                             Colors.white54,
                    //                                                         border:
                    //                                                             Border.all(color: Colors.white.withOpacity(0.8)),
                    //                                                         borderRadius:
                    //                                                             BorderRadius.circular(18),
                    //                                                       ),
                    //                                                       child:
                    //                                                           Padding(
                    //                                                         padding:
                    //                                                             const EdgeInsets.only(left: 20),
                    //                                                         child:
                    //                                                             TextField(
                    //                                                           controller: nameController,
                    //                                                           textInputAction: TextInputAction.next,
                    //                                                           decoration: const InputDecoration(
                    //                                                             border: InputBorder.none,
                    //                                                             hintText: 'Enter Member Token here',
                    //                                                           ),
                    //                                                         ),
                    //                                                       ),
                    //                                                     ),
                    //                                                   ),
                    //                                                   Padding(
                    //                                                     padding: const EdgeInsets.only(
                    //                                                         left:
                    //                                                             60,
                    //                                                         right:
                    //                                                             60),
                    //                                                     child:
                    //                                                         Row(
                    //                                                       children: [
                    //                                                         InkWell(
                    //                                                           child: Container(
                    //                                                             decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(100), border: Border.all(color: Colors.white54)),
                    //                                                             child: const Padding(
                    //                                                               padding: EdgeInsets.all(5.0),
                    //                                                               child: Text(
                    //                                                                 "Cancel",
                    //                                                                 style: TextStyle(color: Colors.white, fontSize: 25, fontWeight: FontWeight.w700),
                    //                                                               ),
                    //                                                             ),
                    //                                                           ),
                    //                                                           onTap: () {
                    //                                                             Navigator.pop(context);
                    //                                                           },
                    //                                                         ),
                    //                                                         const Spacer(),
                    //                                                         InkWell(
                    //                                                           child: Container(
                    //                                                             decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(100), border: Border.all(color: Colors.white54)),
                    //                                                             child: const Padding(
                    //                                                               padding: EdgeInsets.all(5.0),
                    //                                                               child: Text(
                    //                                                                 "Create",
                    //                                                                 style: TextStyle(color: Colors.lightBlueAccent, fontSize: 25, fontWeight: FontWeight.w700),
                    //                                                               ),
                    //                                                             ),
                    //                                                           ),
                    //                                                           onTap: () async {
                    //                                                             // await FirebaseFirestore.instance.collection("users").doc(nameController.text.trim()).collection("family").doc().set({
                    //                                                             //   "id": nameController.text.trim(),
                    //                                                             //   "userId": nameController.text.trim()
                    //                                                             // });
                    //                                                             await FirebaseFirestore.instance.collection("Family").doc(SubjectsData1.id).collection("members").doc(nameController.text.trim()).set({
                    //                                                               "id": nameController.text.trim(),
                    //                                                               "userId": nameController.text.trim()
                    //                                                             });
                    //                                                             showToast("${nameController.text.trim()}'s member Added");
                    //                                                             Navigator.pop(context);
                    //                                                           },
                    //                                                         )
                    //                                                       ],
                    //                                                     ),
                    //                                                   )
                    //                                                 ],
                    //                                               ),
                    //                                             ),
                    //                                           ),
                    //                                         );
                    //                                       },
                    //                                     ).then((_) {
                    //                                       _isDialogOpen = false;
                    //                                     });
                    //                                   },
                    //                                 ),
                    //                               ],
                    //                             ),
                    //                             onLongPress: () async {
                    //                               _isDialogOpen = true;
                    //                               showDialog(
                    //                                 context: context,
                    //                                 builder:
                    //                                     (BuildContext context) {
                    //                                   return Scaffold(
                    //                                     backgroundColor:
                    //                                         Colors.transparent,
                    //                                     body: Center(
                    //                                       child: Container(
                    //                                         height: 100,
                    //                                         width: 300,
                    //                                         decoration:
                    //                                             BoxDecoration(
                    //                                           color: Colors
                    //                                               .black
                    //                                               .withOpacity(
                    //                                                   0.6),
                    //                                           borderRadius:
                    //                                               BorderRadius
                    //                                                   .circular(
                    //                                                       20),
                    //                                           boxShadow: [
                    //                                             BoxShadow(
                    //                                                 blurRadius:
                    //                                                     25.0,
                    //                                                 color: Colors
                    //                                                     .white
                    //                                                     .withOpacity(
                    //                                                         0.3))
                    //                                           ],
                    //                                         ),
                    //                                         child: Column(
                    //                                           mainAxisAlignment:
                    //                                               MainAxisAlignment
                    //                                                   .start,
                    //                                           crossAxisAlignment:
                    //                                               CrossAxisAlignment
                    //                                                   .start,
                    //                                           children: [
                    //                                             const Padding(
                    //                                               padding: EdgeInsets
                    //                                                   .only(
                    //                                                       left:
                    //                                                           15,
                    //                                                       top:
                    //                                                           15),
                    //                                               child: Text(
                    //                                                 "Do you want delete family",
                    //                                                 style: TextStyle(
                    //                                                     color: Colors
                    //                                                         .white,
                    //                                                     fontSize:
                    //                                                         25,
                    //                                                     fontWeight:
                    //                                                         FontWeight.w500),
                    //                                               ),
                    //                                             ),
                    //                                             Padding(
                    //                                               padding: const EdgeInsets
                    //                                                       .only(
                    //                                                   left: 60,
                    //                                                   right: 60,
                    //                                                   top: 8),
                    //                                               child: Row(
                    //                                                 children: [
                    //                                                   InkWell(
                    //                                                     child:
                    //                                                         Container(
                    //                                                       decoration: BoxDecoration(
                    //                                                           color: Colors.black,
                    //                                                           borderRadius: BorderRadius.circular(100),
                    //                                                           border: Border.all(color: Colors.white54)),
                    //                                                       child:
                    //                                                           const Padding(
                    //                                                         padding:
                    //                                                             EdgeInsets.all(5.0),
                    //                                                         child:
                    //                                                             Text(
                    //                                                           "Cancel",
                    //                                                           style: TextStyle(color: Colors.white, fontSize: 25, fontWeight: FontWeight.w700),
                    //                                                         ),
                    //                                                       ),
                    //                                                     ),
                    //                                                     onTap:
                    //                                                         () {
                    //                                                       Navigator.pop(
                    //                                                           context);
                    //                                                     },
                    //                                                   ),
                    //                                                   const Spacer(),
                    //                                                   InkWell(
                    //                                                     child:
                    //                                                         Container(
                    //                                                       decoration: BoxDecoration(
                    //                                                           color: Colors.black,
                    //                                                           borderRadius: BorderRadius.circular(100),
                    //                                                           border: Border.all(color: Colors.white54)),
                    //                                                       child:
                    //                                                           const Padding(
                    //                                                         padding:
                    //                                                             EdgeInsets.all(5.0),
                    //                                                         child:
                    //                                                             Text(
                    //                                                           "Delete",
                    //                                                           style: TextStyle(color: Colors.lightBlueAccent, fontSize: 25, fontWeight: FontWeight.w700),
                    //                                                         ),
                    //                                                       ),
                    //                                                     ),
                    //                                                     onTap:
                    //                                                         () async {
                    //                                                       await FirebaseFirestore
                    //                                                           .instance
                    //                                                           .collection("Family")
                    //                                                           .doc(SubjectsData1.id)
                    //                                                           .delete();
                    //                                                       showToast(
                    //                                                           "${nameController.text.trim()}'s family created");
                    //                                                       Navigator.pop(
                    //                                                           context);
                    //                                                     },
                    //                                                   )
                    //                                                 ],
                    //                                               ),
                    //                                             )
                    //                                           ],
                    //                                         ),
                    //                                       ),
                    //                                     ),
                    //                                   );
                    //                                 },
                    //                               ).then((_) {
                    //                                 _isDialogOpen = false;
                    //                               });
                    //                             },
                    //                           ),
                    //                           Padding(
                    //                             padding:
                    //                                 const EdgeInsets.all(8.0),
                    //                             child: StreamBuilder<
                    //                                     List<
                    //                                         familyMemberConvertor>>(
                    //                                 stream: readFamilyMember(
                    //                                     SubjectsData1.id),
                    //                                 builder:
                    //                                     (context, snapshot) {
                    //                                   final user1 =
                    //                                       snapshot.data;
                    //                                   switch (snapshot
                    //                                       .connectionState) {
                    //                                     case ConnectionState
                    //                                         .waiting:
                    //                                       return const Center(
                    //                                           child:
                    //                                               CircularProgressIndicator(
                    //                                         strokeWidth: 0.3,
                    //                                         color: Colors.cyan,
                    //                                       ));
                    //                                     default:
                    //                                       if (snapshot
                    //                                           .hasError) {
                    //                                         return const Center(
                    //                                             child: Text(
                    //                                                 'Error with TextBooks Data or\n Check Internet Connection'));
                    //                                       } else {
                    //                                         return ListView
                    //                                             .separated(
                    //                                                 physics:
                    //                                                     const BouncingScrollPhysics(),
                    //                                                 shrinkWrap:
                    //                                                     true,
                    //                                                 itemCount:
                    //                                                     user1!
                    //                                                         .length,
                    //                                                 itemBuilder:
                    //                                                     (context,
                    //                                                         int
                    //                                                             index) {
                    //                                                   final SubjectsData2 =
                    //                                                       user1[
                    //                                                           index];
                    //                                                   return StreamBuilder<
                    //                                                           DocumentSnapshot>(
                    //                                                       stream: FirebaseFirestore
                    //                                                           .instance
                    //                                                           .collection("users")
                    //                                                           .doc(SubjectsData2.userId)
                    //                                                           .snapshots(),
                    //                                                       builder: (context, mainsnapshot) {
                    //                                                         switch (mainsnapshot.connectionState) {
                    //                                                           case ConnectionState.waiting:
                    //                                                             return const Center(
                    //                                                                 child: CircularProgressIndicator(
                    //                                                               strokeWidth: 0.3,
                    //                                                               color: Colors.cyan,
                    //                                                             ));
                    //                                                           default:
                    //                                                             if (mainsnapshot.data!.exists && fullUserId() != "SubjectsData2.userId") {
                    //                                                               return InkWell(
                    //                                                                 child: Padding(
                    //                                                                   padding: const EdgeInsets.all(8.0),
                    //                                                                   child: Row(
                    //                                                                     children: [
                    //                                                                       Container(
                    //                                                                         height: 60,
                    //                                                                         width: 60,
                    //                                                                         decoration: BoxDecoration(color: Colors.white, image: const DecorationImage(image: NetworkImage("https://pub.dev/static/hash-aps7rpf8/img/ff-banner-mobile-2x.png"), fit: BoxFit.cover), borderRadius: BorderRadius.circular(35)),
                    //                                                                         child: Align(
                    //                                                                             alignment: Alignment.bottomCenter,
                    //                                                                             child: Container(
                    //                                                                               decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(10)),
                    //                                                                               child: Row(
                    //                                                                                 mainAxisAlignment: MainAxisAlignment.center,
                    //                                                                                 crossAxisAlignment: CrossAxisAlignment.center,
                    //                                                                                 children: [
                    //                                                                                   const SizedBox(
                    //                                                                                     width: 3,
                    //                                                                                   ),
                    //                                                                                   if (mainsnapshot.data!["battery"] < 10)
                    //                                                                                     Transform.rotate(
                    //                                                                                         angle: -1.575,
                    //                                                                                         child: const Icon(
                    //                                                                                           Icons.battery_0_bar,
                    //                                                                                           size: 20,
                    //                                                                                           color: Colors.red,
                    //                                                                                         ))
                    //                                                                                   else if (mainsnapshot.data!["battery"] < 20)
                    //                                                                                     Transform.rotate(
                    //                                                                                         angle: -1.575,
                    //                                                                                         child: const Icon(
                    //                                                                                           Icons.battery_1_bar,
                    //                                                                                           size: 20,
                    //                                                                                           color: Colors.redAccent,
                    //                                                                                         ))
                    //                                                                                   else if (mainsnapshot.data!["battery"] < 35)
                    //                                                                                     Transform.rotate(
                    //                                                                                         angle: -1.575,
                    //                                                                                         child: Icon(
                    //                                                                                           Icons.battery_2_bar,
                    //                                                                                           size: 20,
                    //                                                                                           color: Colors.orangeAccent.shade400,
                    //                                                                                         ))
                    //                                                                                   else if (mainsnapshot.data!["battery"] < 50)
                    //                                                                                     Transform.rotate(
                    //                                                                                         angle: -1.575,
                    //                                                                                         child: const Icon(
                    //                                                                                           Icons.battery_3_bar,
                    //                                                                                           size: 20,
                    //                                                                                           color: Colors.orangeAccent,
                    //                                                                                         ))
                    //                                                                                   else if (mainsnapshot.data!["battery"] < 65)
                    //                                                                                     Transform.rotate(
                    //                                                                                         angle: -1.575,
                    //                                                                                         child: const Icon(
                    //                                                                                           Icons.battery_4_bar,
                    //                                                                                           size: 20,
                    //                                                                                           color: Colors.orange,
                    //                                                                                         ))
                    //                                                                                   else if (mainsnapshot.data!["battery"] < 80)
                    //                                                                                     Transform.rotate(
                    //                                                                                         angle: -1.575,
                    //                                                                                         child: Icon(
                    //                                                                                           Icons.battery_5_bar,
                    //                                                                                           size: 20,
                    //                                                                                           color: Colors.greenAccent.shade400,
                    //                                                                                         ))
                    //                                                                                   else if (mainsnapshot.data!["battery"] < 90)
                    //                                                                                     Transform.rotate(
                    //                                                                                         angle: -1.575,
                    //                                                                                         child: const Icon(
                    //                                                                                           Icons.battery_6_bar,
                    //                                                                                           size: 20,
                    //                                                                                           color: Colors.greenAccent,
                    //                                                                                         ))
                    //                                                                                   else
                    //                                                                                     Transform.rotate(
                    //                                                                                         angle: -1.575,
                    //                                                                                         child: const Icon(
                    //                                                                                           Icons.battery_full,
                    //                                                                                           size: 20,
                    //                                                                                           color: Colors.green,
                    //                                                                                         )),
                    //                                                                                   Text(
                    //                                                                                     "${mainsnapshot.data!["battery"]}% ",
                    //                                                                                     style: const TextStyle(color: Colors.white, fontSize: 15),
                    //                                                                                   ),
                    //                                                                                 ],
                    //                                                                               ),
                    //                                                                             )),
                    //                                                                       ),
                    //                                                                       Padding(
                    //                                                                         padding: const EdgeInsets.only(left: 10, right: 10),
                    //                                                                         child: Column(
                    //                                                                           mainAxisAlignment: MainAxisAlignment.start,
                    //                                                                           crossAxisAlignment: CrossAxisAlignment.start,
                    //                                                                           children: [
                    //                                                                             Text(
                    //                                                                               mainsnapshot.data!["name"],
                    //                                                                               style: const TextStyle(color: Colors.orangeAccent, fontSize: 20),
                    //                                                                             ),
                    //                                                                             Padding(
                    //                                                                               padding: const EdgeInsets.only(top: 3, left: 5),
                    //                                                                               child: Text(
                    //                                                                                 "Location : ${mainsnapshot.data!["location"]}",
                    //                                                                                 style: const TextStyle(color: Colors.lightBlueAccent, fontSize: 15),
                    //                                                                               ),
                    //                                                                             ),
                    //                                                                             Padding(
                    //                                                                               padding: const EdgeInsets.only(top: 3, left: 5),
                    //                                                                               child: Text(
                    //                                                                                 "Last Updated : {SubjectsData2.location}",
                    //                                                                                 style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 10),
                    //                                                                               ),
                    //                                                                             ),
                    //                                                                           ],
                    //                                                                         ),
                    //                                                                       ),
                    //                                                                     ],
                    //                                                                   ),
                    //                                                                 ),
                    //                                                                 onTap: () {
                    //                                                                   Navigator.push(
                    //                                                                       context,
                    //                                                                       MaterialPageRoute(
                    //                                                                           builder: (context) => MyMapWidget(
                    //                                                                                 lat: mainsnapshot.data!["lat"],
                    //                                                                                 lng: mainsnapshot.data!["lng"],
                    //                                                                                 name: mainsnapshot.data!["name"],
                    //                                                                               )));
                    //                                                                 },
                    //                                                               );
                    //                                                             } else {
                    //                                                               return Container();
                    //                                                             }
                    //                                                         }
                    //                                                       });
                    //                                                 },
                    //                                                 separatorBuilder:
                    //                                                     (context,
                    //                                                             index) =>
                    //                                                         const SizedBox(
                    //                                                           height: 1,
                    //                                                         ));
                    //                                       }
                    //                                   }
                    //                                 }),
                    //                           ),
                    //                           Center(
                    //                             child: CopyTextButton(
                    //                                 textToCopy:
                    //                                     "${SubjectsData1.id},${SubjectsData1.familyName}"),
                    //                           ),
                    //                           const SizedBox(
                    //                             height: 10,
                    //                           )
                    //                         ],
                    //                       );
                    //                     },
                    //                     separatorBuilder: (context, index) =>
                    //                         const SizedBox(
                    //                           height: 1,
                    //                         )),
                    //               );
                    //             }
                    //         }
                    //       }),
                    // ),
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
      ),
    );
  }
}

class smartBand extends StatefulWidget {
  const smartBand({Key? key}) : super(key: key);

  @override
  State<smartBand> createState() => _smartBandState();
}

class _smartBandState extends State<smartBand> {
  int _secondsRemaining = 10;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.5),
            borderRadius: BorderRadius.circular(10)),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Flexible(
                    flex: 1,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 5),
                      child: Container(
                        height: 40,
                        width: 45,
                        decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(15),
                            image: DecorationImage(
                                image: AssetImage("assets/th.jpg"))),
                      ),
                    ),
                  ),
                  Flexible(
                    flex: 5,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text(
                              "Smart Band",
                              style: TextStyle(
                                  color: Colors.black87,
                                  fontSize: 25,
                                  fontWeight: FontWeight.w500),
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
                                style: TextStyle(
                                    color: Color.fromRGBO(
                                      4,
                                      4,
                                      97,
                                      1,
                                    ),
                                    fontSize: 17,
                                    fontWeight: FontWeight.w400),
                              )
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: Text(
                            "Last Connected : Today",
                            style: TextStyle(
                                color: Color.fromRGBO(16, 116, 156, 1)),
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
            CountdownFormatted(
              duration: Duration(seconds: _secondsRemaining),
              onFinish: () {},
              builder: (BuildContext ctx, String remaining) {
                double count = 1 - double.parse("0.$remaining") * 6.67;
                return Column(
                  children: [
                    Row(
                      children: [
                        Flexible(
                          flex: 5,
                          child: Padding(
                            padding: const EdgeInsets.only(
                                left: 5, right: 5, bottom: 5),
                            child: LinearProgressIndicator(
                              minHeight: 7,
                              value: count,
                              color: 0.6 <= count
                                  ? Colors.red
                                  : Colors.greenAccent,
                            ),
                          ),
                        ),
                        Flexible(
                            flex: 1,
                            child: Text(
                              " Sec: $remaining",
                              style:
                                  TextStyle(color: Colors.black, fontSize: 17),
                            )),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Text(
                            "Tap to Cancel",
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.w500),
                          ),
                        ),
                      ),
                    )
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class ZoomInZoomOutContainer extends StatefulWidget {
  @override
  _ZoomInZoomOutContainerState createState() => _ZoomInZoomOutContainerState();
}

class _ZoomInZoomOutContainerState extends State<ZoomInZoomOutContainer> {
  late AudioPlayer audioPlayer;
  int mode = 0;
  bool _isZooming = false;
  bool _isStarting = true;
  bool _isContainer = false;
  int _secondsRemaining = 15;
  List<Color> _colors = [Colors.red, Colors.green, Colors.blue, Colors.yellow];
  int _currentColorIndex = 0;
  Color _currentColor = Colors.red;
  double Height = 240;
  double Width = 240;
  double Radiues = 120;
  @override
  void initState() {
    super.initState();
    _currentColor = _colors[_currentColorIndex];
    audioPlayer = AudioPlayer();
    Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (Height == 240) {
          Height = 300;
          Width = 300;
          Radiues = 150;
        } else {
          Height = 240;
          Width = 240;
          Radiues = 120;
        }
        _currentColorIndex = (_currentColorIndex + 1) % _colors.length;
        _currentColor = _colors[_currentColorIndex];
      });
    });
  }

  Future<void> playAlarmSound() async {
    await audioPlayer.play(
        AssetSource('alarm-furious-laboratory-cinematic-trailer-sound.mp3'));
    audioPlayer.setReleaseMode(ReleaseMode.loop);
  }

  Future<void> stopAlarmSound() async {
    await audioPlayer.stop();
  }

  @override
  void dispose() {
    stopAlarmSound();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          setState(() {
            _isZooming = true;
            _isStarting = false;
          });
        },
        child: Column(
          children: [
            _isStarting
                ? ClayContainer(
                    color: Colors.cyanAccent,
                    height: 240,
                    width: 240,
                    borderRadius: 120,
                    curveType: CurveType.concave,
                    child: Center(
                      child: ClayContainer(
                        height: 200,
                        width: 200,
                        borderRadius: 120,
                        curveType: CurveType.convex,
                        child: Center(
                          child: Text(
                            "SOS",
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 80,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ),
                  )
                : Container(),
            _isZooming
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: CountdownFormatted(
                        duration: Duration(seconds: _secondsRemaining),
                        onFinish: () {
                          setState(() {
                            _isZooming = false;
                            _isContainer = true;
                            _isStarting = false;
                            playAlarmSound();
                          });
                        },
                        builder: (BuildContext ctx, String remaining) {
                          double count =
                              1 - double.parse("0.$remaining") * 6.67;
                          return AnimatedContainer(
                            duration: Duration(milliseconds: 700),
                            width: Width,
                            height: Height,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(Radiues),
                              gradient: LinearGradient(
                                colors: [_currentColor, _getNextColor()],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: CustomPaint(
                              foregroundPainter: CircleProgressBarPainter(
                                Radiues: 150,
                                backgroundColor: Colors.grey.withOpacity(0.6),
                                foregroundColor: Colors.purple,
                                percentageCompleted: count,
                                strokeWidth: 13.0,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    "Remaining Time",
                                    style: TextStyle(fontSize: 25),
                                  ),
                                  Text(
                                    remaining,
                                    style: TextStyle(fontSize: 20),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  )
                : Container(),
            _isContainer
                ? Container(
                    height: 240,
                    width: 300,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20)),
                    child: Column(
                      children: [
                        Text(
                          "SOS Is Activated",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 25,
                          ),
                        ),
                        Text(
                          "*Notification send to Family Members",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 25,
                          ),
                        ),
                        Text(
                          "*Notification send to Services Members",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 25,
                          ),
                        ),
                        Text(
                          "SOS Is Activated",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 25,
                          ),
                        ),
                        InkWell(
                          child: Container(
                            decoration: BoxDecoration(
                                color: Colors.greenAccent,
                                borderRadius: BorderRadius.circular(20)),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text("ok Done"),
                            ),
                          ),
                          onTap: () {
                            setState(() {
                              _isContainer = false;
                              _isZooming = false;
                              _isStarting = true;
                              stopAlarmSound();
                            });
                          },
                        )
                      ],
                    ),
                  )
                : Container(),
          ],
        ));
  }

  Color _getNextColor() {
    int nextIndex = (_currentColorIndex + 1) % _colors.length;
    return _colors[nextIndex];
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
    .collection('users')
    .doc(fullUserId())
    .collection("family")
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

class CircleProgressBarPainter extends CustomPainter {
  final Color backgroundColor;
  final Color foregroundColor;
  final double percentageCompleted;
  final double strokeWidth;
  final double Radiues;

  CircleProgressBarPainter(
      {required this.backgroundColor,
      required this.foregroundColor,
      required this.percentageCompleted,
      required this.strokeWidth,
      required this.Radiues});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = backgroundColor
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    double radius = Radiues;
    Offset center = Offset(size.width / 2, size.height / 2);

    canvas.drawCircle(center, radius, paint);

    paint.color = foregroundColor;

    double sweepAngle = 2 * pi * percentageCompleted;
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), -pi / 2,
        sweepAngle, false, paint);
  }

  @override
  bool shouldRepaint(CircleProgressBarPainter oldDelegate) {
    return oldDelegate.percentageCompleted != percentageCompleted;
  }
}
