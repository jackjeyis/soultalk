import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:async';
import 'dart:io';
import 'sign_in.dart';
import 'group_chat_list.dart';
import 'package:sqflite/sqflite.dart';
import 'package:web_socket_channel/io.dart';
import 'package:soultalk/im/im.dart';
import 'package:path/path.dart';


void main() {
  _getLandingFile().then((file) {
    _openSqlite().then((db) async {
      var channel = await IMManager.instance().getChannel();
      runApp(new TalkcasuallyApp(file.existsSync(), db,channel));
    });

  });
}

Future<File> _getLandingFile() async {
  String dir = (await getApplicationDocumentsDirectory()).path;
  return new File('$dir/LandingInformation');
}

Future<Database> _openSqlite() async {
// Get a location using path_provider
  Directory documentsDirectory = await getApplicationDocumentsDirectory();
  String path =  join(documentsDirectory.path,"demo.db");
  // open the database
  return await openDatabase(path, version: 1,
      onCreate: (Database db, int version) async {
        // When creating the db, create the table
        await db.execute(
            '''CREATE TABLE User (id INTEGER PRIMARY KEY, phone TEXT, name TEXT, 
                email TEXT,portrait TEXT,messages TEXT,
                lastMessage TEXT,timestamp,DATETIME DEFAULT CURRENT_TIMESTAMP)''');
      });
}

class TalkcasuallyApp extends StatelessWidget {
  TalkcasuallyApp(this.landing,this.db,this.channel);

  final bool landing;
  final Database db;
  final IOWebSocketChannel channel;

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
        theme: new ThemeData(
          primarySwatch: Colors.blue,
          primaryColor: Colors.grey[50],
          scaffoldBackgroundColor: Colors.grey[50],
          dialogBackgroundColor: Colors.grey[50],
          primaryColorBrightness: Brightness.light,
          buttonColor: Colors.blue,
          iconTheme: new IconThemeData(
            color: Colors.grey[700],
          ),
          hintColor: Colors.grey[400],
        ),
        title: '纸聊',
        home: landing ? new GroupChatList(db,channel): new SignIn(db,channel));
  }
}