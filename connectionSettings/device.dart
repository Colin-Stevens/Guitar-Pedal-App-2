import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:guitar_pedal_app/models/atribute_model.dart';
import 'package:guitar_pedal_app/models/pedal_model.dart';

const SYNC_CONFIG = 'S';
const SYNC_PEDALS = 'P';
const UPDATE_PEDAL = 'U';
const SWAP_PEDAL = 'R';
const EQ_DATA = 'E';

Uuid pedalService = Uuid.parse("091bad492-b950-4226-aa2b-4ede9fa42f59");
Uuid rxUuid = Uuid.parse("091bad492-b950-4226-aa2b-4ede9fa42f59");
Uuid txUuid = Uuid.parse("091bad492-b950-4226-aa2b-4ede9fa42f59");

class Device {
  String id;
  String name;
  late FlutterReactiveBle flutterReactiveBle;
  late QualifiedCharacteristic _rxCharacteristic;
  late QualifiedCharacteristic _txCharacteristic;
  String incomingCommand = "";
  List<String> recievedResponses = [];

  List<Pedal> knownPedals = [];

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

    _txCharacteristic = QualifiedCharacteristic(
        serviceId: pedalService, characteristicId: txUuid, deviceId: id);
  }

  /// Issue a commmand to the device
  void sendCommand(String command) {
    while (command.isNotEmpty) {
      if (command.length > 20) {
        flutterReactiveBle.writeCharacteristicWithResponse(_txCharacteristic,
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
