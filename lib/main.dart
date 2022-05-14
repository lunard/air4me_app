import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
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
  int _counter = 0;
  bool deviceIsConnecting = false;
  bool deviceIsConnected = false;
  String deviceId = "";
  late Timer dataTimer;
  late QualifiedCharacteristic bleCharacteristic;

  final flutterReactiveBle = FlutterReactiveBle();

  @override
  void initState() {
    super.initState();

    dataTimer = readSensorDataTimer(1000);

    attachAir4MeSensor();
  }

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headline4,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }

  void attachAir4MeSensor() {
    flutterReactiveBle.scanForDevices(withServices: [], scanMode: ScanMode.lowLatency).listen((device) {
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

          dataTimer = readSensorDataTimer(1000);
        });
        print("Device ${deviceId} connected :-)");
      } else {
        dataTimer.cancel();
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

  Timer readSensorDataTimer(int milliseconds) {
    return Timer.periodic(Duration(milliseconds: milliseconds), (timer) async {
      if (deviceIsConnected) {
        final measure = await flutterReactiveBle.readCharacteristic(bleCharacteristic);

        print("Read sensor data: ${measure}");
      }
    });
  }
}
