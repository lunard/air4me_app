import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

class Measure {
  num TVOC = 0;
  num eCO2 = 0;
  late DateTime date;
  late Position position;

  setMeasureAsync(num tvoc, num eco2) async {
    this.TVOC = tvoc;
    this.eCO2 = eco2;
    date = DateTime.now();
    position = await getGeoLocationPosition();
  }

  static Future<Position> getGeoLocationPosition() async {
    bool serviceEnabled;
    LocationPermission permission;
    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      await Geolocator.openLocationSettings();
      return Future.error('Location services are disabled.');
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error('Location permissions are permanently denied, we cannot request permissions.');
    }
    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  }
}

class RemoteMeasure {
  final String type;
  final double lat;
  final double lon;
  final num value;

  const RemoteMeasure({required this.type, required this.lat, required this.lon, required this.value});

  factory RemoteMeasure.fromJson(Map<String, dynamic> json) {
    return RemoteMeasure(
      type: json['type'],
      lat: json['lat'],
      lon: json['lon'],
      value: json['value'],
    );
  }
}

class mqttMeasure {
  late String type;
  late double latitude;
  late double longitude;
  late num TVOC;
  late num eCO2;
  late DateTime timestamp;

  mqttMeasure(String type, double latitude, double longitude, num tvoc, num eco2, DateTime? timestamp) {
    this.type = type;
    this.latitude = latitude;
    this.longitude = longitude;
    this.TVOC = tvoc;
    this.eCO2 = eco2;
    this.timestamp = timestamp ?? DateTime.now();
  }

  Map<String, dynamic> toJson() => {
        'type': type,
        'latitude': latitude,
        'longitude': longitude,
        'tvoc': TVOC,
        'eco2': eCO2,
        'timestamp': timestamp.toString(),
      };
}
