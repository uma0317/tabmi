import 'package:flutter/foundation.dart';
import 'dart:async';

import 'package:riverpod/riverpod.dart';
import 'package:uuid/uuid.dart';
import 'pages/createTab.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';
import 'package:tabmi/model/chords.dart';

const _uuid = Uuid();

class ChordBox {
  ChordBox({
    required this.chordType,
    required this.y,
    required this.id,
    required this.groupId,
    required this.x,
  });
  Chords chordType;
  double y;
  final String id;
  final String groupId;
  double x = 0;
  double fontSize = 20;

  Map<String, Object?> toJson() =>
      {'chordType': chordType.toString(), 'y': y, 'x': x, 'gourpId': groupId};

  // List<ChordBox> fromSnapshot(Map<String, Object?> objs) {
  //   for(var obj in objs) {

  //   }
  // }
}

class ChordBoxList extends StateNotifier<List<ChordBox>> {
  ChordBoxList() : super([]);
  // final String id;
  void add(Chords chordType, double y, String groupId) {
    state = [
      ...state,
      ChordBox(
          chordType: chordType, y: y, id: _uuid.v4(), groupId: groupId, x: 0),
    ];
  }

  void editX({
    required String id,
    required double x,
  }) {
    state = [
      for (final chordBox in state)
        if (chordBox.id == id)
          ChordBox(
            id: chordBox.id,
            groupId: chordBox.groupId,
            x: x,
            chordType: chordBox.chordType,
            y: chordBox.y,
          )
        else
          chordBox,
    ];
  }

  void changeChord({
    required String id,
    required Chords chordType,
  }) {
    state = [
      for (final chordBox in state)
        if (chordBox.id == id)
          ChordBox(
            id: chordBox.id,
            groupId: chordBox.groupId,
            x: chordBox.x,
            chordType: chordType,
            y: chordBox.y,
          )
        else
          chordBox,
    ];
  }

  void remove(ChordBox target) {
    state = state.where((chordBox) => chordBox.id != target.id).toList();
  }

  void removeAll() {
    state = [];
  }

  void removeLast() {
    // state = state.where((chordBox) => chordBox.id != target.id).toList();
    state.removeLast();
  }

  void removeByGroupId(String groupId) {
    state = state.where((element) => element.groupId != groupId).toList();
  }

  Map<String, Object?> toJson() {
    return {"chords": state.map((e) => e.toJson()).toList()};
  }

  void restoreFromDb(List<ChordBox> chordBoxes) {
    state = chordBoxes;
  }

  Future saveToDB({required id, required title}) async {
    var dir = await getApplicationDocumentsDirectory();
// make sure it exists
    await dir.create(recursive: true);
// build the database path
    var dbPath = join(dir.path, 'my_database.db');
// open the database
    var db = await databaseFactoryIo.openDatabase(dbPath);
    var store = intMapStoreFactory.store('my_store');
    for (var song in state) {
      var data = {
        "id": id,
        "title": title,
        "chords": toJson(),
      };
      await store.add(db, data);
    }
    var key = await store.add(db, {'value': 'test'});

// Retrieve the record
    var record = store.record(key);
    var readMap = await record.get(db);

    print(record);
    var records = (await (store.find(db,
        finder: Finder(filter: Filter.matches('name', '^ugly')))));
    print(records);
    var recordss = (await (store.find(db,
            finder: Finder(filter: Filter.matches('id', id)))))
        .first;
    print(recordss);
  }
}

class Lyrics {
  Lyrics({required this.text, required this.id, required this.groupId});

  String text;
  final String id;
  final String groupId;

  Map<String, Object?> toJson() => {'gourpId': groupId, "text": text};
}

List<Lyrics> lyricsListFromString(String lyrics) {
  return lyrics.split("\n").map((e) {
    return Lyrics(groupId: _uuid.v4(), id: _uuid.v4(), text: e);
  }).toList();
}

class LyricsList extends StateNotifier<List<Lyrics>> {
  LyricsList([List<Lyrics>? iniialChordBoxes]) : super(iniialChordBoxes ?? []);

  void createFromText(String text) {
    for (var line in text.split("\n")) {
      add(line, _uuid.v4());
    }
  }

  void add(String text, String groupId) {
    state = [
      ...state,
      Lyrics(
        groupId: groupId,
        id: _uuid.v4(),
        text: text,
      ),
    ];
  }

  void addEmpty(String groupId) {
    state = [
      ...state,
      Lyrics(
        groupId: groupId,
        id: _uuid.v4(),
        text: "",
      ),
    ];
  }

  void addNextLine(Lyrics lyric) {
    var index = state.indexOf(lyric);
    state.insert(
      index + 1,
      Lyrics(
        groupId: _uuid.v4(),
        id: _uuid.v4(),
        text: "",
      ),
    );
  }

  void editX({required String id, required String text}) {
    state = [
      for (final lyrics in state)
        if (lyrics.id == id)
          Lyrics(
            id: lyrics.id,
            groupId: lyrics.groupId,
            text: text,
          )
        else
          lyrics,
    ];
  }

  void remove(Lyrics target) {
    state = state.where((lyrics) => lyrics.id != target.id).toList();
  }

  void removeAll() {
    state = [];
  }

  void restoreFromDb(List<Lyrics> lyrics) {
    state = lyrics;
  }

  Map<String, Object?> toJson() {
    return {"lyrics": state.map((e) => e.toJson()).toList()};
  }
}
