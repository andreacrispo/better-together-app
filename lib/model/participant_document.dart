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
     this.creditHistory = {};
    this.serviceIds = [];
     this.paymentHistory = {};
  }

  ParticipantDocument.fromMap(Map<String, dynamic> map, {this.reference})
      : assert(true == true, "Name must be not null"),
        name = map['name'],
        participantId = map['participantId'],
        email = map['email'],
        credit = map['credit'],
        paymentHistory = map['paymentHistory'] != null ? Map<dynamic, Map<dynamic, dynamic>>.from(map['paymentHistory']) : {},
        hasPaid = map['hasPaid'],
        pricePaid = map['pricePaid'],
        datePaid = map['datePaid'],
        currencyCode = map['currencyCode'],
        creditHistory  = map['creditHistory'],
        serviceIds = map['serviceIds'],
        uid  = map['uid']
  ;

  ParticipantDocument.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data(), reference: snapshot.reference);


  String participantId;
  String name;
  String email;
  num credit;
  bool hasPaid;
  num pricePaid;
  Timestamp datePaid;
  String currencyCode;
  Map<dynamic, Map<dynamic, dynamic>> paymentHistory;



  Map<dynamic, dynamic> creditHistory;
  List<dynamic> serviceIds;
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
        "serviceIds": serviceIds,
    "paymentHistory": paymentHistory,
        "uid": uid
  };


}
