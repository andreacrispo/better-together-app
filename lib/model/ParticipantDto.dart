


class ParticipantDto {

  int participantId;
  String name;
  String email;
  bool hasPaid;
  double pricePaid;
  int yearPaid;
  int monthPaid;

  ParticipantDto({
    this.participantId,
    this.name,
    this.email,
    this.hasPaid,
    this.pricePaid,
    this.yearPaid,
    this.monthPaid
  });

  factory ParticipantDto.fromMap(Map<String, dynamic> map) => ParticipantDto(
      participantId: map["participantId"],
      name: map["name"],
      email: map["email"],
      hasPaid: map["hasPaid"] == 1,
      pricePaid: map["pricePaid"],
      yearPaid: map["yearPaid"],
      monthPaid: map["monthPaid"]
  );

  Map<String, dynamic> toMap() => {
    "participantId": participantId,
    "name": name,
    "email": email,
    "hasPaid": hasPaid ,
    "pricePaid": pricePaid,
    "yearPaid": yearPaid,
    "monthPaid": monthPaid,
  };

}