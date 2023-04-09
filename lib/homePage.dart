import 'dart:async';
import 'dart:io';

import 'package:battery_plus/battery_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:countdown_flutter/countdown_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';

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



  @override
  void initState() {
    super.initState();

    Timer.periodic(const Duration(seconds: 100), (timer) {
      getBatteryPerentage();

    });
    var initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettings =
    InitializationSettings(android: initializationSettingsAndroid);
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    flutterLocalNotificationsPlugin.initialize(initializationSettings);

  }
  void getBatteryPerentage() async {
    final level = await battery.batteryLevel;
    if(percentage != level){
      FirebaseFirestore.instance.collection('Family').doc("m90h4LQ10CA7fxqnMpJA").collection("members").doc("oFZ005m9YyyCDRyXk5YZ")
          .update({
        "battery":level
      });
    }
  }
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;



  Future onSelectNotification(String payload) {
    return showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text("Payload"),
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
                    padding: const EdgeInsets.only(left: 10,top: 5),
                    child: ShaderMask(
                      shaderCallback: (Rect bounds) {
                        return RadialGradient(
                          center: Alignment.topLeft,
                          radius: 1.0,
                          colors: <Color>[Colors.yellow, Colors.deepOrange.shade900],
                          tileMode: TileMode.mirror,
                        ).createShader(bounds);
                      },
                      child: const Text('WS App' , style: TextStyle(
                          fontSize: 30,
                          color: Colors.white,
                          fontWeight: FontWeight.w500),),
                    ),
                  ),
                  const Spacer(),
                  InkWell(
                      child: const Icon(Icons.settings,color: Colors.grey,size: 30,),
                  onTap: (){
                        Navigator.push(context, MaterialPageRoute(builder: (context)=>const settings()));
                  },),
                  const SizedBox(width: 20,)
                ],
              ),
            Expanded(child: SingleChildScrollView(
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
                        borderRadius: BorderRadius.circular(20)
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                             const Text("Smart Band",style: TextStyle(color: Colors.white,fontSize: 25),),
                            const Spacer(),
                            if(false)const Text("Not Conected",style: TextStyle(color: Colors.red),)
                            else const Text("Conected",style: TextStyle(color: Colors.greenAccent),)
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
                                  blurRadius: 25.0,
                                  color: Colors.white

                              )
                            ],
                          ),
                          child: const Center(child: Text("SOS",style: TextStyle(color: Colors.white,fontSize: 35),)),
                        ),
                        onTap:   () {
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
                                          borderRadius: BorderRadius.circular(125),
                                          boxShadow: [
                                          const BoxShadow(
                                          blurRadius: 25.0,
                                          color: Colors.white

                                      )
                                      ],
                                      ),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          const Text("SOS",style: TextStyle(color: Colors.red,fontSize: 25,fontWeight: FontWeight.w700),),
                                          const Text("Is",style: TextStyle(color: Colors.red,fontSize: 25,fontWeight: FontWeight.w700),),
                                          const Text("Activited",style: TextStyle(color: Colors.greenAccent,fontSize: 25,fontWeight: FontWeight.w700),),
                                          CountdownFormatted(
                                            duration: Duration(seconds: _secondsRemaining),
                                            onFinish: () {
                                              _showNotification("SoS button was pressed by Sujithnimmala");
                                              Navigator.of(context).pop();
                                            },
                                            builder: (BuildContext ctx, String remaining) {
                                              return Text("Remaining Time : $remaining",style: const TextStyle(color: Colors.white,fontSize: 18,fontWeight: FontWeight.w700),);
                                            },
                                          ),
                                          const SizedBox(height: 10,),
                                          InkWell(
                                            child: Container(
                                              decoration: BoxDecoration(
                                                  color: Colors.black,
                                                  borderRadius: BorderRadius.circular(100),
                                                border: Border.all(color: Colors.white54)
                                              ),
                                              child: const Padding(
                                                padding:  EdgeInsets.all(5.0),
                                                child:  Text("Activate",style: TextStyle(color: Colors.white,fontSize: 25,fontWeight: FontWeight.w700),),
                                              ),
                                            ),

                                          ),
                                          const SizedBox(height: 5,),
                                          InkWell(
                                            child: Container(
                                              decoration: BoxDecoration(
                                                  color: Colors.black,
                                                  borderRadius: BorderRadius.circular(100),
                                                  border: Border.all(color: Colors.white54)
                                              ),
                                              child: const Padding(
                                                padding: EdgeInsets.all(5.0),
                                                child: Text("Cancel",style: TextStyle(color: Colors.white,fontSize: 25,fontWeight: FontWeight.w700),),
                                              ),
                                            ),
                                            onTap: (){
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
                          borderRadius: BorderRadius.circular(20)
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Row(
                          children: [
                            const Text("Family",style: TextStyle(color: Colors.white,fontSize: 25),),
                            const Spacer(),
                            Container(
                              decoration: BoxDecoration(
                                  color: Colors.blue,
                                  borderRadius: BorderRadius.circular(20)
                              ),
                              child: const Padding(
                                padding: EdgeInsets.all(5.0),
                                child: Text("Create",style: TextStyle(color: Colors.white,fontSize: 20),),
                              ),
                            ),
                            const SizedBox(width: 5,),
                            Container(
                              decoration: BoxDecoration(
                                  color: Colors.blue,
                                  borderRadius: BorderRadius.circular(20)
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: Row(
                                  children: [
                                    const Text(" Add",style: TextStyle(color: Colors.white,fontSize: 20),),
                                    const Icon(Icons.add,color: Colors.red,)
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 10,right: 10),
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
                                return const Center(child: Text('Error with TextBooks Data or\n Check Internet Connection'));
                              } else {
                                return Container(
                                  decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(20)
                                  ),
                                  child: ListView.separated(
                                      physics: const BouncingScrollPhysics(),
                                      shrinkWrap: true,
                                      itemCount: user1!.length,
                                      itemBuilder: (context, int index) {
                                        final SubjectsData1 = user1[index];
                                        return Column(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                             Padding(
                                              padding: const EdgeInsets.only(left: 15,top: 5),
                                              child: Text(
                                                SubjectsData1.familyName,
                                                style: const TextStyle(color: Colors.white, fontSize: 30),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: StreamBuilder<List<familyMemberConvertor>>(
                                                  stream: readFamilyMember(SubjectsData1.id),
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
                                                          return const Center(child: Text('Error with TextBooks Data or\n Check Internet Connection'));
                                                        } else {
                                                          return ListView.separated(
                                                              physics: const BouncingScrollPhysics(),
                                                              shrinkWrap: true,
                                                              itemCount: user1!.length,
                                                              itemBuilder: (context, int index) {
                                                                final SubjectsData2 = user1[index];
                                                                return InkWell(
                                                                  child: Padding(
                                                                    padding: const EdgeInsets.all(8.0),
                                                                    child: Row(
                                                                      children: [
                                                                        Container(
                                                                          
                                                                          height: 60,
                                                                          width: 60,
                                                                          decoration: BoxDecoration(
                                                                              color: Colors.white,
                                                                              image: const DecorationImage(image: NetworkImage("https://pub.dev/static/hash-aps7rpf8/img/ff-banner-mobile-2x.png"),fit: BoxFit.cover),

                                                                              borderRadius: BorderRadius.circular(35)
                                                                          ),
                                                                          child: Align(
                                                                            alignment: Alignment.bottomCenter,
                                                                            child: Container(
                                                                              decoration: BoxDecoration(
                                                                               color: Colors.black,
                                                                                borderRadius: BorderRadius.circular(10)
                                                                              ),
                                                                              child: Row(
                                                                                mainAxisAlignment: MainAxisAlignment.center,
                                                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                                                children: [
                                                                                  const SizedBox(width: 3,),
                                                                                  if(SubjectsData2.battery<10)Transform.rotate(
                                                                                      angle: -1.575,
                                                                                      child: const Icon(Icons.battery_0_bar,size: 20,color: Colors.red,))
                                                                                  else if(SubjectsData2.battery<20)Transform.rotate(
                                                                                      angle: -1.575,
                                                                                      child: const Icon(Icons.battery_1_bar,size: 20,color: Colors.redAccent,))
                                                                                  else if(SubjectsData2.battery<35)Transform.rotate(
                                                                                      angle: -1.575,
                                                                                      child: Icon(Icons.battery_2_bar,size: 20,color: Colors.orangeAccent.shade400,))
                                                                                  else if(SubjectsData2.battery<50)Transform.rotate(
                                                                                        angle: -1.575,
                                                                                        child: const Icon(Icons.battery_3_bar,size: 20,color: Colors.orangeAccent,))
                                                                                      else if(SubjectsData2.battery<65)Transform.rotate(
                                                                                            angle: -1.575,
                                                                                            child: const Icon(Icons.battery_4_bar,size: 20,color: Colors.orange,))
                                                                                        else if(SubjectsData2.battery<80)Transform.rotate(
                                                                                              angle: -1.575,
                                                                                              child: Icon(Icons.battery_5_bar,size: 20,color: Colors.greenAccent.shade400,))
                                                                                    else if(SubjectsData2.battery<90)Transform.rotate(
                                                                                          angle: -1.575,
                                                                                          child: const Icon(Icons.battery_6_bar,size: 20,color: Colors.greenAccent,))
                                                                                  else Transform.rotate(
                                                                                      angle: -1.575,
                                                                                      child: const Icon(Icons.battery_full,size: 20,color: Colors.green,)),
                                                                                  Text("${SubjectsData2.battery}% ",style: const TextStyle(color: Colors.white,fontSize: 15),),

                                                                                ],
                                                                              ),
                                                                            )
                                                                          ),
                                                                        ),
                                                                        Padding(
                                                                          padding: const EdgeInsets.only(left: 10,right: 10),
                                                                          child: Column(
                                                                            mainAxisAlignment: MainAxisAlignment.start,
                                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                                            children: [
                                                                              Text(
                                                                                SubjectsData2.familyName,
                                                                                style: const TextStyle(color: Colors.orangeAccent, fontSize: 20),
                                                                              ),
                                                                              Padding(
                                                                                padding: const EdgeInsets.only(top: 3,left: 5),
                                                                                child: Text("Location : ${SubjectsData2.location}",style: const TextStyle(color: Colors.lightBlueAccent, fontSize: 15),),
                                                                              ),
                                                                              Padding(
                                                                                padding: const EdgeInsets.only(top: 3,left: 5),
                                                                                child: Text("Last Updated : {SubjectsData2.location}",style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 10),),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                  onTap: ()  {
                                                                      Navigator.push(context, MaterialPageRoute(builder: (context)=>MyMapWidget(lat: SubjectsData2.lat, lng: SubjectsData2.lng,)));
                                                                  },
                                                                );
                                                              },
                                                              separatorBuilder: (context, index) => const SizedBox(
                                                                height: 1,
                                                              ));
                                                        }
                                                    }
                                                  }),
                                            ),
                                            Center(
                                              child: CopyTextButton(textToCopy: SubjectsData1.id),
                                            ),
                                            const SizedBox(height: 10,)
                                          ],
                                        );
                                      },
                                      separatorBuilder: (context, index) => const SizedBox(
                                        height: 1,
                                      )),
                                );
                              }
                          }
                        }),
                  ),
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text("Our Live Location",style: TextStyle(color: Colors.white,fontSize: 30),),
                  ),
                  MyMap()
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
  familyConvertor({this.id = "",required this.familyName});

  Map<String, dynamic> toJson() => {"id": id,"familyName":familyName};

  static familyConvertor fromJson(Map<String, dynamic> json) =>
      familyConvertor(id: json['id'],familyName: json["familyName"]);
}

Stream<List<familyConvertor>> readFamily() =>
    FirebaseFirestore.instance
        .collection('Family')
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => familyConvertor.fromJson(doc.data()))
        .toList());

