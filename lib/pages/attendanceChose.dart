import 'package:flutter/material.dart';
import 'package:flutter_login_demo/services/authentication.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_login_demo/models/members.dart';
import 'package:flutter_login_demo/models/EventModel.dart';
import 'package:flutter_login_demo/models/eventsignup.dart';
import 'package:flutter_login_demo/pages/main_menu.dart';
import 'package:flutter_login_demo/pages/showAttendance.dart';


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
var checkboxClickedIsTrue = new List(2000);

class AttendanceChoosePage extends StatefulWidget {
  AttendanceChoosePage({Key key, this.auth, this.userId, this.logoutCallback, this.membersList, this.listOfEvents, this.eventSignUpList})
      : super(key: key);

  final BaseAuth auth;
  final VoidCallback logoutCallback;
  final String userId;
  final List<Members> membersList;
  final List<EventModel> listOfEvents;
  final List <EventSignUp> eventSignUpList;


  @override
  State<StatefulWidget> createState() => new _AttendanceChoosePageState(userId: userId,
      auth: auth,
      logoutCallback: logoutCallback, membersList: membersList, listOfEvents: listOfEvents, eventSignUpList: eventSignUpList);
}

class _AttendanceChoosePageState extends State<AttendanceChoosePage> {
  _AttendanceChoosePageState({this.auth, this.userId, this.logoutCallback, this.membersList, this.listOfEvents, this.eventSignUpList});

  final BaseAuth auth;
  final VoidCallback logoutCallback;
  final String userId;
  final List<EventModel> listOfEvents;
  final List<Members> membersList;
  final List <EventSignUp> eventSignUpList;
  String firstLastEmail;

  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final databaseReference = FirebaseDatabase.instance.reference();


  @override
  void initState() {
    super.initState();

    listOfDisplay.length = 0;
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
    for (int j = 0; j < membersList.length; j++) {
      if ((membersList[j].troop == troopOfScoutmaster) && (membersList[j].council == councilOfScoutmaster) &&
            (membersList[j].troopApproved==true) && membersList[j].isScout && membersList[j].active) {
            _validIndex.add(j);
      }}
    for (int i = oldValidLength; i < _validIndex.length; i++) {
        checkboxClickedIsTrue[i] = false;
      }
    oldValidLength=_validIndex.length;
    onlyDoOnce = false;
   // }

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
                setState(() {
                  checkboxClickedIsTrue[index] = true;
                });

              }
              else
              {
                setState(() {
                  checkboxClickedIsTrue[index] = false;
                });
              }
            }

            int numMeetings=findMyMeetingEvents("$firstName $lastName  $email");
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
                        Text("$firstName $lastName    Total #: $numMeetings $email                            ", style: TextStyle(fontSize: 17))),
                    DataCell(
                        IconButton(icon: new Icon(Icons.arrow_forward_ios), onPressed: () {
                          try {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => ShowAttendancePage(userId: userId,
                                   membersList: membersList, firstLastEmail:"$firstName $lastName  $email", listOfEvents: listOfEvents
                              )),
                            );
                          } catch (e) {
                            print(e);
                          }
                        },)),

                  ],
                ),


              ],
            );
          });
    } else {
      return Center(
          child: Text(
            "Welcome. No scouts available.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 30.0),
          ));
    }
  }


  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('Meeting Attendance (Last 12 Months)'),

      ),
      body: showMembersList(),


    );
  }

  int findMyMeetingEvents(String firstLastEmail) {
    int count = 0;

      String userIdOfFoundPerson;

      for (int i = 0; i < membersList.length; i++){
        if ((membersList[i].firstName + " " + membersList[i].lastName + "  " + membersList[i].email)==firstLastEmail ){
          userIdOfFoundPerson = membersList[i].userId;
        }
      }

      for(int i=0;i<eventSignUpList.length;i++) {
        if (eventSignUpList[i].userId == userIdOfFoundPerson) {
          for (int a = 0; a < listOfEvents.length; a++) {
            if ((listOfEvents[a].key == eventSignUpList[i].eventKey) &&
                ((listOfEvents[a].typeOfEvent == "PLC") ||
                    (listOfEvents[a].typeOfEvent == "Troop Meeting") ||
                    (listOfEvents[a].typeOfEvent == "Patrol Meeting")) &&
                ((DateTime
                    .now()
                    .millisecondsSinceEpoch - listOfEvents[a].startDate)) <
                    31622400000) {
              count++;
            }
          }
        }
      }
    return count;
  }
}