import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _mapController;
  Position? _currentPosition;
  final Set<Marker> _markers = {};
  final Set<Circle> _riskZones = {};

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    // TODO: Load sightings and create markers
  }

  Future<void> _getCurrentLocation() async {
    final permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      final result = await Geolocator.requestPermission();
      if (result == LocationPermission.denied) return;
    }

    try {
      final position = await Geolocator.getCurrentPosition();
      setState(() {
        _currentPosition = position;
      });
      _mapController?.animateCamera(
        CameraUpdate.newLatLng(LatLng(position.latitude, position.longitude)),
      );
    } catch (e) {
      debugPrint('Error getting location: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mapa de Riesgo')),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target:
              _currentPosition != null
                  ? LatLng(
                    _currentPosition!.latitude,
                    _currentPosition!.longitude,
                  )
                  : const LatLng(0, 0),
          zoom: 15,
        ),
        onMapCreated: (controller) => _mapController = controller,
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
        markers: _markers,
        circles: _riskZones,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Implement filter options for different types of animals
        },
        child: const Icon(Icons.filter_list),
      ),
    );
  }
}
