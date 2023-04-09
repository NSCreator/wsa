import 'dart:async';

import 'package:battery_plus/battery_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:wsa/authPage.dart';
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



  @override
  void initState() {
    super.initState();

    Timer.periodic(const Duration(seconds: 3), (timer) {
      getBatteryPerentage();

    });


  }
  void getBatteryPerentage() async {
    final level = await battery.batteryLevel;
    if(percentage != level){
      percentage = level;
      setState(() {});
    }


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
                   Text("WS App",style: TextStyle(color: Colors.white,fontSize: 30),),
                  const Spacer(),
                  const Icon(Icons.settings,color: Colors.grey,size: 30,),
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
                             Text("Smart Band",style: TextStyle(color: Colors.white,fontSize: 25),),
                            Spacer(),
                            if(false)Text("Not Conected",style: TextStyle(color: Colors.red),)
                            else Text("Conected",style: TextStyle(color: Colors.greenAccent),)
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
                            BoxShadow(
                            blurRadius: 25.0,
                              color: Colors.white

                        )
                        ],
                          ),
                          child: const Center(child: Text("SOS",style: TextStyle(color: Colors.white,fontSize: 35),)),
                        ),
                        onTap: (){
                          Navigator.push(context, MaterialPageRoute(builder: (context)=>MyMap()));
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
                                              padding: EdgeInsets.only(left: 15,top: 5),
                                              child: Text(
                                                SubjectsData1.familyName,
                                                style: TextStyle(color: Colors.white, fontSize: 25),
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
                                                                              image: DecorationImage(image: NetworkImage("https://pub.dev/static/hash-aps7rpf8/img/ff-banner-mobile-2x.png"),fit: BoxFit.cover),

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
                                                                                children: [
                                                                                  SizedBox(width: 3,),
                                                                                  Transform.rotate(
                                                                                      angle: -1.575,
                                                                                      child: Icon(Icons.battery_full,size: 20,color: Colors.greenAccent,)),
                                                                                  Text("${percentage}%",style: TextStyle(color: Colors.white,fontSize: 15),),

                                                                                ],
                                                                              ),
                                                                            )
                                                                          ),
                                                                        ),
                                                                        Column(
                                                                          mainAxisAlignment: MainAxisAlignment.start,
                                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                                          children: [
                                                                            Text(
                                                                              SubjectsData2.familyName,
                                                                              style: TextStyle(color: Colors.white, fontSize: 20),
                                                                            ),
                                                                            Padding(
                                                                              padding: const EdgeInsets.all(8.0),
                                                                              child: Text("Location : ",style: TextStyle(color: Colors.white, fontSize: 15),),
                                                                            ),
                                                                            Row(
                                                                              children: [
                                                                                Transform.rotate(
                                                                                    angle: -1.575,
                                                                                    child: Icon(Icons.battery_full,size: 30,color: Colors.greenAccent,)),
                                                                                Text("${percentage}%",style: TextStyle(color: Colors.white,fontSize: 18),),

                                                                                Text("Last UPdated",style: TextStyle(color: Colors.white,fontSize: 13),)
                                                                              ],
                                                                            )
                                                                          ],
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                  onTap: ()  {},
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
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color:Colors.blueGrey,
                                                  borderRadius: BorderRadius.circular(20)
                                                ),
                                                child: Padding(
                                                  padding: const EdgeInsets.all(5.0),
                                                  child: Text("Copy Token",style: TextStyle(color: Colors.white),),
                                                ),
                                              ),
                                            ),
                                            SizedBox(height: 10,)
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
                  Padding(
                    padding: const EdgeInsets.all(8.0),
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
  String familyName;
  familyMemberConvertor({this.id = "",required this.familyName});

  Map<String, dynamic> toJson() => {"id": id,"familyName":familyName};

  static familyMemberConvertor fromJson(Map<String, dynamic> json) =>
      familyMemberConvertor(id: json['id'],familyName: json["familyName"]);
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