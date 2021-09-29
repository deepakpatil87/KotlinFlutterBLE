class BLECharacteristic {
  BLECharacteristic({
    required List<BLECharDetail> bLECharDetail,}){
    _bleCharDetail = bLECharDetail;
}

  BLECharacteristic.fromJson(dynamic json) {
    if (json['BLECharDetail'] != null) {
      _bleCharDetail = [];
      json['BLECharDetail'].forEach((v) {
        _bleCharDetail.add(BLECharDetail.fromJson(v));
      });
    }
  }
  List<BLECharDetail> _bleCharDetail=[];

  List<BLECharDetail> get bLECharDetail => _bleCharDetail;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (_bleCharDetail != null) {
      map['BLECharDetail'] = _bleCharDetail.map((v) => v.toJson()).toList();
    }
    return map;
  }

}

/// UUID : "00002a00-0000-1000-8000-00805f9b34fb"
/// print_prop : "READABLE"

class BLECharDetail {
  BLECharDetail({
      String uuid="",
      String printProp="",}){
    _uuid = uuid;
    _printProp = printProp;
}

  BLECharDetail.fromJson(dynamic json) {
    _uuid = json['UUID'];
    _printProp = json['print_prop'];
  }
  String _uuid="";
  String _printProp="";

  String get uuid => _uuid;
  String get printProp => _printProp;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['UUID'] = _uuid;
    map['print_prop'] = _printProp;
    return map;
  }

}