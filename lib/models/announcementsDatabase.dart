import 'package:firebase_database/firebase_database.dart';

class AnnouncementsDatabase {
  String key;
  String council;
  String userId;
  int date;
  String troop ;
  String subject ;
  String message ;
  bool draft;

  AnnouncementsDatabase(this.userId, this.council, this.troop, this.date, this.subject,this.message,this.draft);

  AnnouncementsDatabase.fromSnapshot(DataSnapshot snapshot) :
    key = snapshot.key,
    userId = snapshot.value["userId"],
    council = snapshot.value["council"],
    troop = snapshot.value["troop"],
    date = snapshot.value["date"],
    subject = snapshot.value["subject"],
        message = snapshot.value["message"],
      draft = snapshot.value["draft"];

  AnnouncementsDatabase.fromFireBase(DataSnapshot snapshot) {
    this.userId = snapshot.value["userId"];
    this.council = snapshot.value["council"];
    this.troop = snapshot.value["troop"];
    this.date = snapshot.value["date"];
    this.subject = snapshot.value["subject"];
    this.message = snapshot.value["message"];
    this.draft = snapshot.value["draft"];
  }

  toJson() {
    return {
      "userId": userId,
      "council": council,
      "troop": troop,
      "date": date,
      "subject":subject,
      "message":message,
      "draft": draft,
    };
  }
}

