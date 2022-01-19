import 'dart:convert';
import 'dart:async';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tabmi/tabLine.dart';
import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InputLyrics extends ConsumerStatefulWidget {
  @override
  _InputLyricsState createState() => _InputLyricsState();
}

class _InputLyricsState extends ConsumerState<InputLyrics> {
  String lyrics = '';
  String songId = _uuid.v4();

  @override
  void initState() {
    super.initState();
    // "ref" can be used in all life-cycles of a StatefulWidget.
    ref.read(lyricsListProvider);
  }

  void _handleText(String e) {
    setState(() {
      lyrics = e;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('歌詞入力'),
        ),
        body: Column(
          children: <Widget>[
            TextField(
              enabled: true,
              // 入力数
              // maxLength: 10,
              maxLengthEnforced: false,
              obscureText: false,
              maxLines: null,
              //パスワード
              onChanged: _handleText,
            ),
            IconButton(
              onPressed: () => {
                ref.read(lyricsListProvider.notifier).removeAll(),
                ref.read(lyricsListProvider.notifier).createFromText(lyrics),
                _moveToTab(context, lyrics)
              },
              icon: const Icon(Icons.check),
            )
          ],
        ));
  }

  void _moveToTab(BuildContext context, String lyrics) async {
    final dataFromSecondPage = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                CreateTabPage(lyrics: lyrics, songId: songId)));
  }
}

final chordBoxListProvider =
    StateNotifierProvider.autoDispose<ChordBoxList, List<ChordBox>>((ref) {
  return ChordBoxList();
});

final lyricsListProvider =
    StateNotifierProvider<LyricsList, List<Lyrics>>((ref) {
  return LyricsList();
});

final lyricsProvider = StateProvider<List<ListTile>>((ref) {
  return [];
});

class CreateTabPage extends ConsumerStatefulWidget {
  Map<String, String> lines = {};
  String lyrics;
  String songId;

  CreateTabPage({Key? key, required this.lyrics, required this.songId}) {
    for (var lyric in lyrics.split('\n')) {
      lines["groupId"] = lyric;
    }
    this.lyrics = lyrics;
    this.songId = songId;
    // super(key: key);
  }
  final _chordsLineState = GlobalKey<_ChordsLineState>();

  @override
  _CreateTabPageState createState() => _CreateTabPageState();
}

class _CreateTabPageState extends ConsumerState<CreateTabPage> {
  String title = "";
  Map<String, String> lineStrings = {};

  @override
  void initState() {
    super.initState();
    // "ref" can be used in all life-cycles of a StatefulWidget.
    ref.read(chordBoxListProvider);
    ref.read(lyricsListProvider);
    ref.read(lyricsProvider);
  }

  // @override
  // void dispose() {
  //   // ref.read(lyricsListProvider.notifier).dispose();
  //   super.dispose();
  // }

  // @override
  // void didChangeDependencies() {
  //   ref.read(lyricsListProvider.notifier).createFromText(widget.lyrics);
  // }

  void _handleText(String e) {
    setState(() {
      title = e;
    });
  }

  void _handleLineString(String groupId, String text) {
    setState(() {
      widget.lines[groupId] = text;
      print(lineStrings);
    });
  }

  void addLines() {
    setState(() {
      print("add");
      // lines.add(ChordsLine());
      var groupId = _uuid.v4();
      ref.read(lyricsListProvider.notifier).addEmpty(groupId);
    });
  }

  void removeLines() {
    setState(() {
      if (ref.read(lyricsListProvider).length > 1) {
        // ref.read(chordBoxListProvider.notifier).removeLast();
        var groupId = ref.read(lyricsListProvider).last.groupId;
        print("removeLast");
        print(groupId);
        ref.read(chordBoxListProvider.notifier).removeByGroupId(groupId);
        print(ref.read(chordBoxListProvider));
        ref.read(lyricsListProvider).removeLast();
      }
    });
  }

