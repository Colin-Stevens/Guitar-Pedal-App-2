part of 'app_bloc.dart';

abstract class AppState extends Equatable {
  final String stateID;

  const AppState(this.stateID);

  @override
  List<Object> get props => [stateID];

  Map<String, dynamic> toJson() {
    return {'stateID': stateID};
  }
}

class CreatePedalBoard extends AppState {
  const CreatePedalBoard() : super('CreatePedalBoard');
}

class DisplayPedalBoardGrid extends AppState {
  const DisplayPedalBoardGrid() : super('DisplayPedalBoardGrid');
}

class ActivatePedalBoardState extends AppState {
  const ActivatePedalBoardState() : super('ActivatePedalBoardState');
}

class DisplayPedalBoard extends AppState {
  const DisplayPedalBoard() : super('DisplayPedalBoard');
}

class CreatePedal extends AppState {
  const CreatePedal() : super('CreatePedal');
}

class DisplayConnectionSettings extends AppState {
  const DisplayConnectionSettings() : super('DisplayConnectionSettings');
}

class DisplaySettings extends AppState {
  const DisplaySettings() : super('DisplaySettings');
}

class DisplayLoadingScreen extends AppState {
  const DisplayLoadingScreen() : super('DisplayLoadingScreen');
}

