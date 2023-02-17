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
  const PedalBoard(this.pedalBoardModelName, {super.key});
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
    return ReorderableGridView.builder(
      itemCount: pedalBoardModel.pedals.length + 1,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          childAspectRatio: 1.3,
          crossAxisCount: 2,
          mainAxisSpacing: 20,
          crossAxisSpacing: 10),
      //padding: const EdgeInsets.symmetric(horizontal: 40),
      itemBuilder: (_, index) {
        return index <= (pedalBoardModel.pedals.length - 1)
            ? pedalWidget(pedalBoardModel.pedals[index])
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
        setState(() {
          if (oldIndex < newIndex) {
            newIndex -= 1;
          }
          final Pedal pedal = pedalBoardModel.pedals.removeAt(oldIndex);
          pedalBoardModel.pedals.insert(newIndex, pedal);
        });
      },
    );
  }

  Widget pedalWidget(Pedal pedal) {
    return Container(
        key: Key(pedal.name),
        decoration: BoxDecoration(
            color: pedal.getColor(),
            borderRadius: const BorderRadius.all(Radius.circular(10.0))),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
                child: GridView.builder(
                    itemCount: pedal.effects.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                            childAspectRatio: 1,
                            crossAxisCount: 2,
                            mainAxisSpacing: 2,
                            crossAxisSpacing: 1),
                    //padding: const EdgeInsets.symmetric(horizontal: 40),
                    itemBuilder: (_, index) {
                      return knob(pedal.effects[index]);
                    })),
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
        ));
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
                  size: 70)),
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
