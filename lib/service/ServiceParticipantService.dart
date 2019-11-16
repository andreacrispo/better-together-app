import 'package:better_together_app/model/ParticipantDto.dart';
import 'package:better_together_app/model/ParticipantEntity.dart';
import 'package:better_together_app/model/ServiceEntity.dart';
import 'package:better_together_app/model/ServiceParticipantDto.dart';
import 'package:better_together_app/repository/DBProvider.dart';
import 'package:better_together_app/repository/ParticipantRepository.dart';
import 'package:better_together_app/repository/ServiceParticipantRepository.dart';
import 'package:better_together_app/repository/ServiceRepository.dart';
import 'package:sqflite/sqlite_api.dart';

import 'package:better_together_app/model/ServiceParticipantEntity.dart';

class ServiceParticipantService {

  DBProvider _dbProvider;
  ServiceRepository _serviceRepository;
  ParticipantRepository _participantRepository;
  ServiceParticipantRepository _serviceParticipantRepository;

  ServiceParticipantService() {
    _dbProvider = DBProvider.instance;
    _serviceRepository = ServiceRepository();
    _participantRepository = ParticipantRepository();
    _serviceParticipantRepository = ServiceParticipantRepository();

  }

  Future<void> closeDB() {
    return _dbProvider.close();
  }


  Future<ServiceParticipantDto> getServiceWithParticipants(int serviceId, int monthPaid, int yearPaid) async {
    Database db = await _dbProvider.database;
    ServiceEntity serviceDB = await  _serviceRepository.get(serviceId);
    List<Map<String, dynamic>> data = await db.rawQuery(""" 
      select p.participantId, p.name, p.email, sp.hasPaid, sp.pricePaid, sp.yearPaid, sp.monthPaid
      from ServiceParticipant sp
      join Participant p on sp.participantId = p.participantId
      where sp.serviceId =? 
         and sp.monthPaid =?
         and sp.yearPaid =?
      order by sp.hasPaid desc
    """, [serviceId, monthPaid, yearPaid] );

    List<ParticipantDto> participants =
      data
        .map<ParticipantDto>((item) => ParticipantDto.fromMap(item))
        .toList();

    ServiceParticipantDto service = ServiceParticipantDto.fromMap(serviceDB.toMap());
    service.participants = participants;
    return Future.value(service);
  }


  addParticipantToService(int serviceId, ParticipantDto participantDto) async {
    // TODO FIX - bisogna fare una funzione getOrCreate
    ParticipantEntity participantEntity = ParticipantEntity.fromMap(participantDto.toMap());
    var participantId = await _participantRepository.create(participantEntity);
    if(participantId != null){
      ServiceParticipantEntity item = ServiceParticipantEntity(
        participantId: participantId,
        serviceId: serviceId,
        hasPaid: participantDto.hasPaid,
        pricePaid: participantDto.pricePaid,
        monthPaid: participantDto.monthPaid,
        yearPaid: participantDto.yearPaid
      );
     var relationship = _serviceParticipantRepository.create(item);
    }

  }

  editParticipantFromService(int serviceId, ParticipantDto participantDto) async {
    ServiceParticipantEntity relationship = await _serviceParticipantRepository.findByServiceAndParticipantAndPaymentDate(
          serviceId,
          participantDto.participantId,
          participantDto.monthPaid,
          participantDto.yearPaid
    );
    if(relationship == null)
      return null;

    relationship.hasPaid = participantDto.hasPaid;
    if(relationship.hasPaid ){
      relationship.pricePaid = participantDto.pricePaid != null ? participantDto.pricePaid :  participantDto.pricePaid; // TODO: AUTOMATIC CALC BASED ON SERVICE PRICE AND NUM OF PART
    }else {
      relationship.pricePaid = null;
    }
    relationship.monthPaid = participantDto.monthPaid;
    relationship.yearPaid = participantDto.yearPaid;

    var result = await _serviceParticipantRepository.update(relationship.id, relationship);
  }

  deleteParticipantFromService(int serviceId, ParticipantDto participantDto) async {
    ServiceParticipantEntity relationship = await _serviceParticipantRepository.findByServiceAndParticipantAndPaymentDate(
        serviceId,
        participantDto.participantId,
        participantDto.monthPaid,
        participantDto.yearPaid
    );
    if(relationship == null)
      return null;

    var result = await _serviceParticipantRepository.delete(relationship.id);
    
  }

  copyParticipantsFromPreviousMonth(int serviceId, int currentMonth, int currentYear) async {
    int prevMonth = currentMonth;
    int prevYear = currentYear;
    if (currentMonth - 1 <= 0) {
      prevMonth = 12;
      prevYear -= 1;
    } else {
      prevMonth -= 1;
    }
    print("prevM  " + prevMonth.toString() + " prevY  " + prevYear.toString());
    List<ServiceParticipantEntity> relationshipList = await _serviceParticipantRepository.findParticipantsByPaymentDate(
        serviceId,
        prevMonth,
        prevYear
    );
    print("relationshipList ");
    print(relationshipList);
    if(relationshipList == null)
      return null;

    relationshipList.forEach((item) async {
      ServiceParticipantEntity rel = ServiceParticipantEntity();
      rel.serviceId = item.serviceId;
      rel.participantId = item.participantId;
      rel.monthPaid = currentMonth;
      rel.yearPaid = currentYear;
      var result = await  _serviceParticipantRepository.create(rel);
    });

  }

}