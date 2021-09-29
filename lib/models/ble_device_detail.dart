/// BLEDeviceDetail : [{"device_name":"SpO2088844","device_address":"D5:AC:89:40:C6:00","device_rssi":"-71 dBm"},{"device_name":"Inspire 2","device_address":"E0:25:BE:76:25:71","device_rssi":"-94 dBm"}]

class BleDeviceDetail {
  BleDeviceDetail({
        required List<BLEDeviceDetail> bLEDeviceDetail,}){
    _bLEDeviceDetail = bLEDeviceDetail;
}

  BleDeviceDetail.fromJson(dynamic json) {
    if (json['BLEDeviceDetail'] != null) {
      _bLEDeviceDetail = [];
      json['BLEDeviceDetail'].forEach((v) {
        _bLEDeviceDetail.add(BLEDeviceDetail.fromJson(v));
      });
    }
  }
  List<BLEDeviceDetail> _bLEDeviceDetail=[];

  List<BLEDeviceDetail> get bLEDeviceDetail => _bLEDeviceDetail;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (_bLEDeviceDetail != null) {
      map['BLEDeviceDetail'] = _bLEDeviceDetail.map((v) => v.toJson()).toList();
    }
    return map;
  }

}

/// device_name : "SpO2088844"
/// device_address : "D5:AC:89:40:C6:00"
/// device_rssi : "-71 dBm"

class BLEDeviceDetail {
  BLEDeviceDetail({
       String deviceName="",
       String deviceAddress="",
       String deviceRssi="",}){
    _deviceName = deviceName;
    _deviceAddress = deviceAddress;
    _deviceRssi = deviceRssi;
}

  BLEDeviceDetail.fromJson(dynamic json) {
    _deviceName = json['device_name'];
    _deviceAddress = json['device_address'];
    _deviceRssi = json['device_rssi'];
  }
  String _deviceName="";
  String _deviceAddress="";
  String _deviceRssi="";

  String get deviceName => _deviceName;
  String get deviceAddress => _deviceAddress;
  String get deviceRssi => _deviceRssi;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['device_name'] = _deviceName;
    map['device_address'] = _deviceAddress;
    map['device_rssi'] = _deviceRssi;
    return map;
  }

  @override
  String toString() {
    return 'BLEDeviceDetail{_deviceName: $_deviceName, _deviceAddress: $_deviceAddress, _deviceRssi: $_deviceRssi}';
  }
}