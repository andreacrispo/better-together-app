import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../model/participant_document.dart';
import '../model/service_document.dart';
import '../utils/utils.dart';


class ServiceParticipantFirebase {

  ServiceParticipantFirebase._internal();

  factory ServiceParticipantFirebase() {
    return _singleton;
  }

  static final ServiceParticipantFirebase _singleton = ServiceParticipantFirebase._internal();


  String uid;

  Stream<QuerySnapshot> getServices(String sortByVariable, bool isSortByDesc) {
    return Firestore.instance
                    .collection('services')
                    .where('uid', isEqualTo: this.uid)
                    .orderBy(sortByVariable, descending: isSortByDesc)
                    .snapshots();
  }


  createService(context, ServiceDocument newService) async {
    newService
          ..uid = this.uid
          ..color = newService.color ?? Colors.white60.value
          ..icon = newService.icon ?? DEFAULT_ICON;
    await Firestore.instance.collection('services').add(newService.toMap());
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
    final previousPaid = getTimestamp(year, month - 1);
    final currentPaid = getTimestamp(year, month);

    final QuerySnapshot previousParticipants = await Firestore.instance
        .collection("services")
        .document(serviceId)
        .collection('participants')
        .where('uid', isEqualTo: this.uid)
        .where('datePaid', isEqualTo: previousPaid)
        .getDocuments();

    previousParticipants.documents.forEach((DocumentSnapshot snapshot) {
      final participant = snapshot.data;
      participant['datePaid'] = currentPaid;
      participant['pricePaid'] = null;
      participant['hasPaid'] = false;

      Firestore.instance
          .collection("services")
          .document(serviceId)
          .collection('participants')
          .add(participant);
    });
  }

  addParticipantIntoService({String serviceId, ParticipantDocument participant, bool useCredit}) {
    final String participantId = participant.participantId;

    if(useCredit) {
      participant.credit -= participant.pricePaid;
      final String dateKey = Timestamp.now().toDate().toIso8601String();
      participant.creditHistory.putIfAbsent(dateKey, () => participant.credit);
    }
    Firestore.instance.collection('participants').document(participantId).setData({
      'credit': participant.credit,
      'creditHistory': participant.creditHistory
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
    final FirebaseAuth _auth = FirebaseAuth.instance;
    final FirebaseUser user = await _auth.currentUser();

    newParticipant.uid = user.uid;
    return Firestore.instance.collection('participants').add(newParticipant.toMap());
  }

  void editParticipant(String documentID, ParticipantDocument edited) {
     Firestore.instance
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
