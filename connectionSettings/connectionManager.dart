import 'dart:async';
import 'dart:io';

import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:guitar_pedal_app/bloc/app_bloc.dart';
import 'package:guitar_pedal_app/connectionSettings/device.dart';
import 'package:guitar_pedal_app/models/PedalBoard_model.dart';
import 'package:guitar_pedal_app/models/atribute_model.dart';
import 'package:guitar_pedal_app/models/pedal_model.dart';
import 'package:tuple/tuple.dart';

class ConnectionManager {
  /// Constants
  static const int pollPeriod_ms = 500;
  static const int pollPeriodScaner_ms = 2000;
  int pollPeriodScanerCounter = 0;

  /// State varibles
  /// Name, Id
  List<Tuple2<String, String>> uniqueDeviceNames = [];

  /// Non state retention varibles
  bool deviceConnected = false;
  Device activeDevice = Device.noConfig();
  List<String> commands = [];
  AppBloc bloc;
  List<double> eqData = [];

  List<Tuple2<String, String>> discoveredDevices = [];
  late StreamSubscription<DiscoveredDevice> _scanStream;
  bool _scanStreamIsInitilized = false;
  late StreamSubscription<ConnectionStateUpdate> _currentConnectionStream;
  bool scanning = false;

  ConnectionManager(this.bloc);

  /// Main Function for polling tasks
  /// Polling freq = 60Hz
  /// Tasks:
  ///   Issue any Commands in the Que
  ///   Update Knob values
  ///   Handle any responses from pedal
  ///
  void serviceRoutine() {
    /// TODO: add functionality to check ble stack status and get permissions for use
    if (deviceConnected) {
      /* Handle Heartbeat */

      /* Issue any commands in the que */
      for (String command in commands) {
        activeDevice.sendCommand(command);
      }
      commands = [];

      /**
       * If we are in a state where the user could be updating knobs then
       * check if any need to be updated
       */
      if (bloc.state is DisplayPedalBoard) {
        bool needsUpdate;
        for (int pedalIdx = 0;
            pedalIdx < bloc.appRepository.selected.pedals.length;
            pedalIdx++) {
          needsUpdate = false;
          for (PedalAtribute knob
              in bloc.appRepository.selected.pedals[pedalIdx].effects) {
            if (knob.needsUpdate) {
              needsUpdate = true;
              knob.needsUpdate = false;
            }
          }
          if (needsUpdate) {
            activeDevice.updatePedal(
                bloc.appRepository.selected.pedals[pedalIdx], pedalIdx);
          }
        }
      }

      /* Handle any responses from the device */
      while (activeDevice.recievedResponses.isNotEmpty) {
        String response = activeDevice.recievedResponses.removeAt(0);
        switch (response[1]) {
          case SYNC_PEDALS:
            activeDevice.knownPedals = getknownPedals(response);
            setValidBoards();
            break;
          case EQ_DATA:
            proccessEQData(response);
            break;
          default:
            print(
                "Unknown response code ${response[2]} Full message: $response");
            break;
        }
      }
    }
    if (!scanning) {
      pollPeriodScanerCounter++;
      if (_scanStreamIsInitilized) {
        _scanStream.cancel();
      }
      if (activeDevice.flutterReactiveBle.status == BleStatus.ready &&
          pollPeriodScanerCounter > (pollPeriodScaner_ms / pollPeriod_ms)) {
        startScanForDevices();
        pollPeriodScanerCounter = 0;
      }
    }
  }

  /// Scans the ether for any devices
  void startScanForDevices() {
    scanning = true;
    _scanStreamIsInitilized = true;
    List<Tuple2<String, String>> discoveredDevicesTmp = [];
    _scanStream = activeDevice.flutterReactiveBle
        .scanForDevices(withServices: [pedalService]).listen(
            (device) {
              /// Lets try to conenct to this device
              /// TODO Figure out if we also need to check if we are trying to connect to a device right now
              if (!deviceConnected) {
                deviceConnected = true;
                connectToDevice(device.id, device.name);
              }
              discoveredDevicesTmp
                  .add(Tuple2<String, String>(device.name, device.id));
            },
            onError: (obj) {},
            onDone: () {
              scanning = false;
              discoveredDevices = discoveredDevicesTmp;
            });
  }

