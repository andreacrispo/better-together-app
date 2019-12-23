import 'package:better_together_app/model/ParticipantDocument.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../utils.dart';

class ServiceParticipantFirebase {

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

  addParticipantIntoService(String serviceId, ParticipantDocument participant) {
    String participantId = participant.participantId;

    Firestore.instance.collection('participants').document(participantId).setData({
      'credit': participant.credit
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
}
