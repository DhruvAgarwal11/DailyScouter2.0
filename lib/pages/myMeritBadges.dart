import 'package:flutter/material.dart';
import 'package:flutter_login_demo/services/authentication.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_login_demo/models/members.dart';
import 'package:flutter_login_demo/models/Merit_Badges_Earned.dart';
import 'package:flutter_login_demo/models/meritbadges.dart';
import 'package:flutter_login_demo/pages/main_menu.dart';
import 'package:flutter_login_demo/pages/signup_event.dart';
import 'package:flutter_login_demo/models/eventsignup.dart';
import 'package:flutter_login_demo/models/EventModel.dart';


import 'dart:async';

String troopFromDatabase;
bool isScoutFromDatabase;
String troop;
String rank;
String meritBadges;
String currentMeritBadges;

String council;

class MyMeritBadgesPage extends StatefulWidget {
  MyMeritBadgesPage({Key key, this.auth, this.userId, this.logoutCallback, this.membersList, this.meritBadgesList, this.meritBadgesEarnedList, this.listOfEvents})
      : super(key: key);

  final BaseAuth auth;
  final VoidCallback logoutCallback;
  final String userId;
  final List<Members> membersList;
  final List<MeritBadges> meritBadgesList;
  final List<Merit_Badges_Earned> meritBadgesEarnedList;
  final List<EventModel> listOfEvents;

  @override
  State<StatefulWidget> createState() => new _MyMeritBadgesPageState(userId: userId,
      auth: auth,
      logoutCallback: logoutCallback, membersList: membersList, meritBadgesList: meritBadgesList, meritBadgesEarnedList: meritBadgesEarnedList, listOfEvents: listOfEvents);
}

class _MyMeritBadgesPageState extends State<MyMeritBadgesPage> {
  _MyMeritBadgesPageState({this.auth, this.userId, this.logoutCallback, this.membersList, this.meritBadgesList, this.meritBadgesEarnedList, this.listOfEvents });

  final BaseAuth auth;
  final VoidCallback logoutCallback;
  final String userId;
  final List<Members> membersList;
  final List<MeritBadges> meritBadgesList;
  final List<Merit_Badges_Earned> meritBadgesEarnedList;
  final List<EventModel> listOfEvents;

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
        _listOfSignedUpEvents.add(EventSignUp(values["userId"], values["eventKey"], values["hours"], values["nights"],values["sequenceNum"], values["confirmed"], values ["completed"]));
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
    List<Merit_Badges_Earned> myMeritBadgeEarnedList = [];
    for (int n = 0; n<meritBadgesEarnedList.length;n++){
      if (meritBadgesEarnedList[n].userId==userId && meritBadgesEarnedList[n].eagle==true){
        myMeritBadgeEarnedList.add(meritBadgesEarnedList[n]);

      }
    }
    for (int n = 0; n<meritBadgesEarnedList.length;n++){
      if (meritBadgesEarnedList[n].userId==userId && meritBadgesEarnedList[n].eagle==false){
        myMeritBadgeEarnedList.add(meritBadgesEarnedList[n]);
      }
    }




    if (myMeritBadgeEarnedList.length > 0) {


    return ListView.builder(
        shrinkWrap: true,
        itemCount: myMeritBadgeEarnedList.length,
        itemBuilder: (BuildContext context, int index) {
          String meritBadgeInfo;


          if (myMeritBadgeEarnedList[index].eagle) {
            meritBadgeInfo = (myMeritBadgeEarnedList[index].date_earned + "    " + myMeritBadgeEarnedList[index].meritBadge + "\nEagle Required");
          }
          else{
            meritBadgeInfo = (myMeritBadgeEarnedList[index].date_earned + "    " + myMeritBadgeEarnedList[index].meritBadge);
          }



          if(true){


            return DataTable (
              dataRowHeight: 70,
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



              ],
              rows: <DataRow>[

                DataRow(

                  cells: <DataCell>[

                    DataCell(

                        Container(

                            child: Text(meritBadgeInfo, style: TextStyle(fontStyle: FontStyle.italic, fontSize: 17)))),




 
                  ],
                ),


              
              ],
            );
          }
          else{
            return Container();
          }
        }
    );;

    } else {
      return Center(
          child: Text(
            "You currently don't have any merit badges.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 30.0),
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
          title: new Text('myMeritBadges'),
      ),
      body: goToEvent(),

    );
  }
}