import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:guitar_pedal_app/bloc/app_bloc.dart';
import 'package:guitar_pedal_app/connectionSettings/connectionManager.dart';
import 'package:guitar_pedal_app/homePage/Pedal/flutter_knob.dart';
import 'package:guitar_pedal_app/models/PedalBoard_model.dart';
import 'package:guitar_pedal_app/models/atribute_model.dart';
import 'package:guitar_pedal_app/models/pedal_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:knob_widget/knob_widget.dart';
import 'package:reorderable_grid_view/reorderable_grid_view.dart';

class PedalBoard extends StatefulWidget {
  const PedalBoard(this.pedalBoardModelName, this.controller, {super.key});
  final ScrollController controller;
  final String pedalBoardModelName;

  @override
  _PedalBoard createState() => _PedalBoard();
}

class _PedalBoard extends State<PedalBoard> {
  late AppBloc bloc;
  late PedalBoardModel pedalBoardModel;

  @override
  void initState() {
    super.initState();
    bloc = BlocProvider.of<AppBloc>(context);
    for (PedalBoardModel pedalBoard in bloc.appRepository.pedalBoardlist) {
      if (pedalBoard.id == widget.pedalBoardModelName) {
        pedalBoardModel = pedalBoard;
        break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
        child: ReorderableGridView.builder(
      controller: widget.controller,
      itemCount: pedalBoardModel.pedals.length + 1,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          childAspectRatio: 1.3,
          crossAxisCount: 2,
          mainAxisSpacing: 20,
          crossAxisSpacing: 10),
      //padding: const EdgeInsets.symmetric(horizontal: 40),
      itemBuilder: (_, index) {
        return index <= (pedalBoardModel.pedals.length - 1)
            ? pedalWidget(pedalBoardModel.pedals[index], widget.controller)
            : Padding(
                key: const Key("AddPedal"),
                padding: const EdgeInsets.all(20),
                child: FloatingActionButton(
                    onPressed: () {
                      BlocProvider.of<AppBloc>(context)
                          .add(AddPedal(Pedal.noConfig()));
                    },
                    child: const Icon(
                      Icons.add,
                      size: 75,
                    )));
      },
      onReorder: (int oldIndex, int newIndex) {
        /** Check if oldIndex is the add button or if new Index is at the end
         *  TODO: Validate boundsare correct
         */
        if (oldIndex == pedalBoardModel.pedals.length ||
            newIndex == pedalBoardModel.pedals.length) {
          return;
        }
        setState(() {
          if (oldIndex < newIndex) {
            newIndex -= 1;
          }
          final Pedal pedal = pedalBoardModel.pedals.removeAt(oldIndex);
          pedalBoardModel.pedals.insert(newIndex, pedal);
          bloc.appRepository.connectionManager
              .reorderPedal(oldIndex, newIndex, pedal.name);
        });
      },
    ));
  }

  Widget pedalWidget(Pedal pedal, ScrollController controller) {
    return GestureDetector(
        key: Key(pedal.name),
        child: Container(
            decoration: BoxDecoration(
                color: pedal.getColor(),
                borderRadius: const BorderRadius.all(Radius.circular(10.0))),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    verticalDirection: VerticalDirection.down,
                    children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        for(int i=0; i<pedal.effects.length;i+=2)
                          knob(pedal.effects[i])
                      ],
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        for(int i=1; i<pedal.effects.length;i+=2)
                          knob(pedal.effects[i])
                      ],
                    )
                  ],)),
                Padding(
                  padding: const EdgeInsets.only(top: 10, left: 2),
                  child: Text(
                    pedal.name,
                    style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 25,
                        fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            )),
        onDoubleTap: () async {
          final val = await showDialog<String>(
              context: context,
              builder: (BuildContext context) => AlertDialog(
                      title:
                          const Text('Do you want to delete this pedal board'),
                      actions: <Widget>[
                        TextButton(
                            onPressed: () => Navigator.pop(context, 'Yes'),
                            child: const Text('Yes')),
                        TextButton(
                            onPressed: () => Navigator.pop(context, 'No'),
                            child: const Text('No'))
                      ]));
          if (val == 'Yes') {
            setState(() {
              bloc.appRepository.connectionManager.deletePedal(
                  pedal.name, pedalBoardModel.pedals.indexOf(pedal));
              pedalBoardModel.pedals.remove(pedal);
            });
          }
        });
  }

  Widget knob(PedalAtribute effect) {
    void valueChangedListener(double value) {
      if (mounted) {
        setState(() {
          effect.currValue = value;
          effect.needsUpdate = true;
        });
      }
    }

    return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
              padding: const EdgeInsets.only(top: 10),
              child: CustomKnob(
                  min: effect.minValue,
                  max: effect.maxValue,
                  value: effect.currValue,
                  color: Colors.black,
                  onChanged: valueChangedListener,
                  size: 50)),
          Text(
            effect.name,
            style: const TextStyle(
                color: Colors.black87,
                fontSize: 15,
                fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ]);
  }
}
