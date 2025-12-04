import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationPickerPage extends StatefulWidget {
  @override
  _LocationPickerPageState createState() => _LocationPickerPageState();
}

class _LocationPickerPageState extends State<LocationPickerPage> {
  LatLng? _currentLatLng;
  String _currentAddress = "Fetching address...";
  GoogleMapController? _mapController;
  bool _isLoading = true;
  bool _isAddressLoading = false;
  bool _permissionDenied = false;

  @override
  void initState() {
    super.initState();
    _handlePermissionAndFetch();
  }

  Future<void> _handlePermissionAndFetch() async {
    setState(() {
      _isLoading = true;
      _permissionDenied = false;
    });
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        _currentAddress = "Location services are disabled.";
        _isLoading = false;
      });
      return;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          _currentAddress = "Location permission denied.";
          _isLoading = false;
          _permissionDenied = true;
        });
        return;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      setState(() {
        _currentAddress = "Location permissions are permanently denied.";
        _isLoading = false;
        _permissionDenied = true;
      });
      return;
    }
    _fetchCurrentLocation();
  }

  Future<void> _fetchCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      final latLng = LatLng(position.latitude, position.longitude);
      setState(() {
        _currentLatLng = latLng;
        _isLoading = false;
      });
      _getAddressFromLatLng(latLng);
      // Only move camera if map is ready
      if (_mapController != null) {
        _moveCamera(latLng);
      } else {
        // Wait for map to be created, then move camera
        Future.delayed(Duration(milliseconds: 300), () {
          if (_mapController != null) _moveCamera(latLng);
        });
      }
    } catch (e) {
      setState(() {
        _currentAddress = "Unable to fetch location.";
        _isLoading = false;
      });
    }
  }

  Future<void> _getAddressFromLatLng(LatLng pos) async {
    setState(() => _isAddressLoading = true);
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(pos.latitude, pos.longitude);
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        setState(() {
          _currentAddress =
              "${place.name ?? ''}, ${place.locality ?? ''}, ${place.administrativeArea ?? ''}, ${place.postalCode ?? ''}, ${place.country ?? ''}";
        });
      }
    } catch (e) {
      setState(() {
        _currentAddress = "Unknown location";
      });
    }
    setState(() => _isAddressLoading = false);
  }

  void _onCameraMove(CameraPosition position) {
    _currentLatLng = position.target;
  }

  void _onCameraIdle() {
    if (_currentLatLng != null) {
      _getAddressFromLatLng(_currentLatLng!);
    }
  }

  void _moveCamera(LatLng pos) {
    if (_mapController != null) {
      _mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: pos, zoom: 16),
        ),
      );
    }
  }

  Widget _buildAddressBar() {
    return Positioned(
      top: 40,
      left: 20,
      right: 20,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(Icons.location_on, color: Colors.red),
            SizedBox(width: 8),
            Expanded(
              child: _isAddressLoading
                  ? Row(children: [
                      SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2)),
                      SizedBox(width: 8),
                      Text("Getting address...")
                    ])
                  : Text(
                      _currentAddress,
                      style: TextStyle(fontSize: 16),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
            ),
            IconButton(
              icon: Icon(Icons.my_location, color: Colors.blue),
              onPressed: _fetchCurrentLocation,
              tooltip: "Use current location",
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMap() {
    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: _currentLatLng ?? LatLng(20.5937, 78.9629), // fallback to India center
        zoom: 16,
      ),
      myLocationEnabled: true,
      myLocationButtonEnabled: false,
      zoomControlsEnabled: false,
      onMapCreated: (controller) {
        _mapController = controller;
        // Move camera to current location if available
        if (_currentLatLng != null) {
          _moveCamera(_currentLatLng!);
        }
      },
      onCameraMove: _onCameraMove,
      onCameraIdle: _onCameraIdle,
      markers: {}, // No marker, use floating pin
    );
  }

  Widget _buildFloatingPin() {
    return IgnorePointer(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 32),
          child: Icon(Icons.location_on, size: 48, color: Colors.red),
        ),
      ),
    );
  }

  Widget _buildConfirmButton() {
    return Positioned(
      bottom: 32,
      left: 24,
      right: 24,
      child: ElevatedButton.icon(
        onPressed: _isLoading || _isAddressLoading || _currentLatLng == null
            ? null
            : () {
                Navigator.pop(context, {
                  "address": _currentAddress,
                  "lat": _currentLatLng!.latitude,
                  "lng": _currentLatLng!.longitude,
                });
              },
        style: ElevatedButton.styleFrom(
          minimumSize: Size(double.infinity, 54),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          backgroundColor: Colors.blueAccent,
        ),
        icon: Icon(Icons.check),
        label: Text(
          "Confirm Location",
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }

  Widget _buildPermissionDenied() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.location_off, size: 60, color: Colors.red),
          SizedBox(height: 16),
          Text(
            "Location permission denied",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            "Please enable location permissions in settings to use this feature.",
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24),
          ElevatedButton(
            onPressed: _handlePermissionAndFetch,
            child: Text("Try Again"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _permissionDenied
              ? _buildPermissionDenied()
              : Stack(
                  children: [
                    _buildMap(),
                    _buildFloatingPin(),
                    _buildAddressBar(),
                    _buildConfirmButton(),
                  ],
                ),
    );
  }
}
