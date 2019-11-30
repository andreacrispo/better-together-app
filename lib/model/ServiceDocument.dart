import 'package:cloud_firestore/cloud_firestore.dart';

import 'ParticipantDocument.dart';

class ServiceDocument {
  String serviceId;
  String name;
  String description;
  String color; // Hex
  num price;
  int participantNumber;
  List<ParticipantDocument> participants;
  DocumentReference reference;

  ServiceDocument(
      {this.serviceId,
      this.name,
      this.description,
      this.color,
      this.price,
      this.participantNumber});

  ServiceDocument.fromMap(Map<String, dynamic> map, {this.reference})
      : assert(map['name'] != null),
        serviceId = map['serviceId'],
        name = map['name'],
        description = map['description'],
        color = map['color'],
        price = map['price'],
        participantNumber = map['participantNumber'],
        participants = map['participants'];

  ServiceDocument.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data, reference: snapshot.reference);

  Map<String, dynamic> toMap() => {
        "serviceId": serviceId,
        "name": name,
        "description": description,
        "color": color,
        "price": price,
        "participantNumber": participantNumber,
      };

  @override
  String toString() => "Record<$name>";
}
