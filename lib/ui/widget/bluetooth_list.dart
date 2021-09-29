
import '/models/ble_device_detail.dart';
import '/ui/ble_characteristics_detail.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';




class BLEScanList extends StatelessWidget {

  static const MethodChannel scanBLEMethodChannel =
  MethodChannel('samples.flutter.io/scan_ble_devices');
  List<BLEDeviceDetail> bleDetail=[];

  BLEScanList(this.bleDetail, {Key? key}) : super(key: key);

  Future<void> _connectBLEDevices(text) async {
    String connectBLEDevice;
    try {
      final String? result = await scanBLEMethodChannel
          .invokeMethod('connectBLEDevices', {'text': text});
      connectBLEDevice = '$result';

    } on PlatformException {
      connectBLEDevice = 'Failed to get BLE devices.';
    }

  }
  @override
  Widget build(BuildContext context) {
    return SizedBox(

      child: bleDetail.isEmpty
          ? Column(
        children: <Widget>[
          Text(
            'No BLE devices found yet!',
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
                bleDetail[index].deviceName,
                style: Theme.of(context).textTheme.subtitle1,
              ),
              subtitle: Text(
                bleDetail[index].deviceAddress,
                style: Theme.of(context).textTheme.bodyText1,
              ),

              trailing: ElevatedButton(
                child: const Text(
                  'Connect',
                  style: TextStyle(color: Colors.white,fontFamily: 'OpenSans',
                    fontWeight: FontWeight.bold,
                    fontSize: 15,),
                ),
                onPressed: () async {
                  _connectBLEDevices( index);
                  _navigateToNextScreen(context);
                },
              ),
            ),
          );
        },
        itemCount: bleDetail.length,
      ),
    );
  }
  void _navigateToNextScreen(BuildContext context) {

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) =>  const BleCharacteristicsDetail()),
    );
  }
}
