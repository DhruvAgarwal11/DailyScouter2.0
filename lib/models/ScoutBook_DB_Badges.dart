import 'package:firebase_database/firebase_database.dart';

class ScoutBook_DB_Badges {
  String key;
  String council;
  String troop;
  String bsaId;
  String date_earned;
  String meritBadge;
  bool eagle;

  ScoutBook_DB_Badges(this.council, this.troop, this.bsaId, this.date_earned, this.meritBadge, this.eagle);

  ScoutBook_DB_Badges.fromSnapshot(DataSnapshot snapshot) :
        key = snapshot.key,
        council = snapshot.value["council"],
        troop = snapshot.value["troop"],
        bsaId = snapshot.value["bsaId"],
        date_earned = snapshot.value["date_earned"],
        meritBadge = snapshot.value["meritBadge"],
        eagle = snapshot.value["eagle"];


  ScoutBook_DB_Badges.fromFireBase(DataSnapshot snapshot) {
    this.council = snapshot.value["council"];
    this.troop = snapshot.value["troop"];
    this.bsaId = snapshot.value["bsaId"];
    this.date_earned = snapshot.value["date_earned"];
    this.meritBadge = snapshot.value["meritBadge"];
    this.eagle = snapshot.value["eagle"];
  }

  toJson() {
    return {
      "council": council,
      "troop": troop,
      "bsaId": bsaId,
      "date_earned": date_earned,
      "meritBadge": meritBadge,
      "eagle": eagle,
    };
  }
}

