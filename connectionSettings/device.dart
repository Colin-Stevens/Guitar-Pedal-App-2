import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:guitar_pedal_app/models/atribute_model.dart';
import 'package:guitar_pedal_app/models/pedal_model.dart';

const SYNC_CONFIG = 'S';
const SYNC_PEDALS = 'P';
const UPDATE_PEDAL = 'U';
const SWAP_PEDAL = 'R';
const EQ_DATA = 'E';
const ADD_PEDAL = 'A';
const DELETE_PEDAL = 'X';
const CONFIGURE = 'C';

Uuid pedalService = Uuid.parse("91bad492-b950-4226-aa2b-4ede9fa42f59");
Uuid rxUuid = Uuid.parse("cba1d466-344c-4be3-ab3f-189f80dd7518");
Uuid eqUuid = Uuid.parse("cba1d466-344c-4be3-ab3f-189f80dd7517");
Uuid txUuid = Uuid.parse("cba1d466-344c-4be3-ab3f-189f80dd7519");

class Device {
  String id;
  String name;
  FlutterReactiveBle flutterReactiveBle = FlutterReactiveBle();
  late QualifiedCharacteristic _rxCharacteristic;
  late QualifiedCharacteristic _eqCharacteristic;
  late QualifiedCharacteristic _txCharacteristic;
  String incomingCommand = "";
  List<String> recievedResponses = [];

  List<Pedal> knownPedals = [];

  List<int> eqData = List<int>.filled(32, 1);
  List<int> eqDataTmp = List<int>.filled(32, 1);
  int eqIndex = 0;

  Device(this.id, this.name);

  Device.noConfig()
      : id = "N/A",
        name = "N/A";

  void setCharacteristics() {
    _rxCharacteristic = QualifiedCharacteristic(
        serviceId: pedalService, characteristicId: rxUuid, deviceId: id);
    flutterReactiveBle.subscribeToCharacteristic(_rxCharacteristic).listen(
        (data) {
      String char;
      for (int intChar in data) {
        char = String.fromCharCode(intChar);
        if (char == "<") {
          incomingCommand = "";
        }

        incomingCommand += char;
        if (char == ">") {
          recievedResponses.add(incomingCommand);
          incomingCommand = "";
        }
      }
      // code to handle incoming data
    }, onError: (dynamic error) {
      // code to handle errors
    });

    _eqCharacteristic = QualifiedCharacteristic(
        serviceId: pedalService, characteristicId: eqUuid, deviceId: id);
    flutterReactiveBle.subscribeToCharacteristic(_eqCharacteristic).listen(
        (data) {
      if (data.length == 7 &&
          String.fromCharCodes(data.getRange(0, 7)) == "NEWDATA") {
        eqIndex = 0;
        int maxValue = 0;
        for (int i in eqDataTmp) {
          if (i > maxValue) {
            maxValue = i;
          }
        }
        for (int i = 0; i < eqData.length; i++) {
          eqData[i] = (180 * (eqDataTmp[i] / maxValue)).round() + 1;
        }
      } else {
        ByteData byteValue = ByteData(4);
        for (int i = 0; i < 4; i++) {
          byteValue.setInt8(3, data[0 + i * 4]);
          byteValue.setInt8(2, data[1 + i * 4]);
          byteValue.setInt8(1, data[2 + i * 4]);
          byteValue.setInt8(0, data[3 + i * 4]);
          eqDataTmp[eqIndex] = byteValue.getInt32(0).abs();
          eqIndex++;
        }
      }

      // code to handle incoming data
    }, onError: (dynamic error) {
      // code to handle errors
    });

    _txCharacteristic = QualifiedCharacteristic(
        serviceId: pedalService, characteristicId: txUuid, deviceId: id);
  }

  /// Issue a commmand to the device
  void sendCommand(String command) async {
    while (command.isNotEmpty) {
      if (command.length > 20) {
        final response = await flutterReactiveBle
            .writeCharacteristicWithResponse(_txCharacteristic,
                value: command.substring(0, 20).codeUnits);
        command = command.substring(20);
      } else {
        flutterReactiveBle.writeCharacteristicWithResponse(_txCharacteristic,
            value: command.codeUnits);
        command = "";
        break;
      }
    }
  }

  /// Convert Pedal to Update Request and Issue request
  void updatePedal(Pedal pedal, int pedalIdx) {
    String command = "<$UPDATE_PEDAL $pedalIdx ";
    for (PedalAtribute effect in pedal.effects) {
      command += "${effect.currValue} ";
      /** TODO: format percision */
    }
    command += "| >";
    /** TODO: Unsure if this last space is handled correclty on esp32 */
    sendCommand(command);
  }

  Map<String, dynamic> knownPedalsToJson() {
    Map<String, dynamic> json = {};
    int index = 0;
    for (Pedal pedal in knownPedals) {
      json['$index'] = pedal.toJson();
      index++;
    }
    return json;
  }

  static List<Pedal> knownPedalsFromJson(Map<String, dynamic> json) {
    List<Pedal> knownPedalsTmp = [];
    for (String key in json.keys) {
      knownPedalsTmp.add(Pedal.fromJson(json[key] as Map<String, dynamic>));
    }
    return knownPedalsTmp;
  }
}
