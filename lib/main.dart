import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:tabmi/creaTablePage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod/riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';

void main() {
  runApp(
    ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
      routes: {
        "/home": (BuildContext context) => HomePage(),
        "/list_tab": (BuildContext context) => TabListPage(),
      },
    );
  }
}

PageRouteBuilder bottomToTop(Widget page) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) {
      return page;
    },
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const Offset begin = Offset(0.3, 1.0); // 下から上
      // final Offset begin = Offset(0.0, -1.0); // 上から下
      const Offset end = Offset.zero;
      final Animatable<Offset> tween = Tween(begin: begin, end: end)
          .chain(CurveTween(curve: Curves.easeInOut));
      final Animation<Offset> offsetAnimation = animation.drive(tween);
      return SlideTransition(
        position: offsetAnimation,
        child: child,
      );
    },
  );
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("HOME"),
          bottom: const TabBar(tabs: <Widget>[
            Tab(text: 'Tab 一覧'),
            Tab(text: 'tab2'),
            Tab(text: 'tab3'),
          ]),
        ),
        body: TabBarView(
          children: <Widget>[
            TabListPage(),
            const Center(child: Text('雨', style: TextStyle(fontSize: 50))),
            const Center(child: Text('晴れ', style: TextStyle(fontSize: 50))),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () {
            // Navigator.of(context).pushNamed("/create_tab");
            showModalBottomSheet<void>(
              context: context,
              builder: (BuildContext context) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Ink(
                      child: ListTile(
                        title: const Text('TAB作成'),
                        onTap: () => {
                          Navigator.pop(context),
                          Navigator.of(context).push(
                            bottomToTop(InputLyrics()),
                          )
                        },
                      ),
                    ),
                    const ListTile(
                      title: Text('list2'),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}

// class TabListPage extends StatelessWidget {
//   Future<List<Widget>> fetchSongs() async {
//     var dir = await getApplicationDocumentsDirectory();
//     await dir.create(recursive: true);
//     var dbPath = join(dir.path, 'tabmi.db');
//     var db = await databaseFactoryIo.openDatabase(dbPath);
//     var store = intMapStoreFactory.store('tabs');

//     var tabs = (await (store.find(db)));
//     // print(tabs);
//     List<Widget> lines = [];
//     for (var tab in tabs) {
//       print(tab["title"]);
//       // String title = tab["title"].toString();
//       lines.add(Text(tab["title"].toString()));
//     }

//     return Future.value(lines);
//   }

//   @override
//   Widget build(BuildContext context) {
//     // SharedPreferences prefs = await SharedPreferences.getInstance();
//     // List<String> songIds = await prefs.getStringList("songIds") ?? [];
//     return Scaffold(
//       body: FutureBuilder(
//         future: fetchSongs(),
//         builder: (BuildContext context, AsyncSnapshot<List<Widget>> snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             // 非同期処理未完了 = 通信中
//             return const Center(
//               child: CircularProgressIndicator(),
//             );
//           }

//           if (snapshot.error != null) {
//             // エラー
//             return const Center(
//               child: Text('エラーがおきました'),
//             );
//           }

//           // 成功処理
//           return ListView(children: snapshot.data ?? []);
//           // return ListView(children: [Text('hi')]);
//         },
//       ),
//     );
//   }
// }

class TabListPage extends StatefulWidget {
  @override
  TabListPageState createState() => TabListPageState();
}

class TabListPageState extends State<TabListPage> {
  Future<List<Widget>> fetchSongs() async {
    var dir = await getApplicationDocumentsDirectory();
    await dir.create(recursive: true);
    var dbPath = join(dir.path, 'tabmi.db');
    var db = await databaseFactoryIo.openDatabase(dbPath);
    var store = intMapStoreFactory.store('tabs');

    var tabs = (await (store.find(db)));
    // print(tabs);
    List<Widget> lines = [];
    for (var tab in tabs) {
      print(tab["title"]);
      // String title = tab["title"].toString();
      lines.add(Text(tab["title"].toString()));
    }

    return Future.value(lines);
  }

  @override
  Widget build(BuildContext context) {
    // SharedPreferences prefs = await SharedPreferences.getInstance();
    // List<String> songIds = await prefs.getStringList("songIds") ?? [];
    return Scaffold(
      body: FutureBuilder(
        future: fetchSongs(),
        builder: (BuildContext context, AsyncSnapshot<List<Widget>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // 非同期処理未完了 = 通信中
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.error != null) {
            // エラー
            return const Center(
              child: Text('エラーがおきました'),
            );
          }

          // 成功処理
          return ListView(children: snapshot.data ?? []);
          // return ListView(children: [Text('hi')]);
        },
      ),
    );
  }
}
