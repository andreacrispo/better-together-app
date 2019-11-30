import 'package:cloud_firestore/cloud_firestore.dart';

class ParticipantDocument {
  String name;
  String email;
  bool hasPaid;
  double pricePaid;
  int yearPaid;
  int monthPaid;
  Timestamp datePaid;
  DocumentReference reference;

  ParticipantDocument(
      {this.name,
      this.email,
      this.hasPaid,
      this.pricePaid,
      this.yearPaid,
      this.monthPaid}) {
    this.hasPaid = false;
  }

  ParticipantDocument.fromMap(Map<String, dynamic> map, {this.reference})
      : assert(map['name'] != null),
        name = map['name'],
        email = map['email'],
        hasPaid = map['hasPaid'],
        pricePaid = map['pricePaid'],
        yearPaid = map['yearPaid'],
        monthPaid = map['monthPaid'],
        datePaid = map['datePaid'];

  ParticipantDocument.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data, reference: snapshot.reference);

  Map<String, dynamic> toMap() => {
        "name": name,
        "email": email,
        "hasPaid": hasPaid,
        "pricePaid": pricePaid,
        "yearPaid": yearPaid,
        "monthPaid": monthPaid,
        "datePaid": datePaid,
      };
}
