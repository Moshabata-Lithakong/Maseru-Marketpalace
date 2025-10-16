import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class MapWidget extends StatefulWidget {
  final LatLng initialLocation;
  final Function(LatLng)? onLocationSelected;
  final bool interactive;
  final bool showMarker;

  const MapWidget({
    super.key,
    required this.initialLocation,
    this.onLocationSelected,
    this.interactive = true,
    this.showMarker = true,
  });

  @override
  State<MapWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  late GoogleMapController _mapController;
  LatLng? _selectedLocation;
  bool _mapReady = false;

  @override
  void initState() {
    super.initState();
    _selectedLocation = widget.initialLocation;
    _initializeMap();
  }

  void _initializeMap() {
    setState(() {
      _mapReady = true;
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    
    // Animate to initial location
    _mapController.animateCamera(
      CameraUpdate.newLatLngZoom(widget.initialLocation, 15),
    );
  }

  void _onMapTapped(LatLng position) {
    if (!widget.interactive) return;

    setState(() {
      _selectedLocation = position;
    });

    widget.onLocationSelected?.call(position);
  }

  Set<Marker> _getMarkers() {
    if (!widget.showMarker || _selectedLocation == null) {
      return {};
    }

    return {
      Marker(
        markerId: const MarkerId('selected-location'),
        position: _selectedLocation!,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    if (!_mapReady) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 8),
              Text('Loading Map...'),
            ],
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: GoogleMap(
          onMapCreated: _onMapCreated,
          initialCameraPosition: CameraPosition(
            target: widget.initialLocation,
            zoom: 15,
          ),
          onTap: _onMapTapped,
          markers: _getMarkers(),
          myLocationEnabled: true,
          myLocationButtonEnabled: widget.interactive,
          zoomControlsEnabled: widget.interactive,
          scrollGesturesEnabled: widget.interactive,
          zoomGesturesEnabled: widget.interactive,
          rotateGesturesEnabled: widget.interactive,
          tiltGesturesEnabled: widget.interactive,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }
}