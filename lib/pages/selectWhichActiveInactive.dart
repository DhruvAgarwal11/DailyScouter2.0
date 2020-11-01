import 'package:flutter/material.dart';
import 'package:flutter_login_demo/models/EventModel.dart';
import 'package:flutter_login_demo/services/authentication.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_login_demo/models/members.dart';
import 'package:flutter_login_demo/pages/main_menu.dart';
import 'package:flutter_login_demo/models/drivers.dart';
import 'package:flutter_login_demo/models/eventsignup.dart';

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
String firstName;
String lastName;
String ScoutorParent;
String councilFromDatabase;
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
List<EventSignUp> _listOfSignedUpPeople = [];

class SelectWhichActiveInactivePage extends StatefulWidget {
  SelectWhichActiveInactivePage({Key key, this.auth, this.userId, this.membersList, this.troop, this.council, this.activeOrInactive, this.listOfDrivers, this.listOfEvents, this.eventSignUpList, this.emailOfScoutmaster})
      : super(key: key);

  final BaseAuth auth;
  final String userId;
  final String council;
  final String troop;
  final List<Members> membersList;
  final String activeOrInactive;
  final List<Drivers> listOfDrivers;
  final List<EventSignUp> eventSignUpList;
  final List<EventModel> listOfEvents;
  final String emailOfScoutmaster;

  @override
  State<StatefulWidget> createState() => new _SelectWhichActiveInactivePageState(userId: userId,
      auth: auth,
      membersList: membersList, troop: troop, council: council, activeOrInactive: activeOrInactive, listOfDrivers: listOfDrivers, listOfEvents: listOfEvents, eventSignUpList: eventSignUpList, emailOfScoutmaster: emailOfScoutmaster);
}

class _SelectWhichActiveInactivePageState extends State<SelectWhichActiveInactivePage> {
  _SelectWhichActiveInactivePageState({this.auth, this.userId, this.membersList, this.troop, this.council, this.activeOrInactive, this.listOfDrivers, this.listOfEvents, this.eventSignUpList, this.emailOfScoutmaster});

  final BaseAuth auth;
  final String userId;
  final String council;
  final String troop;
  final List<Members> membersList;
  final String activeOrInactive;
  final List<Drivers> listOfDrivers;
  final List<EventSignUp> eventSignUpList;
  final List<EventModel> listOfEvents;
  final String emailOfScoutmaster;

  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final databaseReference = FirebaseDatabase.instance.reference();

  @override
  void initState() {
    super.initState();
    for(int i=0;i<checkboxClickedIsTrue.length;i++)
      checkboxClickedIsTrue[i] = false;
 }

