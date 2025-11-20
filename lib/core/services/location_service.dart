import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:permission_handler/permission_handler.dart';
import '../utils/logger.dart';

/// Model untuk menyimpan informasi lokasi
class LocationData {
  final double latitude;
  final double longitude;
  final String? address;
  final DateTime timestamp;

  LocationData({
    required this.latitude,
    required this.longitude,
    this.address,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory LocationData.fromMap(Map<String, dynamic> map) {
    return LocationData(
      latitude: (map['latitude'] as num).toDouble(),
      longitude: (map['longitude'] as num).toDouble(),
      address: map['address'] as String?,
      timestamp: map['timestamp'] != null
          ? DateTime.parse(map['timestamp'] as String)
          : DateTime.now(),
    );
  }
}

/// Service untuk mengelola lokasi pengguna
/// Menggunakan permission yang proper dan transparan
class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  /// Cek apakah location service enabled
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// Request permission untuk akses lokasi
  Future<bool> requestLocationPermission() async {
    try {
      // Cek apakah location service enabled
      bool serviceEnabled = await isLocationServiceEnabled();
      if (!serviceEnabled) {
        AppLogger.warn('Location service is disabled');
        return false;
      }

      // Cek permission status
      LocationPermission permission = await Geolocator.checkPermission();
      
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          AppLogger.warn('Location permissions are denied');
          return false;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        AppLogger.warn(
          'Location permissions are permanently denied, we cannot request permissions.',
        );
        return false;
      }

      return true;
    } catch (e) {
      AppLogger.error('Error requesting location permission', e);
      return false;
    }
  }

  /// Request background location permission (untuk Android)
  Future<bool> requestBackgroundLocationPermission() async {
    try {
      // Untuk Android, perlu request background location permission secara terpisah
      if (await Permission.locationAlways.isDenied) {
        final status = await Permission.locationAlways.request();
        return status.isGranted;
      }
      return await Permission.locationAlways.isGranted;
    } catch (e) {
      AppLogger.error('Error requesting background location permission', e);
      return false;
    }
  }

  /// Dapatkan lokasi saat ini (one-time)
  Future<LocationData?> getCurrentLocation({
    bool includeAddress = true,
  }) async {
    try {
      // Request permission dulu
      if (!await requestLocationPermission()) {
        return null;
      }

      // Dapatkan posisi saat ini
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      String? address;
      if (includeAddress) {
        address = await getAddressFromCoordinates(
          position.latitude,
          position.longitude,
        );
      }

      return LocationData(
        latitude: position.latitude,
        longitude: position.longitude,
        address: address,
      );
    } catch (e) {
      AppLogger.error('Error getting current location', e);
      return null;
    }
  }

  /// Dapatkan lokasi terakhir yang diketahui
  Future<LocationData?> getLastKnownLocation({
    bool includeAddress = true,
  }) async {
    try {
      if (!await requestLocationPermission()) {
        return null;
      }

      Position? position = await Geolocator.getLastKnownPosition();
      if (position == null) {
        return null;
      }

      String? address;
      if (includeAddress) {
        address = await getAddressFromCoordinates(
          position.latitude,
          position.longitude,
        );
      }

      return LocationData(
        latitude: position.latitude,
        longitude: position.longitude,
        address: address,
      );
    } catch (e) {
      AppLogger.error('Error getting last known location', e);
      return null;
    }
  }

  /// Stream lokasi (untuk real-time tracking)
  /// Hanya digunakan saat aplikasi aktif (foreground)
  Stream<LocationData> getLocationStream({
    bool includeAddress = false,
    Duration interval = const Duration(seconds: 5),
  }) async* {
    try {
      if (!await requestLocationPermission()) {
        return;
      }

      await for (Position position in Geolocator.getPositionStream(
        locationSettings: LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10, // Update setiap 10 meter
          timeLimit: interval,
        ),
      )) {
        String? address;
        if (includeAddress) {
          address = await getAddressFromCoordinates(
            position.latitude,
            position.longitude,
          );
        }

        yield LocationData(
          latitude: position.latitude,
          longitude: position.longitude,
          address: address,
        );
      }
    } catch (e) {
      AppLogger.error('Error in location stream', e);
    }
  }

  /// Convert koordinat ke alamat (reverse geocoding)
  /// Public method untuk digunakan di widget
  Future<String?> getAddressFromCoordinates(
    double latitude,
    double longitude,
  ) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        latitude,
        longitude,
      );

      if (placemarks.isEmpty) {
        return null;
      }

      Placemark place = placemarks[0];
      
      // Format alamat
      List<String> addressParts = [];
      if (place.street != null && place.street!.isNotEmpty) {
        addressParts.add(place.street!);
      }
      if (place.subLocality != null && place.subLocality!.isNotEmpty) {
        addressParts.add(place.subLocality!);
      }
      if (place.locality != null && place.locality!.isNotEmpty) {
        addressParts.add(place.locality!);
      }
      if (place.administrativeArea != null &&
          place.administrativeArea!.isNotEmpty) {
        addressParts.add(place.administrativeArea!);
      }
      if (place.country != null && place.country!.isNotEmpty) {
        addressParts.add(place.country!);
      }

      return addressParts.isNotEmpty ? addressParts.join(', ') : null;
    } catch (e) {
      AppLogger.error('Error getting address from coordinates', e);
      return null;
    }
  }

  /// Convert alamat ke koordinat (geocoding)
  Future<LocationData?> getLocationFromAddress(String address) async {
    try {
      List<Location> locations = await locationFromAddress(address);

      if (locations.isEmpty) {
        return null;
      }

      Location location = locations[0];
      return LocationData(
        latitude: location.latitude,
        longitude: location.longitude,
        address: address,
      );
    } catch (e) {
      AppLogger.error('Error getting location from address', e);
      return null;
    }
  }

  /// Hitung jarak antara dua koordinat (dalam meter)
  double calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2);
  }
}



