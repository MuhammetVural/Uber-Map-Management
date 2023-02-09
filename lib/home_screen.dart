

import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:uber_map_management/authentication/signInScreen.dart';
import 'package:uber_map_management/push_notifications/push_notification_system.dart';

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

  List<LatLng> polylineCoordinates = [];
  late PolylinePoints polylinePoints;

  late LatLng currentLocation;
  late LatLng destinationLocation;
  late BitmapDescriptor sourceIcon;
  late BitmapDescriptor destinationIcon;
   Position? currentPosition;

  late GoogleMapController newGoogleMapController;

  var geoLocator = Geolocator();



  locateUserPosition() async {
    Position cPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    currentPosition = cPosition;

    LatLng latLngPosition =
    LatLng(currentPosition!.latitude, currentPosition!.longitude);

    CameraPosition cameraPosition = CameraPosition(
      target: latLngPosition,
      zoom: 16,
    );
    newGoogleMapController!
        .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));


  }

  readCurrentDriverInformation() async
  {
    currentFirebaseUser = fAuth.currentUser;
    PushNotificationSystem pushNotificationSystem = PushNotificationSystem();
    pushNotificationSystem.initializeCloudMessaging(context);
    pushNotificationSystem.generateAndGetToken();
  }

  @override
  void initState() {
    locateUserPosition();
    polylinePoints = PolylinePoints();
    super.initState();
    readCurrentDriverInformation();
    setInitialLocation();

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
    Geofire.setLocation(currentFirebaseUser!.uid, currentPosition!.latitude, currentPosition!.longitude);

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
              //TODO

              mapType: MapType.normal,
              initialCameraPosition: initialCameraPosition,
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
                newGoogleMapController = controller;


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
              fAuth.signOut();
              Navigator.push(
                         context, MaterialPageRoute(builder: (c) => SignInScreen()));
              //
              // Position position = await _determinePosition();
              // GoogleMapController controller = await _controller.future;
              //
              // controller.animateCamera(
              //   CameraUpdate.newCameraPosition(
              //     CameraPosition(
              //       target: LatLng(position.latitude, position.longitude),
              //       zoom: 14,
              //     ),
              //   ),
              // );
              //
              // setState(() {});
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
