


import 'package:better_together_app/model/ParticipantEntity.dart';
import 'package:sqflite/sqlite_api.dart';

import 'package:better_together_app/repository/DBProvider.dart';
import 'package:better_together_app/repository/DataRepository.dart';

class ParticipantRepository extends DataRepository<ParticipantEntity> {

  static final tableName = 'Participant';

  DBProvider _dbProvider;

  ParticipantRepository() {
    _dbProvider = DBProvider.instance;
  }

  @override
  Future<void> closeDB() {
    return _dbProvider.close();
  }

  @override
  Future<int> create(ParticipantEntity item) async {
    Database db = await _dbProvider.database;
    var id = db.insert(tableName, item.toMap());
    return id;
  }

  @override
  Future<bool> delete(int id) async {
    Database db = await _dbProvider.database;
    int count = await db.delete(tableName, where: "participantId = ?", whereArgs: [id]);
    return count == 1;
  }

  @override
  Future<ParticipantEntity> get(int id) async {
    Database db = await _dbProvider.database;
    List<Map> maps = await db.query(tableName, where: "participantId = ?", whereArgs: [id]);
    if(maps.length > 0 )
      return ParticipantEntity.fromMap(maps.first);

    return null;
  }

  @override
  Future<List<ParticipantEntity>> getAll() async {
    Database db = await _dbProvider.database;
    List<Map<String, dynamic>> data = await db.query(tableName);
    List<ParticipantEntity> items = data
        .map<ParticipantEntity>((item) => ParticipantEntity.fromMap(item))
        .toList();
    print(items);
    return items;
  }

  @override
  Future<bool> update(int id, ParticipantEntity data) async {
    Database db = await _dbProvider.database;
    int count = await db.update(tableName, data.toMap(), where: "participantId == ?", whereArgs: [id]);
    return count == 1;
  }

}