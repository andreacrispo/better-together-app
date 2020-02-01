import 'package:cloud_firestore/cloud_firestore.dart';

class ServiceParticipantDocument {

  ServiceParticipantDocument({
    this.serviceId,
    this.participantId,
    this.pricePaid,
    this.hasPaid,
  });

  ServiceParticipantDocument.fromMap(Map<String, dynamic> map, {this.reference})
      : assert(map['name'] != null,""),
        serviceId = map['serviceId'],
        participantId = map['participantId'],
        pricePaid = map['pricePaid'],
        hasPaid = map['hasPaid'];

  ServiceParticipantDocument.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data, reference: snapshot.reference);

  String serviceId;
  String participantId;
  num pricePaid;
  bool hasPaid;
  DocumentReference reference;


  Map<String, dynamic> toMap() => {
        "serviceId": serviceId,
        "participantId": participantId,
        "pricePaid": pricePaid,
        "hasPaid": hasPaid,
      };

  @override
  String toString() => "Record<$serviceId>";
}
