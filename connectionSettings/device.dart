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

  List<double> eqData = List<double>.filled(1024, 1.0);
  int eqIndex = 0;
  int currValue = 0;
  ByteData currValueByte = ByteData(4);
  int byteIndex = 0;

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
      if (data.length == 11 &&
          String.fromCharCodes(data.getRange(0, 11)) == "NEWDATA") {
        eqIndex = 0;
        byteIndex = 0;
        currValue = 0;

        // ByteData bytearray = ByteData(4);
        // bytearray.setUint32(0, value);
      } else {
        Uint8List bytes = Uint8List.fromList(data);
        for (int byte in bytes) {
          currValue += (byte << (byteIndex * 8));
          if (byteIndex == 3) {
            currValueByte.setUint32(0, currValue);
            eqData[eqIndex] = currValueByte.getFloat32(0);
            byteIndex = 0;
            currValue = 0;
            eqIndex++;
          } else {
            byteIndex++;
          }
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