  Future<void> saveData(String title, String id) async {
    var dir = await getApplicationDocumentsDirectory();
// make sure it exists
    await dir.create(recursive: true);
// build the database path
    var dbPath = join(dir.path, 'tabmi.db');
// open the database
    var db = await databaseFactoryIo.openDatabase(dbPath);
    var store = intMapStoreFactory.store('tabs');
    for (var song in ref.read(lyricsListProvider)) {
      var data = {
        "title": title,
        "id": id,
        "chords": ref.read(chordBoxListProvider.notifier).toJson(),
        "lyrics": ref.read(lyricsListProvider.notifier).toJson()
      };
      await store.add(db, data);
    }

    var records = (await (store.find(db,
            finder: Finder(filter: Filter.matches('id', id)))))
        .first;
    print(records);
  }

  @override
  Widget build(BuildContext context) {
    final List<Lyrics> lyricLists = ref.watch(lyricsListProvider);

    List<Widget> lines = _generateTextLines(widget.lines);
    return Scaffold(
      appBar: AppBar(
        title: const Text('コード配置'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () => {
              showDialog(
                  context: context,
                  builder: (context) {
                    return SimpleDialog(
                      title: Text("保存"),
                      children: <Widget>[
                        const Text("Title"),
                        TextField(
                          enabled: true,
                          obscureText: false,
                          maxLines: 1,
                          onChanged: _handleText,
                        ),
                        TextButton(
                          child: Text("保存"),
                          onPressed: () async {
                            await saveData(title, widget.songId);
                            Navigator.of(context)
                                .popUntil((route) => route.isFirst);
                          },
                        )
                      ],
                    );
                  })
            },
          ),
        ],
      ),
      body: ListView(
        children: [
          for (var i = 0; i < lyricLists.length; i++) ...[
            ChordsLine(
              groupId: lyricLists[i].groupId,
            ),
            TextField(
              controller: TextEditingController(text: lyricLists[i].text),
              enabled: true,
              // 入力数
              obscureText: false,
              maxLines: 1,
              //パスワード
              onChanged: (text) => {
                lyricLists[i].text = text,
              },
            ),
          ],
          Row(
            children: [
              IconButton(
                onPressed: () => {
                  print("presed"),
                  addLines(),
                },
                icon: const Icon(Icons.add),
              ),
              IconButton(
                onPressed: () => {
                  print("presed"),
                  removeLines(),
                },
                icon: const Icon(Icons.remove),
              ),
            ],
          )
        ],
      ),
    );
  }

  List<Widget> _generateTextLines(Map<String, String> lines) {
    // List<String> lines = lyrics.split('\n');
    List<Widget> lyricsListTile = [];
    for (var lyric in ref.read(lyricsListProvider)) {}
    lines.forEach((groupId, text) {
      lyricsListTile.add(ChordsLine(
        groupId: groupId,
      ));
      // lineStrings[groupId] = line;
      lyricsListTile.add(
        TextField(
          controller: TextEditingController(text: text),
          enabled: true,
          // 入力数
          obscureText: false,
          maxLines: 1,
          //パスワード
          onChanged: (text) => {
            _handleLineString(groupId, text),
          },
        ),
      );
    });
    // for (var line in lines) {
    //   var groupId = _uuid.v4();
    //   lyricsListTile.add(ChordsLine());
    //   lineStrings[groupId] = line;
    //   lyricsListTile.add(
    //     TextField(
    //       controller: TextEditingController(text: line),
    //       enabled: true,
    //       // 入力数
    //       obscureText: false,
    //       maxLines: 1,
    //       //パスワード
    //       onChanged: (text) => {
    //         _handleLineString(groupId, text),
    //       },
    //     ),
    //   );
    // }
    return lyricsListTile;
  }
}

const _uuid = Uuid();

class ChordsLine extends ConsumerStatefulWidget {
  ChordsLine({Key? key, required this.groupId}) : super(key: key);
  String groupId;
  double height = 50;
  double chordSize = 20;

  @override
  _ChordsLineState createState() => _ChordsLineState();
}

class _ChordsLineState extends ConsumerState<ChordsLine> {
  List<Positioned> chords = [];
  double _x = 50;
  double _y = 50;
  double appBarHeight = 40;
  double statusBarHeight = 0;
  Offset pos = Offset(50, 50);
  // List<_ChordBox> chordBoxes = [];
  // String groupId = _uuid.v4();

