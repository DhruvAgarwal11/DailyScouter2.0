import 'package:flutter/material.dart';
import 'package:flutter_login_demo/pages/view_event.dart';
import 'package:flutter_login_demo/pages/add_event.dart';
import 'package:flutter_login_demo/pages/signup_event.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_login_demo/models/EventModel.dart';
import 'package:flutter_login_demo/models/members.dart';

import 'dart:async';

List<EventModel> _listOfEvents;
DateTime dateSelectedByUser = DateTime.now();


void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Calendar',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MainCalendarPage(),
      routes: {
        "add_event": (_) => AddEventPage(),
      },
    );
  }
}

class MainCalendarPage extends StatefulWidget {
  MainCalendarPage({this.userId,this.membersList, this.troop, this.council});
  final List<Members> membersList;
  final String userId;
  final String troop;
  final String council;

  @override
  _MainCalendarPageState createState() => _MainCalendarPageState(userId, membersList, troop, council);
}

class _MainCalendarPageState extends State<MainCalendarPage> {
  _MainCalendarPageState(this.userId,this.membersList, this.troop, this.council);
  CalendarController _controller;
  Map<DateTime, List<dynamic>> _events;
  List<dynamic> _selectedEvents;
  List<Members> membersList;
  String userId;
  String troop;
  String council;
  StreamSubscription<Event> _onEventAddedSubscription;
  StreamSubscription<Event> _onEventChangedSubscription;
  StreamSubscription<Event> _onEventRemovedSubscription;
  Query _eventQuery;

  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final databaseReference = FirebaseDatabase.instance.reference();
  DatabaseReference eventsRef = FirebaseDatabase.instance.reference().child("EventModel");

  getEventsInfo() async {

    await _database.reference().child("EventModel").once().then((DataSnapshot snapshot){

      Map<dynamic, dynamic> values = snapshot.value;

      if(values != null) {
        values.forEach((key, values) {
          bool duplicate=false;
          for (int i=0;i<_listOfEvents.length;i++)
          {
            if((_listOfEvents[i].title.toString() == values["title"].toString())&&(_listOfEvents[i].startDate.toString() == values["startDate"].toString())&&(_listOfEvents[i].endDate.toString() == values["endDate"].toString()))
              duplicate = true;
          }
          if((!duplicate)&&(values["troop"].toString()==troop)&&(values["council"].toString()==council)) {
            _listOfEvents.add(EventModel.fromSnapshot(snapshot));
          }
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _controller = CalendarController();
    _events = {};
    _selectedEvents = [];
    _listOfEvents = new List();

    _eventQuery = _database
        .reference()
        .child("EventModel");
    _onEventAddedSubscription =  _eventQuery.onChildAdded.listen(onEventEntryAdded);
    _onEventChangedSubscription = _eventQuery.onChildChanged.listen(onEventEntryChanged);
    _onEventRemovedSubscription = _eventQuery.onChildRemoved.listen(onEventEntryRemoved);

    getEventsInfo();
  }

  onEventEntryChanged(Event event) {
    var oldEntry = _listOfEvents.singleWhere((entry) {
      return entry.key == event.snapshot.key;
    });

    setState(() {
      _listOfEvents[_listOfEvents.indexOf(oldEntry)] =
          EventModel.fromSnapshot(event.snapshot);
    });
  }

  onEventEntryRemoved(Event event) {
    var oldEntry = _listOfEvents.singleWhere((entry) {
      return entry.key == event.snapshot.key;
    });
    var oldEntry2 = _selectedEvents.singleWhere((entry) {
      return entry.key == event.snapshot.key;
    });

    setState(() {
        _listOfEvents.removeAt(_listOfEvents.indexOf(oldEntry));
        _selectedEvents.removeAt(_selectedEvents.indexOf(oldEntry2));
    });
  }

  onEventEntryAdded(Event event) {
    setState(() {
      bool foundExisting = false;
      for(int i=0;i<_listOfEvents.length;i++)
      {
        if (_listOfEvents[i].title == EventModel.fromSnapshot(event.snapshot).title)
          foundExisting = true;
      }
      if ((!foundExisting)&& (EventModel.fromSnapshot(event.snapshot).troop == troop) && (EventModel.fromSnapshot(event.snapshot).council == council) ) {
        _listOfEvents.add(EventModel.fromSnapshot(event.snapshot));
      }
    });
  }

    Map<DateTime, List<dynamic>> _groupEvents() {
      Map<DateTime, List<dynamic>> data = {};
        _listOfEvents.forEach((event) {
          DateTime date = DateTime.fromMillisecondsSinceEpoch(event.startDate);
          DateTime updated_date = DateTime(date.year,date.month,date.day,0,0);
          if (data[updated_date] == null) data[updated_date] = [];
          data[updated_date].add(event);
        }
      );
      return data;
    }

  @override
  void dispose() {
    _onEventAddedSubscription.cancel();
    _onEventChangedSubscription.cancel();
    _onEventRemovedSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Events'),
      ),
    body: StreamBuilder(
          stream: eventsRef.onValue,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              _events = _groupEvents();
            }
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  TableCalendar(
                    events: _events,
                    initialCalendarFormat: CalendarFormat.month,
                    calendarStyle: CalendarStyle(
                        canEventMarkersOverflow: true,
                        todayColor: Colors.orange,
                        selectedColor: Theme.of(context).primaryColor,
                        todayStyle: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18.0,
                            color: Colors.white)),
                    headerStyle: HeaderStyle(
                      centerHeaderTitle: true,
                      formatButtonDecoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      formatButtonTextStyle: TextStyle(color: Colors.white),
                      formatButtonShowsNext: false,
                    ),
                    startingDayOfWeek: StartingDayOfWeek.sunday,
                    onDaySelected: (date, events) {
                      dateSelectedByUser = date;
                      _selectedEvents = [];
                      setState(() {
                        _selectedEvents = events;
                      });
                      for(int i=0;i<events.length;i++)
                        setState(() {
                          _selectedEvents = events;
                        });
                      },
                    builders: CalendarBuilders(
                      selectedDayBuilder: (context, date, events) => Container(
                          margin: const EdgeInsets.all(4.0),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              borderRadius: BorderRadius.circular(10.0)),
                          child: Text(
                            date.day.toString(),
                            style: TextStyle(color: Colors.white),
                          )),
                      todayDayBuilder: (context, date, events) => Container(
                          margin: const EdgeInsets.all(4.0),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                              color: Colors.orange,
                              borderRadius: BorderRadius.circular(10.0)),
                          child: Text(
                            date.day.toString(),
                            style: TextStyle(color: Colors.white),
                          )),
                    ),
                    calendarController: _controller,
                  ),
                  ..._selectedEvents.map((event) => ListTile(
                        title: Text(event.title),
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => SignupEventPage( //EventDetailsPage(
                                        userId: userId, membersList: membersList, troop: troop, council: council, currentEvent: event, initialDate: dateSelectedByUser, pageCameFrom: "mainCalendarPage",
                                        //event: event,
                                      )));
                        },
                      )),
                ],
              ),
            );
          }),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {try {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddEventPage(userId: userId,membersList: membersList, troop: troop, council: council, initialDate: dateSelectedByUser)),
          );
        } catch (e) {
          print(e);
        }}
      ),
    );
  }
}
