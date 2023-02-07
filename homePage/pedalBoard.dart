
import 'package:flutter/material.dart';
import 'package:guitar_pedal_app/bloc/app_bloc.dart';
import 'package:guitar_pedal_app/models/PedalBoard_model.dart';
import 'package:guitar_pedal_app/models/pedal_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reorderable_grid_view/reorderable_grid_view.dart';

class PedalBoard extends StatefulWidget {
  const PedalBoard(this.pedalBoardModel, {super.key});
  final PedalBoardModel pedalBoardModel;

  @override
  _PedalBoard createState() => _PedalBoard();
}

class _PedalBoard extends State<PedalBoard> {
  Color oddTileColor = Colors.white54;
  Color evenTileColor = Colors.white70;
  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      ReorderableListView(
        //shrinkWrap: true,
        padding: const EdgeInsets.symmetric(horizontal: 40),
        children: <Widget>[
          for (int index = 0;
              index < widget.pedalBoardModel.pedals.length;
              index += 1)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              key: Key(widget.pedalBoardModel.pedals[index].name),
              child: ListTile(
                //Key can be used to prevent adding same pedal
                tileColor: index.isOdd ? oddTileColor : evenTileColor,
                title:
                    Text(widget.pedalBoardModel.pedals[index].name),
              ),
            )
        ],
        onReorder: (int oldIndex, int newIndex) {
          setState(() {
            if (oldIndex < newIndex) {
              newIndex -= 1;
            }
            final Pedal pedal =
                widget.pedalBoardModel.pedals.removeAt(oldIndex);
            widget.pedalBoardModel.pedals.insert(newIndex, pedal);
          });
        },
      ),
      Align(
          alignment: Alignment.bottomLeft,
          child: FloatingActionButton(
              onPressed: () {
                BlocProvider.of<AppBloc>(context).add(AddPedal(Pedal.noConfig()));
              },
              child: const Icon(Icons.add)))
    ]);
  }
}


Widget pedalWidget(List<Pedal> pedals){
  return ReorderableGridView.builder(
      itemCount: pedals.length + 1,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          childAspectRatio: 1.3,
          crossAxisCount: 2,
          mainAxisSpacing: 20,
          crossAxisSpacing: 10),
      itemBuilder: (_, index) {
        return index <= (pedals.length - 1)
            ? PedalBoardWidget(
                pedals[index].id, pedals[index].isActive, pedals[index].isValid)
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