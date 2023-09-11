import 'dart:convert';
import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:tabmi/pages/createTab.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod/riverpod.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';
import 'package:tabmi/app.dart';
import 'package:tabmi/model/model.dart';
import 'package:tabmi/pages/detail.dart';
import 'package:tabmi/pages/import.dart';
import 'package:tabmi/provider/dbProvider.dart';
import 'package:uni_links/uni_links.dart';
import 'package:flutter/services.dart';

Future main() async {
  await init();
  runApp(
    const ProviderScope(
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
      theme: ThemeData.dark(),
      home: HomePage(),
      routes: {
        "/home": (BuildContext context) => HomePage(),
        "/input": (context) => InputLyrics(),
        "/list_tab": (BuildContext context) => TabListPage(),
        "/import": (BuildContext context) => ImportPage(),
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
      const Offset begin = Offset(0.0, 1.0); // 下から上
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
          bottomOpacity: 0.0,
          elevation: 0.0,
          title: const Text("TAB 一覧"),
        ),
        body: TabListPage(),
        floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.add),
          onPressed: () {
            // Navigator.pop(context);
            Navigator.of(context).pushNamed("/input");
            // showModalBottomSheet<void>(
            //   context: context,
            //   builder: (BuildContext context) {
            //     return Column(
            //       mainAxisSize: MainAxisSize.min,
            //       children: <Widget>[
            //         Ink(
            //           child: ListTile(
            //             title: const Text('TAB作成'),
            //             onTap: () => {
            //               Navigator.pop(context),
            //               Navigator.of(context).pushNamed("/input"),
            //             },
            //           ),
            //         ),
            //         Ink(
            //           child: ListTile(
            //             title: const Text('インポート'),
            //             onTap: () => {
            //               Navigator.pop(context),
            //               Navigator.of(context)
            //                   .pushNamed('/import', arguments: 'Hello'),
            //             },
            //           ),
            //         ),
            //         const ListTile(
            //           title: Text('list2'),
            //         ),
            //       ],
            //     );
            //   },
            // );
          },
        ),
      ),
    );
  }
}

class TabListPage extends StatefulWidget {
  @override
  TabListPageState createState() => TabListPageState();
}

class TabListPageState extends State<TabListPage> {
  @override
  Widget build(BuildContext context) {
    // var stream = _eventListStream;
    return StreamBuilder<List<RecordSnapshot<int, Map<String, Object?>>>>(
      stream: tabProvider.onTabs(),
      builder: (BuildContext context, snapshot) {
        if (snapshot.hasError) {
          return Text('error:${snapshot.error}');
        }

        if (snapshot.data == null) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        List<TabData> tabs = [];
        for (var tab in snapshot.data!) {
          tabs.add(snapshotToTab(tab));
          print(snapshotToTab(tab));
        }

        return ListView.builder(
            itemCount: tabs.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(tabs[index].title),
                onTap: () => {
                  Navigator.of(context)
                      .push(MaterialPageRoute(builder: (context) {
                    return TabDetailPage(dbKey: tabs[index].key);
                  }))
                },
              );
            });
      },
    );
  }
}
