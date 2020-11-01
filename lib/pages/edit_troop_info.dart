import 'package:flutter/material.dart';
import 'package:flutter_login_demo/services/authentication.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_login_demo/models/members.dart';
import 'package:flutter_login_demo/models/Merit_Badges_Earned.dart';
import 'package:flutter_login_demo/models/ScoutBook_DB_Badges.dart';
import 'package:flutter_login_demo/models/ScoutBook_DB_Ranks.dart';
import 'package:flutter_login_demo/pages/main_menu.dart';

String email;
String profilePhoneNumber;
String profileAddress;
String profileRank;
bool profileIsScout;
String profileLeadership;
bool profileActive;
bool profileTroopApproved;
bool profileIsScoutmaster;
bool profileIsAdmin;
bool isThisPersonAScoutmaster;
String firstName;
String lastName;
String ScoutorParent;
String troopFromDatabase;
bool isScoutFromDatabase;
String troopOfScoutmaster;
String councilOfScoutmaster;
int theRealIndex;
bool onlyDoOnce = true;
int sum = 0;
List<int> _validIndex = new List();
int oldValidLength=0;
var checkboxClickedIsTrue = new List (2000);
List<TextEditingController> lastNameController = new List(2000);
List<TextEditingController> bsaIdController = new List(2000);
List<TextEditingController> firstNameController = new List(2000);
List<String> leadershipPositionController = new List(2000);
List<String> rankController = new List(2000);
List<bool> isAdminController = new List(2000);
List<bool> isScoutmasterController = new List(2000);
List<bool> isScoutController = new List(2000);


//List<Members> membersList;

class EditTroopInfoPage extends StatefulWidget {
  EditTroopInfoPage({Key key, this.auth, this.userId, this.logoutCallback, this.membersList, this.validIndex, this.checkboxClickedIsTrue, this.scoutBookList, this.meritBadgesEarnedList, this.councilFromDatabase, this.troopFromDatabase, this.scoutBookRanksList})
      : super(key: key);

  final BaseAuth auth;
  final VoidCallback logoutCallback;
  final String userId;
  final List<Members> membersList;
  var checkboxClickedIsTrue;
  final List<int> validIndex;
  final List<ScoutBook_DB_Badges> scoutBookList;
  final List<Merit_Badges_Earned> meritBadgesEarnedList;
  final List<ScoutBook_DB_Ranks> scoutBookRanksList;
  final String councilFromDatabase;
  final String troopFromDatabase;

  @override
  State<StatefulWidget> createState() => new _EditTroopInfoPageState(userId: userId,
      auth: auth,
      logoutCallback: logoutCallback, membersList: membersList, validIndex: validIndex, checkboxClickedIsTrue: checkboxClickedIsTrue, scoutBookList: scoutBookList, meritBadgesEarnedList: meritBadgesEarnedList, councilFromDatabase: councilFromDatabase, troopFromDatabase: troopFromDatabase, scoutBookRanksList: scoutBookRanksList );
}

class _EditTroopInfoPageState extends State<EditTroopInfoPage> {
  _EditTroopInfoPageState({this.auth, this.userId, this.logoutCallback, this.membersList, this.validIndex, this.checkboxClickedIsTrue, this.scoutBookList, this.meritBadgesEarnedList, this.councilFromDatabase, this.troopFromDatabase, this.scoutBookRanksList});

  final BaseAuth auth;
  final VoidCallback logoutCallback;
  final String userId;
  var checkboxClickedIsTrue;
  final List<int> validIndex;
  final List<ScoutBook_DB_Badges> scoutBookList;
  final List<Merit_Badges_Earned> meritBadgesEarnedList;
  final List<ScoutBook_DB_Ranks> scoutBookRanksList;

  final String councilFromDatabase;
  final String troopFromDatabase;
  final List<Members> membersList;

  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final databaseReference = FirebaseDatabase.instance.reference();

