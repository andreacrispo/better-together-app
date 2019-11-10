

class ServiceParticipantEntity {
  int id;
  int participantId;
  int serviceId;
  bool hasPaid;
  double pricePaid;
  int yearPaid;
  int monthPaid;

  ServiceParticipantEntity({
    this.id,
    this.participantId,
    this.serviceId,
    this.hasPaid,
    this.pricePaid,
    this.yearPaid,
    this.monthPaid
  });

  factory ServiceParticipantEntity.fromMap(Map<String, dynamic> map) => ServiceParticipantEntity(
      id: map["id"],
      participantId: map["participantId"],
      serviceId: map["serviceId"],
      hasPaid: map["hasPaid"] == 1,
      pricePaid: map["pricePaid"],
      yearPaid: map["yearPaid"],
      monthPaid: map["monthPaid"]
  );

  Map<String, dynamic> toMap() => {
    "id": id,
    "participantId": participantId,
    "serviceId": serviceId,
    "hasPaid": hasPaid ,
    "pricePaid": pricePaid,
    "yearPaid": yearPaid,
    "monthPaid": monthPaid,
  };
}


