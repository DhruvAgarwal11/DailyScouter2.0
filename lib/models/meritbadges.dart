import 'package:firebase_database/firebase_database.dart';

class MeritBadges {
  String key;
  String DB;
  bool Eagle;


  MeritBadges(this.key, this.DB, this.Eagle);

  MeritBadges.fromSnapshot(DataSnapshot snapshot) :
        key = snapshot.key,
        DB = snapshot.value["DB"],
        Eagle = snapshot.value["Eagle"];

  MeritBadges.fromFireBase(DataSnapshot snapshot) {
    this.key = snapshot.value["key"];
    this.DB = snapshot.value["DB"];
    this.Eagle = snapshot.value["Eagle"];
  }

  toJson() {
    return {
      "key": key,
      "DB": DB,
      "Eagle": Eagle,
    };
  }
}

