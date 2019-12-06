import 'package:cloud_firestore/cloud_firestore.dart';

class ParticipantDocument {
  String participantId;
  String name;
  String email;
  num credit;
  bool hasPaid;
  num pricePaid;
  Timestamp datePaid;
  DocumentReference reference;

  ParticipantDocument({
      this.name,
      this.email,
      this.hasPaid,
      this.pricePaid,
  }) {
    this.hasPaid = false;
  }

  ParticipantDocument.fromMap(Map<String, dynamic> map, {this.reference})
      : assert(map['name'] != null),
        name = map['name'],
        participantId = map['participantId'],
        email = map['email'],
        credit = map['credit'],
        hasPaid = map['hasPaid'],
        pricePaid = map['pricePaid'],
        datePaid = map['datePaid'];

  ParticipantDocument.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data, reference: snapshot.reference);

  Map<String, dynamic> toMap() => {
        "participantId": participantId,
        "name": name,
        "email": email,
        "credit": credit,
        "hasPaid": hasPaid,
        "pricePaid": pricePaid,
        "datePaid": datePaid,
      };
}
