import 'package:cloud_firestore/cloud_firestore.dart';

import 'participant_document.dart';

class ServiceDocument {

  ServiceDocument({
    this.serviceId,
    this.name,
    this.description,
    this.color,
    this.price,
    this.icon,
    this.currencyCode,
    this.participantNumber,
    this.uid
  });

  ServiceDocument.fromMap(Map<String, dynamic> map, {this.reference})
      : assert(map['name'] != null, ""),
        serviceId = map['serviceId'],
        name = map['name'],
        description = map['description'],
        color = map['color'],
        price = map['price'],
        icon  = map['icon'],
        currencyCode = map['currencyCode'],
        participantNumber = map['participantNumber'],
        participants = map['participants'],
        uid = map['uid']
  ;

  ServiceDocument.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data, reference: snapshot.reference);


  String serviceId;
  String name;
  String description;
  String color;
  num price;
  int participantNumber;
  String icon; // To be define better
  String currencyCode;
  List<ParticipantDocument> participants;
  DocumentReference reference;

  String uid;


  Map<String, dynamic> toMap() => {
        "serviceId": serviceId,
        "name": name,
        "description": description,
        "color": color,
        "price": price,
        "icon": icon,
        "currencyCode": currencyCode,
        "participantNumber": participantNumber,
        "uid": uid,
  };


}
