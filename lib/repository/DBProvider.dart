

import 'dart:async';
import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqlite_api.dart';
import 'package:path_provider/path_provider.dart';

class DBProvider {
  DBProvider._(); // private constructor
  static final DBProvider instance = DBProvider._();

  static Database _database;

  Future<Database> get database async {
    if (_database == null)
      _database = await _initDB();

    return _database;
  }

  Future<Database> _initDB() async {
    Directory appDir = await getApplicationDocumentsDirectory();
    String path = join(appDir.path, 'MsdAOK_database.db');
    return await openDatabase(
      path,
      version: 1,
      onOpen: (db){},
      onCreate: (db, ver) async {
        String create1 = """
            CREATE TABLE Service ( 
             serviceId INTEGER PRIMARY KEY AUTOINCREMENT,
             name VARCHAR(255),
             color INTEGER,
             description VARCHAR(255),
             icon VARCHAR(255),
             monthlyPrice REAL,
             participantNumber INTEGER
            );
        """;
        String create2 = """
            CREATE TABLE ServiceParticipant ( 
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              serviceId INTEGER,
              participantId INTEGER,
              hasPaid TINYINT,
              pricePaid REAL,
              yearPaid INTEGER,
              monthPaid INTEGER
            );
        """;
        String create3 = """
            CREATE TABLE Participant ( 
              participantId INTEGER PRIMARY KEY AUTOINCREMENT,
              name VARCHAR(255),
              email VARCHAR(255)
            );
        """;
        await db.execute(create1);
        await db.execute(create2);
        await db.execute(create3);
        await db.execute("INSERT INTO Service (serviceId,name,monthlyPrice,participantNumber) values(1,'test', 15,6)");
        await db.execute("INSERT INTO Service (serviceId,name) values(2,'prova')");
      }
    );
  }

  Future<void> close() async {
    if(_database != null)
        return _database.close();

    return null;
  }

}