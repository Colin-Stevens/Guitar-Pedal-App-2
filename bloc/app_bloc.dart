import 'package:equatable/equatable.dart';
import 'package:guitar_pedal_app/bloc/app_repository.dart';
import 'package:guitar_pedal_app/connectionSettings/connectionManager.dart';
import 'package:guitar_pedal_app/models/PedalBoard_model.dart';
import 'package:guitar_pedal_app/models/pedal_model.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

part 'app_event.dart';
part 'app_state.dart';

class AppBloc extends HydratedBloc<AppEvent, AppState> {
  AppRepository appRepository = AppRepository();
  bool initConnectionManager = true;

  AppBloc() : super(const DisplayPedalBoardGrid()) {
    if (initConnectionManager) {
      appRepository.connectionManager = ConnectionManager(this);
    }
    on<AddPedalBoard>((event, emit) {
      if (state is CreatePedalBoard) {
        appRepository.pedalBoardlist.add(event.newPedal);
        emit(const DisplayPedalBoardGrid());
      } else {
        emit(const CreatePedalBoard());
      }
    });
    on<ReturnToPedalGrid>((event, emit) {
      emit(const DisplayPedalBoardGrid());
    });
    on<ActivatePedalBoard>((event, emit) {
      if (state is DisplayPedalBoardGrid) {
        for (PedalBoardModel currPedalBoard in appRepository.pedalBoardlist) {
          currPedalBoard.isActive = currPedalBoard.id == event.id;
          if (currPedalBoard.isActive) {
            appRepository.connectionManager
                .configurePedalBoard(currPedalBoard.pedals, currPedalBoard.id);
          }
        }

        emit(const DisplayPedalBoardGrid());
      }
    });
    on<SelectPedalBoard>((event, emit) {
      for (PedalBoardModel currPedalBoard in appRepository.pedalBoardlist) {
        if (currPedalBoard.id == event.id) {
          appRepository.selected = currPedalBoard;
        }
      }
      emit(const DisplayPedalBoard());
    });
    on<AddPedal>((event, emit) {
      if (state is CreatePedal) {
        appRepository.selected.pedals.add(event.newPedal);
        appRepository.connectionManager.addPedal(event.newPedal);
        emit(const DisplayPedalBoard());
      } else {
        emit(const CreatePedal());
      }
    });
    on<GoToConnectionManager>((event, emit) {
      emit(const DisplayConnectionSettings());
    });
    on<GoToSettings>((event, emit) {
      emit(const DisplaySettings());
    });
    on<LoadAppEvent>((event, emit) async {
      await Future<void>.delayed(const Duration(seconds: 1));
      emit(const DisplayPedalBoardGrid());
    });
    on<RemovePedalBoard>((event, emit) {
      for (PedalBoardModel currPedalBoard in appRepository.pedalBoardlist) {
        if (currPedalBoard.id == event.id) {
          appRepository.pedalBoardlist.remove(currPedalBoard);
          break;
        }
      }
    });
  }

  @override
  AppState fromJson(Map<String, dynamic> json) {
    String stateID;
    if (json.containsKey('stateID')) {
      stateID = (json['stateID'] as String);
    } else {
      stateID = "DisplayPedalBoardGrid";
    }

    if (json.containsKey('device')) {
      appRepository.connectionManager = ConnectionManager.fromJson(
          this, json['device'] as Map<String, dynamic>);
      initConnectionManager = false;
    }

    if (json.containsKey('selected')) {
      appRepository.selected =
          PedalBoardModel.fromJson(json['selected'] as Map<String, dynamic>);
    } else {
      appRepository.selected = PedalBoardModel.noConfig();
    }

    if (json.containsKey('pedalBoardlist')) {
      appRepository.pedalBoardlist = AppRepository().pedalBoardlistFromJson(
          json['pedalBoardlist'] as Map<String, dynamic>);
    } else {
      appRepository.pedalBoardlist = [];
    }

    if (json.containsKey('navBarIndex')) {
      appRepository.navBarIndex = json['navBarIndex'] as int;
    }
    switch (stateID) {
      case "CreatePedalBoard":
        return const CreatePedalBoard();
      case "DisplayPedalBoardGrid":
        return const DisplayPedalBoardGrid();
      case "DisplayPedalBoard":
        return const DisplayPedalBoard();
      case "CreatePedal":
        return const CreatePedal();
      case "DisplayConnectionSettings":
        return const DisplayConnectionSettings();
      case "DisplaySettings":
        return const DisplaySettings();
      case "DisplayLoadingScreen":
        return const DisplayLoadingScreen();
      default:
        return const DisplayLoadingScreen();
    }
  }

  @override
  Map<String, dynamic> toJson(AppState state) {
    return {
      'device': appRepository.connectionManager.toJson(),
      'selected': appRepository.selected.toJson(),
      'pedalBoardlist': appRepository.pedalBoardlistToJson(),
      'stateID': state.stateID,
      'navBarIndex': appRepository.navBarIndex
    };
  }
}


// <P hardClipping 1 2 3 4 5 6 max 100 0 1 min 0 -100.01 .1 | FFT 0 0 0 0 0 0 | >