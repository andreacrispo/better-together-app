import 'dart:developer' as developer;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../model/participant_document.dart';
import '../model/service_document.dart';
import '../utils/utils.dart';


class ServiceParticipantFirebase {

  factory ServiceParticipantFirebase() {
    return _singleton;
  }

  ServiceParticipantFirebase._internal();

  static final ServiceParticipantFirebase _singleton = ServiceParticipantFirebase._internal();


  String uid;

  Stream<QuerySnapshot> getServices(String sortByVariable, bool isSortByDesc) {
    return Firestore.instance
                    .collection('services')
                    .where('uid', isEqualTo: this.uid)
                    .orderBy(sortByVariable, descending: isSortByDesc)
                    .snapshots();
  }


  Future<DocumentReference> createService(context, ServiceDocument newService) async {
    newService
          ..uid = this.uid
          ..color = newService.color ?? Colors.white60.value
          ..icon = newService.icon ?? DEFAULT_ICON;
    final result = await Firestore.instance.collection('services').add(newService.toMap());
    return result;
  }

  editService(documentID, ServiceDocument editedService) async {
    await Firestore.instance.collection('services')
          .document(documentID)
          .setData(editedService.toMap());
  }

  Stream<QuerySnapshot> getServiceWithParticipants(String serviceId, Timestamp datePaid) {
    return Firestore.instance
        .collection('services')
        .document(serviceId)
        .collection('participants')
        .where('datePaid', isEqualTo: datePaid)
        .snapshots();
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
       final participant = snapshot.data;
       participant['datePaid'] = currentToTimestamp;
       participant['pricePaid'] = null;
       participant['hasPaid'] = false;

       await Firestore.instance
                      .collection("services")
                      .document(serviceId)
                      .collection('participants')
                      .add(participant);
    }

  }


  addParticipantIntoService({String serviceId, ParticipantDocument participant, bool useCredit}) {
    final String participantId = participant.participantId;

    if(useCredit) {
      participant.credit -= participant.pricePaid;
      final String dateKey = Timestamp.now().toDate().toIso8601String();
      participant.creditHistory.putIfAbsent(dateKey, () => participant.credit);
    }

    final serviceListIds = participant.serviceIds.toSet()
                ..add(serviceId);
    developer.log("services $serviceListIds");
    developer.log("serviceIds.toList() ${serviceListIds.toList()}");
    Firestore.instance.collection('participants').document(participantId).setData({
      'credit': participant.credit,
      'creditHistory': participant.creditHistory,
      'serviceIds': serviceListIds.toList()
    }, merge: true);

    
    Firestore.instance
        .collection('services')
        .document(serviceId)
        .collection('participants')
        .add(participant.toMap());
  }

  Future<void> editParticipantFromService(String serviceId, ParticipantDocument participant) {
    final String participantId = participant.reference.documentID;
    return Firestore.instance
        .collection('services')
        .document(serviceId)
        .collection('participants')
        .document(participantId)
        .setData(participant.toMap());
  }

  Future<void> deleteParticipantFromService(String serviceId, ParticipantDocument participant) {
    final String participantId = participant.reference.documentID;
    return Firestore.instance
        .collection('services')
        .document(serviceId)
        .collection('participants')
        .document(participantId)
        .delete();
  }


  Stream<QuerySnapshot> getParticipants() {
    return Firestore.instance
        .collection('participants')
        .where('uid', isEqualTo: this.uid)
        //.orderBy('name', descending: false) // Problema con orderBy, la query carica all'infinito
        .snapshots();
  }

  Stream<DocumentSnapshot> getParticipantDetail(String participantId) {
    return Firestore.instance
          .collection('participants')
          .document(participantId)
          .snapshots();
  }


  Future<DocumentReference> createParticipant(ParticipantDocument newParticipant) async {
    newParticipant.uid = this.uid;
    return Firestore.instance.collection('participants').add(newParticipant.toMap());
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

  void deleteParticipant(String documentID) {
    Firestore.instance
        .collection('participants')
        .document(documentID)
        .delete();
  }


}
