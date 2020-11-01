import 'package:firebase_database/firebase_database.dart';

class Members {
  String key;
  String council;
  String troop;
  String email;
  String userId;
  String firstName;
  String lastName;
  String phoneNumber;
  String address;
  bool troopApproved;
  bool active;
  bool isScout;
  String rank;
  String leadershipPosition;
  bool isAdmin;
  bool isScoutmaster;
  bool isApprovedOrRejected;
  String bsaId;

  Members( this.email, this.userId, this.council, this.troop, this.address, this.phoneNumber,this.firstName, this.lastName, this.rank, this.leadershipPosition, this.troopApproved, this.active, this.isScout,  this.isAdmin, this.isScoutmaster, this.isApprovedOrRejected, this.bsaId);

  Members.fromSnapshot(DataSnapshot snapshot) :
    key = snapshot.key,
    council = snapshot.value["council"],
    troop = snapshot.value["troop"],
    email = snapshot.value["email"],
    userId = snapshot.value["userId"],
    firstName = snapshot.value["firstName"],
    lastName = snapshot.value["lastName"],
    phoneNumber = snapshot.value["phoneNumber"],
        active = snapshot.value["active"],
        isScout = snapshot.value["isScout"],
        rank = snapshot.value["rank"],
        leadershipPosition = snapshot.value["leadershipPosition"],
      address = snapshot.value["address"],
    troopApproved = snapshot.value["troopApproved"],
    isAdmin = snapshot.value["isAdmin"],
    isScoutmaster = snapshot.value["isScoutmaster"],
        isApprovedOrRejected = snapshot.value["isApprovedOrRejected"],
  bsaId = snapshot.value["bsaId"];

  Members.fromFireBase(DataSnapshot snapshot) {
    this.council = snapshot.value["council"];
    this.troop = snapshot.value["troop"];
    this.email = snapshot.value["email"];
    this.userId = snapshot.value["userId"];
    this.phoneNumber = snapshot.value["phoneNumber"];
    this.active = snapshot.value["active"];
    this.isScout = snapshot.value["isScout"];
    this.rank = snapshot.value["rank"];
    this.leadershipPosition = snapshot.value["leadershipPosition"];
    this.address = snapshot.value["address"];
    this.firstName = snapshot.value["firstName"];
    this.lastName = snapshot.value["lastName"];
    this.troopApproved = snapshot.value["troopApproved"];
    this.isAdmin = snapshot.value["isAdmin"];
    this.isScoutmaster = snapshot.value["isScoutmaster"];
    this.isApprovedOrRejected = snapshot.value["isApprovedOrRejected"];
    this.bsaId = snapshot.value["bsaId"];

  }

  toJson() {
    return {
      "council": council,
      "troop": troop,
      "email": email,
      "userId": userId,
      "phoneNumber": phoneNumber,
      "address": address,
      "firstName": firstName,
      "lastName": lastName,
      "troopApproved": troopApproved,
      "isAdmin": isAdmin,
      "isScoutmaster": isScoutmaster,
      "active": active,
      "isScout": isScout,
      "leadershipPosition": leadershipPosition,
      "rank": rank,
      "isApprovedOrRejected": isApprovedOrRejected,
      "bsaId": bsaId,
    };
  }
}

