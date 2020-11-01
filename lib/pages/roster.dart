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

class RosterPage extends StatefulWidget {
  RosterPage({Key key, this.auth, this.userId, this.logoutCallback, this.membersList, this.meritBadgesList, this.meritBadgesEarnedList, this.listOfEvents})
      : super(key: key);

  final BaseAuth auth;
  final VoidCallback logoutCallback;
  final String userId;
  final List<Members> membersList;
  final List<MeritBadges> meritBadgesList;
  final List<Merit_Badges_Earned> meritBadgesEarnedList;
  final List<EventModel> listOfEvents;

  @override
  State<StatefulWidget> createState() => new _RosterPageState(userId: userId,
      auth: auth,
      logoutCallback: logoutCallback, membersList: membersList, meritBadgesList: meritBadgesList, meritBadgesEarnedList: meritBadgesEarnedList, listOfEvents: listOfEvents);
}

class _RosterPageState extends State<RosterPage> {
  _RosterPageState({this.auth, this.userId, this.logoutCallback, this.membersList, this.meritBadgesList, this.meritBadgesEarnedList, this.listOfEvents });

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
    List<Members> membersOfTroop = [];
    for (int n = 0; n<membersList.length;n++){
      if (membersList[n].userId==userId ){
        troop = membersList[n].troop;
        council = membersList[n].council;
      }
    }
    for (int n = 0; n<membersList.length;n++){
      if (membersList[n].troop==troop && membersList[n].council==council && membersList[n].isScout && membersList[n].leadershipPosition=="SPL" && membersList[n].troopApproved && membersList[n].active){
        membersOfTroop.add(membersList[n]);
      }
    }
    for (int n = 0; n<membersList.length;n++){
      if (membersList[n].troop==troop && membersList[n].council==council && membersList[n].isScout && membersList[n].isAdmin && membersList[n].leadershipPosition!="SPL"&& membersList[n].troopApproved && membersList[n].active){
        membersOfTroop.add(membersList[n]);
      }
    }
    for (int n = 0; n<membersList.length;n++){
      if (membersList[n].troop==troop && membersList[n].council==council && membersList[n].isScout && !membersList[n].isAdmin && membersList[n].leadershipPosition!="SPL"&& membersList[n].troopApproved && membersList[n].active){
        membersOfTroop.add(membersList[n]);
      }
    }
    for (int n = 0; n<membersList.length;n++){
      if (membersList[n].troop==troop && membersList[n].council==council && !membersList[n].isScout && membersList[n].isScoutmaster&& membersList[n].troopApproved && membersList[n].active){
        membersOfTroop.add(membersList[n]);
      }
    }
    for (int n = 0; n<membersList.length;n++){
      if (membersList[n].troop==troop && membersList[n].council==council && !membersList[n].isScout && membersList[n].isAdmin && !membersList[n].isScoutmaster&& membersList[n].troopApproved && membersList[n].active){
        membersOfTroop.add(membersList[n]);
      }
    }
    for (int n = 0; n<membersList.length;n++){
      if (membersList[n].troop==troop && membersList[n].council==council && !membersList[n].isScout && !membersList[n].isAdmin && !membersList[n].isScoutmaster&& membersList[n].troopApproved && membersList[n].active){
        membersOfTroop.add(membersList[n]);
      }
    }




    if (membersOfTroop.length > 0) {


    return ListView.builder(
        shrinkWrap: true,
        itemCount: membersOfTroop.length,
        itemBuilder: (BuildContext context, int index) {

          String personInfo;
            if (membersOfTroop[index].rank=="None" && membersOfTroop[index].leadershipPosition!="None" && membersOfTroop[index].isScout){
              personInfo = (membersOfTroop[index].firstName + " "+membersOfTroop[index].lastName + "   " + "No Rank" + "\n"+membersOfTroop[index].leadershipPosition+"\n"+membersOfTroop[index].phoneNumber+"\n"+membersOfTroop[index].address+"\n"+membersOfTroop[index].email+"\n");
            } else if (membersOfTroop[index].leadershipPosition=="None" && membersOfTroop[index].rank!="None"&& membersOfTroop[index].isScout){
            personInfo = (membersOfTroop[index].firstName + " "+membersOfTroop[index].lastName + "   " + membersOfTroop[index].rank + "\n"+"Troop Member"+"\n"+membersOfTroop[index].phoneNumber+"\n"+membersOfTroop[index].address+"\n"+membersOfTroop[index].email+"\n");
          } else if (membersOfTroop[index].leadershipPosition=="None" && membersOfTroop[index].rank=="None"&& membersOfTroop[index].isScout){
            personInfo = (membersOfTroop[index].firstName + " "+membersOfTroop[index].lastName + "   " + "No Rank"+ "\n"+"Troop Member"+"\n"+membersOfTroop[index].phoneNumber+"\n"+membersOfTroop[index].address+"\n"+membersOfTroop[index].email+"\n");
          } else if (membersOfTroop[index].isScoutmaster){
              personInfo = (membersOfTroop[index].firstName + " "+membersOfTroop[index].lastName +"\nScoutmaster\n"+membersOfTroop[index].phoneNumber+"\n"+membersOfTroop[index].address+"\n"+membersOfTroop[index].email);
            }else if (!membersOfTroop[index].isScout){
              personInfo = (membersOfTroop[index].firstName + " "+membersOfTroop[index].lastName +"\nParent\n"+membersOfTroop[index].phoneNumber+"\n"+membersOfTroop[index].address+"\n"+membersOfTroop[index].email);
            } else {
            personInfo = (membersOfTroop[index].firstName + " " + membersOfTroop[index].lastName + "   " + membersOfTroop[index].rank + "\n" + membersOfTroop[index].leadershipPosition + "\n" + membersOfTroop[index].phoneNumber + "\n" + membersOfTroop[index].address + "\n" + membersOfTroop[index].email + "\n");
          }

          if(true){

            return DataTable (
              dataRowHeight: 120,
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
                            child: Text(personInfo, style: TextStyle(fontStyle: FontStyle.italic, fontSize: 17)))),
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
            "There is currently no one in your troop.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 30.0),
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
          title: new Text('Roster'),
      ),
      body: goToEvent(),

    );
  }
}