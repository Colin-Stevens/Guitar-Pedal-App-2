part of 'app_bloc.dart';

abstract class AppEvent extends Equatable {
  const AppEvent();

  @override
  List<Object> get props => [];
}

class AddPedalBoard extends AppEvent {
  final PedalBoardModel newPedal;

  const AddPedalBoard(this.newPedal);

  @override
  List<Object> get props => [newPedal];
}

class RemovePedalBoard extends AppEvent {
  final String id;
  const RemovePedalBoard(this.id);

  @override
  List<Object> get props => [id];
}

class ActivatePedalBoard extends AppEvent {
  final String id;

  const ActivatePedalBoard(this.id);

  @override
  List<Object> get props => [id];
}

class SelectPedalBoard extends AppEvent {
  final String id;

  const SelectPedalBoard(this.id);

  @override
  List<Object> get props => [id];
}

class ReturnToPedalGrid extends AppEvent {}

class AddPedal extends AppEvent {
  final Pedal newPedal;

  const AddPedal(this.newPedal);

  @override
  List<Object> get props => [newPedal];
}

class GoToConnectionManager extends AppEvent {
  const GoToConnectionManager();
}

class GoToSettings extends AppEvent {
  const GoToSettings();
}

class LoadAppEvent extends AppEvent {}
