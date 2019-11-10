
class ParticipantEntity {
  int participantId;
  String name;
  String email;


  ParticipantEntity({
    this.participantId,
    this.name,
    this.email
  });

  factory ParticipantEntity.fromMap(Map<String, dynamic> map) => ParticipantEntity(
      participantId: map["participantId"],
      name: map["name"],
      email: map["email"]
  );

  Map<String, dynamic> toMap() => {
    "participantId": participantId,
    "name": name,
    "email": email
  };
}
