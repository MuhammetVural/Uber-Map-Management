

import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'global/global.dart';

//LatLng SOURCE_LOCATION = LatLng(sharedPreferences!.getDouble("lat")!, sharedPreferences!.getDouble("lng")!);
LatLng SOURCE_LOCATION = LatLng(39.79, 30.49);
LatLng DEST_LOCATION = LatLng(39.7866393, 30.509036);
const double CAMERA_ZOOM = 15;
const double CAMERA_TILT = 5;
const double CAMERA_BEARING = 5;

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String statusText = "Now Offline";
  Color statusColor = Colors.grey;
  bool isDriverActive = false;

  StreamSubscription<Position>? streamSubscriptionPosition;



  final Completer<GoogleMapController> _controller = Completer();

  final Set<Marker> _markers = <Marker>{};
  final Set<Polyline> _polylines = <Polyline>{};
  List<LatLng> polylineCoordinates = [];
  late PolylinePoints polylinePoints;

  late LatLng currentLocation;
  late LatLng destinationLocation;
  late BitmapDescriptor sourceIcon;
  late BitmapDescriptor destinationIcon;
  late Position currentPosition;

  late GoogleMapController newGoogleMapController;

  var geoLocator = Geolocator();

  void setSourceAndDestinationMarkerIcons() async {
    sourceIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.0),
        'assets/images/location_blue.png');
    destinationIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.0),
        'assets/images/location_red.png');
  }

  void locatePosition() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    currentPosition = position;

    LatLng latLatPosition = LatLng(position.latitude, position.longitude);

    CameraPosition cameraPosition =
    new CameraPosition(target: latLatPosition, zoom: 16);
    newGoogleMapController
        .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
  }

  @override
  void initState() {
    locatePosition();
    polylinePoints = PolylinePoints();
    super.initState();

    setInitialLocation();
    setSourceAndDestinationMarkerIcons();
  }

  Future<Position> _determinePosition() async {
    bool serviceEnable;
    LocationPermission permission;
    serviceEnable = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnable) {
      return Future.error('Location Services Are Disable');
    }
    permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permistion denied');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions permanently denied');
    }

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    return position;
  }

  void showPinsOnMap() async {
    Position position = await _determinePosition();
    setState(() {
      _markers.add(
        Marker(
          markerId: MarkerId('currentLocation'),
          position: LatLng(position.latitude, position.longitude),
          icon:
          BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow),
        ),
      );

      _markers.add(
        Marker(
          markerId: MarkerId('sourcePin'),
          position: currentLocation,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ),
      );
      _markers.add(
        Marker(
          markerId: MarkerId('destinationPin'),
          position: destinationLocation,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        ),
      );
    });
  }

  void setPolylines() async {
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      "AIzaSyCalOpqAMn-ubjg_EfYbywge3paFfuHdgc",
      PointLatLng(
        currentPosition.latitude,
        currentPosition.longitude,
      ),
      PointLatLng(destinationLocation.latitude, destinationLocation.longitude),
    );
    if (result.status == 'OK') {
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(
          LatLng(point.latitude, point.longitude),
        );
      });
      setState(() {
        _polylines.add(
          Polyline(
            polylineId: PolylineId('polyline'),
            color: Colors.purple,
            points: polylineCoordinates,
          ),
        );
      });
    }
  }

  void setInitialLocation() {
    currentLocation = LatLng(
      SOURCE_LOCATION.latitude,
      SOURCE_LOCATION.longitude,
    );
    destinationLocation = LatLng(
      DEST_LOCATION.latitude,
      DEST_LOCATION.longitude,
    );
  }
  driverIsOnlineNow(){
    Geofire.initialize("activeDrivers");
    Geofire.setLocation(currentFirebaseUser!.uid, currentPosition.latitude, currentPosition.longitude);

    DatabaseReference? ref = FirebaseDatabase.instance.ref().child("drivers").child(currentFirebaseUser!.uid).child("newRideStatus");

    ref.onDisconnect();
    ref.remove();
    ref = null;
  }

  driverIsOfflineNow()
  {
    Geofire.removeLocation(currentFirebaseUser!.uid);

    DatabaseReference? ref = FirebaseDatabase.instance.ref()
        .child("drivers")
        .child(currentFirebaseUser!.uid)
        .child("newRideStatus");
    ref.onDisconnect();
    ref.remove();
    ref = null;

    Future.delayed(const Duration(milliseconds: 2000), ()
    {

    });
  }


  updateDriversLocationAtRealTime()
  {
    streamSubscriptionPosition = Geolocator.getPositionStream()
        .listen((Position position)
    {
      currentPosition = position;

      if(isDriverActive == true)
      {
        Geofire.setLocation(
            currentFirebaseUser!.uid,
            currentPosition!.latitude,
            currentPosition!.longitude
        );
      }

      LatLng latLng = LatLng(
        currentPosition!.latitude,
        currentPosition!.longitude,
      );

      newGoogleMapController!.animateCamera(CameraUpdate.newLatLng(latLng));
    });
  }

  @override
  Widget build(BuildContext context) {
    CameraPosition initialCameraPosition = CameraPosition(
      target: destinationLocation,
      zoom: CAMERA_ZOOM,
      tilt: CAMERA_TILT,
      bearing: CAMERA_BEARING,
    );
    return Scaffold(
      appBar: AppBar(
        title: Text(''
         // sharedPreferences!.getString("name")!,
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Container(
            height: MediaQuery.of(context).size.height,
            width: double.infinity,
            child: GoogleMap(
              myLocationButtonEnabled: false,
              myLocationEnabled: true,
              compassEnabled: false,
              tiltGesturesEnabled: false,
              polylines: _polylines,
              markers: _markers,
              mapType: MapType.normal,
              initialCameraPosition: initialCameraPosition,
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
                newGoogleMapController = controller;

                showPinsOnMap();
                setPolylines();
              },
            ),
          ),
          statusText != "Now Online"
              ? Container(
            height: MediaQuery.of(context).size.height,
            width: double.infinity,
            color: Colors.black87,
          )
              : Container(),

          //button for online or offline driver
          Positioned(
            top: statusText != "Now Online"
                ? MediaQuery.of(context).size.height * 0.40
                : 25,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(

                    onPressed: () {
                      if(isDriverActive != true) //offline
                          {
                        driverIsOnlineNow();
                        updateDriversLocationAtRealTime();

                        setState(() {
                          statusText = "Now Online";
                          isDriverActive = true;
                          statusColor = Colors.transparent;
                        });

                        //display Toast
                        Fluttertoast.showToast(msg: "you are Online Now");
                      }
                      else //online
                          {
                        driverIsOfflineNow();

                        setState(() {
                          statusText = "Now Offline";
                          isDriverActive = false;
                          statusColor = Colors.grey;
                        });

                        //display Toast
                        Fluttertoast.showToast(msg: "you are Offline Now");
                      }
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey,
                        padding: EdgeInsets.symmetric(horizontal: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        )
                    ),
                    child: statusText != "Now Online"
                        ? Text(statusText, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),)
                        : Icon(Icons.phonelink_ring, size: 26,))
              ],
            ),
          )
        ],
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FloatingActionButton(
            // child: Icon(Icons.book_online),
            // onPressed: () {
            //   firebaseAuth.signOut();
            //   Navigator.push(
            //       context, MaterialPageRoute(builder: (c) => SignInScreen()));
            // }

            child: Icon(Icons.online_prediction),
            onPressed: () async {
              Position position = await _determinePosition();
              GoogleMapController controller = await _controller.future;

              controller.animateCamera(
                CameraUpdate.newCameraPosition(
                  CameraPosition(
                    target: LatLng(position.latitude, position.longitude),
                    zoom: 14,
                  ),
                ),
              );

              setState(() {});
            },
            backgroundColor: Theme.of(context).primaryColorLight,
            foregroundColor: const Color(0xffCAFB09),
          ),
          const SizedBox(
            width: 10,
          ),
        ],
      ),
      floatingActionButtonLocation:
      FloatingActionButtonLocation.miniCenterFloat,
    );
  }
}
