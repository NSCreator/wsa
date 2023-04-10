import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

import 'package:wsa/settings.dart';

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
    location.getLocation().then((location){

      getAddressFromLatLng(_locationData);
      setState(() {
        currentLocation = location;
        print("${currentLocation!.latitude}");
      });
    });


  }
  List<LatLng>polylineCoordinates = [];
  void getPolyPoints() async{
    PolylinePoints polylinePoints = PolylinePoints();
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        google_api_key,
        PointLatLng(sourceLocation.latitude, sourceLocation.longitude),
        PointLatLng(destination.latitude, destination.longitude),
    );
    if(result.points.isNotEmpty){
      for (var point in result.points) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      }
     setState(() {});
    }
  }

  @override
  void initState(){
    getCurrentLocation();
    getPolyPoints();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return currentLocation==null?CircularProgressIndicator():
    Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        height: 300,
        width: double.infinity,
        child: GoogleMap(
          initialCameraPosition: CameraPosition(
            target: LatLng(currentLocation!.latitude!,currentLocation!.longitude!),
            zoom: 14.5,
          ),
          polylines: {
            Polyline(
              polylineId: const PolylineId("route"),
              points:polylineCoordinates,
            )
          },
          markers: {
            Marker(markerId: MarkerId("My Location"),
                position: LatLng(currentLocation!.latitude!,currentLocation!.longitude!),
            ),
            Marker(markerId: MarkerId("source"),
                position: sourceLocation
            ),
            Marker(markerId: MarkerId("destination"),
                position: destination
            )
          },
        ),
      ),
    );
  }
}


class MyMapWidget extends StatefulWidget {
  final double lat;
  final double lng;

  MyMapWidget({required this.lat, required this.lng});

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
              padding: EdgeInsets.only(
                bottom: 120),
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
                  markers: Set<Marker>.of([
                    Marker(
                      markerId: MarkerId("source"),
                      position: _sourceLocation,
                      infoWindow: InfoWindow(title: "Source"),
                    ),
                  ]),
                ),
          ),
          DraggableScrollableSheet(

            initialChildSize: .14,
            minChildSize: .14,
            maxChildSize: .6,

            builder: (BuildContext context, ScrollController scrollController){
              return Container(
                decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(40),
                    topLeft: Radius.circular(40),
                  )
                ),
                child: ListView.separated(
                  physics: BouncingScrollPhysics(),
                    controller: scrollController,
                    itemCount: 5,
                    itemBuilder: (BuildContext context, int index){
                      return Padding(
                        padding: const EdgeInsets.only(left: 10,right: 10),
                        child: Row(
                          children: [
                            Container(
                              height:50,
                              width: 50,
                              decoration: BoxDecoration(
                                  color: Colors.black,
                                  borderRadius: BorderRadius.circular(25)
                              ),
                            ),
                            Column(
                              children: [
                                Text("13/03/2002",
                                  style: TextStyle(
                                    fontSize: 20
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  separatorBuilder: (BuildContext context, int index) => const Divider(thickness: 1.5,),
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
  void _GoogleMapBottomSheet(BuildContext context) =>
      showModalBottomSheet(
        backgroundColor: Colors.black54,
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(30),
            )),
        builder: (context) =>
            DraggableScrollableSheet(
                initialChildSize: 0.4,
                maxChildSize: 0.55,
                minChildSize: 0.32,
                expand: false,
                builder: (context, scrollController) {
                  return SingleChildScrollView(
                    controller: scrollController,
                    child: Stack(
                      alignment: AlignmentDirectional.topCenter,
                      clipBehavior: Clip.none,
                      children: [
                        Positioned(
                          top: -15,
                          child: Container(
                            width: 60,
                            height: 7,
                            margin: const EdgeInsets.only(bottom: 20),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                              ]),
                        )
                      ],
                    ),
                  );
                }
            ),
      );

Widget bottomDetailsSheet() {
  return DraggableScrollableSheet(
    initialChildSize: .2,
    minChildSize: .1,
    maxChildSize: .6,

    builder: (BuildContext context, ScrollController scrollController) {
      return Container(
        color: Colors.lightGreen[100],
        child: ListView(
          controller: scrollController,
          shrinkWrap: true,
          children: [
            ListTile(
              title: Text(
                "NAME",
              ),
              subtitle: Text(
                "animalNames[selectedTile]",
              ),
            ),
            ListTile(
              title: Text(
                "FAMILY",
              ),
              subtitle: Text(
               " animalFamily[selectedTile]",
              ),
            ),
            ListTile(
              title: Text(
                "LIFESPAN",
              ),
              subtitle: Text(
                "animalLifeSpan[selectedTile]",
              ),
            ),
            ListTile(
              title: Text(
                "WEIGHT",
              ),
              subtitle: Text(
                "animalWeight[selectedTile]",
              ),
            ),
          ],
        ),
      );
    },
  );
}
