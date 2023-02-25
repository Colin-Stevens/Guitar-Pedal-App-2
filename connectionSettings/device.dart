import 'package:guitar_pedal_app/models/atribute_model.dart';
import 'package:guitar_pedal_app/models/pedal_model.dart';

const HEARTBEAT = 'H';
const SYNC_CONFIG = 'S';
const SYNC_PEDALS = 'P';
const UPDATE_PEDAL = 'U';
const SWAP_PEDAL = 'R';
const EQ_DATA = 'E';
class Device {
  String macId;
  String name;
  String productType;

  List<Pedal> knownPedals = [];

  ///DEBUG Code
  List<String> debugResponses = [];

  Device(this.macId, this.name, this.productType);

  Device.noConfig()
      : macId = "N/A",
        name = "N/A",
        productType = "N/A";

  /// Issue a commmand to the device
  bool sendCommand(String command) {
    print("Sending command: $command");
    return false;
  }

  /// Empty Bluetooth buffer and convert into list of responses
  List<String> readResponses() {
    List<String> copy = [];
    for (String response in debugResponses) {
      copy.add(response);
    }
    debugResponses = [];
    return copy;
  }

  /// Attempt to connect to this device
  bool connect() {
    return true;
  }

  /// Convert Pedal to Update Request and Issue request
  bool updatePedal(Pedal pedal, int pedalIdx){
    String command = "<$UPDATE_PEDAL $pedalIdx ";
    for(PedalAtribute effect in pedal.effects){
      command += "${effect.currValue} "; /** TODO: format percision */
    }
    command += "| >"; /** TODO: Unsure if this last space is handled correclty on esp32 */
    return sendCommand(command);
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

  Device.fromJson(Map<String, dynamic> json)
      : macId = json['macId'] as String,
        name = json['name'] as String,
        productType = json['productType'] as String,
        knownPedals =
            knownPedalsFromJson(json['knownPedals'] as Map<String, dynamic>);

  
  Map<String, dynamic> toJson() {
    return {
      'macId': macId,
      'name': name,
      'productType': productType,
      'knownPedals': knownPedalsToJson()
    };
  }
}
