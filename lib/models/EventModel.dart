import 'package:firebase_database/firebase_database.dart';

class EventModel{
   String key;
   String title;
   String description;
   int minimumAdults;
   int minimumSeats;
   int maximumScouts;
   String location;
   int startDate;
   int endDate;
   String council;
   String troop;
   int hours;
   int nights;
   bool completed;

   String userID;
   String fee;
   String additionalNotes;
   String eventCoordinator;
   String typeOfEvent;

  EventModel(this.title, this.description, this.minimumAdults, this.minimumSeats, this.maximumScouts, this.location, this.startDate, this.endDate, this.userID, this.fee, this.additionalNotes, this.eventCoordinator, this.typeOfEvent, this.troop, this.council, this.hours, this.nights, this.completed);

  EventModel.fromSnapshot(DataSnapshot snapshot) :
         key = snapshot.key,
         title = snapshot.value["title"],
         description = snapshot.value["description"],
         minimumAdults = snapshot.value["minimumAdults"],
         minimumSeats = snapshot.value["minimumSeats"],
         maximumScouts = snapshot.value["maximumScouts"],
         location = snapshot.value["location"],
         startDate = snapshot.value["startDate"],
         endDate = snapshot.value["endDate"],
         userID = snapshot.value["userID"],
         fee = snapshot.value["fee"],
         additionalNotes = snapshot.value["additionalNotes"],
        eventCoordinator = snapshot.value["eventCoordinator"],
        troop = snapshot.value["troop"],
        council = snapshot.value["council"],
         typeOfEvent = snapshot.value["typeOfEvent"],
        hours = snapshot.value["hours"],
        nights = snapshot.value["nights"],
        completed = snapshot.value["completed"];


   EventModel.fromFireBase(DataSnapshot snapshot) {
     this.title = snapshot.value["title"];
     this.description = snapshot.value["description"];
     this.minimumAdults = snapshot.value["minimumAdults"];
     this.minimumSeats = snapshot.value["minimumSeats"];
     this.maximumScouts = snapshot.value["maximumScouts"];
     this.location = snapshot.value["location"];
     this.startDate = snapshot.value["startDate"];
     this.endDate = snapshot.value["endDate"];
     this.userID = snapshot.value["userID"];
     this.fee = snapshot.value["fee"];
     this.additionalNotes = snapshot.value["additionalNotes"];
     this.eventCoordinator = snapshot.value["eventCoordinator"];
     this.troop = snapshot.value["troop"];
     this.council = snapshot.value["council"];
     this.hours = snapshot.value["hours"];
     this.nights = snapshot.value["nights"];
     this.typeOfEvent = snapshot.value["typeOfEvent"];
     this.completed = snapshot.value["completed"];
   }

   toJson() {
     return {
      "title":title,
      "description": description,
      "minimumAdults": minimumAdults,
      "minimumSeats": minimumSeats,
      "maximumScouts": maximumScouts,
      "location": location,
      "startDate":startDate,
      "endDate":endDate,
      "userID": userID,
      "fee": fee,
      "additionalNotes": additionalNotes,
       "eventCoordinator": eventCoordinator,
       "troop": troop,
       "council": council,
       "hours": hours,
       "nights": nights,
       "typeOfEvent": typeOfEvent,
       "completed": completed,
    };
  }
}