import 'package:flutter/material.dart';
import 'package:guitar_pedal_app/bloc/app_bloc.dart';
import 'package:guitar_pedal_app/models/PedalBoard_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CreatePedalBoardPage extends StatefulWidget {
  const CreatePedalBoardPage({super.key});

  @override
  _CreatePedalBoardPage createState() => _CreatePedalBoardPage();
}

class _CreatePedalBoardPage extends State<CreatePedalBoardPage> {
  late String name;
  late String peddalBoardConfig;
  late AppBloc bloc;

  @override
  initState() {
    super.initState();
    bloc = BlocProvider.of<AppBloc>(context);
    peddalBoardConfig = "No Config";
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: ThemeData(
            primaryColor: Colors.brown.shade900, brightness: Brightness.dark),
        home: Scaffold(
          appBar: AppBar(title: const Text('Create a new Pedal')),
          body: Container(
              child: Align(
            alignment: Alignment.topLeft,
            child: TextField(
              onChanged: (text) {
                name = text;
              },
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter pedal name',
              ),
            ),
          )),
          floatingActionButton: FloatingActionButton(
              onPressed: () {
                bloc
                  .add(AddPedalBoard(PedalBoardModel(
                      name, peddalBoardConfig, false, true)));
              },
              child: const Icon(Icons.backspace)),
        ));
  }
}
