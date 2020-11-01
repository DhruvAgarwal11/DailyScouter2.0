import 'package:firebase_database/firebase_database.dart';

class Ranks {
  String key;
  String DB;

  Ranks(this.key, this.DB);

  Ranks.fromSnapshot(DataSnapshot snapshot) :
        key = snapshot.key,
        DB = snapshot.value["DB"];

  Ranks.fromFireBase(DataSnapshot snapshot) {
    this.key = snapshot.value["key"];
    this.DB = snapshot.value["DB"];
  }

  toJson() {
    return {
      "key": key,
      "DB": DB,
    };
  }
}