  @override
  void initState() {
    super.initState();

    for (int i = 0; i<membersList.length; i++){
      if (membersList[i].userId == userId){
        profileIsScoutmaster = membersList[i].isScoutmaster;
        profileIsAdmin = membersList[i].isAdmin;
        profileIsScout=membersList[i].isScout;
        isThisPersonAScoutmaster = membersList[i].isScoutmaster;
      }
    }
    for (int i =0; i<validIndex.length; i++){
      if (checkboxClickedIsTrue[i]){
        firstNameController[i] = TextEditingController(text: membersList[validIndex[i]].firstName);
        lastNameController[i] = TextEditingController(text: membersList[validIndex[i]].lastName);
        bsaIdController[i] = TextEditingController(text: membersList[validIndex[i]].bsaId);
        leadershipPositionController[i] = membersList[validIndex[i]].leadershipPosition;
        rankController[i] = membersList[validIndex[i]].rank;
        isAdminController[i] = membersList[validIndex[i]].isAdmin;
        isScoutController[i] = membersList[validIndex[i]].isScout;
        isScoutmasterController[i] = membersList[validIndex[i]].isScoutmaster;
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  signOut() async {
    try {
      await widget.auth.signOut();
      widget.logoutCallback();
    } catch (e) {
      print(e);
    }
  }

  showMainMenu() async {
    try {
      new MenuPage();
    } catch (e) {
      print(e);
    }
  }


  updateMembers(Members members) {
    //Toggle completed
    if (members != null) {
      _database.reference().child("members").child(members.key).set(members.toJson());
    }
  }

  Widget showMembersList() {
    if (validIndex.length > 0) {
      return ListView.builder(
          shrinkWrap: true,
          itemCount: validIndex.length,
          itemBuilder: (BuildContext context, int index) {
            if(checkboxClickedIsTrue[index]){

      return DataTable (
        headingRowHeight: 20,
        columnSpacing:0,
        columns: <DataColumn>[
          DataColumn(

            label: Text(
              '     ',
              style: TextStyle(
                  fontStyle: FontStyle.italic, fontSize: 50, backgroundColor: Colors.grey),
            ),

          ),
          DataColumn(
            label: Text(
              '     ',
              style: TextStyle(
                  fontStyle: FontStyle.italic, fontSize: 50, backgroundColor: Colors.grey),
            ),
          ),
        ],
        rows: <DataRow>[

          DataRow(
            cells: <DataCell>[
              DataCell(
                Container(
                  width: 100,
                  child: Text("First: ", style: TextStyle(fontStyle: FontStyle.italic, fontSize: 17)))),
              DataCell(
                TextField(
                  enabled: profileIsScoutmaster,
                  controller: firstNameController[index],
                  onChanged: (text) {
                  },
                ),),
            ],
          ),
          DataRow(
            cells: <DataCell>[
              DataCell(
                  Text("Last: ", style: TextStyle(fontStyle: FontStyle.italic, fontSize: 17))),
              DataCell(
                TextField(
                  enabled: profileIsScoutmaster,
                  controller: lastNameController[index],
                  onChanged: (text) {
                  },
                ),),
            ],
          ),
          if (isScoutController[index])DataRow(
            cells: <DataCell>[
              DataCell(
                  Text("BSA ID: ", style: TextStyle(fontStyle: FontStyle.italic, fontSize: 17))),
              DataCell(
                TextField(
                  enabled: true,
                  controller: bsaIdController[index],
                  onChanged: (text) {
                  },
                ),),
            ],
          ),
          if (isScoutController[index])DataRow(
            cells: <DataCell>[
              DataCell(
                  Text("Leadership Position: ", style: TextStyle(fontStyle: FontStyle.italic, fontSize: 17))),
              DataCell(
                DropdownButton(
                  value: leadershipPositionController[index],
                  onChanged: (value) {
                    setState(() {
                      leadershipPositionController[index] = value;
                    });
                  },
            items: <String>["None","SPL", "ASPL", "JASM", "Lead JASM", "Troop Guide", "Patrol Leader", "Outdoor Ethics\nGuide", "OA Rep", "Instructor","Scribe", "Quartermaster", "Historian", "Librarian",  "Bugler", "Chaplain Aid" ,"Assistant Patrol\nLeader", "Webmaster", "Den Chief"].map(
            (String value) {
              return DropdownMenuItem(
                value: value,
                child: new Text(value, style: TextStyle(fontSize: 14)),
                );
              },
            ).toList(),
                ),),
            ],
          ),

          if (isScoutController[index])DataRow(
            cells: <DataCell>[
              DataCell(
                  Text("Rank: ", style: TextStyle(fontStyle: FontStyle.italic, fontSize: 17))),
              DataCell(
                DropdownButton(
                  value: rankController[index],
                  onChanged: (value) {
                    setState(() {
                      rankController[index] = value;
                    });
                  },
                  items: <String>["None","Scout", "Tenderfoot", "Second Class", "First Class", "Star", "Life", "Eagle", "Venturing", "Discovery", "Pathfinder", "Summit", "Lion", "Bobcat", "Tiger", "Wolf", "Bear", "Webelos", "Arrow of Light"].map(
                        (String value) {
                      return DropdownMenuItem(
                        value: value,
                        child: new Text(value),
                      );},
                  ).toList(),
                ),),
            ],
          ),
          if (profileIsScoutmaster)DataRow(
            cells: <DataCell>[
              DataCell(
                  Text("Scout?: ", style: TextStyle(fontStyle: FontStyle.italic, fontSize: 17))),
              DataCell(
                DropdownButton(
                  value: isScoutController[index],
                  onChanged: (value) {
                    setState(() {
                      if(value)
                      {
                        leadershipPositionController[index] = "None";
                        rankController[index] = "None";
                      }
                      isScoutController[index] = value;
                    });
                  },
                  items: <bool>[true,false].map(
                        (bool value) {
                      return DropdownMenuItem(
                        value: value,
                        child: new Text(value.toString()),
                      );},
                  ).toList(),
                ),),
            ],
          ),
          if (profileIsScoutmaster)DataRow(
            cells: <DataCell>[
              DataCell(
                  Text("Admin?: ", style: TextStyle(fontStyle: FontStyle.italic, fontSize: 17))),
              DataCell(
                DropdownButton(
                  value: isAdminController[index],
                  onChanged: (value) {
                    setState(() {
                      if (isScoutmasterController[index]){
                      isAdminController[index] = true;
                      }
                      else{
                        isAdminController[index]=value;
                      }
                      //membersList[validIndex[index]].isAdmin = value;
                    });
                  },
                  items: <bool>[true,false].map(
                        (bool value) {
                      return DropdownMenuItem(
                        value: value,
                        child: new Text(value.toString()),
                      );},
                  ).toList(),
                ),),
            ],
          ),
          if (profileIsScoutmaster && !isScoutController[index])DataRow(
            cells: <DataCell>[
              DataCell(
                  Text("Scoutmaster?: ", style: TextStyle(fontStyle: FontStyle.italic, fontSize: 17))),
              DataCell(
                DropdownButton(
                  value: isScoutmasterController[index],
                  onChanged: (value) {
                    setState(() {
                      isScoutmasterController[index] = value;
                      if (value){
                        isAdminController[index]=true;
                      }
                      //membersList[validIndex[index]].isScoutmaster = value;
                    });
                  },
                  items: <bool>[true,false].map(
                        (bool value) {
                      return DropdownMenuItem(
                        value: value,
                        child: new Text(value.toString()),
                      );},
                  ).toList(),
                ),),
            ],
          ),
        ],
      );
              }
else{
  return Container();
}
          }
          );

    } else {
      return Center(
          child: Text(
            "No scouts or parents in your troop.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 30.0),
          ));
    }
  }


  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('Update Info'),
          actions: <Widget>[
            SizedBox(height: 20), RaisedButton(
              onPressed:(){
                bool pushToDatabase = true;
                for(int i=0;i<validIndex.length;i++) {
                  if (checkboxClickedIsTrue[i]){
                    if (((firstNameController[i].text=="") || (lastNameController[i].text==""))){
                      pushToDatabase=false;
                   }
                  }
                }
                if (pushToDatabase){
                  for(int i=0;i<validIndex.length;i++) {
                    if (checkboxClickedIsTrue[i]){
                      if (isScoutController[i]) {
                        membersList[validIndex[i]].isAdmin = isAdminController[i];
                        membersList[validIndex[i]].firstName = firstNameController[i].text;
                        membersList[validIndex[i]].lastName = lastNameController[i].text;
                        membersList[validIndex[i]].bsaId = bsaIdController[i].text;
                        membersList[validIndex[i]].isScoutmaster = false;
                        membersList[validIndex[i]].rank = rankController[i];

                        //For the rank, check if we have an over-riding value available in ScoutBook records
                        if (membersList[validIndex[i]].bsaId != "")
                          {
                            for (int scoutBookRankEntryIndex = 0; scoutBookRankEntryIndex < scoutBookRanksList.length; scoutBookRankEntryIndex++) {
                              if ((councilFromDatabase == scoutBookRanksList[scoutBookRankEntryIndex].council) && (troopFromDatabase == scoutBookRanksList[scoutBookRankEntryIndex].troop)
                                  && (membersList[validIndex[i]].bsaId == scoutBookRanksList[scoutBookRankEntryIndex].bsaId)) {
                                // Found the rank for this person in ScoutBook_DB_Ranks
                                // If rank does not match the one listed in ScoutBook, update the scout member record
                                if (scoutBookRanksList[scoutBookRankEntryIndex].rank != membersList[validIndex[i]].rank) {
                                  print("Need to update rank for " + membersList[validIndex[i]].bsaId + " from " + membersList[validIndex[i]].rank + " to " + scoutBookRanksList[scoutBookRankEntryIndex].rank);
                                  membersList[validIndex[i]].rank = scoutBookRanksList[scoutBookRankEntryIndex].rank;
                                  break;
                                }
                              }
                            }
                          }
                        membersList[validIndex[i]].leadershipPosition= leadershipPositionController[i];
                        membersList[validIndex[i]].isScout= true;
                        _database.reference().child("members").child(membersList[validIndex[i]].key).set(membersList[validIndex[i]].toJson());

                        //Let's also update the users merit badges info from reference ScoutBook data, if available
                        if(bsaIdController[i].text!="")
                        {
                          for(int scoutBookEntryIndex=0;scoutBookEntryIndex<scoutBookList.length;scoutBookEntryIndex++)
                          {
                            if((councilFromDatabase == scoutBookList[scoutBookEntryIndex].council)&&(troopFromDatabase == scoutBookList[scoutBookEntryIndex].troop)
                                &&(bsaIdController[i].text == scoutBookList[scoutBookEntryIndex].bsaId)) {
                              // Found a merit badge for this person in ScoutBook_DB_Badges
                              // If there is an existing record, update it if needed
                              // else add a new record
                              bool foundExistingMeritBadgeRecord = false;
                              for(int j=0;j<meritBadgesEarnedList.length;j++)
                              {
                                if((meritBadgesEarnedList[j].userId == membersList[validIndex[i]].userId)&&(meritBadgesEarnedList[j].meritBadge == scoutBookList[scoutBookEntryIndex].meritBadge))
                                {
                                  //Found existing record for this scout for this badge
                                  foundExistingMeritBadgeRecord = true;

                                  // If date matches, then nothing to do, else update record
                                  if(meritBadgesEarnedList[j].date_earned != scoutBookList[scoutBookEntryIndex].date_earned)
                                  {
                                    print("Need to update "+meritBadgesEarnedList[j].meritBadge+" for "+bsaIdController[i].text+" with date"+scoutBookList[scoutBookEntryIndex].date_earned+" from earlier date "+meritBadgesEarnedList[j].date_earned);
                                    meritBadgesEarnedList[j].date_earned = scoutBookList[scoutBookEntryIndex].date_earned;
                                    _database.reference().child("Merit_Badges_Earned").child(meritBadgesEarnedList[j].key).set(meritBadgesEarnedList[j].toJson());
                                  }
                                  break;
                                }
                              }

                              // Did not find existing badge entry, and so add new record
                              if(!foundExistingMeritBadgeRecord)
                              {
                                print("Need to add "+scoutBookList[scoutBookEntryIndex].meritBadge+" for "+bsaIdController[i].text+" with date"+scoutBookList[scoutBookEntryIndex].date_earned);
                                Merit_Badges_Earned meritBadgeToAdd = new Merit_Badges_Earned(membersList[validIndex[i]].userId.toString(), scoutBookList[scoutBookEntryIndex].date_earned,scoutBookList[scoutBookEntryIndex].meritBadge,scoutBookList[scoutBookEntryIndex].eagle);
                                _database.reference().child("Merit_Badges_Earned").push().set(meritBadgeToAdd.toJson());
                              }
                            }
                          }
                        }
                      }
                      else{
                        membersList[validIndex[i]].isAdmin= isAdminController[i];
                        membersList[validIndex[i]].firstName= firstNameController[i].text;
                        membersList[validIndex[i]].lastName= lastNameController[i].text;
                        membersList[validIndex[i]].bsaId= "";
                        membersList[validIndex[i]].isScoutmaster= isScoutmasterController[i];
                        membersList[validIndex[i]].rank= "None";
                        membersList[validIndex[i]].leadershipPosition= "None";
                        membersList[validIndex[i]].isScout= false;
                        _database.reference().child("members").child(membersList[validIndex[i]].key).set(membersList[validIndex[i]].toJson());
                      }
                  }}
                  showAlertDialog(context, "You have successfully updated the members of your troop!");
                }
                else{
                  showAlertDialog2(context, "The first name or last name is empty for one or more of your scouts.!");
                }

              },
              textColor: Colors.white,
              color: Colors.blue,
              child: const Text('Save', style: TextStyle(fontSize: 15)),)
          ]

      ),
      body: showMembersList(),



    );
  }
}

showAlertDialog(BuildContext context, String displayString) {
  // set up the button
  Widget okButton = FlatButton(
    child: Text("OK"),
    onPressed: () {  Navigator.of(context).popUntil((route) => route.isFirst);
    },
  );
  // set up the AlertDialog
  AlertDialog alert = AlertDialog(
    title: Text("Successful Update"),
    content: Text(displayString),
    actions: [
      okButton,
    ],
  );
  // show the dialog
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}
showAlertDialog2(BuildContext context, String displayString) {
  // set up the button
  Widget okButton = FlatButton(
    child: Text("OK"),
    onPressed: () {Navigator.of(context).pop(); },
  );
  // set up the AlertDialog
  AlertDialog alert = AlertDialog(
    title: Text("Invalid Update"),
    content: Text(displayString),
    actions: [
      okButton,
    ],
  );
  // show the dialog
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}