import 'package:firebase_database/firebase_database.dart';

class EventSignUp {
  String key;
  String eventKey;
  int hours;
  String userId;
  int nights;
  int sequenceNum; // This number starts from 0
  bool confirmed;
  bool completed;


  EventSignUp(this.userId, this.eventKey, this.hours, this.nights, this.sequenceNum, this.confirmed, this.completed);

  EventSignUp.fromSnapshot(DataSnapshot snapshot) :
    key = snapshot.key,
    eventKey = snapshot.value["eventKey"],
    userId = snapshot.value["userId"],
    hours = snapshot.value["hours"],
    nights = snapshot.value["nights"],
    sequenceNum = snapshot.value["sequenceNum"],  // This number starts from 0
    confirmed = snapshot.value["confirmed"],
  completed = snapshot.value["completed"];

  EventSignUp.fromFireBase(DataSnapshot snapshot) {
    this.eventKey = snapshot.value["eventKey"];
    this.userId = snapshot.value["userId"];
    this.hours = snapshot.value["hours"];
    this.nights = snapshot.value["nights"];
    this.sequenceNum = snapshot.value["sequenceNum"];
    this.confirmed = snapshot.value["confirmed"];
    this.completed = snapshot.value["completed"];
  }

  toJson() {
    return {
      "eventKey": eventKey,
      "userId": userId,
      "hours": hours,
      "nights": nights,
      "sequenceNum": sequenceNum,
      "confirmed": confirmed,
      "completed": completed,
    };
  }
}

