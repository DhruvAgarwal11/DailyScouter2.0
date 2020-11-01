import 'package:flutter/material.dart';
import 'package:flutter_login_demo/services/authentication.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_login_demo/models/members.dart';
import 'package:flutter_login_demo/models/Merit_Badges_Earned.dart';
import 'package:flutter_login_demo/models/meritbadges.dart';
import 'package:flutter_login_demo/pages/main_menu.dart';
import 'package:flutter_login_demo/pages/signup_event.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_login_demo/models/eventsignup.dart';
import 'package:flutter_login_demo/models/EventModel.dart';
import 'package:flutter_login_demo/models/drivers.dart';



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
String userIDOfSelected;
String firstName;
String lastName;
bool shouldShowTable = false;
bool showSuccessfulDialog = false;
String ScoutorParent;
String councilFromDatabase;
List<bool> listOfIsEagle = new List();
bool initMeritBadgesList=false;
bool initAlreadyEarnedMeritBadgesList=false;

bool Eagle;


String troopFromDatabase;
bool isScoutFromDatabase;
String troop;
String rank;
String meritBadges;
String currentMeritBadges;


String council;
int theRealIndex;
bool onlyDoOnce = true;
int sum = 0;
List<int> validIndex = new List();
var checkboxClickedIsTrue = new List (2000);
List<TextEditingController> lastNameController = new List(2000);
List<TextEditingController> firstNameController = new List(2000);



class MyEventsPage extends StatefulWidget {
  MyEventsPage({Key key, this.auth, this.userId, this.logoutCallback, this.membersList, this.meritBadgesList, this.meritBadgesEarnedList, this.listOfEvents})
      : super(key: key);

  final BaseAuth auth;
  final VoidCallback logoutCallback;
  final String userId;
  final List<Members> membersList;
  final List<MeritBadges> meritBadgesList;
  final List<Merit_Badges_Earned> meritBadgesEarnedList;
  final List<EventModel> listOfEvents;

  @override
  State<StatefulWidget> createState() => new _MyEventsPageState(userId: userId,
      auth: auth,
      logoutCallback: logoutCallback, membersList: membersList, meritBadgesList: meritBadgesList, meritBadgesEarnedList: meritBadgesEarnedList, listOfEvents: listOfEvents);
}

class _MyEventsPageState extends State<MyEventsPage> {
  _MyEventsPageState({this.auth, this.userId, this.logoutCallback, this.membersList, this.meritBadgesList, this.meritBadgesEarnedList, this.listOfEvents });

  final BaseAuth auth;
  final VoidCallback logoutCallback;
  final String userId;
  final List<Members> membersList;
  final List<MeritBadges> meritBadgesList;
  final List<Merit_Badges_Earned> meritBadgesEarnedList;
  final List<EventModel> listOfEvents;

  List<EventSignUp> _listOfSignedUpEvents = [];
  List <EventSignUp> _listOfIncomplete = [];
  List <EventSignUp> _listOfComplete = [];
  List<Drivers> _listOfDrivers = [];

  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final databaseReference = FirebaseDatabase.instance.reference();
  String _date = "Not set";
  String _time = "Not set";
  StreamSubscription<Event> _onPersonSignedUpAddedSubscription;
  StreamSubscription<Event> _onPersonSignedUpChangedSubscription;
  StreamSubscription<Event> _onDriverAddedSubscription;
  StreamSubscription<Event> _onDriverChangedSubscription;
  Query onSignedUpQuery;
  Query onDriverQuery;



  @override
  void initState() {
    super.initState();
    _listOfDrivers.length=0;

    onSignedUpQuery = _database
        .reference()
        .child("EventSignUp");
    _onPersonSignedUpAddedSubscription =  onSignedUpQuery.onChildAdded.listen(onPersonEntryAdded);
    _onPersonSignedUpChangedSubscription = onSignedUpQuery.onChildChanged.listen(onPersonEntryChanged);
    onDriverQuery = _database
        .reference()
        .child("Drivers");
    _onDriverAddedSubscription =  onDriverQuery.onChildAdded.listen(onDriverAdded);
    _onDriverChangedSubscription = onDriverQuery.onChildChanged.listen(onDriverChanged);

    initMeritBadgesList = true;
  }

