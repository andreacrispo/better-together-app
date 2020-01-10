import 'package:better_together_app/model/ParticipantDocument.dart';
import 'package:better_together_app/model/ServiceDocument.dart';
import 'package:better_together_app/utils/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ServiceParticipantFirebase {

  static final ServiceParticipantFirebase _singleton = ServiceParticipantFirebase._internal();

  factory ServiceParticipantFirebase() {
    return _singleton;
  }

  ServiceParticipantFirebase._internal();



  String uid;

  Stream<QuerySnapshot> getServices(String sortByVariable, bool isSortByDesc) {
    print("USERID UID   " + this.uid);
    return Firestore.instance
                    .collection('services')
                    .where('uid', isEqualTo: this.uid)
                    .orderBy(sortByVariable, descending: isSortByDesc)
                    .snapshots();
  }


  createService(context, ServiceDocument newService) async {

    newService.uid = this.uid;
    newService.color = newService.color ?? Colors.white60.value; // Theme.of(context).primaryColor.value;
    newService.icon = newService.icon ?? DEFAULT_ICON;
    Firestore.instance.collection('services').add(newService.toMap());
  }

  Stream<QuerySnapshot> getServiceWithParticipants(String serviceId, Timestamp datePaid) {
    return Firestore.instance
        .collection('services')
        .document(serviceId)
        .collection('participants')
        .where('datePaid', isEqualTo: datePaid)
        .snapshots();
  }

  copyParticipantsFromPreviousMonth(String serviceId, int year, int month) async {
    var previousPaid = getTimestamp(year, month - 1);
    var currentPaid = getTimestamp(year, month);

    QuerySnapshot previousParticipants = await Firestore.instance
        .collection("services")
        .document(serviceId)
        .collection('participants')
        .where('uid', isEqualTo: this.uid)
        .where('datePaid', isEqualTo: previousPaid)
        .getDocuments();

    previousParticipants.documents.forEach((DocumentSnapshot snapshot) {
      var participant = snapshot.data;
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
    String participantId = participant.participantId;

    if(useCredit) {
      participant.credit -= participant.pricePaid;
      String dateKey = Timestamp.now().toDate().toIso8601String();
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

  editParticipantFromService(String serviceId, ParticipantDocument participant) {
    String participantId = participant.reference.documentID;
    return Firestore.instance
        .collection('services')
        .document(serviceId)
        .collection('participants')
        .document(participantId)
        .setData(participant.toMap());
  }

  deleteParticipantFromService(String serviceId, ParticipantDocument participant) {
    String participantId = participant.reference.documentID;
    return Firestore.instance
        .collection('services')
        .document(serviceId)
        .collection('participants')
        .document(participantId)
        .delete();
  }


  getParticipants() {
    return Firestore.instance
        .collection('participants')
        .where('uid', isEqualTo: this.uid)
        .snapshots();
  }

  getParticipantDetail(String participantId) {
    return Firestore.instance
          .collection('participants')
          .document(participantId)
          .snapshots();
  }


  createParticipant(ParticipantDocument newParticipant) async {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    FirebaseUser user = await _auth.currentUser();

    newParticipant.uid = user.uid;
    Firestore.instance.collection('participants').add(newParticipant.toMap());
  }

  editParticipant(documentID, edited) {
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
