import 'package:flutter/material.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

import 'package:tabmi/app.dart';

class ImportPage extends StatefulWidget {
  @override
  _ImportPageState createState() => _ImportPageState();
}

class _ImportPageState extends State<ImportPage> {
  String encoded = '';

  void _handleText(String e) {
    setState(() {
      encoded = e;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('インポート'),
      ),
      body: ListView(
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
            onPressed: () {
              tabProvider.importTab(encoded);
              // print(decoded);
            },
            icon: const Icon(Icons.check),
          )
        ],
      ),
    );
  }
}
