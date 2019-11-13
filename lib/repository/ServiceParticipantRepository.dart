


import 'package:sqflite/sqlite_api.dart';

import 'package:better_together_app/repository/DBProvider.dart';
import 'package:better_together_app/repository/DataRepository.dart';
import 'package:better_together_app/model/ServiceParticipantEntity.dart';

class ServiceParticipantRepository extends DataRepository<ServiceParticipantEntity> {

  static final tableName = 'ServiceParticipant';

  DBProvider _dbProvider;

  ServiceParticipantRepository() {
    _dbProvider = DBProvider.instance;
  }

  @override
  Future<void> closeDB() {
    return _dbProvider.close();
  }

  @override
  Future<int> create(ServiceParticipantEntity item) async {
    Database db = await _dbProvider.database;
    var id = db.insert(tableName, item.toMap());
    return id;
  }

  @override
  Future<bool> delete(int id) {
    // TODO: implement delete
    return null;
  }

  @override
  Future<ServiceParticipantEntity> get(int id) {
    // TODO: implement get
    return null;
  }

  @override
  Future<List<ServiceParticipantEntity>> getAll() {
    // TODO: implement getAll
    return null;
  }

  @override
  Future<bool> update(int id, ServiceParticipantEntity data) async {
    Database db = await _dbProvider.database;
    int count = await db.update(
        tableName, data.toMap(), where: "id = ?", whereArgs: [id]);
    return count == 1;
  }

  Future<ServiceParticipantEntity> findByServiceAndParticipantAndPaymentDate(
    int serviceId,
    int participantId,
    int monthPaid,
    int yearPaid
  ) async {
    Database db = await _dbProvider.database;
    const String whereCondition = """ 
          serviceId = ? 
      and participantId = ?
      and monthPaid = ?
      and yearPaid  = ?
     """;
    var result =  await db.query(tableName, where: whereCondition, whereArgs: [serviceId,participantId,monthPaid,yearPaid]);
    if(result.length > 0 )
      return ServiceParticipantEntity.fromMap(result.first);

    return null;
  }


}