  /// Try to connect to a device
  void connectToDevice(String deviceId, String name) {
    _currentConnectionStream = activeDevice.flutterReactiveBle
        .connectToDevice(
      id: deviceId,
      servicesWithCharacteristicsToDiscover: {
        pedalService: [rxUuid, txUuid, eqUuid]
      },
      connectionTimeout: const Duration(seconds: 2),
    )
        .listen((event) {
      // Handle connection state updates
      switch (event.connectionState) {
        // We're connected and good to go!
        case DeviceConnectionState.connecting:
          print("CONNECting");
          break;
        case DeviceConnectionState.connected:
          {
            print("CONNECTED");
            deviceConnected = true;
            activeDevice.id = deviceId;
            activeDevice.name = name;
            activeDevice.setCharacteristics();
            initDevice();
            break;
          }
        // Can add various state state updates on disconnect
        case DeviceConnectionState.disconnected:
          {
            deviceConnected = false;
            break;
          }
        default:
      }
    }, onError: (Object error) {
      // Handle a possible error
    }, onDone: () {});
  }

  void initDevice() {
    commands.add('<$SYNC_PEDALS>');
    deviceConnected = true;
  }

  List<Pedal> getknownPedals(String response) {
    response = response.substring(2, response.length - 3);

    List<String> configs = response.split('|');
    List<Pedal> pedals = [];
    for (String config in configs) {
      pedals.add(Pedal.fromConfig(config));
    }

    return pedals;
  }

  /// Set isvalid flag for all pedal boards in repo
  void setValidBoards() {
    /// Generate a list of known pedals
    List<String> knownPedalNames = [];
    for (Pedal knownPedal in activeDevice.knownPedals) {
      knownPedalNames.add(knownPedal.name);
    }

    for (PedalBoardModel pedalBoard in bloc.appRepository.pedalBoardlist) {
      pedalBoard.isValid = true;
      for (Pedal pedal in pedalBoard.pedals) {
        if (!knownPedalNames.contains(pedal.name)) {
          pedalBoard.isValid = false;
          break;
        }
      }
    }
  }

  /// TODO: Validate indexing is correct
  /// No longer need to send pedal name. Update on esp32 first
  void reorderPedal(int oldIdx, int newIdx, String pedalName) {
    if (deviceConnected) {
      commands.add("<$SWAP_PEDAL $pedalName $oldIdx $newIdx | >");
    }
  }

  void addPedal(Pedal pedal) {
    if (deviceConnected) {
      String command = "<$ADD_PEDAL ${pedal.name} ";

      for (PedalAtribute attr in pedal.effects) {
        command += "${attr.currValue} ";
      }
      command += "| >";
      commands.add(command);
    }
  }

  void deletePedal(String name, int index) {
    if (deviceConnected) {
      commands.add("<$DELETE_PEDAL $name $index | >");
    }
  }

  void configurePedalBoard(List<Pedal> pedals, String boardName) {
    if (deviceConnected) {
      String command = "<$CONFIGURE $boardName ";
      for (Pedal pedal in pedals) {
        command += "${pedal.name} ";
        for (PedalAtribute attr in pedal.effects) {
          command += "${attr.currValue} ";
        }
        command += "| ";
      }
      command += ">";
      commands.add(command);
    }
  }

  /// TODO: Sort of ineffcient to send data as ascii characters
  void proccessEQData(String response) {
    response = response.substring(3, response.length - 4);
    List<double> buffer = [];
    for (String datapoint in response.split(' ')) {
      buffer.add(double.parse(datapoint));
    }
    bloc.appRepository.EQcontroller.add(buffer);
  }

  Map<String, dynamic> uniqueDeviceNamesToJson() {
    Map<String, dynamic> json = {};
    int index = 0;
    for (Tuple2<String, String> identifier in uniqueDeviceNames) {
      json['$index'] = {"Name": identifier.item1, "Id": identifier.item2};
      index++;
    }

    return json;
  }

  static List<Tuple2<String, String>> uniqueDeviceNamesFromJson(
      Map<String, dynamic> json) {
    List<Tuple2<String, String>> uniqueDeviceNamesTmp = [];
    for (String key in json.keys) {
      uniqueDeviceNamesTmp.add(Tuple2<String, String>(
          json[key]["Name"] as String, json[key]["Id"] as String));
    }
    return uniqueDeviceNamesTmp;
  }

  ConnectionManager.fromJson(AppBloc bloc_, Map<String, dynamic> json)
      : bloc = bloc_,
        uniqueDeviceNames = uniqueDeviceNamesFromJson(
            json['uniqueDeviceNames'] as Map<String, dynamic>);

  Map<String, dynamic> toJson() {
    return {'uniqueDeviceNames': uniqueDeviceNamesToJson()};
  }
}
