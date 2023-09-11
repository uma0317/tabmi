import 'package:flutter/material.dart';
import 'package:sembast/sembast.dart';
import 'package:tabmi/pages/createTab.dart';
import 'package:tabmi/tabLine.dart';
import 'package:uuid/uuid.dart';
import 'package:tabmi/model/chords.dart';

// import 'package:tabmi/';

const _uuid = Uuid();

class DbTab {
  final String _id = "";
  final String title = "";
  final String chords = "";
  final String lyrics = "";

  String get id => _id;

  // DbTab({required this._id})
  // @override
  // List<CvField> get fields => [title, content, date];
}

TabData snapshotToTab(RecordSnapshot snapshot) {
  int key = snapshot.key;
  String title = snapshot.value["title"];
  String id = snapshot.value["id"];

  List<ChordBox> chords = [];
  List<Lyrics> lyrics = [];

  for (var data in snapshot.value["chords"]["chords"]) {
    Chords c =
        Chords.values.firstWhere((e) => e.toString() == data["chordType"]);
    chords.add(
      ChordBox(
        chordType: c,
        y: data["y"],
        id: _uuid.v4(),
        groupId: data["gourpId"],
        x: data["x"],
      ),
    );
  }

  for (var data in snapshot.value["lyrics"]["lyrics"]) {
    lyrics.add(Lyrics(
      text: data["text"] ?? "",
      id: _uuid.v4(),
      groupId: data["gourpId"],
    ));
  }

  return TabData(
      key: key, id: id, title: title, chords: chords, lyrics: lyrics);
}

List<ChordBox> filterByGroupId(List<ChordBox> chordBoxes, String groupId) {
  return chordBoxes.where((e) => e.groupId == groupId).toList();
}

class TabData {
  int key;
  String id;
  String title;
  List<ChordBox> chords;
  List<Lyrics> lyrics;

  TabData({
    required this.key,
    required this.id,
    required this.title,
    required this.chords,
    required this.lyrics,
  });
}
