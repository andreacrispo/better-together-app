




import 'ParticipantDto.dart';

class ServiceParticipantDto {

  int serviceId;
  String name;
  String description;
  String icon;
  int color; // Hex
  double monthlyPrice;
  int participantNumber;
  List<ParticipantDto> participants;


  ServiceParticipantDto({
    this.serviceId,
    this.name,
    this.description,
    this.icon,
    this.color,
    this.monthlyPrice,
    this.participantNumber
  });

  factory ServiceParticipantDto.fromMap(Map<String, dynamic> json) => ServiceParticipantDto(
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

