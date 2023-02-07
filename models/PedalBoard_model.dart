import 'package:guitar_pedal_app/models/pedal_model.dart';

class PedalBoardModel {
  String id;
  String config;
  bool isActive;
  bool isValid;
  List<Pedal> pedals = [];

  PedalBoardModel(this.id, this.config, this.isActive, this.isValid);
  PedalBoardModel.noConfig()
      : id = "",
        config = "No Config",
        isActive = false,
        isValid = true;

  PedalBoardModel.fromJson(Map<String, dynamic> json)
      : id = json['PedalModel_id'] as String,
        config = json['PedalModel_config'] as String,
        isActive = json['PedalModel_isActive'] as bool,
        isValid = json['PedalModel_isValid'] as bool,
        pedals =
            pedalsFromJson(json['PedalModel_pedals'] as Map<String, dynamic>);

  Map<String, dynamic> toJson() {
    return {
      'PedalModel_id': id,
      'PedalModel_config': config,
      'PedalModel_isActive': isActive,
      'PedalModel_isValid': isValid,
      'PedalModel_pedals': pedalsToJson()
    };
  }

  Map<String, dynamic> pedalsToJson() {
    Map<String, dynamic> json = {};
    int index = 0;
    for (Pedal pedal in pedals) {
      json['$index'] = pedal.toJson();
      index++;
    }
    return json;
  }

  static List<Pedal> pedalsFromJson(Map<String, dynamic> json) {
    List<Pedal> pedalsTmp = [];
    for (String key in json.keys) {
      pedalsTmp.add(Pedal.fromJson(json[key] as Map<String, dynamic>));
    }
    return pedalsTmp;
  }
}
