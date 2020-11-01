import 'package:firebase_database/firebase_database.dart';

class ScoutBook_DB_Ranks {
  String key;
  String council;
  String troop;
  String bsaId;
  String rank;

  ScoutBook_DB_Ranks(this.council, this.troop, this.bsaId, this.rank);

  ScoutBook_DB_Ranks.fromSnapshot(DataSnapshot snapshot) :
        key = snapshot.key,
        council = snapshot.value["council"],
        troop = snapshot.value["troop"],
        bsaId = snapshot.value["bsaId"],
        rank = snapshot.value["rank"];


  ScoutBook_DB_Ranks.fromFireBase(DataSnapshot snapshot) {
    this.council = snapshot.value["council"];
    this.troop = snapshot.value["troop"];
    this.bsaId = snapshot.value["bsaId"];
    this.rank = snapshot.value["rank"];
  }

  toJson() {
    return {
      "council": council,
      "troop": troop,
      "bsaId": bsaId,
      "rank": rank,
    };
  }
}

