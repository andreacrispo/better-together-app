import 'dart:developer' as developer;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../model/participant_document.dart';
import '../model/service_document.dart';
import '../utils/utils.dart';
import 'firestore_service.dart';


class FireStorePath {
  static String services() => "services";
  static String service(String documentId) => "services/$documentId";
  static String participants() => "participants";
  static String participant(String documentId) => "participants/$documentId";
  static String participantsOfService(String serviceDocId) =>  "services/$serviceDocId/participants";
  static String serviceParticipant(String serviceDocId, String participantDocId) =>  "services/$serviceDocId/participants/$participantDocId";
}



class ServiceParticipantFirebase {

  factory ServiceParticipantFirebase() {
    return _singleton;
  }

  ServiceParticipantFirebase._internal();

  static final ServiceParticipantFirebase _singleton = ServiceParticipantFirebase._internal();

  String uid;


  final _database = FirestoreService.instance;

  Stream<List<ServiceDocument>> getServices(String sortByVariable, {bool isSortByDesc }) {

    return _database.collectionStream(
        path: FireStorePath.services(),
        builder: (data, reference) => ServiceDocument.fromMap(data, reference: reference),
        queryBuilder: (Query query) => query
                                        .where('uid', isEqualTo: this.uid)
                                        .orderBy(sortByVariable, descending: isSortByDesc),
    );
  }


  Future<DocumentReference> createService(ServiceDocument newService) async {
    newService
          ..uid = this.uid
          ..color = newService.color ?? Colors.white60.value
          ..icon = newService.icon ?? DEFAULT_ICON;
    final result = await _database.addData(path: FireStorePath.services(), data: newService.toMap());
    return result;
  }

  Future<void> editService(String documentID, ServiceDocument editedService) async {
    await _database.setData(
      path: FireStorePath.service(documentID),
      data: editedService.toMap()
    );
  }

  Future<void> deleteService(String documentID) async {
    await _database.deleteData(path: FireStorePath.service(documentID));
  }

  Stream<List<ParticipantDocument>> getServiceWithParticipants(String serviceId, String datePaid) {

    final hasPaidDate = 'paymentHistory.$datePaid.hasPaid';

    final participantsOfService = _database.collectionStream(
      path: FireStorePath.participantsOfService(serviceId),
      builder: (data, reference) => ParticipantDocument.fromMap(data, reference: reference),
      queryBuilder: (Query query) => query.where(hasPaidDate, whereIn: [true,false])
    );

    return participantsOfService.map((snapshot) {
      final result = snapshot
          .map(( ParticipantDocument snapshot) {
        snapshot.pricePaid =  snapshot.paymentHistory[datePaid]['pricePaid'];
        snapshot.hasPaid = snapshot.paymentHistory[datePaid]['hasPaid'];
              return snapshot;
          }).toList();

      return result;
    });
  }




    Future<void> copyParticipantsFromPreviousMonth(String serviceId, int year, int month) async {
    final currentPaid = getDatePaid(year, month);
    int prevMonth = month;
    int prevYear = year;
    if (month - 1 <= 0) {
      prevMonth = 12;
      prevYear -= 1;
    } else {
      prevMonth -= 1;
    }
    final previousPaid = getDatePaid(prevYear, prevMonth);

    await this.copyParticipantsFromAnotherDate(
      serviceId: serviceId,
      fromAnotherTimestamp: previousPaid,
      currentToTimestamp: currentPaid
    );
  }

  Future<void> copyParticipantsFromAnotherDate({
    String serviceId,
    String fromAnotherTimestamp,
    String currentToTimestamp
  }) async {

    final hasPaidDate = 'paymentHistory.$fromAnotherTimestamp.hasPaid';
    final QuerySnapshot previousParticipants = await FirebaseFirestore.instance
          .collection("services")
          .doc(serviceId)
          .collection('participants')
          .where('uid', isEqualTo: this.uid)
          .where(hasPaidDate, whereIn: [true,false])
          .get();

    for(final DocumentSnapshot snapshot in previousParticipants.docs){
      Map<String, dynamic> data = snapshot.data();

       final participant = ParticipantDocument.fromMap(data);
      Map<String, dynamic> values = {
        'hasPaid': false,
        'pricePaid': 0
      };
       participant.paymentHistory.putIfAbsent(currentToTimestamp, () => values);
       await this.addParticipantIntoService(serviceId: serviceId, participant: participant, useCredit: false);
    }

  }


