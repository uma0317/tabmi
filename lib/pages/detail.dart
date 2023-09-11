import 'package:flutter/material.dart';
import 'package:tabmi/model/model.dart';
import 'package:tabmi/app.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';
import 'package:tabmi/tabLine.dart';
import 'package:tabmi/pages/createTab.dart';
import 'package:flutter/foundation.dart';
import 'package:tabmi/pages/createTab.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:tabmi/model/chords.dart';

final chordBoxListEditProvider =
    StateNotifierProvider<ChordBoxList, List<ChordBox>>((ref) {
  return ChordBoxList();
});

final lyricsListEditProvider =
    StateNotifierProvider<LyricsList, List<Lyrics>>((ref) {
  return LyricsList();
});

class TabDetailPage extends ConsumerStatefulWidget {
  int dbKey;
  TabDetailPage({required this.dbKey});
  @override
  TabDetailPageState createState() => TabDetailPageState();
}

class TabDetailPageState extends ConsumerState<TabDetailPage> {
  // TabDetailPage({Key? key, required this.dbKey}) : super(key: key);
  double _currentSliderValue = 300;
  double minSliderValue = 10;
  double maxSliderValue = 600;
  Future<TabData?> fetchTab() {
    return tabProvider.getTab(widget.dbKey);
  }

  @override
  void initState() {
    super.initState();
    // "ref" can be used in all life-cycles of a StatefulWidget.
    ref.read(chordBoxListProvider);
    ref.read(lyricsListProvider);
  }

