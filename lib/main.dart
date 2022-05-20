import 'package:ari4me_app/models/BLEmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ari4me_app/models/BLEmodel.dart';
import 'package:geolocator/geolocator.dart';

import 'dart:async';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'air4me',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'air4me'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // Sensor
  bool deviceIsConnecting = false;
  bool deviceIsConnected = false;
  String deviceId = "";
  late QualifiedCharacteristic bleCharacteristic;
  final flutterReactiveBle = FlutterReactiveBle();
  Measure measure = Measure();

  // Maps
  LatLng initialPosition = LatLng(0, 0);
  late GoogleMapController mapController;
  late CameraPosition lastCameraPosition;
  int lastVisibleRadiusInMeter = 0;
  Timer cameraIdleTimer = Timer(Duration(milliseconds: 1000), () => {});

  @override
  void initState() {
    super.initState();
    attachAir4MeSensor();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Container(
                color: Colors.amber.shade200,
                width: double.infinity,
                child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Row(
                      children: [
                        Text("TVOC: ${measure.TVOC} ppb",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.blueAccent)),
                        Spacer(),
                        Text("eCO2: ${measure.eCO2} ppb",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.blueAccent)),
                      ],
                    ))),
            SizedBox(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height - 250,
                child: GoogleMap(
                  mapType: MapType.hybrid,
                  initialCameraPosition: CameraPosition(
                    target: initialPosition,
                    zoom: 14.4746,
                  ),
                  onMapCreated: onMapCreated,
                  onCameraMove: onCameraMove,
                  onCameraIdle: onCameraIdle,
                  myLocationEnabled: true,
                  zoomGesturesEnabled: true,
                  zoomControlsEnabled: false,
                )),
            Container(
                color: Colors.amber.shade200,
                width: double.infinity,
                child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Row(
                      children: [
                        Text("Current visible radius: ${lastVisibleRadiusInMeter} m",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: Colors.blueAccent)),
                      ],
                    ))),
          ],
        ),
      ),
    );
  }

  void onMapCreated(GoogleMapController controller) async {
    mapController = controller;

    var value = await Measure.getGeoLocationPosition();
    initialPosition = LatLng(value.latitude, value.longitude);
    await mapController.moveCamera(CameraUpdate.newLatLngZoom(initialPosition, 14));
  }

  void onCameraMove(CameraPosition position) async {
    var visibleRegion = await mapController.getVisibleRegion();
    var radius = Geolocator.distanceBetween(visibleRegion.northeast.latitude, visibleRegion.northeast.longitude,
        visibleRegion.southwest.latitude, visibleRegion.southwest.longitude);
    setState(() {
      lastCameraPosition = position;
      lastVisibleRadiusInMeter = radius.round();
    });

    if (cameraIdleTimer.isActive) cameraIdleTimer.cancel();
    cameraIdleTimer = startMapMovedTimer(500);
  }

  // Event never fired !! :-( :-(
  void onCameraIdle() {
    print("Camera idle: last camera position: ${lastCameraPosition}");
  }

  void attachAir4MeSensor() {
    flutterReactiveBle.scanForDevices(withServices: [], scanMode: ScanMode.balanced).listen((device) {
      if (!deviceIsConnected && !deviceIsConnecting && device.name == "air4me") {
        print("Found air4me sensor: ${device.toString()}");

        setState(() {
          deviceId = device.id;
        });

        connectToDevice(device.id);
      }
    }, onError: (error) {
      print(error);
    });
  }

  void connectToDevice(String deviceId) {
    deviceIsConnected = true;
    flutterReactiveBle
        .connectToDevice(
      id: deviceId,
      connectionTimeout: const Duration(seconds: 2),
    )
        .listen((connectionState) {
      if (connectionState.connectionState == DeviceConnectionState.connecting) {
        setState(() {
          deviceIsConnecting = true;
          deviceIsConnected = false;
        });
        print("Device ${deviceId} is connecting :-|");
      } else if (connectionState.connectionState == DeviceConnectionState.connected) {
        setState(() {
          deviceIsConnecting = false;
          deviceIsConnected = true;
          bleCharacteristic = QualifiedCharacteristic(
              serviceId: Uuid.parse("06538008-d393-11ec-9d64-0242ac120002"),
              characteristicId: Uuid.parse("105fce30-d393-11ec-9d64-0242ac120002"),
              deviceId: deviceId);
        });

        flutterReactiveBle.subscribeToCharacteristic(bleCharacteristic).listen((data) async {
          await manageSensorData(String.fromCharCodes(data));
        }, onError: (dynamic error) {
          print("BLE notify error: ${error.toString()}");
        });

        print("Device ${deviceId} connected :-)");
      } else {
        setState(() {
          deviceIsConnecting = false;
          deviceIsConnected = false;
        });

        print("Device ${deviceId} disconnected :-(");
      }
    }, onError: (dynamic error) {
      // Handle a possible error
    });
  }

  Future<void> manageSensorData(String dataAsString) async {
    var tokens = dataAsString.split("##");
    num tvoc = num.parse(tokens[0]);
    num eco2 = num.parse(tokens[1]);

    var m = Measure();
    await m.setMeasureAsync(tvoc, eco2);
    setState(() {
      measure = m;
    });

    print("Measure ${measure.TVOC},  ${measure.eCO2}, ${measure.position}");
  }

  Timer startMapMovedTimer([int milliseconds = 10000]) => Timer(Duration(milliseconds: milliseconds), () {
        print(
            "Camera moved: last camera position: ${lastCameraPosition}, visible radius: ${lastVisibleRadiusInMeter} meter");
      });
}
