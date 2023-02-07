import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:guitar_pedal_app/bloc/app_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guitar_pedal_app/bloc/app_repository.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  _SettingsPage createState() => _SettingsPage();
}


class _SettingsPage extends State<SettingsPage> {
  String name = "";
  String macId = "";
  String productType = "";

  @override
  Widget build(BuildContext context) {
    AppBloc bloc = BlocProvider.of<AppBloc>(context);
    return Stack(
      children: [
        ListView(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            children: <Widget>[
              TextFormField(
                decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: 'Enter ESP32 Response'),
                onFieldSubmitted: (response) => bloc
                    .appRepository.connectionManager.activeDevice.debugResponses
                    .add(response),
              ),
              TextFormField(
                decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: 'Debug Device Name'),
                onChanged: (value) => name = value,
              ),
              TextFormField(
                decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: 'Debug Device MacID'),
                onChanged: (value) => macId = value,
              ),
              TextFormField(
                decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: 'Debug Device Product Type'),
                onChanged: (value) => productType = value,
              ),
              TextButton(
                  onPressed: () {
                    print(
                        'Adding device with macId: $macId name: $name and procuct type: $productType');
                    bloc.appRepository.connectionManager
                        .connectToNewDevice(name, macId, productType);
                  },
                  child: const Text('Create new device'))
            ])
      ],
    );
  }
}
