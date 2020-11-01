import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_login_demo/models/eventsignup.dart';
import 'package:flutter_login_demo/models/EventModel.dart';
import 'package:intl/intl.dart';


import 'dart:async';

String troopFromDatabase;
bool isScoutFromDatabase;
String troop;
String rank;
String meritBadges;
String currentMeritBadges;
List<EventSignUp> mySignedUpEvents = [];
List<EventModel> myEvents = [];
List<String> entriesToOutput = [];
int totalCampingNights = 0;

String council;

class MyCampingNightsPage extends StatefulWidget {
  MyCampingNightsPage({this.userId, this.listOfEvents})
      : super();

  final String userId;
  final List<EventModel> listOfEvents;


  @override
  State<StatefulWidget> createState() => new _MyCampingNightsPageState(userId: userId, listOfEvents: listOfEvents);
}

class _MyCampingNightsPageState extends State<MyCampingNightsPage> {
  _MyCampingNightsPageState({this.userId, this.listOfEvents });

  final String userId;
  final List<EventModel> listOfEvents;
  StreamSubscription<Event> _onPersonSignedUpAddedSubscription;
  StreamSubscription<Event> _onPersonSignedUpChangedSubscription;
  Query onSignedUpQuery;

  final FirebaseDatabase _database = FirebaseDatabase.instance;

  @override
  void initState() {
    super.initState();
    entriesToOutput.length = 0;
    mySignedUpEvents.length = 0;
    totalCampingNights = 0;

    entriesToOutput.add("Total Camping Nights: 0");

    onSignedUpQuery = _database
        .reference().child("EventSignUp")
        .orderByChild("userId").equalTo(userId);
    _onPersonSignedUpAddedSubscription =  onSignedUpQuery.onChildAdded.listen(onPersonEntryAdded);
    _onPersonSignedUpChangedSubscription = onSignedUpQuery.onChildChanged.listen(onPersonEntryChanged);
  }

  onPersonEntryChanged(Event event) {
    var oldEntry = mySignedUpEvents.singleWhere((entry) {
      return entry.key == event.snapshot.key;
    });

    setState(() {
      if(userId == EventSignUp.fromSnapshot(event.snapshot).userId)
        mySignedUpEvents[mySignedUpEvents.indexOf(oldEntry)] = EventSignUp.fromSnapshot(event.snapshot);
    });
  }

  onPersonEntryAdded(Event event) {
    setState(() {
      Map<dynamic, dynamic> values = event.snapshot.value;
      if (userId == values["userId"]) {
         mySignedUpEvents.add(EventSignUp(values["userId"], values["eventKey"], values["hours"], values["nights"],values["sequenceNum"], values["confirmed"], values["completed"]));
      }
    });

  }

  getCompletedEventsInfo() {
    entriesToOutput.length=0;
    entriesToOutput.add("Total Camping Nights: 0");
    for(int i=0;i < mySignedUpEvents.length; i++)
      {
        for(int j=0;j<listOfEvents.length;j++)
          if (listOfEvents[j].key == mySignedUpEvents[i].eventKey && userId==mySignedUpEvents[i].userId)
          {
            if(mySignedUpEvents[i].completed && mySignedUpEvents[i].confirmed && (mySignedUpEvents[i].nights > 0))
            {
              int nights = mySignedUpEvents[i].nights;
              entriesToOutput.add(DateFormat('yyyy-MM-dd').format(DateTime.fromMillisecondsSinceEpoch(listOfEvents[j].startDate)) + " " +
                  listOfEvents[j].typeOfEvent + "\n" + listOfEvents[j].title + "\nNights: " + nights.toString());
              totalCampingNights += nights;
            }
          }
      }
    entriesToOutput[0] = ("Total Camping Nights: "+totalCampingNights.toString());
  }

  @override
  void dispose() {
    _onPersonSignedUpAddedSubscription.cancel();
    _onPersonSignedUpChangedSubscription.cancel();
    super.dispose();
  }

  Widget goToCampingNights() {
    getCompletedEventsInfo();

    if (entriesToOutput.length > 0) {

    return ListView.builder(
        shrinkWrap: true,
        itemCount: entriesToOutput.length,
        itemBuilder: (BuildContext context, int index) {
            return DataTable (
              headingRowHeight: 20,
              dataRowHeight: 75,
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
                            child: (index == 0)? Text(entriesToOutput[index], style: TextStyle(fontStyle: FontStyle.italic, fontWeight: FontWeight.bold, fontSize: 17))
                                :Text(entriesToOutput[index], style: TextStyle(fontSize: 17))
                        )),
                  ],
                ),
              ],
            );
        }
    );

    } else {
      return Center(
          child: Text(
            "You currently don't have any camping nights",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 30.0),
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
          title: new Text('myCampingNights'),
      ),
      body: goToCampingNights(),

    );
  }
}