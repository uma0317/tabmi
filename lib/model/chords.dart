import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

enum Chords { C, D, E, F, G, A, B }

extension on Chords {
  String get string => describeEnum(this);
}

List<PopupMenuEntry<Chords>> generatePopupMenuEntry() {
  return [
    const PopupMenuItem<Chords>(
      value: Chords.C,
      child: Text('C'),
    ),
    const PopupMenuItem<Chords>(
      value: Chords.D,
      child: Text('D'),
    ),
    const PopupMenuItem<Chords>(
      value: Chords.E,
      child: Text('E'),
    ),
    const PopupMenuItem<Chords>(
      value: Chords.F,
      child: Text('F'),
    ),
    const PopupMenuItem<Chords>(
      value: Chords.G,
      child: Text('G'),
    ),
    const PopupMenuItem<Chords>(
      value: Chords.A,
      child: Text('A'),
    ),
    const PopupMenuItem<Chords>(
      value: Chords.B,
      child: Text('B'),
    ),
    const PopupMenuItem<Chords>(
      value: Chords.B,
      child: Text('B'),
    ),
    const PopupMenuItem<Chords>(
      value: Chords.B,
      child: Text('B'),
    ),
    const PopupMenuItem<Chords>(
      value: Chords.B,
      child: Text('B'),
    ),
    const PopupMenuItem<Chords>(
      value: Chords.B,
      child: Text('B'),
    ),
    const PopupMenuItem<Chords>(
      value: Chords.B,
      child: Text('B'),
    ),
    const PopupMenuItem<Chords>(
      value: Chords.B,
      child: Text('B'),
    ),
    const PopupMenuItem<Chords>(
      value: Chords.B,
      child: Text('B'),
    ),
    const PopupMenuItem<Chords>(
      value: Chords.B,
      child: Text('B'),
    ),
    const PopupMenuItem<Chords>(
      value: Chords.B,
      child: Text('B'),
    ),
    const PopupMenuItem<Chords>(
      value: Chords.B,
      child: Text('B'),
    ),
  ];
}
