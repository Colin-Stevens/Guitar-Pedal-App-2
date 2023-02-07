import 'package:flutter/material.dart';
import 'package:guitar_pedal_app/bloc/app_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guitar_pedal_app/connectionSettings/device.dart';

class SelectDeviceSettings extends StatelessWidget {
  final Color oddTileColor = Colors.white54;
  final Color evenTileColor = Colors.white70;

  const SelectDeviceSettings({super.key});
  @override
  Widget build(BuildContext context) {
    AppBloc bloc = BlocProvider.of<AppBloc>(context);
    List<Device> availableDevices =
        bloc.appRepository.connectionManager.knownDevices;
    return Stack(
      children: [
        ListView(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            children: <Widget>[
              for (int index = 0; index < availableDevices.length; index += 1)
                DeviceWidget(index / 2 > 0 ? oddTileColor : evenTileColor,
                    availableDevices[index].name),
            ])
      ],
    );
  }
}

class DeviceWidget extends StatelessWidget {
  final Color tileColor;
  final String id;

  const DeviceWidget(this.tileColor, this.id, {super.key});

  @override
  Widget build(BuildContext context) {
    AppBloc bloc = BlocProvider.of<AppBloc>(context);
    return Padding(
        padding: const EdgeInsets.only(top: 10),
        child: ListTile(
          //Key can be used to prevent adding same pedal
          tileColor: tileColor,
          title: Text(id),
          onTap: () {
            bloc.appRepository.connectionManager.connectToDevice(id);
          },
        ));
  }
}
