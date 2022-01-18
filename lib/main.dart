import 'package:flutter/material.dart';
import 'package:tabmi/creaTablePage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod/riverpod.dart';

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

class TabListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: const <Widget>[
          ListTile(
            title: Text('test1'),
          ),
          Card(
            child: ListTile(
              title: Text('test2'),
            ),
          ),
          Card(
            child: ListTile(
              title: Text('test3'),
            ),
          ),
          Card(
            child: ListTile(
              title: Text('test4'),
            ),
          ),
        ],
      ),
    );
  }
}