  @override
  Widget build(BuildContext context) {
    final ScrollController _controller = ScrollController();
    bool scrolling = false;

    void _scrollDown() {
      if (scrolling) {
        _controller.position.hold(() {});
      } else {
        _controller.animateTo(
          _controller.position.maxScrollExtent,
          duration: Duration(
              seconds: (maxSliderValue - _currentSliderValue).toInt() + 1),
          curve: Curves.linear,
        );
      }
      scrolling = !scrolling;
    }

    void _stopScroll() {
      _controller.position.hold(() {});
      // _controller.position.hold(() {});
    }

    return StreamBuilder<RecordSnapshot<int, Map<String, Object?>>?>(
      stream: tabProvider.onTab(widget.dbKey),
      builder: (BuildContext context, snapshot) {
        if (snapshot.hasError) {
          return Text('error:${snapshot.error}');
        }

        if (snapshot.data == null) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }

        List<TabData> tabs = [];
        print(snapshot.data);
        var tab = snapshotToTab(snapshot.data!);
        return Scaffold(
            appBar: AppBar(
              bottomOpacity: 0.0,
              elevation: 0.0,
              title: Text(tab.title),
            ),
            body: GestureDetector(
              child: ListView(
                controller: _controller,
                padding: EdgeInsets.all(10),
                children: [
                  for (var i = 0; i < tab.lyrics.length; i++) ...[
                    ChordPlayLine(
                      chordBoxes:
                          filterByGroupId(tab.chords, tab.lyrics[i].groupId),
                    ),
                    TextField(
                      controller:
                          TextEditingController(text: tab.lyrics[i].text),
                      enabled: false,
                      // 入力数
                      obscureText: false,
                      maxLines: 1,
                      //パスワード
                      onChanged: (text) => {
                        // lyricLists[i].text = text,
                      },
                      decoration: InputDecoration(
                        border: InputBorder.none,
                      ),
                    ),
                  ]
                ],
              ),
              onTap: () {
                _scrollDown();
              },
            ),
            bottomNavigationBar: BottomAppBar(
              child: Row(
                // mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Expanded(
                    child: Container(
                      height: 50,
                      child: Slider(
                        // label: '$_currentSliderValue',
                        min: minSliderValue,
                        max: maxSliderValue,
                        value: _currentSliderValue,
                        // activeColor: Colors.orange,
                        // inactiveColor: Colors.blueAccent,
                        divisions: 10,
                        onChangeStart: (double value) {
                          setState(() {
                            if (scrolling) {
                              scrolling = false;
                              _stopScroll();
                            }
                          });
                        },
                        onChanged: (double value) => {
                          setState(() {
                            _currentSliderValue = value;
                          })
                        },
                        onChangeEnd: (double value) {},
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => {
                      if (scrolling) {_stopScroll()},
                      showModalBottomSheet<void>(
                        context: context,
                        builder: (BuildContext context) {
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Ink(
                                child: ListTile(
                                  leading: Icon(Icons.edit),
                                  title: const Text('編集'),
                                  onTap: () => {
                                    Navigator.pop(context),
                                    ref
                                        .read(lyricsListProvider.notifier)
                                        .removeAll(),
                                    ref
                                        .read(lyricsListProvider.notifier)
                                        .restoreFromDb(tab.lyrics),
                                    ref
                                        .read(chordBoxListProvider.notifier)
                                        .restoreFromDb(tab.chords),
                                    Navigator.of(context).push(
                                        MaterialPageRoute(builder: (context) {
                                      return CreateTabPage(
                                        songId: tab.id,
                                        title: tab.title,
                                      );
                                    }))
                                  },
                                ),
                              ),
                              Ink(
                                child: ListTile(
                                  leading: const Icon(Icons.ios_share),
                                  title: const Text("共有"),
                                  onTap: () async {
                                    print(snapshot.data!.value);
                                    var jsonData =
                                        jsonEncode(snapshot.data!.value);
                                    Codec<String, String> stringToBase64 =
                                        utf8.fuse(base64);
                                    String encoded =
                                        stringToBase64.encode(jsonData);
                                    String decoded =
                                        stringToBase64.decode(encoded);
                                    print(encoded);
                                    print(decoded);
                                    await Share.share(
                                        'tabmi://umauma.tabmi/import/${encoded}');
                                    // await Share.share(
                                    //     '${tab.title}のタブ譜を見て演奏しよう! tabmi://${encoded}');
                                  },
                                ),
                              ),
                              Ink(
                                child: ListTile(
                                  leading: const Icon(Icons.delete),
                                  title: const Text('削除'),
                                  onTap: () => {
                                    showDialog(
                                        context: context,
                                        builder: (_) {
                                          return AlertDialog(
                                            title: const Text("削除"),
                                            content: Text(
                                                "「${tab.title}」を削除してよろしいですか?"),
                                            actions: [
                                              TextButton(
                                                child: const Text("Cancel"),
                                                onPressed: () =>
                                                    Navigator.pop(context),
                                              ),
                                              TextButton(
                                                child: const Text("OK"),
                                                onPressed: () async {
                                                  tabProvider
                                                      .deleteTab(tab.key)
                                                      .then((_) => {
                                                            ScaffoldMessenger
                                                                    .of(context)
                                                                .showSnackBar(
                                                              SnackBar(
                                                                content: Text(
                                                                    '${tab.title} を削除しました。'),
                                                              ),
                                                            )
                                                          });
                                                  Navigator.of(context)
                                                      .popUntil((route) =>
                                                          route.isFirst);
                                                },
                                              ),
                                            ],
                                          );
                                        })
                                  },
                                ),
                              ),
                              Ink(
                                child: ListTile(
                                  leading: Icon(Icons.copy),
                                  title: const Text('コピーを作成'),
                                  onTap: () => {},
                                ),
                              ),
                            ],
                          );
                        },
                      )
                    },
                    icon: const Icon(Icons.more_vert),
                  ),
                ],
              ),
            ));
      },
    );
  }
}

class ChordPlayLine extends StatelessWidget {
  List<ChordBox> chordBoxes;
  double height = 50;
  double chordSize = 20;
  ChordPlayLine({required List<ChordBox> this.chordBoxes});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      child: Stack(
        alignment: Alignment.centerRight,
        children: [
          for (var i = 0; i < chordBoxes.length; i++) ...[
            Positioned(
              left: chordBoxes[i].x,
              top: chordBoxes[i].y,
              child: Text(
                chordBoxes[i].chordType.string,
                style: TextStyle(
                  fontSize: chordSize,
                ),
              ),
            )
          ],
        ],
      ),
    );
  }
}

extension on Chords {
  String get string => describeEnum(this);
}