  addParticipantIntoService({String serviceId, ParticipantDocument participant, bool useCredit}) async {
    final String participantId = participant.participantId;

    Map<String, dynamic> pricePaid = {};
    if(participant.hasPaid != null && participant.hasPaid && useCredit) {
      participant.credit -= participant.pricePaid;
      final String dateKey = Timestamp.now().toDate().toIso8601String();
      participant.creditHistory.putIfAbsent(dateKey, () => participant.credit);
      pricePaid = {
        'hasPaid': true,
        'pricePaid': participant.pricePaid
      };
    } else {
      pricePaid = {
        'hasPaid': false,
        'pricePaid': 0
      };
    }

    final serviceListIds = participant.serviceIds.toSet()..add(serviceId);
    final datePaid = participant.datePaid != null ? participant.datePaid.toDate()  : Timestamp.now().toDate();

    participant.paymentHistory.putIfAbsent(getDatePaid(datePaid.year, datePaid.month), () => pricePaid);
    participant.serviceIds = serviceListIds.toList();

    await _database.setData(
        path: FireStorePath.participant(participantId),
        data: participant.toMap(),
        merge: true
    );


    await _database.setData(
        path: FireStorePath.serviceParticipant(serviceId, participantId),
        data: participant.toMap(),
        merge: true
    );
  }

  Future<void> editParticipantFromService({String serviceId, ParticipantDocument participant, bool useCredit}) async {

    final String participantId = participant.participantId;

    Map<String, dynamic> pricePaid = {};
    if(participant.hasPaid != null && participant.hasPaid && useCredit) {
      participant.credit -= participant.pricePaid;
      final String dateKey = Timestamp.now().toDate().toIso8601String();
      participant.creditHistory.putIfAbsent(dateKey, () => participant.credit);
      pricePaid = {
        'hasPaid': true,
        'pricePaid': participant.pricePaid
      };
    } else {
      pricePaid = {
        'hasPaid': false,
        'pricePaid': 0
      };
    }

    final serviceListIds = participant.serviceIds.toSet()..add(serviceId);
    final datePaid = participant.datePaid != null ? participant.datePaid.toDate()  : Timestamp.now().toDate();


    final datePaidKey = getDatePaid(datePaid.year, datePaid.month);
    if(participant.paymentHistory.containsKey(datePaidKey)){
      participant.paymentHistory[datePaidKey] = pricePaid;
    }else {
      participant.paymentHistory.putIfAbsent(getDatePaid(datePaid.year, datePaid.month), () => pricePaid);
    }
    participant.serviceIds = serviceListIds.toList();

    await _database.setData(
        path: FireStorePath.participant(participantId),
        data: participant.toMap(),
        merge: true
    );


    await _database.setData(
        path: FireStorePath.serviceParticipant(serviceId, participantId),
        data: participant.toMap(),
        merge: true
    );
  }

  Future<void> deleteParticipantFromService(String serviceId, ParticipantDocument participant) async {
    final String participantId = participant.reference.id;
    await  _database.deleteData(path: FireStorePath.serviceParticipant(serviceId, participantId));
  }


  Stream<List<ParticipantDocument>> getParticipants() {
    return _database.collectionStream(
        path: FireStorePath.participants(),
        builder: (data, reference) => ParticipantDocument.fromMap(data, reference: reference),
        queryBuilder: (Query query) => query.where('uid', isEqualTo: this.uid),
        // TODO: FIXME: Remove when sort order works in firebase
        // Problema con orderBy di firebase, la query carica all'infinito
        sort: (a, b) => a.name.toString().toLowerCase().compareTo(b.name.toString().toLowerCase())
    );
  }

  Stream<ParticipantDocument> getParticipantDetail(String participantId) {
    return _database.documentStream(
          path: FireStorePath.participant(participantId),
          builder: (data, reference) => ParticipantDocument.fromMap(data, reference: reference)
    );
  }


  Future<DocumentReference> createParticipant(ParticipantDocument newParticipant) async {
    newParticipant.uid = this.uid;
    return _database.addData(path: FireStorePath.participants(), data: newParticipant.toMap());
  }

  Future<void> editParticipant(String documentID, ParticipantDocument edited) async {
      //TODO: Find if there is a better way
     developer.log("documentID $documentID");
     final serviceListIds = edited.serviceIds;
     for(final String serviceId in serviceListIds) {

        final QuerySnapshot participants = await FirebaseFirestore.instance
            .collection('services')
            .doc(serviceId)
            .collection('participants')
            .where('uid', isEqualTo: this.uid)
            .where('participantId', isEqualTo: edited.reference.id)
            .get();

        for(final DocumentSnapshot docParticipant in participants.docs) {
          Map<String, dynamic>  participantMapData = docParticipant.data();


          participantMapData['name'] = edited.name;
       participantMapData['credit'] = edited.credit;


          await FirebaseFirestore.instance
              .collection('services')
              .doc(serviceId)
              .collection('participants')
              .doc(docParticipant.id)
              .set(participantMapData, SetOptions(merge: true));
        }
     }
     
     await FirebaseFirestore.instance
        .collection('participants')
        .doc(documentID)
        .set(edited.toMap());
  }

  Future<void> deleteParticipant(String documentID) async {
    await _database.deleteData(path: FireStorePath.participant(documentID));
  }


}
