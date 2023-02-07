import 'package:flutter/material.dart';
import 'package:guitar_pedal_app/bloc/app_bloc.dart';
import 'package:guitar_pedal_app/models/PedalBoard_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CreatePedalPage extends StatefulWidget {
  CreatePedalPage({super.key});
  @override
  _CreatePedalPage createState() => _CreatePedalPage();
}

class _CreatePedalPage extends State<CreatePedalPage> {
  late AppBloc bloc;
  late PedalBoardModel selectedBoard;
  Color oddTileColor = Colors.white54;
  Color evenTileColor = Colors.white70;
  @override
  initState() {
    super.initState();
    bloc = BlocProvider.of<AppBloc>(context);
    selectedBoard = bloc.appRepository.selected;
  }

  genListOfPedals() {
    return <Widget>[
      for (int index = 0; index < bloc.appRepository.connectionManager.activeDevice.knownPedals.length; index++)
        Padding(
          padding: const EdgeInsets.only(top: 10),
          key: Key(bloc.appRepository.connectionManager.activeDevice.knownPedals[index].name),
          child: ListTile(
            //Key can be used to prevent adding same pedal
            tileColor: index.isOdd ? oddTileColor : evenTileColor,
            title: Text(bloc.appRepository.connectionManager.activeDevice.knownPedals[index].name),
            onTap: () {
              bloc.add(AddPedal(bloc.appRepository.connectionManager.activeDevice.knownPedals[index]));
            },
          ),
        )
    ];
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: ThemeData(
            primaryColor: Colors.brown.shade900, brightness: Brightness.dark),
        home: Scaffold(
          appBar: AppBar(title: Text('Select a pedal')),
          body: ListView(
            //shrinkWrap: true,
            padding: const EdgeInsets.symmetric(horizontal: 40),
            children: genListOfPedals(),
          ),
          floatingActionButton: FloatingActionButton(
              onPressed: () {
                bloc
                  .add(SelectPedalBoard(bloc.appRepository.selected.id));
              },
              child: const Icon(Icons.backspace)),
        ));
  }
}