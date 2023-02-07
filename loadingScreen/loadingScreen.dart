import 'package:flutter/material.dart';

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
            backgroundColor: Colors.amber[100],
            body: Stack(children: [
              Padding(
                  padding: const EdgeInsets.only(top: 70),
                  child: Text(
                    '  Guitar \n       Gear',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                        color: Colors.amber.shade900,
                        fontSize: 75,
                        fontStyle: FontStyle.italic,
                        fontFamily: 'Open sans',
                        shadows: const <Shadow>[
                          Shadow(
                              offset: Offset(1.0, 1.0),
                              blurRadius: 3.0,
                              color: Color.fromARGB(255, 0, 0, 0)),
                          Shadow(
                              offset: Offset(1.0, 1.0),
                              blurRadius: 8.0,
                              color: Color.fromARGB(125, 0, 0, 255))
                        ]),
                  )),
              Padding(
                  padding: const EdgeInsets.only(bottom: 50),
                  child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Text(
                        'Frogger Manner Productions',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.green[200],
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Open sans',
                            shadows: const <Shadow>[
                              Shadow(
                                  offset: Offset(1.0, 1.0),
                                  blurRadius: 3.0,
                                  color: Colors.black),
                              // Shadow(
                              //   offset: Offset(1.0, 1.0),
                              //   blurRadius: 8.0,
                              //   color: Color.fromARGB(125, 0, 0, 255))
                            ]),
                      )))
            ])));
  }
}
