import 'package:cloud_firestore/cloud_firestore.dart';
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
            Text("Settings",style: TextStyle(color: Colors.white,fontSize: 20),),
            Expanded(
                child: Column(
                  children: [
                    Container(
                      width:double.infinity,
                      decoration: BoxDecoration(
                          color: Colors.brown,
                          borderRadius: BorderRadius.circular(20)
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            Container(
                              height:50,
                              width: 50,
                              decoration: BoxDecoration(
                                  color: Colors.black,
                                  borderRadius: BorderRadius.circular(25)
                              ),
                            ),
                            Text("Name"),
                            Text("Sujithnimmala032gmail.com")
                          ],
                        ),
                      ),
                    )
                  ],
                )
            )
          ],
        ),
      ),
    );
  }
}


 getAddressFromLatLng(location)  async {
   List<Placemark> placemarks = await placemarkFromCoordinates(
     location.latitude,
     location.longitude,
   );
   Placemark place = placemarks[0];
   FirebaseFirestore.instance.collection('Family').doc("m90h4LQ10CA7fxqnMpJA").collection("members").doc("oFZ005m9YyyCDRyXk5YZ")
       .update({
     "location":"${place.street}, "
         "${place.locality}, "
         "${place.country}",
     "lng":location.longitude,
     "lat":location.latitude,

       });
}