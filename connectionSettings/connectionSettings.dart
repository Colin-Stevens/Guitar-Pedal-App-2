import 'package:flutter/material.dart';
import 'package:guitar_pedal_app/bloc/app_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ConnectionSettings extends StatefulWidget {
  const ConnectionSettings({super.key});

  @override
  _ConnectionSettings createState() => _ConnectionSettings();
}

class _ConnectionSettings extends State<ConnectionSettings> {
  final Color oddTileColor = Colors.white54;
  final Color evenTileColor = Colors.white70;
  final List<String> settings = ["Sampling Rate", "Some other setting", "Derp"];
  String textvalue = "";

  @override
  Widget build(BuildContext context) {
    AppBloc bloc = BlocProvider.of<AppBloc>(context);

    return Stack(
      children: const []);
  }
}


  // ConnectionSettings({super.key});
  // @override
  // Widget build(BuildContext context) {
  //   AppBloc bloc = BlocProvider.of<AppBloc>(context);
  //   return Stack(
  //     children: [
  //       ListView(
  //           padding: const EdgeInsets.symmetric(horizontal: 40),
  //           children: <Widget>[
  //             for (int index = 0; index < settings.length; index += 1)
  //               Padding(
  //                 padding: const EdgeInsets.only(top: 10),
  //                 //key: Key('${availableDevices[index]}'),
  //                 child: ListTile(
  //                   //Key can be used to prevent adding same pedal
  //                   tileColor: index.isOdd ? oddTileColor : evenTileColor,
  //                   title: Text(settings[index]),
  //                 ),
  //               )
  //           ])
  //     ],
  //   );
  // }