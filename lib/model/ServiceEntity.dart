


import 'ParticipantEntity.dart';

class ServiceEntity {
  int serviceId;
  String name;
  String description;
  String icon;
  int color; // Hex
  double monthlyPrice;
  int participantNumber;


  ServiceEntity({
    this.serviceId,
    this.name,
    this.description,
    this.icon,
    this.color,
    this.monthlyPrice,
    this.participantNumber
  });

  factory ServiceEntity.fromMap(Map<String, dynamic> json) => ServiceEntity(
    serviceId: json["serviceId"],
    name: json["name"],
    description: json["description"],
    color: json['color'],
    icon: json["icon"],
    monthlyPrice: json["monthlyPrice"],
    participantNumber: json["participantNumber"],
  );

  Map<String, dynamic> toMap() => {
    "serviceId": serviceId,
    "name": name,
    "description": description,
    "icon": icon,
    "color": color,
    "monthlyPrice": monthlyPrice,
    "participantNumber": participantNumber,
  };
}

