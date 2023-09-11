import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:flutter/foundation.dart';
import 'package:sembast/sembast.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast_io.dart';
import 'package:tabmi/model/model.dart';
import 'package:tabmi/provider/dbProvider.dart';

import 'main.dart';

late DbTabProvider tabProvider;

Future<void> init() async {
  WidgetsFlutterBinding.ensureInitialized();
  // For dev, find the proper sqlite3.dll
  // if (!kIsWeb) {
  //   sqflite.sqfliteWindowsFfiInit();
  // }

  tabProvider = DbTabProvider();
  // devPrint('/notepad Starting');
  await tabProvider.ready;
  runApp(MyApp());
}
