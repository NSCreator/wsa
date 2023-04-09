import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:wsa/authPage.dart';

String google_api_key = "AIzaSyCiHAuZJyIZoMmdDIldB1UlLn8OBsOE2E0";

class MyMap extends StatefulWidget {
  @override
  _MyMapState createState() => _MyMapState();
}

class _MyMapState extends State<MyMap> {
  final Completer<GoogleMapController> _controller = Completer();
  LatLng _center = LatLng(0, 0);
  String _placeName = "";
  late String currentAddress;
  Set<Marker> _markers = {};
  late Position currentPosition;
  static const LatLng sourceLocation = LatLng(37.33500926, -122.03272188);
  static const LatLng destination = LatLng(37.33429383, -122.06600055);

  // LocationData? currentLocation;
  // void getCurrentLocation(){
  //   Location location = Location();
  //
  //   location.getLocation().then((location){
  //     currentLocation = location;
  //     setState(() {
  //       print("${currentLocation}");
  //     });
  //   });
  // }
  Future<void> _getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      currentPosition = position;
    });
    _getAddressFromLatLng();
  }
  Future<void> _getAddressFromLatLng() async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
          currentPosition.latitude, currentPosition.longitude);

      Placemark place = placemarks[0];
      setState(() {
        currentAddress = "${place.name}, ${place.locality}, ${place.country}";

        showToast(currentAddress);
      });
    } catch (e) {
      print(e);
    }
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
    _getCurrentLocation();
    getPolyPoints();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return currentPosition==null?CircularProgressIndicator():
    Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        height: 300,
        width: double.infinity,
        child: GoogleMap(
          initialCameraPosition: CameraPosition(
            target: LatLng(currentPosition!.latitude!,currentPosition!.longitude!),
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
                position: LatLng(currentPosition!.latitude!,currentPosition!.longitude!),
              infoWindow: InfoWindow(
                title: _placeName,
              ),
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

