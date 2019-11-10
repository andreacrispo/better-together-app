


import 'package:better_together_app/model/ServiceEntity.dart';
import 'package:sqflite/sqlite_api.dart';

import 'package:better_together_app/repository/DBProvider.dart';
import 'package:better_together_app/repository/DataRepository.dart';

class ServiceRepository extends DataRepository<ServiceEntity> {

  static final tableName = 'Service';

  DBProvider _dbProvider;

  ServiceRepository() {
    _dbProvider = DBProvider.instance;
  }

  @override
  Future<void> closeDB() {
    return _dbProvider.close();
  }

  @override
  Future<int> create(ServiceEntity item) async {
    Database db = await _dbProvider.database;
    var id = db.insert(tableName, item.toMap());
    return id;
  }

  @override
  Future<bool> delete(int id) async {
    Database db = await _dbProvider.database;
    int count = await db.delete(tableName, where: "serviceId = ?", whereArgs: [id]);
    return count == 1;
  }

  @override
  Future<ServiceEntity> get(int id) async {
    Database db = await _dbProvider.database;
    List<Map> maps = await db.query(tableName, where: "serviceId = ?", whereArgs: [id]);
    if(maps.length > 0 )
      return ServiceEntity.fromMap(maps.first);

    return null;
  }

  @override
  Future<List<ServiceEntity>> getAll() async {
    Database db = await _dbProvider.database;
    List<Map<String, dynamic>> data = await db.query(tableName);
    List<ServiceEntity> items = data
        .map<ServiceEntity>((item) => ServiceEntity.fromMap(item))
        .toList();
    return items;
  }

  @override
  Future<bool> update(int id, ServiceEntity data) async {
    Database db = await _dbProvider.database;
    int count = await db.update(tableName, data.toMap(), where: "serviceId == ?", whereArgs: [id]);
    return count == 1;
  }

}