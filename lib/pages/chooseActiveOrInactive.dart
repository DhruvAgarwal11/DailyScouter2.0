import 'package:flutter/material.dart';
import 'package:flutter_login_demo/services/authentication.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_login_demo/models/members.dart';
import 'package:flutter_login_demo/models/Merit_Badges_Earned.dart';
import 'package:flutter_login_demo/models/meritbadges.dart';
import 'package:flutter_login_demo/pages/main_menu.dart';
import 'package:flutter_login_demo/pages/signup_event.dart';
import 'package:flutter_login_demo/pages/selectWhichActiveInactive.dart';
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



class ChooseActiveOrInactivePage extends StatefulWidget {
  ChooseActiveOrInactivePage({Key key, this.auth, this.userId, this.logoutCallback, this.membersList, this.meritBadgesList, this.meritBadgesEarnedList, this.listOfEvents, this.listOfDrivers, this.eventSignUpList, this.emailOfScoutmaster})
      : super(key: key);

  final BaseAuth auth;
  final VoidCallback logoutCallback;
  final String userId;
  final List<Members> membersList;
  final List<MeritBadges> meritBadgesList;
  final List<Merit_Badges_Earned> meritBadgesEarnedList;
  final List<EventModel> listOfEvents;
  final List<Drivers> listOfDrivers;
  final List<EventSignUp> eventSignUpList;
  final String emailOfScoutmaster;


  @override
  State<StatefulWidget> createState() => new _ChooseActiveOrInactivePageState(userId: userId,
      auth: auth,
      logoutCallback: logoutCallback, membersList: membersList, meritBadgesList: meritBadgesList, meritBadgesEarnedList: meritBadgesEarnedList, listOfEvents: listOfEvents, listOfDrivers: listOfDrivers, eventSignUpList: eventSignUpList, emailOfScoutmaster: emailOfScoutmaster);
}

class _ChooseActiveOrInactivePageState extends State<ChooseActiveOrInactivePage> {
  _ChooseActiveOrInactivePageState({this.auth, this.userId, this.logoutCallback, this.membersList, this.meritBadgesList, this.meritBadgesEarnedList, this.listOfEvents, this.listOfDrivers, this.eventSignUpList, this.emailOfScoutmaster });

  final BaseAuth auth;
  final VoidCallback logoutCallback;
  final String userId;
  final List<Members> membersList;
  final List<MeritBadges> meritBadgesList;
  final List<Merit_Badges_Earned> meritBadgesEarnedList;
  final List<EventModel> listOfEvents;
  final List<Drivers> listOfDrivers;
  final List<EventSignUp> eventSignUpList;
  final String emailOfScoutmaster;

  List<EventSignUp> _listOfSignedUpEvents = [];


  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final databaseReference = FirebaseDatabase.instance.reference();
  StreamSubscription<Event> _onPersonSignedUpAddedSubscription;
  StreamSubscription<Event> _onPersonSignedUpChangedSubscription;
  Query onSignedUpQuery;


  @override
  void initState() {
    super.initState();
    onSignedUpQuery = _database
        .reference()
        .child("EventSignUp");
    _onPersonSignedUpAddedSubscription =  onSignedUpQuery.onChildAdded.listen(onPersonEntryAdded);
    _onPersonSignedUpChangedSubscription = onSignedUpQuery.onChildChanged.listen(onPersonEntryChanged);

    initMeritBadgesList = true;

    String tempDate=DateTime(1971,5,31).toString();
  }

  onPersonEntryChanged(Event event) {
    var oldEntry = _listOfSignedUpEvents.singleWhere((entry) {
      return entry.key == event.snapshot.key;
    });

    setState(() {
      if(userId == EventSignUp.fromSnapshot(event.snapshot).userId)
        _listOfSignedUpEvents[_listOfSignedUpEvents.indexOf(oldEntry)] = EventSignUp.fromSnapshot(event.snapshot);
    });
  }

  onPersonEntryAdded(Event event) {
    setState(() {
      Map<dynamic, dynamic> values = event.snapshot.value;
      if (userId == values["userId"]) {
        _listOfSignedUpEvents.add(EventSignUp(values["userId"], values["eventKey"], values["hours"], values["nights"],values["sequenceNum"], values["confirmed"], values["completed"]));
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
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

    validIndex.length = 0;

    if (true) {


    return ListView.builder(
        shrinkWrap: true,
        itemCount: 1,
        itemBuilder: (BuildContext context, int index) {

            return DataTable (
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

                        Container(

                            child: Text("De-activate", style: TextStyle(fontStyle: FontStyle.italic, fontSize: 17)))),
                    DataCell(
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
                                        builder: (_) => SelectWhichActiveInactivePage( //EventDetailsPage(
                                          userId: userId, membersList: membersList, troop: troop, council: council, activeOrInactive: "Active", listOfDrivers: listOfDrivers, listOfEvents: listOfEvents, eventSignUpList: eventSignUpList, emailOfScoutmaster: emailOfScoutmaster
                                        )));
                              },
                            )
                        )),
                  ],
                ),
                DataRow(

                  cells: <DataCell>[

                    DataCell(

                        Container(

                            child: Text("Activate", style: TextStyle(fontStyle: FontStyle.italic, fontSize: 17)))),
                    DataCell(
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
                                        builder: (_) => SelectWhichActiveInactivePage( //EventDetailsPage(
                                            userId: userId, membersList: membersList, troop: troop, council: council, activeOrInactive: "Inactive", listOfDrivers: listOfDrivers, listOfEvents: listOfEvents, eventSignUpList: eventSignUpList, emailOfScoutmaster: emailOfScoutmaster
                                          //event: event,
                                        )));
                              },
                            )
                        )),
                  ],
                ),
              ],
            );
        }
    );;

    }
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
          title: new Text('Activate or De-activate'),
      ),
      body: goToEvent(),

    );
  }
}