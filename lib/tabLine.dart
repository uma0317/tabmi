import 'package:flutter/foundation.dart';
import 'package:riverpod/riverpod.dart';
import 'package:uuid/uuid.dart';
import 'creaTablePage.dart';

const _uuid = Uuid();

class ChordBox {
  ChordBox({
    required this.chordType,
    required this.y,
    required this.id,
    required this.x,
  });
  Chords chordType;
  double y;
  final String id;
  double x = 0;
  double fontSize = 20;
}

class ChordBoxList extends StateNotifier<List<ChordBox>> {
  ChordBoxList([List<ChordBox>? iniialChordBoxes])
      : super(iniialChordBoxes ?? []);

  void add(Chords chordType, double y) {
    state = [
      ...state,
      ChordBox(chordType: chordType, y: y, id: _uuid.v4(), x: 0),
    ];
  }

  void editX({required String id, required double x}) {
    state = [
      for (final chordBox in state)
        if (chordBox.id == id)
          ChordBox(
            id: chordBox.id,
            x: x,
            chordType: chordBox.chordType,
            y: chordBox.y,
          )
        else
          chordBox,
    ];
  }

  void remove(ChordBox target) {
    state = state.where((target) => target.id != target.id).toList();
  }
}

class TabLine {
  TabLine({
    required this.chords,
    required this.id,
    required this.lyrics,
  });
  ChordBoxList chords;
  String lyrics;
  final String id;
}

class TabLineList extends StateNotifier<List<TabLine>> {
  TabLineList([List<TabLine>? iniialChordBoxes])
      : super(iniialChordBoxes ?? []);

  void add(ChordBoxList chords, String lyrics) {
    state = [
      ...state,
      TabLine(id: _uuid.v4(), chords: chords, lyrics: lyrics),
    ];
  }

  void editX(
      {required String id,
      required ChordBoxList chords,
      required String lyrics}) {
    state = [
      for (final tabline in state)
        if (tabline.id == id)
          TabLine(
            id: tabline.id,
            lyrics: lyrics,
            chords: chords,
          )
        else
          tabline,
    ];
  }

  void remove(TabLinetarget) {
    state = state.where((target) => target.id != target.id).toList();
  }
}

class Lyrics {
  Lyrics({required this.text, required this.id});

  final String text;
  final String id;
}

class LyricsList extends StateNotifier<List<Lyrics>> {
  LyricsList([List<Lyrics>? iniialChordBoxes]) : super(iniialChordBoxes ?? []);

  void add(String text) {
    state = [
      ...state,
      Lyrics(id: _uuid.v4(), text: text),
    ];
  }

  void editX({required String id, required String text}) {
    state = [
      for (final lyrics in state)
        if (lyrics.id == id)
          Lyrics(
            id: lyrics.id,
            text: text,
          )
        else
          lyrics,
    ];
  }

  void remove(Lyrics target) {
    state = state.where((target) => target.id != target.id).toList();
  }
}
