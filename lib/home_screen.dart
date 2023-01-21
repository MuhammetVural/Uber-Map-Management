// import 'dart:async';
//
//
// import '../widgets/my_drawer.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_polyline_points/flutter_polyline_points.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'global/global.dart';
//
// //LatLng SOURCE_LOCATION = LatLng(sharedPreferences!.getDouble("lat")!, sharedPreferences!.getDouble("lng")!);
// LatLng SOURCE_LOCATION = LatLng(39.79, 30.49);
// LatLng DEST_LOCATION = LatLng(39.7866393, 30.509036);
// const double CAMERA_ZOOM = 15;
// const double CAMERA_TILT = 5;
// const double CAMERA_BEARING = 5;
//
// class HomeScreen extends StatefulWidget {
//
//   static final CameraPosition _kGooglePlex = CameraPosition(
//     target: LatLng(37.42796133580664, 30.48),
//     zoom: 14.4746,
//   );
//
//   const HomeScreen({Key? key}) : super(key: key);
//
//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }
//
// class _HomeScreenState extends State<HomeScreen> {
//
//   final items = [
//     "slider/0.jpg",
//     "slider/1.jpg",
//     "slider/2.jpg",
//     "slider/3.jpg",
//     "slider/4.jpg",
//     "slider/5.jpg",
//
//   ];
//
//   final Completer<GoogleMapController> _controller = Completer();
//
//   final Set<Marker> _markers = <Marker>{};
//   final Set<Polyline> _polylines = <Polyline>{};
//   List<LatLng> polylineCoordinates = [];
//   late PolylinePoints polylinePoints;
//
//   late LatLng currentLocation;
//   late LatLng destinationLocation;
//   late BitmapDescriptor sourceIcon;
//   late BitmapDescriptor destinationIcon;
//   late Position currentPosition;
//
//   late GoogleMapController newGoogleMapController;
//
//   var geoLocator = Geolocator();
//
//   void setSourceAndDestinationMarkerIcons() async {
//     sourceIcon = await BitmapDescriptor.fromAssetImage(
//         ImageConfiguration(devicePixelRatio: 2.0),
//         'assets/images/location_blue.png');
//     destinationIcon = await BitmapDescriptor.fromAssetImage(
//         ImageConfiguration(devicePixelRatio: 2.0),
//         'assets/images/location_red.png');
//   }
//
//   @override
//   void initState() {
//     polylinePoints = PolylinePoints();
//     super.initState();
//     setInitialLocation();
//     setSourceAndDestinationMarkerIcons();
//   }
//
//   void setInitialLocation() {
//     currentLocation = LatLng(
//       SOURCE_LOCATION.latitude,
//       SOURCE_LOCATION.longitude,
//     );
//     destinationLocation = LatLng(
//       DEST_LOCATION.latitude,
//       DEST_LOCATION.longitude,
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     CameraPosition initialCameraPosition = CameraPosition(
//       target: SOURCE_LOCATION,
//       zoom: CAMERA_ZOOM,
//       tilt: CAMERA_TILT,
//       bearing: CAMERA_BEARING,
//     );
//     return Scaffold(
//       drawer: MyDrawer(),
//       appBar: AppBar(
//
//
//
//         title: Text(
//           sharedPreferences!.getString("name")!,
//         ),
//         centerTitle: true,
//       ),
//
//       body: Stack(
//         children: [
//           Container(
//             height: MediaQuery.of(context).size.height,
//             width: double.infinity,
//             child: GoogleMap(
//               mapType: MapType.normal,
//               zoomControlsEnabled: false,
//               myLocationButtonEnabled: false,
//               polylines: _polylines,
//               markers: _markers,
//               myLocationEnabled: true,
//               initialCameraPosition: HomeScreen._kGooglePlex,
//               onMapCreated: (GoogleMapController controller) {
//                 _controller.complete(controller);
//                 newGoogleMapController = controller;
//                 locatePosition();
//                  showPinsOnMap();
//                  setPolylines();
//               },
//             ),
//           ),
//         ],
//       ),
//       floatingActionButton: Row(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           FloatingActionButton(
//             // child: Icon(Icons.book_online),
//             // onPressed: () {
//             //   firebaseAuth.signOut();
//             //   Navigator.push(
//             //       context, MaterialPageRoute(builder: (c) => SignInScreen()));
//             // }
//
//             child: Icon(Icons.online_prediction),
//             onPressed: () async {
//               Position position = await _determinePosition();
//               GoogleMapController controller = await _controller.future;
//
//               controller.animateCamera(CameraUpdate.newCameraPosition(
//                 CameraPosition(
//                   target: LatLng(position.latitude, position.longitude), zoom: 14,
//                 ),),
//               );
//               _markers.add(
//                 Marker(
//                   markerId: MarkerId('currentLocation'),
//                   position: LatLng(position.latitude, position.longitude),
//                   icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow),
//                 ),
//               );
//               setState(() {
//
//               });
//             }
//
//             ,
//             backgroundColor: Theme.of(context).primaryColorLight,
//             foregroundColor: const Color(0xffCAFB09),
//           ),
//           const SizedBox(
//             width: 10,
//           ),
//         ],
//       ),
//       floatingActionButtonLocation:
//           FloatingActionButtonLocation.miniCenterFloat,
//     );
//   }
//
//
//   void locatePosition() async
//   {
//     Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
//     currentPosition = position;
//
//     LatLng latLatPosition = LatLng(position.latitude, position.longitude);
//
//     CameraPosition cameraPosition = new CameraPosition(target: latLatPosition, zoom: 16);
//     newGoogleMapController.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
//   }
//
//
//   Future<Position> _determinePosition() async {
//     bool serviceEnable;
//     LocationPermission permission;
//     serviceEnable = await Geolocator.isLocationServiceEnabled();
//     if (!serviceEnable) {
//       return Future.error('Location Services Are Disable');
//     }
//     permission = await Geolocator.checkPermission();
//
//     if (permission == LocationPermission.denied) {
//       permission = await Geolocator.requestPermission();
//       if (permission == LocationPermission.denied) {
//         return Future.error('Location permistion denied');
//       }
//     }
//     if (permission == LocationPermission.deniedForever) {
//       return Future.error('Location permissions permanently denied');
//     }
//
//     Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
//     return position;
//   }
//
//   void showPinsOnMap() {
//     setState(() {
//       _markers.add(
//         Marker(
//           markerId: MarkerId('sourcePin'),
//           position: currentLocation,
//           icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
//         ),
//       );
//       _markers.add(
//         Marker(
//           markerId: MarkerId('destinationPin'),
//           position: destinationLocation,
//           icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
//         ),
//       );
//     });
//   }
//
//   void setPolylines() async {
//     PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
//       "AIzaSyBvE3V--5yCHQj-phkOi-S_26HN8V5yq7E",
//       PointLatLng(
//         currentLocation.latitude,
//         currentLocation.longitude,
//       ),
//       PointLatLng(destinationLocation.latitude, destinationLocation.longitude),
//     );
//     if (result.status == 'OK') {
//       result.points.forEach((PointLatLng point) {
//         polylineCoordinates.add(
//           LatLng(point.latitude, point.longitude),
//         );
//       });
//       setState(() {
//         _polylines.add(
//           Polyline(
//             polylineId: PolylineId('polyline'),
//             color: Colors.purple,
//
//             points: polylineCoordinates,
//           ),
//         );
//       });
//     }
//   }
// }
