import 'package:flutter/material.dart';
import 'package:flutter_login_demo/services/authentication.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_login_demo/models/members.dart';
import 'package:flutter_login_demo/models/eventsignup.dart';
import 'package:flutter_login_demo/models/EventModel.dart';
import 'package:flutter_login_demo/pages/main_menu.dart';
import 'package:flutter_login_demo/pages/profile_edit.dart';
import 'package:flutter_login_demo/pages/leadership_setup.dart';
import 'package:flutter_login_demo/pages/home_page.dart';
import 'dart:async';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

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
String councilFromDatabase;
String troopFromDatabase;
bool isScoutFromDatabase;
String troopOfScoutmaster;
String councilOfScoutmaster;
int theRealIndex;
bool onlyDoOnce = true;
int sum = 0;
int oldValidLength=0;
var checkboxClickedIsTrue = new List (2000);
List<String> listOfDisplay = [];



//List<Members> _membersList;

class ShowAttendancePage extends StatefulWidget {
  ShowAttendancePage({Key key, this.auth, this.userId, this.membersList, this.firstLastEmail, this.listOfEvents})
      : super(key: key);

  final BaseAuth auth;
  final String userId;
  final List<Members> membersList;
  final String firstLastEmail;
  final List<EventModel> listOfEvents;


  @override
  State<StatefulWidget> createState() => new _ShowAttendancePageState(userId: userId,
      auth: auth,
       membersList: membersList, firstLastEmail: firstLastEmail, listOfEvents: listOfEvents);
}

class _ShowAttendancePageState extends State<ShowAttendancePage> {
  _ShowAttendancePageState({this.auth, this.userId, this.membersList, this.firstLastEmail, this.listOfEvents});

  final BaseAuth auth;
  final String userId;
  final List<Members> membersList;
  final String firstLastEmail;
  final List<EventModel> listOfEvents;


  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final databaseReference = FirebaseDatabase.instance.reference();

  Query onEventSignUpQuery;
  StreamSubscription<Event> _onEventSignUpAddedSubscription;


  @override
  void initState() {
    super.initState();

    listOfDisplay.length = 0;

    onEventSignUpQuery = _database
        .reference()
        .child("EventSignUp");
    _onEventSignUpAddedSubscription =  onEventSignUpQuery.onChildAdded.listen(onEventSignUpAdded);
  }



  onEventSignUpAdded(Event event) {
    setState(() {
      Map<dynamic, dynamic> values = event.snapshot.value;
      String troop, council;
      bool personFound = false;
      String userIdOfFoundPerson;

      for (int i = 0; i < membersList.length; i++){
        if ((membersList[i].firstName + " " + membersList[i].lastName + "  " + membersList[i].email)==firstLastEmail ){
          userIdOfFoundPerson = membersList[i].userId;
        }
      }

      if (userIdOfFoundPerson!=null){
        if (userIdOfFoundPerson == EventSignUp.fromSnapshot(event.snapshot).userId){
          for (int a = 0; a < listOfEvents.length; a++){
            if ((listOfEvents[a].key == EventSignUp.fromSnapshot(event.snapshot).eventKey) && ((listOfEvents[a].typeOfEvent == "PLC")||(listOfEvents[a].typeOfEvent == "Troop Meeting")||(listOfEvents[a].typeOfEvent == "Patrol Meeting")) && ((DateTime.now().millisecondsSinceEpoch - listOfEvents[a].startDate)) < 31622400000 ){
              bool duplicateEntry = false;
              for (int b = 0; b<listOfDisplay.length; b++){
                if (listOfDisplay[b]==(DateTime.fromMillisecondsSinceEpoch(listOfEvents[a].startDate).month.toString() + "/" + DateTime.fromMillisecondsSinceEpoch(listOfEvents[a].startDate).day.toString() + "/" + DateTime.fromMillisecondsSinceEpoch(listOfEvents[a].startDate).year.toString()+ " "+ listOfEvents[a].title))
                      {
                        duplicateEntry = true;
                        break;
                      }
                }
                if (!duplicateEntry) listOfDisplay.add(DateTime.fromMillisecondsSinceEpoch(listOfEvents[a].startDate).month.toString() + "/" + DateTime.fromMillisecondsSinceEpoch(listOfEvents[a].startDate).day.toString() + "/" + DateTime.fromMillisecondsSinceEpoch(listOfEvents[a].startDate).year.toString()+ " "+ listOfEvents[a].title);
              }
            }
          }
        }
      }
    );
  }

  @override
  void dispose() {
    _onEventSignUpAddedSubscription.cancel();
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

    if (listOfDisplay.length > 0) {
      return ListView.builder(
          shrinkWrap: true,
          itemCount: listOfDisplay.length,
          itemBuilder: (BuildContext context, int index) {

      return DataTable (
        dataRowHeight: 70,
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
        ],
        rows: <DataRow>[

          DataRow(
            cells: <DataCell>[
              DataCell(
                Container(
                  width: 100,
                  child: Text(listOfDisplay[index], style: TextStyle(fontStyle: FontStyle.italic, fontSize: 17)))),

            ],
          ),

        ],
      );
              }
      );
          }
    else {
      return Center(
          child: Text(
            "No attendance record for this Scout",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 30.0),
          ));
      }
    }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('Last 12-Month Attendance'),

      ),
      body: showMembersList(),

    );
  }
}

showAlertDialog(BuildContext context, String displayString) {
  // set up the button
  Widget okButton = FlatButton(
    child: Text("OK"),
    onPressed: () {Navigator.of(context).pop(); },
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
