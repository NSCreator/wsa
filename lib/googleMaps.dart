// ignore_for_file: prefer_const_constructors

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

import 'package:wsa/settings.dart';

import 'homePage.dart';

String google_api_key = "AIzaSyCiHAuZJyIZoMmdDIldB1UlLn8OBsOE2E0";

class MyMap extends StatefulWidget {
  @override
  _MyMapState createState() => _MyMapState();
}

class _MyMapState extends State<MyMap> {
  final Completer<GoogleMapController> _controller = Completer();
  late LocationData _locationData;
  static const LatLng sourceLocation = LatLng(37.33500926, -122.03272188);
  static const LatLng destination = LatLng(37.33429383, -122.06600055);

  LocationData? currentLocation;

  Future<void> getCurrentLocation() async {
    Location location = Location();
    _locationData = await location.getLocation();
    location.getLocation().then((location) {
      getAddressFromLatLng(_locationData);
      setState(() {
        currentLocation = location;
        print("${currentLocation!.latitude}");
      });
    });
  }

  List<LatLng> polylineCoordinates = [];

  void getPolyPoints() async {
    PolylinePoints polylinePoints = PolylinePoints();
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      google_api_key,
      PointLatLng(sourceLocation.latitude, sourceLocation.longitude),
      PointLatLng(destination.latitude, destination.longitude),
    );
    if (result.points.isNotEmpty) {
      for (var point in result.points) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      }
      setState(() {});
    }
  }

  @override
  void initState() {
    getCurrentLocation();
    getPolyPoints();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return currentLocation == null
        ? Center(
            child: SizedBox(
                height: 50, width: 50, child: CircularProgressIndicator()))
        : GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(
                  currentLocation!.latitude!, currentLocation!.longitude!),
              zoom: 14.5,
            ),
            polylines: {
              Polyline(
                polylineId: const PolylineId("route"),
                points: polylineCoordinates,
              )
            },
            markers: {
              Marker(
                markerId: MarkerId("My Location"),
                position: LatLng(
                    currentLocation!.latitude!, currentLocation!.longitude!),
              ),
              Marker(markerId: MarkerId("source"), position: sourceLocation),
              Marker(markerId: MarkerId("destination"), position: destination)
            },
          );
  }
}

class MyMapWidget extends StatefulWidget {
  final double lat;
  final double lng;
  final String name;

  MyMapWidget({required this.lat, required this.lng, required this.name});

  @override
  _MyMapWidgetState createState() => _MyMapWidgetState();
}

class _MyMapWidgetState extends State<MyMapWidget> {
  late GoogleMapController _mapController;
  late LatLng _sourceLocation;

