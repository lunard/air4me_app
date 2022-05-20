import 'package:ari4me_app/models/BLEmodel.dart';
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
  late QualifiedCharacteristic bleCharacteristic;
  final flutterReactiveBle = FlutterReactiveBle();

  // Sensor data
  Measure measure = Measure(-1, -1);

  @override
  void initState() {
    super.initState();
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
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Wrap(
              spacing: 50,
              children: [
                Text("TVOC: ${measure.TVOC} ppb",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.blueAccent)),
                Text("eCO2: ${measure.eCO2} ppb",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.blueAccent)),
              ],
            )
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

        flutterReactiveBle.subscribeToCharacteristic(bleCharacteristic).listen((data) {
          manageSensorData(String.fromCharCodes(data));
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

  void manageSensorData(String dataAsString) {
    var tokens = dataAsString.split("##");
    num tvoc = num.parse(tokens[0]);
    num eco2 = num.parse(tokens[1]);
    setState(() {
      measure = Measure(tvoc, eco2);
    });
    print("Measure ${measure.TVOC},  ${measure.eCO2}");
  }
}
