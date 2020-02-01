import 'package:cloud_firestore/cloud_firestore.dart';

class ParticipantDocument {

  ParticipantDocument({
    this.name,
    this.email,
    this.hasPaid,
    this.pricePaid,
    this.currencyCode,
    this.uid
  }) {
    this.hasPaid = false;
    this.creditHistory = {};
  }

  ParticipantDocument.fromMap(Map<String, dynamic> map, {this.reference})
      : assert(map['name'] != null, "Name must be not null"),
        name = map['name'],
        participantId = map['participantId'],
        email = map['email'],
        credit = map['credit'],
        hasPaid = map['hasPaid'],
        pricePaid = map['pricePaid'],
        datePaid = map['datePaid'],
        currencyCode = map['currencyCode'],
        creditHistory  = map['creditHistory'],
        uid  = map['uid']
  ;

  ParticipantDocument.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data, reference: snapshot.reference);

  String participantId;
  String name;
  String email;
  num credit;
  bool hasPaid;
  num pricePaid;
  Timestamp datePaid;
  String currencyCode;
  Map<dynamic, dynamic> creditHistory;
  DocumentReference reference;

  String uid;

  Map<String, dynamic> toMap() => {
        "participantId": participantId,
        "name": name,
        "email": email,
        "credit": credit,
        "hasPaid": hasPaid,
        "pricePaid": pricePaid,
        "datePaid": datePaid,
        "currencyCode": currencyCode,
        "creditHistory": creditHistory,
        "uid": uid
      };
}
