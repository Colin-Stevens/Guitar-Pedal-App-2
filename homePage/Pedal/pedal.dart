import 'package:flutter/material.dart';
import 'package:guitar_pedal_app/models/atribute_model.dart';

class PedalWidget extends StatelessWidget {
  final String pedalImage;
  final List<PedalAtribute> effects;
  const PedalWidget(this.pedalImage, this.effects, {super.key});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Row(
        children: [
          Image(image: AssetImage('assets/images/$pedalImage.png')),
        ],
      )
    ]);
  }
}
