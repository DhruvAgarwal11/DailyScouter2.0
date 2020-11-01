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


import 'dart:async';



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



class AllEventsPage extends StatefulWidget {
  AllEventsPage({Key key, this.auth, this.userId, this.logoutCallback, this.membersList, this.meritBadgesList, this.meritBadgesEarnedList, this.listOfEvents})
      : super(key: key);

  final BaseAuth auth;
  final VoidCallback logoutCallback;
  final String userId;
  final List<Members> membersList;
  final List<MeritBadges> meritBadgesList;
  final List<Merit_Badges_Earned> meritBadgesEarnedList;
  final List<EventModel> listOfEvents;

  @override
  State<StatefulWidget> createState() => new _AllEventsPageState(userId: userId,
      auth: auth,
      logoutCallback: logoutCallback, membersList: membersList, meritBadgesList: meritBadgesList, meritBadgesEarnedList: meritBadgesEarnedList, listOfEvents: listOfEvents);
}

class _AllEventsPageState extends State<AllEventsPage> {
  _AllEventsPageState({this.auth, this.userId, this.logoutCallback, this.membersList, this.meritBadgesList, this.meritBadgesEarnedList, this.listOfEvents });

  final BaseAuth auth;
  final VoidCallback logoutCallback;
  final String userId;
  final List<Members> membersList;
  final List<MeritBadges> meritBadgesList;
  final List<Merit_Badges_Earned> meritBadgesEarnedList;
  final List<EventModel> listOfEvents;

  List<EventSignUp> _listOfSignedUpEvents = [];
  List<EventModel> _listOfGoodEvents = [];


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

    for (int i = 0; i<membersList.length; i++){
      if (userId==membersList[i].userId){
        troop = membersList[i].troop;
        council = membersList[i].council;

      }
    }
    _listOfGoodEvents.length = 0;

    for (int l = 0; l<listOfEvents.length; l++){
      bool duplicateFlag = false;
      if ((listOfEvents[l].troop==troop) && (listOfEvents[l].council==council) && (DateTime.now().millisecondsSinceEpoch < listOfEvents[l].startDate)){
        for (int w = 0; w<_listOfGoodEvents.length; w++){
          if (_listOfGoodEvents[w].key==listOfEvents[l].key){
            duplicateFlag =true;
          }
        }
        if (!duplicateFlag){
          if((listOfEvents[l].typeOfEvent!="Troop Meeting") && (listOfEvents[l].typeOfEvent!="Patrol Meeting") && (listOfEvents[l].typeOfEvent!="PLC")) {
            _listOfGoodEvents.add(listOfEvents[l]);
          }
        }
      }
    }
    for (int l = 0; l<listOfEvents.length; l++){
      bool duplicateFlag = false;
      if (listOfEvents[l].troop==troop && listOfEvents[l].council==council && DateTime.now().millisecondsSinceEpoch<listOfEvents[l].startDate ){
        for (int w = 0; w<_listOfGoodEvents.length; w++){
          if (_listOfGoodEvents[w].key==listOfEvents[l].key){
            duplicateFlag =true;
          }
        }
        if (!duplicateFlag){
          if((listOfEvents[l].typeOfEvent=="Troop Meeting") || (listOfEvents[l].typeOfEvent=="Patrol Meeting") || (listOfEvents[l].typeOfEvent=="PLC")) {
            _listOfGoodEvents.add(listOfEvents[l]);
          }
        }
      }
    }




    if (_listOfGoodEvents.length > 0) {


    return ListView.builder(
        shrinkWrap: true,
        itemCount: _listOfGoodEvents.length,
        itemBuilder: (BuildContext context, int index) {
          String eventInfo;
          DateTime dateToSend;

          EventModel currentEvent;

              String date= (DateTime.fromMillisecondsSinceEpoch(_listOfGoodEvents[index].startDate).month.toString() + "/" + DateTime.fromMillisecondsSinceEpoch(_listOfGoodEvents[index].startDate).day.toString()+"/"+DateTime.fromMillisecondsSinceEpoch(_listOfGoodEvents[index].startDate).year.toString() + " " + DateTime.fromMillisecondsSinceEpoch(_listOfGoodEvents[index].startDate).hour.toString() + ":"+ DateTime.fromMillisecondsSinceEpoch(_listOfGoodEvents[index].startDate).minute.toString());
              dateToSend=  DateTime.fromMillisecondsSinceEpoch(_listOfGoodEvents[index].startDate);
              eventInfo = (date + "    " + _listOfGoodEvents[index].title + "\n"  + _listOfGoodEvents[index].typeOfEvent );
                currentEvent = _listOfGoodEvents[index];

            return DataTable (
              headingRowHeight: 20,
              dataRowHeight: 70,
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

                            child: Text(eventInfo, style: TextStyle(fontStyle: FontStyle.italic, fontSize: 17)))),
                    DataCell(
                        Container(

                            child: IconButton(
                              icon: new Icon(Icons.chevron_right),
                              onPressed: (){
                                _listOfGoodEvents.length=0;
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) => SignupEventPage( //EventDetailsPage(
                                          userId: userId, membersList: membersList, troop: troop, council: council, currentEvent: currentEvent, initialDate: dateToSend, pageCameFrom: "myEventsPage"
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

    } else {
      return Center(
          child: Text(
            "There are currently no upcoming events.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 30.0),
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
          title: new Text('Upcoming Events'),
      ),
      body: goToEvent(),

    );
  }
}