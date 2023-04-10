import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';

import 'authPage.dart';

class settings extends StatefulWidget {
  const settings({Key? key}) : super(key: key);

  @override
  State<settings> createState() => _settingsState();
}

class _settingsState extends State<settings> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              "Settings",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),

            Expanded(
                child: Column(
                  children: [
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
                                return Container(
                                  width:double.infinity,
                                  decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.3),
                                      borderRadius: BorderRadius.circular(20)
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        const Text("Profile",style: TextStyle(fontSize: 25),),
                                        Container(
                                          height:50,
                                          width: 50,
                                          decoration: BoxDecoration(
                                              color: Colors.black,
                                              borderRadius: BorderRadius.circular(25)
                                          ),
                                        ),
                                        Text(mainsnapshot.data!["name"],style: const TextStyle(fontSize: 20,color: Colors.orangeAccent),),
                                        Text(mainsnapshot.data!["email"],style: const TextStyle(fontSize: 20,color: Colors.blue),),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            Text("Age : ${mainsnapshot.data!["age"]}",style: const TextStyle(fontSize: 20,color: Colors.white),),
                                            const SizedBox(width: 10,),
                                            Text("Phone : ${mainsnapshot.data!["phoneNumber"]}",style: const TextStyle(fontSize: 20,color: Colors.white),)
                                          ],
                                        ),
                                        Text("Address : ${mainsnapshot.data!['address']}",style: const TextStyle(fontSize: 20,color: Colors.blue),),
                                        Text(mainsnapshot.data!["lastUpdate"],)
                                      ],
                                    ),
                                  ),
                                );
                              }else{
                                return Container();
                              }
                          }
                        }),
                  ],
                )
            )
          ],
        ),
      ),
    );
  }
}

getAddressFromLatLng(location) async {
  List<Placemark> placemarks = await placemarkFromCoordinates(
    location.latitude,
    location.longitude,
  );
  Placemark place = placemarks[0];
  FirebaseFirestore.instance
      .collection('Family')
      .doc("m90h4LQ10CA7fxqnMpJA")
      .collection("members")
      .doc("oFZ005m9YyyCDRyXk5YZ")
      .update({
    "location": "${place.street}, "
        "${place.locality}, "
        "${place.country}",
    "lng": location.longitude,
    "lat": location.latitude,
  });
}

fullUserId() {
  var user = FirebaseAuth.instance.currentUser!.email!;
  return user;
}