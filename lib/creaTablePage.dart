import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
            // Text(
            //   "$lyrics",
            //   style: TextStyle(
            //       color: Colors.blueAccent,
            //       fontSize: 30.0,
            //       fontWeight: FontWeight.w500),
            // ),
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
    print(lyrics);
    final dataFromSecondPage = await Navigator.push(context,
        MaterialPageRoute(builder: (context) => CreateTabPage(lyrics: lyrics)));
  }
}

class CreateTabPage extends StatefulWidget {
  final String lyrics;
  CreateTabPage({Key? key, required this.lyrics}) : super(key: key);
  final _chordsLineState = GlobalKey<_ChordsLineState>();

  @override
  _CreateTabPageState createState() => _CreateTabPageState();

  void tt() {
    print('tt');
    print(_chordsLineState.currentWidget);
    print('tt');
  }
}

class _CreateTabPageState extends State<CreateTabPage> {
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
              print("iketeru?"),
              widget.tt(),
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

  void getAllDatas() {
    print("hi");
    // print(_chordsLineState.currentState?.chordBoxes);
    print("finish");
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

class ChordsLine extends StatefulWidget {
  ChordsLine({Key? key}) : super(key: key);

  double height = 50;
  double chordSize = 20;
  @override
  _ChordsLineState createState() => _ChordsLineState();
}

class _ChordsLineState extends State<ChordsLine> {
  List<Positioned> chords = [];
  double _x = 50;
  double _y = 50;
  double appBarHeight = 40;
  double statusBarHeight = 0;
  Offset pos = Offset(50, 50);
  List<_ChordBox> chordBoxes = [];

  void pushChord(_ChordBox chord) {
    setState(() {
      chordBoxes.add(chord);
    });
  }

  List<_ChordBox> getChordBoxes() {
    return chordBoxes;
  }

  @override
  Widget build(BuildContext context) {
    print(chordBoxes);
    _y = widget.height / 2 - widget.chordSize / 2;
    // chordBoxes.forEach((element) {});

    return Container(
      height: widget.height,
      child: Stack(
        alignment: Alignment.centerRight,
        children: [
          ...chordBoxes,
          PopupMenuButton(
            icon: Icon(Icons.add),
            onSelected: (Chords result) {
              // var cbox = _ChordBox(result, _y);
              pushChord(_ChordBox(result, _y));
              print("add");
              print(chords);
            },
            itemBuilder: (context) => <PopupMenuEntry<Chords>>[
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
            ],
          )
        ],
      ),
    );
  }
}

class _ChordBox extends StatefulWidget {
  @override
  late Chords chordType;
  double y = 50;
  double fontSize = 20;
  _ChordBox(Chords chordType, double y) {
    this.chordType = chordType;
    this.y = y;
  }

  _ChordBoxState createState() => _ChordBoxState();
}

class _ChordBoxState extends State<_ChordBox> {
  double x = 50;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: x,
      top: widget.y,
      child: Draggable(
        child: Text(
          widget.chordType.string,
          style: TextStyle(
            fontSize: widget.fontSize,
          ),
        ),
        feedback: Text(
          widget.chordType.string,
          style: TextStyle(
            fontSize: widget.fontSize,
          ),
        ),
        childWhenDragging: Container(),
        onDragEnd: (dragDetails) {
          setState(() {
            var dx = dragDetails.offset.dx;
            if (dx < 0) {
              x = 0;
            } else {
              x = dx;
            }
            print(x);
            // if applicable, don't forget offsets like app/status bar
            // _y = dragDetails.offset.dy - appBarHeight - statusBarHeight;
          });
        },
      ),
    );
  }
}

enum Chords { C, D, E, F, G, A, B }

extension on Chords {
  String get string => describeEnum(this);
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