  @override
  void initState() {
    // "ref" can be used in all life-cycles of a StatefulWidget.
    ref.read(chordBoxListProvider);
    super.initState();
  }

  // List<_ChordBox> getChordBoxes() {
  //   return chordBoxes;
  // }

  @override
  Widget build(BuildContext context) {
    // print(chordBoxes);
    _y = widget.height / 2 - widget.chordSize / 2;
    final List<ChordBox> chordBoxes = ref
        .watch(chordBoxListProvider)
        .where((s) => s.groupId == widget.groupId)
        .toList();

    return Container(
      height: widget.height,
      child: Stack(
        alignment: Alignment.centerRight,
        children: [
          for (var i = 0; i < chordBoxes.length; i++) ...[
            Positioned(
              left: chordBoxes[i].x,
              top: chordBoxes[i].y,
              child: Draggable(
                child: GestureDetector(
                  onTap: () => {
                    showModalBottomSheet<void>(
                      context: context,
                      builder: (BuildContext context) {
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Ink(
                              child: ListTile(
                                title: const Text('変更'),
                                onTap: () => {
                                  Navigator.pop(context),
                                },
                              ),
                              // child: SizedBox(
                              //   width: double.infinity,
                              //   child: PopupMenuButton(
                              //     // icon: Icon(Icons.add),
                              //     child: Text("変更"),
                              //     onSelected: (Chords result) {
                              //       print(result);
                              //       ref
                              //           .read(chordBoxListProvider.notifier)
                              //           .changeChord(
                              //               id: chordBoxes[i].id,
                              //               chordType: result);
                              //     },
                              //     itemBuilder: (context) =>
                              //         generatePopupMenuEntry(),
                              //   ),
                              // ),
                            ),
                            Ink(
                              child: ListTile(
                                title: const Text('削除'),
                                onTap: () => {
                                  ref
                                      .read(chordBoxListProvider.notifier)
                                      .remove(chordBoxes[i]),
                                  Navigator.pop(context),
                                },
                              ),
                            ),
                          ],
                        );
                      },
                    )
                  },
                  child: Text(
                    chordBoxes[i].chordType.string,
                    style: TextStyle(
                      fontSize: widget.chordSize,
                    ),
                  ),
                  // child: PopupMenuButton(
                  //   icon: Icon(Icons.add),
                  //   onSelected: (Chords result) {
                  //     print(result);
                  //     ref
                  //         .read(chordBoxListProvider.notifier)
                  //         .changeChord(id: chordBoxes[i].id, chordType: result);
                  //   },
                  //   itemBuilder: (context) => generatePopupMenuEntry(),
                  // ),
                ),
                feedback: Text(
                  chordBoxes[i].chordType.string,
                  style: TextStyle(
                    fontSize: widget.chordSize,
                  ),
                ),
                childWhenDragging: Container(),
                onDragEnd: (dragDetails) {
                  setState(() {
                    var dx = dragDetails.offset.dx;
                    if (dx < 0) {
                      ref
                          .read(chordBoxListProvider.notifier)
                          .editX(id: chordBoxes[i].id, x: 0);
                    } else {
                      ref
                          .read(chordBoxListProvider.notifier)
                          .editX(id: chordBoxes[i].id, x: dx);
                    }
                    // if applicable, don't forget offsets like app/status bar
                    // _y = dragDetails.offset.dy - appBarHeight - statusBarHeight;
                  });
                },
              ),
            )
          ],
          PopupMenuButton(
            icon: Icon(Icons.add),
            onSelected: (Chords result) {
              // var cbox = _ChordBox(result, _y);
              // pushChord(ChordBox(chordType: result, x: 0, y: _y));
              ref
                  .read(chordBoxListProvider.notifier)
                  .add(result, _y, widget.groupId);
              print("add");
              print(widget.groupId);
            },
            itemBuilder: (context) => generatePopupMenuEntry(),
          )
        ],
      ),
    );
  }
}

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