  @override
  void initState() {
    super.initState();
    _sourceLocation = LatLng(widget.lat, widget.lng);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Positioned(
            top: 0,
            bottom: 0,
            left: 0,
            right: 0,
            child: GoogleMap(
              padding: EdgeInsets.only(bottom: 120),
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              compassEnabled: true,
              onMapCreated: (controller) {
                _mapController = controller;
              },
              initialCameraPosition: CameraPosition(
                target: _sourceLocation,
                zoom: 14.0,
              ),
              markers: <Marker>{
                Marker(
                  markerId: MarkerId("source"),
                  position: _sourceLocation,
                  infoWindow: InfoWindow(title: "Source"),
                ),
              },
            ),
          ),
          Positioned(
            top: 100,
            left: 100,
            child: StreamBuilder<List<familyMembersConvertor>>(
                stream: readFamilyMembers(),
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
                        return SizedBox(
                          height: 30,
                          child: ListView.separated(
                              physics: const BouncingScrollPhysics(),
                              scrollDirection: Axis.horizontal,
                              shrinkWrap: true,
                              itemCount: user1!.length,
                              itemBuilder: (context, int index) {
                                final SubjectsData1 = user1[index];
                                return StreamBuilder<DocumentSnapshot>(
                                    stream: FirebaseFirestore.instance
                                        .collection("users")
                                        .doc(SubjectsData1.name)
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
                                            return InkWell(
                                                child: Container(
                                              decoration: BoxDecoration(
                                                  color: Colors.greenAccent,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10)),
                                              child: Row(
                                                children: [
                                                  Container(
                                                    height: 30,
                                                    width: 38,
                                                    decoration: BoxDecoration(
                                                        color: Colors.green,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10),
                                                        image: DecorationImage(
                                                            image: NetworkImage(
                                                          mainsnapshot.data![
                                                              "photoUrl"],
                                                        ))),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            3.0),
                                                    child: Text(
                                                      mainsnapshot
                                                          .data!["name"],
                                                      style: TextStyle(
                                                          color: Colors.black,
                                                          fontSize: 20),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ));
                                          } else {
                                            return Container();
                                          }
                                      }
                                    });
                              },
                              separatorBuilder: (context, index) =>
                                  const SizedBox(
                                    width: 5,
                                  )),
                        );
                      }
                  }
                }),
          ),
          DraggableScrollableSheet(
            initialChildSize: .14,
            minChildSize: .14,
            maxChildSize: .6,
            builder: (BuildContext context, ScrollController scrollController) {
              return Container(
                decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(30),
                      topLeft: Radius.circular(30),
                    )),
                child: SingleChildScrollView(
                  physics: NeverScrollableScrollPhysics(),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 15, top: 10),
                        child: Text(
                          "See More About ${widget.name}",
                          style: TextStyle(
                              color: Colors.orangeAccent, fontSize: 19),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 10, top: 5),
                        child: Text(
                          "Google Maps History",
                          style: TextStyle(color: Colors.white, fontSize: 25),
                        ),
                      ),
                      ListView.separated(
                        physics: BouncingScrollPhysics(),
                        controller: scrollController,
                        itemCount: 1,
                        shrinkWrap: true,
                        itemBuilder: (BuildContext context, int index) {
                          return Padding(
                            padding: const EdgeInsets.only(left: 10, right: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  height: 50,
                                  width: 50,
                                  decoration: BoxDecoration(
                                      color: Colors.black,
                                      borderRadius: BorderRadius.circular(25)),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Sujith Nimmala",
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.white),
                                    ),
                                    Text(
                                      "Place",
                                      style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.white),
                                    ),
                                    Text(
                                      "13/03/2002",
                                      style: TextStyle(
                                          fontSize: 16, color: Colors.white),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                        separatorBuilder: (BuildContext context, int index) =>
                            const Divider(
                          thickness: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          )
        ],
      ),
      // body: Column(
      //   children: [
      //     GoogleMap(
      //       onMapCreated: (controller) {
      //         _mapController = controller;
      //       },
      //       initialCameraPosition: CameraPosition(
      //         target: _sourceLocation,
      //         zoom: 14.0,
      //       ),
      //       markers: Set<Marker>.of([
      //         Marker(
      //           markerId: MarkerId("source"),
      //           position: _sourceLocation,
      //           infoWindow: InfoWindow(title: "Source"),
      //         ),
      //       ]),
      //     ),
      //     bottomDetailsSheet()
      //   ],
      // ),
    );
  }
}

class familyMembersConvertor {
  String id;
  String name;

  familyMembersConvertor({this.id = "", required this.name});

  Map<String, dynamic> toJson() => {"id": id, "userId": name};

  static familyMembersConvertor fromJson(Map<String, dynamic> json) =>
      familyMembersConvertor(id: json['id'], name: json["userId"]);
}

Stream<List<familyMembersConvertor>> readFamilyMembers() =>
    FirebaseFirestore.instance
        .collection('Family')
        .doc("m90h4LQ10CA7fxqnMpJA")
        .collection("members")
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => familyMembersConvertor.fromJson(doc.data()))
            .toList());

//
// class HorizontalList extends StatefulWidget {
//   @override
//   _HorizontalListState createState() => _HorizontalListState();
// }
//
// class _HorizontalListState extends State<HorizontalList> {
//   final databaseReference = FirebaseDatabase.instance;
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: 150,
//       child:
//     );
//   }
// }
