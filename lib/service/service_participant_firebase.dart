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

  Stream<List<ParticipantDocument>> getServiceWithParticipants(String serviceId, Timestamp datePaid) {
    return _database.collectionStream(
      path: FireStorePath.participantsOfService(serviceId),
      builder: (data, reference) => ParticipantDocument.fromMap(data, reference: reference),
      queryBuilder: (Query query) => query.where('datePaid', isEqualTo: datePaid)
    );
  }

  Future<void> copyParticipantsFromPreviousMonth(String serviceId, int year, int month) async {
    final currentPaid = getTimestamp(year, month);
    if (month - 1 <= 0) {
      month = 12;
      year -= 1;
    } else {
      month -= 1;
    }
    final previousPaid = getTimestamp(year, month);

    await this.copyParticipantsFromAnotherDate(
      serviceId: serviceId,
      fromAnotherTimestamp: previousPaid,
      currentToTimestamp: currentPaid
    );
  }

  Future<void> copyParticipantsFromAnotherDate({
    String serviceId,
    Timestamp fromAnotherTimestamp,
    Timestamp currentToTimestamp
  }) async {

    final QuerySnapshot previousParticipants = await Firestore.instance
          .collection("services")
          .document(serviceId)
          .collection('participants')
          .where('uid', isEqualTo: this.uid)
          .where('datePaid', isEqualTo: fromAnotherTimestamp)
          .getDocuments();

    for(final DocumentSnapshot snapshot in previousParticipants.documents){
       final data = snapshot.data;
       data['datePaid'] = currentToTimestamp;
       data['pricePaid'] = null;
       data['hasPaid'] = false;

       final participant = ParticipantDocument.fromMap(data);
       await this.addParticipantIntoService(serviceId: serviceId, participant: participant, useCredit: false);
    }

  }


  addParticipantIntoService({String serviceId, ParticipantDocument participant, bool useCredit}) async {
    final String participantId = participant.participantId;

    if(useCredit) {
      participant.credit -= participant.pricePaid;
      final String dateKey = Timestamp.now().toDate().toIso8601String();
      participant.creditHistory.putIfAbsent(dateKey, () => participant.credit);
    }

    final serviceListIds = participant.serviceIds.toSet()..add(serviceId);

    await _database.setData(
        path: FireStorePath.participant(participantId),
        data: {
          'credit': participant.credit,
          'creditHistory': participant.creditHistory,
          'serviceIds': serviceListIds.toList()
        },
        merge: true
    );

    await _database.addData(path: FireStorePath.participantsOfService(serviceId), data: participant.toMap());
  }

  Future<void> editParticipantFromService({String serviceId, ParticipantDocument participant, bool useCredit}) async {

    if(useCredit && participant.pricePaid != null) {
      participant.credit -= participant.pricePaid;
      final String dateKey = Timestamp.now().toDate().toIso8601String();
      participant.creditHistory.putIfAbsent(dateKey, () => participant.credit);
    }

    final serviceListIds = participant.serviceIds.toSet()..add(serviceId);


    await _database.setData(
        path: FireStorePath.participant(participant.participantId),
        data: {
          'credit': participant.credit,
          'creditHistory': participant.creditHistory,
          'serviceIds': serviceListIds.toList()
        },
        merge: true
    );

    final String docRefId =  participant.reference.documentID;

    await _database.setData(
        path: FireStorePath.serviceParticipant(serviceId, docRefId),
        data: participant.toMap()
    );
  }

  Future<void> deleteParticipantFromService(String serviceId, ParticipantDocument participant) async {
    final String participantId = participant.reference.documentID;
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

        final QuerySnapshot participants = await Firestore.instance
            .collection('services')
            .document(serviceId)
            .collection('participants')
            .where('uid', isEqualTo: this.uid)
            .where('participantId', isEqualTo: edited.reference.documentID)
            .getDocuments();

        for(final DocumentSnapshot docParticipant in participants.documents) {
          final participantMapData = docParticipant.data;
          participantMapData['name'] = edited.name;
          participantMapData['credit'] = edited.credit;
          await Firestore.instance
              .collection('services')
              .document(serviceId)
              .collection('participants')
              .document(docParticipant.documentID)
              .setData(participantMapData, merge: true);
        }
     }
     
     await Firestore.instance
        .collection('participants')
        .document(documentID)
        .setData(edited.toMap());
  }

  Future<void> deleteParticipant(String documentID) async {
    await _database.deleteData(path: FireStorePath.participant(documentID));
  }


}
