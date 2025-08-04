import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geocoding/geocoding.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart' as loc;
import 'package:tilikjalan/core/core.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> with AutomaticKeepAliveClientMixin {
  final MapController _mapController = MapController();
  final loc.Location _location = loc.Location();
  LatLng? _currentPosition;
  bool _isLoading = true;
  String? _errorMessage;
  bool _hasInitialized = false;
  String? _currentAddress;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    if (!_hasInitialized) {
      _getCurrentLocation();
      _hasInitialized = true;
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // Check if location service is enabled
      var serviceEnabled = await _location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await _location.requestService();
        if (!serviceEnabled) {
          setState(() {
            _errorMessage = 'Location service is disabled';
            _isLoading = false;
          });
          return;
        }
      }

      // Check location permissions
      var permissionGranted = await _location.hasPermission();
      if (permissionGranted == loc.PermissionStatus.denied) {
        permissionGranted = await _location.requestPermission();
        if (permissionGranted != loc.PermissionStatus.granted) {
          setState(() {
            _errorMessage = 'Location permission denied';
            _isLoading = false;
          });
          return;
        }
      }

      // Get current location
      final locationData = await _location.getLocation();
      if (locationData.latitude != null && locationData.longitude != null) {
        final newPosition = LatLng(
          locationData.latitude!,
          locationData.longitude!,
        );

        // Get address from coordinates
        final address = await _getAddressFromCoordinates(
          locationData.latitude!,
          locationData.longitude!,
        );

        setState(() {
          _currentPosition = newPosition;
          _currentAddress = address;
          _isLoading = false;
        });

        // Move map to current location
        _mapController.move(_currentPosition!, 15);
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error getting location: $e';
        _isLoading = false;
      });
    }
  }

  Future<String> _getAddressFromCoordinates(
    double latitude,
    double longitude,
  ) async {
    try {
      final placemarks = await placemarkFromCoordinates(
        latitude,
        longitude,
      );
      if (placemarks.isNotEmpty) {
        final place = placemarks[0];
        return '${place.street ?? ''}, ${place.subLocality ?? ''}, ${place.locality ?? ''}, ${place.postalCode ?? ''}, ${place.country ?? ''}'
            .replaceAll(RegExp(r'^,\s*|,\s*,'), ',')
            .replaceAll(RegExp(r'^,\s*'), '')
            .replaceAll(RegExp(r',\s*$'), '');
      }
      return 'Address not found';
    } catch (e) {
      return 'Error getting address: $e';
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    final colors = context.colors;

    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter:
                  _currentPosition ??
                  const LatLng(-6.2088, 106.8456), // Default to Jakarta
              initialZoom: 15,
              onTap: (tapPosition, point) async {
                final address = await _getAddressFromCoordinates(
                  point.latitude,
                  point.longitude,
                );
                setState(() {
                  _currentPosition = point;
                  _currentAddress = address;
                });
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'dev.fleaflet.flutter_map.example',
              ),
              if (_currentPosition != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _currentPosition!,
                      child: const Icon(
                        Icons.location_pin,
                        color: Colors.red,
                        size: 40,
                      ),
                    ),
                  ],
                ),
            ],
          ),
          // Location info card
          Positioned(
            top: 42,
            left: 16,
            right: 16,
            child: Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Lokasi Saat Ini',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (_isLoading)
                      const Row(
                        children: [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.blue,
                            ),
                          ),
                          SizedBox(width: 8),
                          Text('Getting location...'),
                        ],
                      )
                    else if (_errorMessage != null)
                      Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red),
                      )
                    else if (_currentPosition != null)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (_currentAddress != null) ...[
                          
                            Text(
                              _currentAddress!,
                              style: const TextStyle(fontSize: 13),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      )
                    else
                      const Text('No location data available'),
                  ],
                ),
              ),
            ),
          ),
          // Refresh location button
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton(
              onPressed: _getCurrentLocation,
              backgroundColor: colors.primary[500],
              child: const Icon(Icons.my_location),
            ),
          ),
        ],
      ),
    );
  }
}
