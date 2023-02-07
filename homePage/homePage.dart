import 'dart:async';
import 'package:flutter/material.dart';
import 'package:guitar_pedal_app/connectionSettings/connectionManager.dart';
import 'package:guitar_pedal_app/connectionSettings/connectionSettings.dart';
import 'package:guitar_pedal_app/bloc/app_bloc.dart';
import 'package:guitar_pedal_app/connectionSettings/selectDeviceSettings.dart';
import 'package:guitar_pedal_app/homePage/createPedalBoardPage.dart';
import 'package:guitar_pedal_app/homePage/createPedalPage.dart';
import 'package:guitar_pedal_app/loadingScreen/loadingScreen.dart';
import 'package:guitar_pedal_app/models/PedalBoard_model.dart';
import 'package:guitar_pedal_app/settingsPage/settingsPage.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'pedalBoard.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePage createState() => _HomePage();
}

class _HomePage extends State<HomePage> {
  late Timer connectionTimer;
  late AppBloc bloc;

  /// State Functions
  @override
  void initState() {
    super.initState();
    bloc = BlocProvider.of<AppBloc>(context);
    connectionTimer = Timer.periodic(
        const Duration(milliseconds: ConnectionManager.pollPeriod_ms),
        (Timer t) => pollServiceRoutine());
  }

  @override
  void dispose() {
    connectionTimer.cancel();
    super.dispose();
  }

  /// Device Connection Functions
  pollServiceRoutine() {
    setState(() {
      bloc.appRepository.connectionManager.serviceRoutine();
    });
  }

  /// Generate Different Pages Functions
  genSettingsScreen() {
    return SettingsPage();
  }

  void navBarTap(int index) {
    bloc.appRepository.navBarIndex = index;
    switch (index) {
      case 0:
        bloc.add(ReturnToPedalGrid());
        break;
      case 1:
        bloc.add(const GoToConnectionManager());
        break;
      case 2:
        bloc.add(const GoToSettings());
        break;
      default:
        bloc.add(ReturnToPedalGrid());
        break;
    }
  }

  genPedalGrid() {
    List<PedalBoardModel> pedalBoards = bloc.appRepository.pedalBoardlist;
    return GridView.builder(
      itemCount: pedalBoards.length + 1,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          childAspectRatio: 1.3,
          crossAxisCount: 2,
          mainAxisSpacing: 20,
          crossAxisSpacing: 10),
      itemBuilder: (_, index) {
        return index <= (pedalBoards.length - 1)
            ? PedalBoardWidget(
                pedalBoards[index].id, pedalBoards[index].isActive, pedalBoards[index].isValid)
            : Padding(
                padding: const EdgeInsets.all(20),
                child: FloatingActionButton(
                    onPressed: () {
                      bloc.add(AddPedalBoard(PedalBoardModel.noConfig()));
                    },
                    child: const Icon(
                      Icons.add,
                      size: 75,
                    )));
      },
      primary: true,
      padding: const EdgeInsets.all(20),
    );
  }

  genSettings() {
    return SettingsPage();
  }

  genConnectionSettings() {
    if (bloc.appRepository.connectionManager.deviceConnected) {
      return ConnectionSettings();
    } else {
      return const SelectDeviceSettings();
    }
  }

  genPedalBoardPage() {
    return PedalBoard(bloc.appRepository.selected);
  }

  genScreenWithNavBar(Function() screen, String title) {
    return MaterialApp(
        theme: ThemeData(
            primaryColor: Colors.brown.shade900, brightness: Brightness.dark),
        home: Scaffold(
            appBar: AppBar(title: Text(title)),
            body: screen(),
            bottomNavigationBar: BottomNavigationBar(
                items: <BottomNavigationBarItem>[
                  const BottomNavigationBarItem(
                    icon: Icon(Icons.home),
                    label: 'Home',
                    backgroundColor: Color.fromARGB(255, 250, 22, 6),
                  ),
                  BottomNavigationBarItem(
                    icon: const Icon(Icons.bluetooth),
                    label: bloc.appRepository.connectionManager.deviceConnected
                        ? bloc.appRepository.connectionManager.activeDevice.name
                        : "No Device",
                    backgroundColor: Colors.green,
                  ),
                  const BottomNavigationBarItem(
                    icon: Icon(Icons.settings),
                    label: 'Settings',
                    backgroundColor: Colors.pink,
                  ),
                ],
                currentIndex: bloc.appRepository.navBarIndex,
                selectedItemColor: Colors.amber[800],
                onTap: navBarTap)));
  }

  @override
  Widget build(BuildContext context) {
    if (bloc.state is CreatePedalBoard) {
      return const AnimatedSwitcher(
          duration: Duration(milliseconds: 250), child: CreatePedalBoardPage());
    } else if (bloc.state is DisplayPedalBoard) {
      return AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: genScreenWithNavBar(
              genPedalBoardPage, bloc.appRepository.selected.id));
    } else if (bloc.state is CreatePedal) {
      return AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: CreatePedalPage());
    } else if (bloc.state is DisplayConnectionSettings) {
      return AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: genScreenWithNavBar(
              genConnectionSettings, "Device Connection Settings"));
    } else if (bloc.state is DisplaySettings) {
      return AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: genScreenWithNavBar(genSettings, "Settings"));
    } else if (bloc.state is DisplayLoadingScreen) {
      return const AnimatedSwitcher(
          duration: Duration(milliseconds: 250), child: LoadingScreen());
    }
    return AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: genScreenWithNavBar(genPedalGrid, "Home Page"));
  }
}

class PedalBoardWidget extends StatelessWidget {
  final bool isActive;
  final String id;
  final bool isValid;

  const PedalBoardWidget(this.id, this.isActive, this.isValid, {super.key});

  @override
  Widget build(BuildContext context) {
    AppBloc bloc = BlocProvider.of<AppBloc>(context);
    return Stack(children: [
      GestureDetector(
          child: Container(
              decoration: const BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage('assets/images/pedalBoard.png'),
                      fit: BoxFit.fill),
                  borderRadius: BorderRadius.all(Radius.circular(10.0))),
              child: Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: const EdgeInsets.only(top: 10, left: 2),
                  child: Text(
                    id,
                    style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 15,
                        fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
              )),
          onTap: () {
            BlocProvider.of<AppBloc>(context).add(SelectPedalBoard(id));
          },
          onLongPress: () async {
            final val = await showDialog<String>(
                context: context,
                builder: (BuildContext context) => AlertDialog(
                        title: const Text(
                            'Do you want to delete this pedal board'),
                        actions: <Widget>[
                          TextButton(
                              onPressed: () => Navigator.pop(context, 'Yes'),
                              child: const Text('Yes')),
                          TextButton(
                              onPressed: () => Navigator.pop(context, 'No'),
                              child: const Text('No'))
                        ]));
            if (val == 'Yes') {
              bloc.add(RemovePedalBoard(id));
            }
          }),
      GestureDetector(
        child: Stack(children: [
          Padding(
              padding: const EdgeInsets.only(top: 5, left: 150),
              child: Icon(Icons.power_settings_new,
                  color:isValid ? isActive ? Colors.green : Colors.white54 : Colors.red)),
          const Padding(
              padding: EdgeInsets.only(top: 2.5, left: 147.5),
              child: Icon(
                Icons.circle,
                color: Colors.black38,
                size: 30,
              ))
        ]),
        onTap: () {
          BlocProvider.of<AppBloc>(context).add(ActivatePedalBoard(id));
        },
      )
    ]);
  }
}