  onPersonEntryChanged(Event event) {
    var oldEntry = _listOfSignedUpEvents.singleWhere((entry) {
      return entry.key == event.snapshot.key;
    });
    var oldEntry3;
    var oldEntry2;
    if (!EventSignUp.fromSnapshot((event.snapshot)).completed) {
       oldEntry3 = _listOfSignedUpEvents.singleWhere((entry) {
        return entry.key == event.snapshot.key;
      });
    }
    if (EventSignUp.fromSnapshot((event.snapshot)).completed) {
      oldEntry2 = _listOfSignedUpEvents.singleWhere((entry) {
        return entry.key == event.snapshot.key;
      });
    }
      setState(() {
      if(userId == EventSignUp.fromSnapshot(event.snapshot).userId) {
        _listOfSignedUpEvents[_listOfSignedUpEvents.indexOf(oldEntry)] = EventSignUp.fromSnapshot(event.snapshot);
        if (!EventSignUp.fromSnapshot((event.snapshot)).completed) {
          _listOfIncomplete[_listOfIncomplete.indexOf(oldEntry3)] = EventSignUp.fromSnapshot(event.snapshot);
        }
        else {
          _listOfComplete[_listOfComplete.indexOf(oldEntry2)] = EventSignUp.fromSnapshot(event.snapshot);
        }
      }
    }
    );
  }

  onDriverAdded(Event event) {
    setState(() {
      Map<dynamic, dynamic> values = event.snapshot.value;
      if (userId == values["userId"]) {
        for (int i = 0; i<listOfEvents.length; i++){
          if ((listOfEvents[i].key == values["eventKey"]) && !listOfEvents[i].completed){
            _listOfDrivers.add(Drivers(values["userId"], values["eventKey"], values["seatsAvailable"]));

          }
        }
      }
    });
  }

  onDriverChanged(Event event) {
    var oldEntry = _listOfDrivers.singleWhere((entry) {
      return entry.key == event.snapshot.key;
    });

    setState(() {
      if(userId == Drivers.fromSnapshot(event.snapshot).userId)
        _listOfDrivers[_listOfDrivers.indexOf(oldEntry)] = Drivers.fromSnapshot(event.snapshot);
    });
  }

  onPersonEntryAdded(Event event) {
    setState(() {
      Map<dynamic, dynamic> values = event.snapshot.value;
      if (userId == values["userId"]) {
        _listOfSignedUpEvents.add(EventSignUp(values["userId"], values["eventKey"], values["hours"], values["nights"],values["sequenceNum"], values["confirmed"], values["completed"]));
          if (values["completed"]){
            _listOfComplete.add(EventSignUp(values["userId"], values["eventKey"], values["hours"], values["nights"],values["sequenceNum"], values["confirmed"], values["completed"]));
          }
        if (!values["completed"]){
          _listOfIncomplete.add(EventSignUp(values["userId"], values["eventKey"], values["hours"], values["nights"],values["sequenceNum"], values["confirmed"], values["completed"]));
        }
      }
    });
  }


