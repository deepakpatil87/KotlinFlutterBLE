import 'dart:async';
import 'dart:convert';

import '/models/ble_characteristic.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'widget/dialog.dart';

class BleCharacteristicsDetail extends StatelessWidget {
  const BleCharacteristicsDetail({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "BLE characteristic",
          style: Theme.of(context).textTheme.headline1,
        ),
      ),
      body: const BLECharacteristicInfo(),
    );
  }
}

class BLECharacteristicInfo extends StatefulWidget {
  const BLECharacteristicInfo({Key? key}) : super(key: key);

  @override
  State<BLECharacteristicInfo> createState() => _BLECharacteristicState();
}

class _BLECharacteristicState extends State<BLECharacteristicInfo> {
  static const EventChannel getBLECharacteristicInfoChannel =
      EventChannel('samples.flutter.io/get_ble_characteristic_info');

  List<BLECharDetail> bLECharDetail = [];

  late StreamSubscription _getBLEChartSubscription;

  @override
  void initState() {
    super.initState();

    _getBLEChartSubscription = getBLECharacteristicInfoChannel
        .receiveBroadcastStream()
        .listen(_onEvent, onError: _onError);
  }

  void _onEvent(Object? event) {
    if (mounted) {
      setState(() {
        try {
          if (event != null) {
            print(json.encode(event.toString()));
            BLECharacteristic detail =
                BLECharacteristic.fromJson(json.decode(event.toString()));
            bLECharDetail.clear();
            bLECharDetail.addAll(detail.bLECharDetail);
          }
        } catch (e) {
          print(e.toString());
        }
      });
    } else {
      _disableTimer();
    }
  }

  void _onError(Object error) {
    setState(() {  showMyDialog(
        context, error.toString());});

  }

  void _disableTimer() {
    _getBLEChartSubscription.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: bLECharDetail.isEmpty
          ? Center(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  const SizedBox(height: 20,),
                  Text(
                    'No BLE characteristic found yet!',
                    style: Theme.of(context).textTheme.subtitle1,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  SizedBox(
                      height: 200,
                      child: Image.asset(
                        'assets/images/waiting.png',
                        fit: BoxFit.cover,
                      )),
                ],
              ),
          )
          : ListView.builder(
              itemBuilder: (ctx, index) {
                return Card(
                  elevation: 5,
                  margin: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 5,
                  ),
                  child: ListTile(
                    title: Text(
                      bLECharDetail[index].uuid,
                      style: Theme.of(context).textTheme.subtitle1,
                    ),
                    subtitle: Text(
                      bLECharDetail[index].printProp,
                      style: Theme.of(context).textTheme.bodyText1,
                    ),
                  ),
                );
              },
              itemCount: bLECharDetail.length,
            ),
    );
  }
}
