import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tabmi/tabLine.dart';
import 'package:uuid/uuid.dart';
import 'package:tabmi/model/chords.dart';
import 'package:tabmi/app.dart';

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
        bottomOpacity: 0.0,
        elevation: 0.0,
        title: const Text('歌詞入力'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () => {
              _moveToTab(context, lyrics),
            },
          ),
        ],
      ),
      body: Container(
        margin: EdgeInsets.fromLTRB(10, 10, 10, 10),
        child: ListView(
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
          ],
        ),
      ),
    );
  }

  void _moveToTab(BuildContext context, String lyrics) async {
    ref.read(lyricsListProvider.notifier).removeAll();
    ref.read(chordBoxListProvider.notifier).removeAll();
    ref.read(lyricsListProvider.notifier).createFromText(lyrics);
    await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => CreateTabPage(
                  songId: songId,
                  title: "",
                )));
  }
}

final chordBoxListProvider =
    StateNotifierProvider<ChordBoxList, List<ChordBox>>((ref) {
  return ChordBoxList();
});

final lyricsListProvider =
    StateNotifierProvider<LyricsList, List<Lyrics>>((ref) {
  return LyricsList();
});

class CreateTabPage extends ConsumerStatefulWidget {
  Map<String, String> lines = {};
  String title;
  String songId;

  CreateTabPage({Key? key, required this.songId, required this.title}) {
    // for (var lyric in lyrics.split('\n')) {
    //   lines["groupId"] = lyric;
    // }
    // super(key: key);
  }

  @override
  _CreateTabPageState createState() => _CreateTabPageState();
}

class _CreateTabPageState extends ConsumerState<CreateTabPage> {
  // String title = widget.title;
  Map<String, String> lineStrings = {};

  @override
  void initState() {
    super.initState();
    // "ref" can be used in all life-cycles of a StatefulWidget.
    ref.read(chordBoxListProvider);
    ref.read(lyricsListProvider);
  }

  void _handleText(String e) {
    setState(() {
      widget.title = e;
    });
  }

  void addNexLine(Lyrics lyric) {
    setState(() {
      ref.read(lyricsListProvider.notifier).addNextLine(lyric);
    });
  }

  void removeLines(Lyrics lyric) {
    setState(() {
      if (ref.read(lyricsListProvider).length > 1) {
        // ref.read(chordBoxListProvider.notifier).removeLast();
        // var groupId = ref.read(lyricsListProvider).last.groupId;

        ref.read(chordBoxListProvider.notifier).removeByGroupId(lyric.groupId);
        // print(ref.read(chordBoxListProvider));
        ref.read(lyricsListProvider).remove(lyric);
      }
    });
  }

  Future<void> saveData(String title, String id) async {
    if (await tabProvider.isEmpty(id)) {
    } else {
      await tabProvider.deleteTabWithId(id);
    }

    await tabProvider.saveTab(
      title: title,
      id: id,
      chords: ref.read(chordBoxListProvider.notifier).toJson(),
      lyrics: ref.read(lyricsListProvider.notifier).toJson(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Lyrics> lyricLists = ref.watch(lyricsListProvider);
    print(ref.read(chordBoxListProvider.notifier).toJson());
    print(ref.read(lyricsListProvider.notifier).toJson());
    // List<Widget> lines = _generateTextLines(widget.lines);
    return Scaffold(
        appBar: AppBar(
          bottomOpacity: 0.0,
          elevation: 0.0,
          title: const Text('コード配置'),
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: () => {
                showDialog(
                    context: context,
                    builder: (context) {
                      return SimpleDialog(
                        title: const Text("保存"),
                        children: <Widget>[
                          const Text("Title"),
                          TextField(
                            controller:
                                TextEditingController(text: widget.title),
                            enabled: true,
                            obscureText: false,
                            maxLines: 1,
                            onChanged: _handleText,
                          ),
                          TextButton(
                            child: const Text("保存"),
                            onPressed: () async {
                              await saveData(widget.title, widget.songId);
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
        body: Container(
          margin: EdgeInsets.fromLTRB(10, 10, 10, 10),
          child: ListView(
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
                Row(
                  children: [
                    IconButton(
                      onPressed: () => {
                        print("presed"),
                        addNexLine(lyricLists[i]),
                      },
                      icon: const Icon(Icons.add),
                    ),
                    IconButton(
                      onPressed: () => {
                        print("presed"),
                        removeLines(lyricLists[i]),
                      },
                      icon: const Icon(Icons.remove),
                    ),
                  ],
                )
              ],
            ],
          ),
        ));
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

  @override
  void initState() {
    ref.read(chordBoxListProvider);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // print(chordBoxes);
    _y = widget.height / 2 - widget.chordSize / 2;
    final List<ChordBox> chordBoxes = ref
        .watch(chordBoxListProvider)
        .where((s) => s.groupId == widget.groupId)
        .toList();
    // print(ref.read(provider))
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
                  });
                },
              ),
            )
          ],
          PopupMenuButton(
            icon: Icon(Icons.add),
            onSelected: (Chords result) {
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

extension on Chords {
  String get string => describeEnum(this);
}
