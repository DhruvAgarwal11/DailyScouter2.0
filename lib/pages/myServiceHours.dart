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
double totalServiceHours = 0;

String council;

class MyServiceHoursPage extends StatefulWidget {
  MyServiceHoursPage({this.userId, this.listOfEvents})
      : super();

  final String userId;
  final List<EventModel> listOfEvents;


  @override
  State<StatefulWidget> createState() => new _MyServiceHoursPageState(userId: userId, listOfEvents: listOfEvents);
}

class _MyServiceHoursPageState extends State<MyServiceHoursPage> {
  _MyServiceHoursPageState({this.userId, this.listOfEvents });

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
    totalServiceHours = 0;

    entriesToOutput.add("Total Service Hours: 0.0");

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
    for(int i=0;i < mySignedUpEvents.length; i++)
      {
        for(int j=0;j<listOfEvents.length;j++)
          if (listOfEvents[j].key == mySignedUpEvents[i].eventKey)
          {
            if (mySignedUpEvents[i].completed && mySignedUpEvents[i].confirmed && (mySignedUpEvents[i].hours > 0))
            {
              double hrs = double.parse(mySignedUpEvents[i].hours.toString());
              hrs = hrs / 10;
              entriesToOutput.add(DateFormat('yyyy-MM-dd').format(DateTime.fromMillisecondsSinceEpoch(listOfEvents[j].startDate)) + " " +
                  listOfEvents[j].typeOfEvent + "\n" + listOfEvents[j].title + "\nHours: " + hrs.toString());
              totalServiceHours += hrs;
            }
          }
      }
    entriesToOutput[0] = ("Total Service Hours: "+totalServiceHours.toString());
  }

  @override
  void dispose() {
    _onPersonSignedUpAddedSubscription.cancel();
    _onPersonSignedUpChangedSubscription.cancel();
    super.dispose();
  }

  Widget goToServiceHours() {
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
            "You currently don't have any service hours",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 30.0),
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
          title: new Text('myServiceHours'),
      ),
      body: goToServiceHours(),

    );
  }
}