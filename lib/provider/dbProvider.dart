import 'package:flutter/foundation.dart';
import 'package:sembast/sembast.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast_io.dart';
import 'package:sembast/utils/sembast_import_export.dart';
import 'package:tabmi/model/model.dart';
import 'dart:convert';

// DbTab snapshotToNote(RecordSnapshot snapshot) {
//   return DbTab()
//     ..fromMap(snapshot.value as Map)
//     ..id = snapshot.key as int;
// }

// class DbNotes extends ListBase<DbTab> {
//   final List<RecordSnapshot<int, Map<String, Object?>>> list;
//   late List<DbTab?> _cacheNotes;

//   DbNotes(this.list) {
//     _cacheNotes = List.generate(list.length, (index) => null);
//   }

//   @override
//   DbTab operator [](int index) {
//     return _cacheNotes[index] ??= snapshotToNote(list[index]);
//   }

//   @override
//   int get length => list.length;

//   @override
//   void operator []=(int index, DbTab? value) => throw 'read-only';

//   @override
//   set length(int newLength) => throw 'read-only';
// }

class DbTabProvider {
  static const String dbName = 'tabs.db';
  static const int kVersion1 = 1;
  static final String tabsStoreName = 'tabs';
  // final lock = Lock(reentrant: true);
  // final DatabaseFactory dbFactory;
  Database? db;

  final tabsStore = intMapStoreFactory.store(tabsStoreName);

  // DbTabProvider(this.dbFactory);

  Future<Database> openPath(String path) async {
    var dir = await getApplicationDocumentsDirectory();
// make sure it exists
    await dir.create(recursive: true);
// build the database path
    var dbPath = join(dir.path, 'tabmi.db');
    db = await databaseFactoryIo.openDatabase(dbPath,
        version: kVersion1, onVersionChanged: _onVersionChanged);
    return db!;
  }

  Future<Database> get ready async {
    if (db == null) {
      await open();
    }
    return db!;
  }

  Future<TabData?> getTab(int id) async {
    var map = await tabsStore.record(id).getSnapshot(db!);
    // devPrint('getNote: ${map}');
    if (map != null) {
      return snapshotToTab(map);
    }
    return null;
  }

  void _onVersionChanged(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < kVersion1) {
      // await tabsStore.addAll(db, [
      //   (DbTab()
      //         ..title.v = 'Simple title'
      //         ..content.v = 'Simple content'
      //         ..date.v = 1)
      //       .toMap(),
      //   (DbTab()
      //         ..title.v = 'Welcome to NotePad'
      //         ..content.v =
      //             'Enter your notes\n\nThis is a content. Just tap anywhere to edit the note.\n'
      //                 '${kIsWeb ? '\nYou can open multiple tabs or windows and see that the content is the same in all tabs' : ''}'
      //         ..date.v = 2)
      //       .toMap(),
      // ]);
    }
  }

  Future<Database> open() async {
    return await openPath(await fixPath(dbName));
  }

  Future<String> fixPath(String path) async => path;

  Future importTab(String encoded) async {
    Codec<String, String> stringToBase64 = utf8.fuse(base64);
    String jsonData = stringToBase64.decode(encoded);
    Map<String, dynamic> tabData = jsonDecode(jsonData);
    await saveTab(
        title: tabData["title"],
        id: tabData["id"],
        chords: tabData["chords"],
        lyrics: tabData["lyrics"]);
  }

  Future saveTab({
    required String title,
    required String id,
    required Map<String, Object?> chords,
    required Map<String, Object?> lyrics,
  }) async {
    // await tabsStore.record(updatedNote.id!).put(db!, updatedNote.toMap());
    var data = {
      "title": title,
      "id": id,
      "chords": chords,
      "lyrics": lyrics,
    };
    var record = await tabsStore.add(db!, data);
    print(await getTab(record));
  }

  Future deleteTab(int? id) async {
    if (id != null) {
      await tabsStore.record(id).delete(db!);
    }
  }

  Future deleteTabWithId(String id) async {
    if (id != null) {
      await (tabsStore.delete(db!,
          finder: Finder(
            filter: Filter.matches('id', id),
          )));
    }
  }

  Future isEmpty(String id) async {
    bool isEmpty = (await (tabsStore.find(db!,
            finder: Finder(
              filter: Filter.matches('id', id),
            ))))
        .isEmpty;
    return isEmpty;
  }

  // var tabsTransformer = StreamTransformer<
  //     List<RecordSnapshot<int, Map<String, Object?>>>,
  //     List<DbTab>>.fromHandlers(handleData: (snapshotList, sink) {
  //   sink.add(json.decode(snapshotList));
  // });

  // var noteTransformer = StreamTransformer<
  //     RecordSnapshot<int, Map<String, Object?>>?,
  //     DbTab?>.fromHandlers(handleData: (snapshot, sink) {
  //   sink.add(snapshot == null ? null : snapshotToNote(snapshot));
  // });

  /// Listen for changes on any note
  Stream<List<RecordSnapshot<int, Map<String, Object?>>>> onTabs() {
    return tabsStore
        .query(finder: Finder(sortOrders: [SortOrder('title', true)]))
        .onSnapshots(db!);
  }

  /// Listed for changes on a given note
  Stream<RecordSnapshot<int, Map<String, Object?>>?> onTab(int id) {
    return tabsStore.record(id).onSnapshot(db!);
  }

  Future clearAllNotes() async {
    await tabsStore.delete(db!);
  }

  Future close() async {
    await db!.close();
  }

  Future deleteDb() async {
    await databaseFactoryIo.deleteDatabase(await fixPath(dbName));
  }
}
