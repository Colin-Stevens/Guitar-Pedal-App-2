import 'package:guitar_pedal_app/bloc/app_bloc.dart';
import 'package:guitar_pedal_app/connectionSettings/device.dart';
import 'package:guitar_pedal_app/models/PedalBoard_model.dart';
import 'package:guitar_pedal_app/models/pedal_model.dart';

class ConnectionManager {
  /// Constants
  static const int pollPeriod_ms = 50;
  static const int heartbeatTimeout_ms = 600000;

  /// State varibles
  bool deviceConnected = false;
  List<Device> knownDevices = [];
  Device activeDevice = Device.noConfig();

  /// Non state retention varibles
  int heartbeatTicks = 0;
  List<String> commands = [];
  AppBloc bloc;

  ConnectionManager(this.bloc);

  /// Main Function for polling tasks
  /// Polling freq = 60Hz
  /// Tasks:
  ///   Heartbeat
  ///   Check for equilizer data
  void serviceRoutine() {
    if (deviceConnected) {
      /* Handle Heartbeat */
      if (heartbeatTicks * pollPeriod_ms > heartbeatTimeout_ms) {
        deviceConnected = false;
        return;
      }
      heartbeatTicks++;

      /* Issue any commands in the que */
      for (String command in commands) {
        activeDevice.sendCommand(command);
      }
      commands = [];

      /* Handle any responses from the device */
      for (String response in activeDevice.readResponses()) {
        switch (response[1]) {
          case HEARTBEAT:
            heartbeatTicks = 0;
            break;
          case SYNC_PEDALS:
            activeDevice.knownPedals = getknownPedals(response);
            setValidBoards();
            break;
          default:
            print(
                "Unknown response code ${response[2]} Full message: $response");
            break;
        }
      }
    } else {
      pollknownDevices();
    }
  }

  /// Searchs the ether for any devices we have connected to before
  /// If one is found it automatically connects and sets it as the active device
  /// Only run this if there is no device connected
  void pollknownDevices() {
    for (Device device in knownDevices) {
      if (device.connect()) {
        initDevice(device);
        break;
      }
    }
  }

  /// Try to connect to a known device
  bool connectToDevice(String deviceName) {
    for (Device device in knownDevices) {
      if (device.name == deviceName) {
        if (device.connect()) {
          return initDevice(device);
        }
        return false;
      }
    }
    return false;
  }

  /// This is a new deivce, need to create it
  bool connectToNewDevice(
      String deviceName, String deviceMacID, String productType) {
    Device newDevice = Device(deviceMacID, deviceName, productType);
    if (newDevice.connect()) {
      knownDevices.add(newDevice);
      return initDevice(newDevice);
    }
    return false;
  }

  bool initDevice(Device device) {
    activeDevice = device;
    commands.add('<$SYNC_PEDALS>');
    deviceConnected = true;
    heartbeatTicks = 0;

    return true;
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
    /// Generate a list of known
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

  Map<String, dynamic> knownDevicesToJson() {
    Map<String, dynamic> json = {};
    int index = 0;
    for (Device device in knownDevices) {
      json['$index'] = device.toJson();
      index++;
    }

    return json;
  }

  static List<Device> knownDevicesFromJson(Map<String, dynamic> json) {
    List<Device> knownDevicesTmp = [];
    for (String key in json.keys) {
      knownDevicesTmp.add(Device.fromJson(json[key] as Map<String, dynamic>));
    }
    return knownDevicesTmp;
  }

  ConnectionManager.fromJson(AppBloc bloc_, Map<String, dynamic> json)
      : bloc = bloc_,
        deviceConnected = json['deviceConnected'] as bool,
        activeDevice =
            Device.fromJson(json['activeDevice'] as Map<String, dynamic>),
        knownDevices =
            knownDevicesFromJson(json['knownDevices'] as Map<String, dynamic>);

  Map<String, dynamic> toJson() {
    return {
      'deviceConnected': deviceConnected,
      'activeDevice': activeDevice.toJson(),
      'knownDevices': knownDevicesToJson()
    };
  }
}