class familyMemberConvertor {
  String id;
  String familyName,location;
  int battery;
  double lng,lat;
  familyMemberConvertor({this.id = "",required this.familyName,required this.location,required this.battery,required this.lng,required this.lat});

  Map<String, dynamic> toJson() => {"id": id,"familyName":familyName,"location":location,"battery":battery,"lng":lng,"lat":lat};

  static familyMemberConvertor fromJson(Map<String, dynamic> json) =>
      familyMemberConvertor(id: json['id'],familyName: json["familyName"],location: json['location'],battery: json['battery'],lat: json["lat"],lng:json["lng"]);
}

Stream<List<familyMemberConvertor>> readFamilyMember(String id) =>
    FirebaseFirestore.instance
        .collection('Family').doc(id).collection("members")
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
  late int _batteryLevel=0;

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
            color:Colors.blueGrey,
            borderRadius: BorderRadius.circular(20)
        ),
        child: const Padding(
          padding: EdgeInsets.all(5.0),
          child: Text('Copy Text',style: TextStyle(color: Colors.white,fontSize: 18,fontWeight: FontWeight.w500),),
        ),
      ),
      onTap: (){
        Clipboard.setData(ClipboardData(text: textToCopy));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Text copied to clipboard')),
        );
      },
    );
  }
}