  @override
  void dispose() {
    super.dispose();
    _onDriverAddedSubscription.cancel();
    _onDriverChangedSubscription.cancel();
    _onPersonSignedUpAddedSubscription.cancel();

    _onPersonSignedUpChangedSubscription.cancel();
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

  Widget goToEvent() {
    List<String> listToDisplay = [];
    List<int> listOfIndices = [];
    String confirmedToString;

    if(_listOfDrivers.length > 0) {
      listToDisplay.add("Registered as Driver:");
      listOfIndices.add(-1);
    }
    for(int i=0;i<_listOfDrivers.length;i++)
      {
        for(int x = 0; x<listOfEvents.length; x++) {
          if (listOfEvents[x].key == _listOfDrivers[i].eventKey) {
            String date = (DateTime.fromMillisecondsSinceEpoch(listOfEvents[x].startDate).month.toString() + "/" +
                DateTime.fromMillisecondsSinceEpoch(listOfEvents[x].startDate).day.toString() + "/" +
                DateTime.fromMillisecondsSinceEpoch(listOfEvents[x].startDate).year.toString() + " " +
                DateTime.fromMillisecondsSinceEpoch(listOfEvents[x].startDate).hour.toString() + ":" +
                DateTime.fromMillisecondsSinceEpoch(listOfEvents[x].startDate).minute.toString());
            listToDisplay.add(date + "    " + listOfEvents[x].title + "\nDriver [Seats: " + _listOfDrivers[i].seatsAvailable.toString() +
                "]    " + listOfEvents[x].typeOfEvent);
            listOfIndices.add(x);
          }
        }
      }

    // Find list of all upcoming events
    bool found_first = false;
    for(int i=0;i<_listOfSignedUpEvents.length;i++)
    {
      if(!(_listOfSignedUpEvents[i].completed))
      {
        if(found_first == false)
          {
            found_first = true;
            listToDisplay.add("Non-completed Events:");
            listOfIndices.add(-1);
          }
        if(_listOfSignedUpEvents[i].confirmed) {
          confirmedToString = "Confirmed";
        }
        else{
          confirmedToString = "Waitlisted";
        }

        for(int x = 0; x<listOfEvents.length; x++) {
          if (listOfEvents[x].key == _listOfSignedUpEvents[i].eventKey) {
            String date = (DateTime.fromMillisecondsSinceEpoch(listOfEvents[x].startDate).month.toString() + "/" +
                DateTime.fromMillisecondsSinceEpoch(listOfEvents[x].startDate).day.toString() + "/" +
                DateTime.fromMillisecondsSinceEpoch(listOfEvents[x].startDate).year.toString() + " " +
                DateTime.fromMillisecondsSinceEpoch(listOfEvents[x].startDate).hour.toString() + ":" +
                DateTime.fromMillisecondsSinceEpoch(listOfEvents[x].startDate).minute.toString());
            //dateToSend = DateTime.fromMillisecondsSinceEpoch(listOfEvents[x].startDate);
            listToDisplay.add(date.toString() + "    " + listOfEvents[x].title.toString() + "\n" +
                confirmedToString.toString() + "    " +
                listOfEvents[x].typeOfEvent.toString());
            listOfIndices.add(x);
            //currentEvent = listOfEvents[x];
          }
        }
      }
    }

    found_first = false;

    // Find list of all completed events
    for(int i=0;i<_listOfSignedUpEvents.length;i++)
    {
      if(_listOfSignedUpEvents[i].completed)
      {
        if(found_first == false)
        {
          found_first = true;
          listToDisplay.add("Completed Events:");
          listOfIndices.add(-1);
        }
        if(_listOfSignedUpEvents[i].confirmed) {
          confirmedToString = "Confirmed";
        }
        else{
          confirmedToString = "Waitlisted";
        }

        for(int x = 0; x<listOfEvents.length; x++) {
          if (listOfEvents[x].key == _listOfSignedUpEvents[i].eventKey) {
            String date = (DateTime.fromMillisecondsSinceEpoch(listOfEvents[x].startDate).month.toString() + "/" +
                DateTime.fromMillisecondsSinceEpoch(listOfEvents[x].startDate).day.toString() + "/" +
                DateTime.fromMillisecondsSinceEpoch(listOfEvents[x].startDate).year.toString() + " " +
                DateTime.fromMillisecondsSinceEpoch(listOfEvents[x].startDate).hour.toString() + ":" +
                DateTime.fromMillisecondsSinceEpoch(listOfEvents[x].startDate).minute.toString());
            listToDisplay.add(date.toString() + "    " + listOfEvents[x].title.toString() + "\n" +
                confirmedToString.toString() + "    " +
                listOfEvents[x].typeOfEvent.toString());
            listOfIndices.add(x);
          }
        }
      }
    }

    if (listToDisplay.length > 0) {
      return ListView.builder(
        shrinkWrap: true,
        itemCount: listToDisplay.length,
        itemBuilder: (BuildContext context, int index) {
            return DataTable (
              dataRowHeight: 80,
              headingRowHeight: 20,
              columnSpacing:0,
              columns: <DataColumn>[
                DataColumn(

                  label: Text(
                    '     ',
                    style: TextStyle(
                        fontStyle: FontStyle.italic, fontSize: 50, ),
                  ),

                ),
                DataColumn(
                  numeric: true,

                  label: Text(
                    '     ',
                    style: TextStyle(
                      fontStyle: FontStyle.italic, fontSize: 50, ),
                  ),

                ),


              ],
              rows: <DataRow>[

                DataRow(

                  cells: <DataCell>[

                    DataCell(
                        Container(child: ((listToDisplay[index]=="Non-completed Events:")||(listToDisplay[index]=="Completed Events:")||(listToDisplay[index]=="Registered as Driver:"))?Text(listToDisplay[index], style: TextStyle(fontStyle: FontStyle.italic, fontWeight: FontWeight.bold, color: Colors.blue, fontSize: 17)):Text(listToDisplay[index], style: TextStyle(fontStyle: FontStyle.italic, fontSize: 17)))),
                    if (listOfIndices[index] != -1) DataCell(
                        Container(
                            child: IconButton(
                              icon: new Icon(Icons.chevron_right),
                              onPressed: (){
                                for (int i = 0; i<membersList.length; i++){
                                  if (userId==membersList[i].userId){
                                    troop = membersList[i].troop;
                                    council = membersList[i].council;
                                  }
                                }
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) => SignupEventPage( //EventDetailsPage(
                                          userId: userId, membersList: membersList, troop: troop, council: council, currentEvent: listOfEvents[listOfIndices[index]], initialDate: DateTime.fromMillisecondsSinceEpoch(
                                            listOfEvents[listOfIndices[index]].startDate), pageCameFrom: "myEventsPage"
                                          //event: event,
                                        )));
                              },
                            )
                        )),
                    if (listOfIndices[index] == -1) DataCell(
                       Container())
                  ],
                ),
              ],
            );
        }
    );

    } else {
      return Center(
          child: Text(
            "You are not signed up for any event! Get active :-)",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 30.0),
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
          title: new Text('myEvents'),
      ),
      body: goToEvent(),

    );
  }
}