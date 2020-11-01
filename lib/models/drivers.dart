import 'package:firebase_database/firebase_database.dart';

class Drivers {
  String key;
  String userId;
  String eventKey;
  int seatsAvailable;

  Drivers(this.userId, this.eventKey, this.seatsAvailable);

  Drivers.fromSnapshot(DataSnapshot snapshot) :
    key = snapshot.key,
    userId = snapshot.value["userId"],
    eventKey = snapshot.value["eventKey"],
    seatsAvailable = snapshot.value["seatsAvailable"];


  Drivers.fromFireBase(DataSnapshot snapshot) {
    this.userId = snapshot.value["userId"];
    this.eventKey = snapshot.value["eventKey"];
    this.seatsAvailable = snapshot.value["seatsAvailable"];
  }

  toJson() {
    return {
      "userId": userId,
      "eventKey": eventKey,
      "seatsAvailable": seatsAvailable,
    };
  }
}

