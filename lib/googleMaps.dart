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
      body: GoogleMap(
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
    );
  }
}
