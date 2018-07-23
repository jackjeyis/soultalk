import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'dart:async';
import 'dart:io';



class AppDatabase{
  static final AppDatabase _appDatabase = new AppDatabase._internal();

  //private internal constructor to make it singleton
  AppDatabase._internal();

  Database _database;

  static AppDatabase get() {
    return _appDatabase;
  }

  bool didInit = false;

  /// Use this method to access the database which will provide you future of [Database],
  /// because initialization of the database (it has to go through the method channel)
  Future<Database> _getDb() async {
    if (!didInit) await _init();
    return _database;
  }

  Future _init() async {
    // Get a location using path_provider
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "tasks.db");
    _database = await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
          // When creating the db, create the table
          await _createUserTable(db);
        }, onUpgrade: (Database db, int oldVersion, int newVersion) async {

        });
    didInit = true;
  }

  Future _createUserTable(Database db){
    return db.transaction((txn){
      txn.execute('''CREATE TABLE User (id INTEGER PRIMARY KEY, phone TEXT, name TEXT, 
                email TEXT,portrait TEXT,messages TEXT,
                 lastMessage TEXT,timestamp,DATETIME DEFAULT CURRENT_TIMESTAMP)''');
    });
  }

  Future createSessionTable(String session) async {
    var db = await _getDb();
    return db.transaction((txn){
      txn.execute('''CREATE TABLE ${session} (id INTEGER PRIMARY KEY,snd_name TEXT,
            img_url TEXT,text TEXT)''');
    });
  }
  
  Future writeSession(String session,Map json) async {
    var db = await _getDb();
    return db.transaction((txn){
      txn.rawInsert('''INSERT INTO User(phone,name,email,portrait,messages,lastMessage)
          ' VALUES(${json['phone']},${json['name']},${json['email']}
          ,${json['portrait']},${json['messages']},${json['lastMessage']})''');
    });
  }

  Future<List<Map>> getSessions() async {
    var db = await _getDb();
    return db.rawQuery('SELECT * FROM User');
  }
}

