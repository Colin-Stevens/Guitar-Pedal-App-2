import 'package:guitar_pedal_app/connectionSettings/connectionManager.dart';
import 'package:guitar_pedal_app/models/PedalBoard_model.dart';

class AppRepository {
  List<PedalBoardModel> pedalBoardlist = [];
  late ConnectionManager connectionManager;
  PedalBoardModel selected = PedalBoardModel.noConfig();

  int navBarIndex = 0;


  Map<String, dynamic> pedalBoardlistToJson() {
    Map<String, dynamic> json = {};
    int index = 0;

    for (PedalBoardModel pedalBoard in pedalBoardlist) {
      json['$index'] = pedalBoard.toJson();
      index++;
    }

    return json;
  }

  List<PedalBoardModel> pedalBoardlistFromJson(Map<String, dynamic> json) {
    List<PedalBoardModel> pedalBoardListTmp = [];
    for (String key in json.keys) {
      pedalBoardListTmp
          .add(PedalBoardModel.fromJson(json[key] as Map<String, dynamic>));
    }
    return pedalBoardListTmp;
  }
}
