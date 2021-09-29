import 'dart:async';
import 'dart:convert';


import '/ui/widget/dialog.dart';

import '/ui/widget/bluetooth_list.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

import 'models/ble_device_detail.dart';


class BELDevicesPage extends StatefulWidget {
  const BELDevicesPage({Key? key}) : super(key: key);

  @override
  State<BELDevicesPage> createState() => _BELDevicesPageState();
}

class _BELDevicesPageState extends State<BELDevicesPage> {
  static const MethodChannel scanBLEMethodChannel =
      MethodChannel('samples.flutter.io/scan_ble_devices');

  static const EventChannel getBLEScanInfoChannel =
      EventChannel('samples.flutter.io/get_scan_ble_info');

  String _scanLevel = 'Start Scan';
  List<BLEDeviceDetail> bLEDeviceDetail = [];
  bool isGpsOn = false;

  Future<void> _checkPermission() async {
    final serviceStatus = await Permission.locationWhenInUse.serviceStatus;
    isGpsOn = serviceStatus == ServiceStatus.enabled;
    if (!isGpsOn) {
      print('Turn on location services before requesting permission.');
      showMyDialog(
          context, 'Turn on location services.');
      return;
    }
    final status = await Permission.locationWhenInUse.request();
    if (status == PermissionStatus.granted) {
      print('Permission granted');
    } else if (status == PermissionStatus.denied) {
      print(
          'Permission denied. Show a dialog and again ask for the permission');
    } else if (status == PermissionStatus.permanentlyDenied) {
      print('Take the user to the settings page.');
      await openAppSettings();
    }
  }

  Future<void> _scanBLEDevices() async {
    String scanBLE;
    try {
      final String? result =
          await scanBLEMethodChannel.invokeMethod('scanBLEDevices');
      scanBLE = '$result';
    } on PlatformException {
      scanBLE = 'Failed to get BLE devices.';
    }
    setState(() {
      _scanLevel = scanBLE;
    });
  }

  @override
  void initState() {
    super.initState();
    _checkPermission();
    getBLEScanInfoChannel
        .receiveBroadcastStream()
        .listen(_onEvent, onError: _onError);
  }

  void _onEvent(Object? event) {
    setState(() {
      try {
        print(json.encode(event.toString()));
        BleDeviceDetail detail =
            BleDeviceDetail.fromJson(json.decode(event.toString()));
        bLEDeviceDetail.clear();
        bLEDeviceDetail.addAll(detail.bLEDeviceDetail);
        print(detail.bLEDeviceDetail[0].deviceName);
      } catch (e) {
        print(e.toString());
      }
    });
  }

  void _onError(Object error) {
    setState(() {   showMyDialog(
        context, error.toString());});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'BLE Devices',
          style: Theme.of(context).textTheme.headline1,
        ),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextButton(
              child: Text(
                _scanLevel,
                style: Theme.of(context).textTheme.headline1,
              ),
              onPressed: () {
                if (isGpsOn) {
                  _scanBLEDevices();
                } else {
                  _checkPermission();
                }
              },
            ),
          ),
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const SizedBox(height: 20,),
          Expanded(
            child: BLEScanList(bLEDeviceDetail),
          ),
        ],
      ),
    );
  }
}

void main() {
  runApp(const BLEDevicesHome());
}

class BLEDevicesHome extends StatelessWidget {
  const BLEDevicesHome({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.blue)
            .copyWith(secondary: Colors.amber),
        fontFamily: 'Quicksand',
        textTheme: ThemeData.light().textTheme.copyWith(
              headline1: const TextStyle(
                  fontFamily: 'Quicksand',
                  fontWeight: FontWeight.bold,
                  fontSize: 19,
                  color: Colors.white),
              subtitle1: const TextStyle(
                  fontFamily: 'OpenSans',
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.black),
              bodyText1: const TextStyle(
                  fontFamily: 'OpenSans', fontSize: 16, color: Colors.black),
            ),
      ),
      home: const BELDevicesPage(),
    );
  }
}
