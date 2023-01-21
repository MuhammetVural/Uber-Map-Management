import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class GgMap extends StatefulWidget {
  final double lat;
  final double lng;

  const GgMap({Key? key, required this.lat, required this.lng})
      : super(key: key);

  @override
  State<GgMap> createState() => _GgMapState();
}

class _GgMapState extends State<GgMap> {

  late GoogleMapController _googleMapController;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      child: GoogleMap(
          trafficEnabled: true,
          myLocationButtonEnabled: true,
          zoomControlsEnabled: false,
          mapType: MapType.normal,
          initialCameraPosition:
              CameraPosition(target: LatLng(widget.lat, widget.lng), zoom: 13),
          onMapCreated: (controller) => _googleMapController = controller,
          markers: {
            Marker(
              markerId: MarkerId("source"),
              position: LatLng(widget.lat, widget.lng),
            ),
            const Marker(
              markerId: MarkerId("hedef"),
              position: LatLng(39.7837169, 30.4865968),
            ),

          }
          ),
    );
  }
}