  @override
  void dispose() {
    super.dispose();
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

    for (int j = 0; j < membersList.length; j++) {
      if (membersList[j].userId == userId) {
        troopOfScoutmaster = membersList[j].troop;
        councilOfScoutmaster = membersList[j].council;
      }}
    _validIndex.length = 0;
    bool activeQuestion ;

    for (int j = 0; j < membersList.length; j++) {
      if (activeOrInactive == "Active"){
        activeQuestion=true;
      }
      else{
        activeQuestion=false;
      }
      if ((membersList[j].troop == troopOfScoutmaster) && (membersList[j].council == councilOfScoutmaster) &&
            (membersList[j].troopApproved==true) && (membersList[j].active == activeQuestion)) {
            _validIndex.add(j);
      }}
    for (int i = oldValidLength; i < _validIndex.length; i++) {
       checkboxClickedIsTrue[i] = false;
      }
    oldValidLength=_validIndex.length;
    onlyDoOnce = false;

    if (_validIndex.length > 0) {
      return ListView.builder(
          shrinkWrap: true,
          itemCount: _validIndex.length,
          itemBuilder: (BuildContext context, int index) {

            String firstName = membersList[_validIndex[index]].firstName;
            String lastName = membersList[_validIndex[index]].lastName;
            String membersId = membersList[_validIndex[index]].key;
            String email = membersList[_validIndex[index]].email;

            void toggleCheckbox(bool value) {
              if(checkboxClickedIsTrue[index] == false)
              {
                // Put your code here which you want to execute on CheckBox Checked event.
                setState(() {
                  checkboxClickedIsTrue[index] = true;
                });
              }
              else
              {
                // Put your code here which you want to execute on CheckBox Un-Checked event.
                setState(() {
                  checkboxClickedIsTrue[index] = false;
                });
              }
            }


            return DataTable (
              key: Key(membersId),
              headingRowHeight: 20,
              columns: <DataColumn>[
                DataColumn(
                  label: Text(
                    '',
                    style: TextStyle(
                        fontStyle: FontStyle.italic, fontSize: 20),

                  ),
                ),
                DataColumn(
                  label: Text(
                    '',
                    style: TextStyle(
                        fontStyle: FontStyle.italic, fontSize: 20),

                  ),
                ),


              ],
              rows: <DataRow>[

                 DataRow(
                  cells: <DataCell>[
                    DataCell(
                        Checkbox(tristate: false ,value: checkboxClickedIsTrue[index], activeColor: Colors.blue, onChanged: (value){
                          toggleCheckbox(value);
                        })),

                    DataCell(
                        Text("$firstName $lastName  $email                            ", style: TextStyle(fontSize: 17))),
                  ],
                ),
              ],
            );
          });
    } else {
      return Center(
          child: Text(
            "No scouts or parents available for this action",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 30.0),
          ));
    }
  }

  updateSignedUpList(EventModel currentEvent, int fromSeqNum) async {
    await _database.reference().child("EventSignUp").once().then((DataSnapshot snapshot){
      Map<dynamic, dynamic> values = snapshot.value;
      _listOfSignedUpPeople.length = 0;
      if(values != null) {
        values.forEach((key, values) {
          bool newConfirm = values["confirmed"];
          if((currentEvent.key == values["eventKey"])&&(values["sequenceNum"] > fromSeqNum))
          {
            if((values["sequenceNum"]-1) == fromSeqNum) newConfirm = true;
            EventSignUp updateSignUp = new EventSignUp(values["userId"], values["eventKey"], currentEvent.hours, currentEvent.nights, (values["sequenceNum"]-1), newConfirm, values["completed"]);
            _database.reference().child("EventSignUp").child(key).set(updateSignUp.toJson());
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {

    return new Scaffold(
      appBar: new AppBar(
        title: new Text('Select Members'),
        actions: <Widget>[
          SizedBox(height: 5, width: 1,), RaisedButton(
            onPressed: () {
              for (int i=0; i<_validIndex.length;i++)
                {
                  if((checkboxClickedIsTrue[i] == true)&&(userId!=(membersList[_validIndex[i]].userId)))
                    {
                      if(activeOrInactive == "Active") {
                        membersList[_validIndex[i]].active = false;
                      }
                      else
                        {
                          membersList[_validIndex[i]].active = true;
                        }
                      _database.reference().child("members").child(membersList[_validIndex[i]].key).set(membersList[_validIndex[i]].toJson());
                      if(membersList[_validIndex[i]].active == false){
                        // For any incomplete events: Remove from driver list and registered list (+ move everyone else up)
                        // For all event: make scoutmaster the eventCoordinator where this person is doing that
                        for(int eventIndex=0;eventIndex < listOfEvents.length;eventIndex++)
                          {
                            if(membersList[_validIndex[i]].email == listOfEvents[eventIndex].eventCoordinator)
                              {
                                listOfEvents[eventIndex].eventCoordinator = emailOfScoutmaster;
                                _database.reference().child("EventModel").child(listOfEvents[eventIndex].key).set(listOfEvents[eventIndex].toJson());
                              }

                              if(!listOfEvents[eventIndex].completed)
                              {
                                for(int j=0; j<eventSignUpList.length;j++)
                                  {
                                    if((eventSignUpList[j].userId == membersList[_validIndex[i]].userId)&&(eventSignUpList[j].eventKey == listOfEvents[eventIndex].key))
                                      {
                                        updateSignedUpList(listOfEvents[eventIndex], eventSignUpList[j].sequenceNum);
                                        _database.reference().child("EventSignUp").child(eventSignUpList[j].key).remove();
                                      }
                                  }
                                for(int j=0; j<listOfDrivers.length;j++)
                                {
                                  if((listOfDrivers[j].userId == membersList[_validIndex[i]].userId)&&(listOfDrivers[j].eventKey == listOfEvents[eventIndex].key))
                                  {
                                    _database.reference().child("Drivers").child(listOfDrivers[j].key).remove();
                                  }
                                }
                              }
                          }
                      }
                    }
                }
              Navigator.pop(context);
            },
            textColor: Colors.white,
            color: Colors.blue,

            child: (activeOrInactive == "Active")? Text('De-activate', style: TextStyle(fontSize: 15)):Text('Activate', style: TextStyle(fontSize: 15)),),

        ],
      ),
      body: showMembersList(),


    );
  }
}
