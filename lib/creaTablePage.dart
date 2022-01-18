import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tabmi/tabLine.dart';

class InputLyrics extends StatefulWidget {
  @override
  _InputLyricsState createState() => _InputLyricsState();
}

class _InputLyricsState extends State<InputLyrics> {
  String lyrics = '';

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
            new TextField(
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
              onPressed: () => _moveToTab(context, lyrics),
              icon: const Icon(Icons.check),
            )
          ],
        ));
  }

  void _moveToTab(BuildContext context, String lyrics) async {
    final dataFromSecondPage = await Navigator.push(context,
        MaterialPageRoute(builder: (context) => CreateTabPage(lyrics: lyrics)));
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

final tabLinetProvider =
    StateNotifierProvider<TabLineList, List<TabLine>>((ref) {
  return TabLineList();
});

final lyricsProvider = StateProvider<List<ListTile>>((ref) {
  return [];
});

class CreateTabPage extends ConsumerStatefulWidget {
  final String lyrics;
  CreateTabPage({Key? key, required this.lyrics}) : super(key: key);
  final _chordsLineState = GlobalKey<_ChordsLineState>();

  @override
  _CreateTabPageState createState() => _CreateTabPageState();
}

class _CreateTabPageState extends ConsumerState<CreateTabPage> {
  @override
  void initState() {
    super.initState();
    // "ref" can be used in all life-cycles of a StatefulWidget.
    ref.read(chordBoxListProvider);
    ref.read(lyricsListProvider);
    ref.read(tabLinetProvider);
    ref.read(lyricsProvider);
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> lines = _generateTextLines(widget.lyrics);
    return new Scaffold(
      appBar: AppBar(
        title: const Text('コード配置'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.navigate_next),
            onPressed: () => {
              print(ref.read(chordBoxListProvider)),
            },
          ),
        ],
      ),
      body: ListView(
        children: [
          ...lines,
          IconButton(
            onPressed: () => {},
            icon: const Icon(Icons.add),
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    // var a = ref.watch(chordBoxListProvider);
    // a = [];
    // super.dispose();
  }

  List<Widget> _generateTextLines(String lyrics) {
    List<String> lines = lyrics.split('\n');
    List<Widget> lyricsListTile = [];
    List<_TabLine> tablines = [];
    lines.forEach((line) {
      lyricsListTile.add(new ChordsLine());
      lyricsListTile.add(ListTile(title: Text(line)));
    });
    return lyricsListTile;
  }
}

class ChordsLine extends ConsumerStatefulWidget {
  ChordsLine({Key? key}) : super(key: key);

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
    final List<ChordBox> chordBoxes = ref.watch(chordBoxListProvider);

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
                child: Text(
                  chordBoxes[i].chordType.string,
                  style: TextStyle(
                    fontSize: widget.chordSize,
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
              ref.read(chordBoxListProvider.notifier).add(result, _y);
              print("add");
              print(chords);
            },
            itemBuilder: (context) => generatePopupMenuEntry(),
          )
        ],
      ),
    );
  }
}

class _TabLine {
  Container chords = new Container();
  ListTile lyrics = new ListTile();

  _TabLine(String lyrics) {
    this.chords = Container(
      height: 100,
      child: Stack(
        children: <Widget>[
          Positioned(
            left: 20.0,
            top: 20.0,
            width: 100.0,
            height: 100.0,
            child: Container(
              color: Colors.indigo,
            ),
          ),
        ],
      ),
    );
    this.lyrics = ListTile(title: Text(lyrics));
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
