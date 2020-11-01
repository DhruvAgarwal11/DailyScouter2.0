import 'package:firebase_database/firebase_database.dart';

class Merit_Badges_Earned {
  String key;
  String userId;
  String date_earned;
  String meritBadge;
  bool eagle;


  Merit_Badges_Earned(this.userId,this.date_earned,this.meritBadge, this.eagle);

  Merit_Badges_Earned.fromSnapshot(DataSnapshot snapshot) :
        key = snapshot.key,
        userId = snapshot.value["userId"],
        date_earned = snapshot.value["date_earned"],
        meritBadge = snapshot.value["meritBadge"],
        eagle = snapshot.value["eagle"];

  Merit_Badges_Earned.fromFireBase(DataSnapshot snapshot) {
    this.userId = snapshot.value["userId"];
    this.date_earned = snapshot.value["date_earned"];
    this.meritBadge = snapshot.value["meritBadge"];
    this.eagle = snapshot.value["eagle"];
  }

  toJson() {
    return {
      "userId": userId,
      "date_earned": date_earned,
      "meritBadge": meritBadge,
      "eagle": eagle,
    };
  }
}

