import 'package:firebase_database/firebase_database.dart';

class Troops {
  String key;
  String council;
  String troop;
  bool isSMasterAssigned;

  Troops(this.council, this.troop, this.isSMasterAssigned);

  Troops.fromSnapshot(DataSnapshot snapshot) :
    key = snapshot.key,
    council = snapshot.value["council"],
    troop = snapshot.value["troop"],
    isSMasterAssigned = snapshot.value["isSMasterAssigned"];


  Troops.fromFireBase(DataSnapshot snapshot) {
    this.council = snapshot.value["council"];
    this.troop = snapshot.value["troop"];
    this.isSMasterAssigned = snapshot.value["isSMasterAssigned"];
  }

  toJson() {
    return {
      "council": council,
      "troop": troop,
      "isSMasterAssigned": isSMasterAssigned,
    };
  }
}

