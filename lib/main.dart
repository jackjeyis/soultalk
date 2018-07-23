import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:web_socket_channel/io.dart';
import 'package:soultalk/config/conf.dart';
import 'package:soultalk/db/appbase.dart';

import 'dart:convert';
import 'home.dart';



void main() {
  getLandingFile().then((file) {
      runApp(new TalkcasuallyApp(file.existsSync()));
  });

}

class TalkcasuallyApp extends StatelessWidget {
  TalkcasuallyApp(this.landing);

  final bool landing;

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
        debugShowMaterialGrid:false,
        theme: new ThemeData(
          primarySwatch: Colors.blue,
          primaryColor: Colors.blue,
          scaffoldBackgroundColor: Colors.grey[50],
          dialogBackgroundColor: Colors.grey[50],
          primaryColorBrightness: Brightness.light,
          buttonColor: Colors.blue,
          iconTheme: new IconThemeData(
            color: Colors.grey[700],
          ),
          hintColor: Colors.grey[400],
        ),
        title: 'Soultalk',
        home: new HomePage(title:"Soultalk",landing: landing,)
    );

  }
}
