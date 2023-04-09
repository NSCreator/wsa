import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';

class MyApp5 extends StatefulWidget {
  @override
  State<MyApp5> createState() => _MyApp5State();
}

class _MyApp5State extends State<MyApp5> {
  late Position currentPosition;
  late String currentAddress;

  late GoogleMapController mapController;
  Set<Marker> _markers = {};
  late LatLng _center;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      currentPosition = position;
      _center = LatLng(currentPosition.latitude, currentPosition.longitude);
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
        print(currentAddress);
        _markers.add(
          Marker(
            markerId: MarkerId('current_location'),
            position: _center,
            infoWindow: InfoWindow(
              title: currentAddress,
            ),
          ),
        );
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        key: _scaffoldKey,
        body: Stack(
          children: [
            GoogleMap(
              onMapCreated: (GoogleMapController controller) {
                mapController = controller;
              },
              initialCameraPosition: CameraPosition(
                target: _center,
                zoom: 16.0,
              ),
              markers: _markers,
            ),
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  currentAddress ?? "Loading..",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
