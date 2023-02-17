import 'package:flutter/material.dart';
import 'dart:math';

class CustomKnob extends StatefulWidget {
  // Define the parameters of this widget
  final double value;
  final double min;
  final double max;

  // Two extra parameters to make the widget more easy to customise
  final double size;
  final Color color;

  // ValueChanged is a type built into Dart for a function that changes a value
  final Function onChanged;

  // Define a build method for the widget which uses these parameters
  CustomKnob(
      {required this.value,
      this.min = 0,
      this.max = 1,
      this.color = Colors.blue,
      this.size = 70,
      required this.onChanged});

  @override
  State<StatefulWidget> createState() => CustomKnobState();
}

class CustomKnobState extends State<CustomKnob> {
  final GlobalKey _key = GlobalKey();
  // These are static constants because they are in internal parameters of the knob that
  // can't be changed from the outside
  static const double minAngle = -60;
  static const double maxAngle = 240;
  static const double sweepAngle = maxAngle - minAngle;

  @override
  Widget build(BuildContext context) {
    double normalisedValue =
        (widget.value - widget.min) / (widget.max - widget.min);
    double angle =
        (minAngle - 90 + normalisedValue * sweepAngle) * 2 * pi / 360;
    double size = widget.size;

    return Center(
      child: Container(
        key: _key,
        width: size,
        height: size,
        child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onPanUpdate: (details) {
              double changeInY = details.localPosition.dy - size / 2;
              double changeInX = details.localPosition.dx - size / 2;
              if (changeInX == 0) changeInX = 0.1;
              if (changeInY == 0) changeInY = 0.1;

              double newAngle =
                  (atan(changeInY.abs() / changeInX.abs()) * 180 / pi);

              if (changeInX < 0 && changeInY > 0) {
                newAngle = 180 + newAngle;
              } else if (changeInX < 0 && changeInY < 0) {
                newAngle = 180 - newAngle;
              } else if (changeInY > 0 && changeInX > 0) {
                newAngle = -newAngle;
              }

              newAngle = min(max(newAngle, minAngle), maxAngle);
              double newValue = (maxAngle - newAngle) *
                      ((widget.max - widget.min) / sweepAngle) +
                  widget.min;

              widget.onChanged(newValue);
            },
            child: Container(
              width: size,
              height: size,
              padding: const EdgeInsets.all(4),
              child: Transform.rotate(
                angle: angle,
                child: ClipOval(
                    child: Container(
                        color: widget.color,
                        child: Icon(
                          Icons.arrow_upward,
                          color: Colors.white,
                          size: size-8,
                        ))),
              ),
            )),
      ),
    );
  }
}
