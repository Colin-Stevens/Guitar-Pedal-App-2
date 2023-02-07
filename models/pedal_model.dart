import 'dart:ffi';

import 'package:guitar_pedal_app/models/atribute_model.dart';

class Pedal {
  String name;
  List<int> hexColor = [0, 0, 0, 0, 0, 0];
  List<PedalAtribute> effects;

  Pedal(this.name, this.effects);

  Pedal.noConfig()
      : name = "",
        effects = [];

  static Pedal fromConfig(String config) {
    Pedal pedal = Pedal.noConfig();
    List<String> attributes = config.split(' ');

    /// Remove First and last
    attributes.removeLast();
    attributes.removeAt(0);

    /// First grab the name
    pedal.name = attributes[0];
    attributes.removeAt(0);

    /// Next 6 values are the hex color code
    for (int i = 0; i < 6; i++) {
      pedal.hexColor[i] = int.parse(attributes[0]);
      attributes.removeAt(0);
    }

    /// Grab the Knob configuration. They are sent as:
    /// Name Max Min Step

    while (attributes.isNotEmpty) {
      pedal.effects.add(PedalAtribute(
          attributes[0],
          double.parse(attributes[1]),
          double.parse(attributes[2]),
          double.parse(attributes[3])));
      attributes.removeRange(0, 4);
    }

    return pedal;
  }

  Pedal.fromJson(Map<String, dynamic> json)
      : name = json['name'] as String,
        effects = effectsFromJson(json['effects'] as Map<String, dynamic>),
        hexColor = [
          (json['hexColor'] as Map<String, dynamic>)['0'] as int,
          (json['hexColor'] as Map<String, dynamic>)['1'] as int,
          (json['hexColor'] as Map<String, dynamic>)['2'] as int,
          (json['hexColor'] as Map<String, dynamic>)['3'] as int,
          (json['hexColor'] as Map<String, dynamic>)['4'] as int,
          (json['hexColor'] as Map<String, dynamic>)['5'] as int
        ];

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'effects': effectsToJson(),
      'hexColor': {
        '0': hexColor[0],
        '1': hexColor[1],
        '2': hexColor[2],
        '3': hexColor[3],
        '4': hexColor[4],
        '5': hexColor[5]
      }
    };
  }

  Map<String, dynamic> effectsToJson() {
    Map<String, dynamic> json = {};
    int index = 0;
    for (PedalAtribute effect in effects) {
      json['$index'] = effect.toJson();
      index++;
    }
    return json;
  }

  static List<PedalAtribute> effectsFromJson(Map<String, dynamic> json) {
    List<PedalAtribute> effectsTmp = [];
    for (String key in json.keys) {
      effectsTmp.add(PedalAtribute.fromJson(json[key] as Map<String, dynamic>));
    }
    return effectsTmp;
  }
}
