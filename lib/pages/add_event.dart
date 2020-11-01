import 'package:flutter_login_demo/models/EventModel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_login_demo/models/members.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'dart:async';



class AddEventPage extends StatefulWidget {
  AddEventPage({Key key, this.note, this.userId,this.membersList, this.troop, this.council, this.initialDate}):super(key: key);
  final EventModel note;
  Query authMemberQuery;
  List<Members> membersList;
  String userId;
  String troop;
  String council;
  DateTime initialDate;


  @override
  _AddEventPageState createState() => _AddEventPageState(userId,membersList, troop, council,initialDate);
}

class _AddEventPageState extends State<AddEventPage> {
  _AddEventPageState(this.userId,this.membersList, this.troop, this.council,this.initialDate);
  TextStyle style = TextStyle(fontFamily: 'Montserrat', fontSize: 20.0);
  TextEditingController _title;
  TextEditingController _description;
  TextEditingController _location;
  TextEditingController _minimumAdults;
  TextEditingController _minimumSeats;
  TextEditingController _hours;
  TextEditingController _nights;
  TextEditingController _maximumScouts;
  TextEditingController fee;
  TextEditingController additionalNotes;
  String eventCoordinator;
  String email;
  List<Members> membersList;
  String userId;
  String troop;
  String council;
  DateTime startDateAsDateTime;
  bool foundOldEventWithTitle = false;
  DateTime endDateAsDateTime;
  DateTime initialDate;
  int startingMonth;
  int startingDay;
  int startingYear;
  int startingHour;
  int startingMinute;
  int endingMonth;
  int endingDay;
  int endingYear;
  int endingHour;
  List<String> EventTitles = [];

  int endingMinute;

  String typeOfEvent;
  List<Members> _membersList;

  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final databaseReference = FirebaseDatabase.instance.reference();

  StreamSubscription<Event> _onEventAddedSubscription;
  StreamSubscription<Event> _onEventChangedSubscription;

  Query _EventQuery;

  String _date = "Not set";
  String startTime = "Not set";
  String endTime = "Not set";
  String startDate = "Not set";
  String endDate = "Not set";
  List<String> _ListOfTroopMember = [];

  DateTime _eventDate;
  final _formKey = GlobalKey<FormState>();
  final _key = GlobalKey<ScaffoldState>();
  bool processing;

  @override
  void initState() {
    super.initState();
    _title = TextEditingController(text: widget.note != null ? widget.note.title : "");
    _description = TextEditingController(text:  widget.note != null ? widget.note.description : "");
    _location = TextEditingController(text:  widget.note != null ? widget.note.location : "");
    _minimumAdults = TextEditingController(text:  widget.note != null ? widget.note.minimumAdults : "0");
    _minimumSeats = TextEditingController(text:  widget.note != null ? widget.note.minimumSeats : "0");
    _hours = TextEditingController(text:  widget.note != null ? widget.note.hours : "0");
    _nights = TextEditingController(text:  widget.note != null ? widget.note.nights : "0");
    _maximumScouts = TextEditingController(text:  widget.note != null ? widget.note.maximumScouts : "0");

    additionalNotes = TextEditingController(text:  widget.note != null ? widget.note.additionalNotes : "None");
    fee = TextEditingController(text:  widget.note != null ? widget.note.fee : "0");

    _ListOfTroopMember.length=0;
    for(int x = 0; x<membersList.length; x++) {
      if (membersList[x].active){
      _ListOfTroopMember.add(membersList[x].firstName + " " + membersList[x].lastName + "\n" + membersList[x].email);
    }}

    startDate = initialDate.year.toString()+" - "+initialDate.month.toString()+" - "+initialDate.day.toString();
     endDate = startDate;
     startingYear = initialDate.year;
     startingMonth = initialDate.month;
     startingDay = initialDate.day;
     endingYear = startingYear;
     endingMonth = startingMonth;
     endingDay = startingDay;
     startingHour = 12;
     startingMinute = 0;
     endingHour = 12;
     endingMinute = 0;
     startTime = "12 : 00";
     endTime = "12 : 00";

    _eventDate = DateTime.now();
    processing = false;

    _database.reference().child("EventModel").once().then((DataSnapshot snapshot){
      Map<dynamic, dynamic> values = snapshot.value;
      if(values != null) {
        values.forEach((key, values) {
          EventTitles.add(values["title"].toString());
        });
      }
    });

    _EventQuery = _database
        .reference()
        .child("EventModel");
    _onEventAddedSubscription =  _EventQuery.onChildAdded.listen(onEventEntryAdded);
    _onEventChangedSubscription = _EventQuery.onChildChanged.listen(onEventEntryChanged);

  }

  onEventEntryChanged(Event event) {
    setState(() {
      bool found = false;
      for(int i=0;i<EventTitles.length;i++)
        {
          if(EventTitles[i] == EventModel.fromSnapshot(event.snapshot).title)
            found = true;
        }
      if (!found)
        EventTitles.add(EventModel.fromSnapshot(event.snapshot).title);
    });
  }

  onEventEntryAdded(Event event) {
    setState(() {
      bool found = false;
      for(int i=0;i<EventTitles.length;i++)
      {
        if(EventTitles[i] == EventModel.fromSnapshot(event.snapshot).title)
          found = true;
      }
      if (!found)
        EventTitles.add(EventModel.fromSnapshot(event.snapshot).title);
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.note != null ? "Edit Event" : "Add event"),
      ),
      key: _key,
      body: Form(
        key: _formKey,
        child: Container(
          alignment: Alignment.center,
          child: ListView(
            children: <Widget>[
              SizedBox(
                height: 20.0,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Text("Event Type:", style: TextStyle(fontSize: 20, color: Colors.grey[600]))
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: DropdownButton<String>(
                  value: typeOfEvent,
                  onChanged: (value) {
                    setState(() {
                      typeOfEvent= value;
                    });
                  },
                  items: <String>["Troop Meeting","Campout", "Service Project", "PLC", "Patrol Meeting","Court of Honor",  "Board of Review", "Other"].map(
                        (String value) {
                      return DropdownMenuItem(
                        value: value,
                        child: new Text(value, style: TextStyle(fontSize: 20, color: Colors.grey[600])),
                      );},
                  ).toList(),
                ),
              ),
              Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Text("Coordinator:", style: TextStyle(fontSize: 20, color: Colors.grey[600]))
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: DropdownButton<String>(
                  value: eventCoordinator,
                  onChanged: (value) {
                    setState(() {
                      eventCoordinator= value;
                    });
                  },
                  items: _ListOfTroopMember.map(
                        (value) {
                      return DropdownMenuItem(
                        value: value,
                        child: new AutoSizeText(value, maxLines: 2, style: TextStyle(color: Colors.grey[600]), overflow: TextOverflow.ellipsis),
                      );},
                  ).toList(),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: TextFormField(
                  controller: _title,
                  validator: (value) =>
                      ((value.isEmpty)) ? "Please Enter title" : null,
                  style: style,
                  decoration: InputDecoration(
                      labelText: "Title",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: TextFormField(
                  controller: _description,
                  minLines: 3,
                  maxLines: 5,
                  validator: (value) =>
                      (value.isEmpty) ? "Please Enter The Main Description Of The Event" : null,
                  style: style,
                  decoration: InputDecoration(
                      labelText: "Description",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: TextFormField(
                  controller: _minimumAdults,
                  minLines: 1,
                  maxLines: 1,
                  validator: (value) =>
                  ((value.isEmpty)||(int.tryParse(_minimumAdults.text) == null)) ? "Please Enter Valid Minimum Number Of Adults" : null,
                  style: style,
                  decoration: InputDecoration(
                      labelText: "Minimum # of Adults",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: TextFormField(
                  controller: _minimumSeats,
                  minLines: 1,
                  maxLines: 1,
                  validator: (value) =>
                  ((value.isEmpty)||(int.tryParse(_minimumSeats.text) == null)) ? "Please Enter Valid Minimum Number Of Seats" : null,
                  style: style,
                  decoration: InputDecoration(
                      labelText: "Minimum # of Seats",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: TextFormField(
                  controller: _maximumScouts,
                  minLines: 1,
                  maxLines: 1,
                  validator: (value) =>
                  ((value.isEmpty)||(int.tryParse(_maximumScouts.text) == null)) ? "Please Enter Valid Maximum Number Of Attendees" : null,
                  style: style,
                  decoration: InputDecoration(
                      labelText: "Max Attendees (No limit=0)",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: TextFormField(
                  controller: _location,
                  minLines: 1,
                  maxLines: 4,
                  validator: (value) =>
                  (value.isEmpty) ? "Please Enter The Location of the Event" : null,
                  style: style,
                  decoration: InputDecoration(
                      labelText: "Location",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: TextFormField(
                  controller: fee,
                  minLines: 1,
                  maxLines: 1,
                  validator: (value) =>
                  ((value.isEmpty)||(double.tryParse(fee.text) == null)) ? "Please Enter Valid Fee of the Event" : null,
                  style: style,
                  decoration: InputDecoration(
                      labelText: "Fee (\$)",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: TextFormField(
                  controller: _hours,
                  minLines: 1,
                  maxLines: 1,
                  validator: (value) =>
                  ((value.isEmpty)||(double.tryParse(_hours.text) == null)) ? "Please Enter Valid # Of Hours for the Event" : null,
                  style: style,
                  decoration: InputDecoration(
                      labelText: "Hours of Service To Credit",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: TextFormField(
                  controller: _nights,
                  minLines: 1,
                  maxLines: 1,
                  validator: (value) =>
                  ((value.isEmpty)||(int.tryParse(_nights.text) == null)) ? "Please Enter Valid # Of Nights for the Event" : null,
                  style: style,
                  decoration: InputDecoration(
                      labelText: "Nights of Camping To Credit",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
                ),
              ),

             /* const SizedBox(height: 10.0),
              ListTile(
                title: Text("Date (YYYY-MM-DD)"),
                subtitle: Text("${_eventDate.year} - ${_eventDate.month} - ${_eventDate.day}"),
                onTap: ()async{
                  DateTime picked = await showDatePicker(context: context, initialDate: _eventDate, firstDate: DateTime(_eventDate.year-10), lastDate: DateTime(_eventDate.year+10));
                  if(picked != null) {
                    setState(() {
                      _eventDate = picked;
                    });
                  }
                },
              ),*/
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      RaisedButton(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5.0)),
                        elevation: 4.0,
                        onPressed: () {
                          DatePicker.showDatePicker(context,
                              theme: DatePickerTheme(
                                containerHeight: 210.0,
                              ),
                              showTitleActions: true,
                              minTime: DateTime(2000, 1, 1),
                              maxTime: DateTime.now().add(Duration(days: 1825)), onConfirm: (date) {
                                startDate = '${date.year} - ${date.month} - ${date.day}';
                                startingYear = date.year;
                                startingMonth = date.month;
                                startingDay = date.day;

                                setState(() {});
                              }, currentTime: DateTime(startingYear,startingMonth,startingDay), locale: LocaleType.en);
                        },
                        child: Container(
                          alignment: Alignment.center,
                          height: 50.0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  Container(
                                    child: Row(
                                      children: <Widget>[
                                        Icon(
                                          Icons.date_range,
                                          size: 18.0,
                                          color: Colors.teal,
                                        ),
                                        Text(
                                          " $startDate",
                                          style: TextStyle(
                                              color: Colors.teal,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18.0),
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                              Text(
                                "  Start",
                                style: TextStyle(
                                    color: Colors.teal,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18.0),
                              ),
                            ],
                          ),
                        ),
                        color: Colors.white,
                      ),
                      SizedBox(
                        height: 20.0,
                      ),
                      RaisedButton(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5.0)),
                        elevation: 4.0,
                        onPressed: () {
                          DatePicker.showDatePicker(context,
                              theme: DatePickerTheme(
                                containerHeight: 210.0,
                              ),
                              showTitleActions: true,
                              minTime: DateTime(2000, 1, 1),
                              maxTime: DateTime.now().add(Duration(days: 1825)), onConfirm: (date) {
                                endDate = '${date.year} - ${date.month} - ${date.day}';
                                endDateAsDateTime = DateTime(date.year, date.month, date.day);
                                endingYear = date.year;
                                endingMonth = date.month;
                                endingDay = date.day;

                                setState(() {});
                              }, currentTime: DateTime(endingYear, endingMonth, endingDay), locale: LocaleType.en);
                        },
                        child: Container(
                          alignment: Alignment.center,
                          height: 50.0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  Container(
                                    child: Row(
                                      children: <Widget>[
                                        Icon(
                                          Icons.date_range,
                                          size: 18.0,
                                          color: Colors.teal,
                                        ),
                                        Text(
                                          " $endDate",
                                          style: TextStyle(
                                              color: Colors.teal,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18.0),
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                              Text(
                                "  End",
                                style: TextStyle(
                                    color: Colors.teal,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18.0),
                              ),
                            ],
                          ),
                        ),
                        color: Colors.white,
                      ),
                      SizedBox(
                        height: 20.0,
                      ),
                      RaisedButton(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5.0)),
                        elevation: 4.0,
                        onPressed: () {
                          DatePicker.showTimePicker(context,
                              theme: DatePickerTheme(
                                containerHeight: 210.0,
                              ),
                              showTitleActions: true, onConfirm: (time) {
                                startTime = '${time.hour} : ${time.minute}';
                                startingHour = time.hour;
                                startingMinute = time.minute;
                                setState(() {});
                              }, currentTime: DateTime(startingYear, startingMonth, startingDay, startingHour, startingMinute, 0), locale: LocaleType.en);
                          setState(() {});
                        },
                        child: Container(
                          alignment: Alignment.center,
                          height: 50.0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  Container(
                                    child: Row(
                                      children: <Widget>[
                                        Icon(
                                          Icons.access_time,
                                          size: 18.0,
                                          color: Colors.teal,
                                        ),
                                        Text(
                                          " $startTime",
                                          style: TextStyle(
                                              color: Colors.teal,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18.0),
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                              Text(
                                "  Start",
                                style: TextStyle(
                                    color: Colors.teal,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18.0),
                              ),
                            ],
                          ),
                        ),
                        color: Colors.white,
                      ),
                      SizedBox(
                        height: 20.0,
                      ),
                      RaisedButton(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5.0)),
                        elevation: 4.0,
                        onPressed: () {
                          DatePicker.showTimePicker(context,
                              theme: DatePickerTheme(
                                containerHeight: 210.0,
                              ),
                              showTitleActions: true, onConfirm: (time) {
                                endTime = '${time.hour} : ${time.minute}';
                                endingHour = time.hour;
                                endingMinute = time.minute;
                                setState(() {});
                              }, currentTime: DateTime(endingYear, endingMonth, endingDay, endingHour, endingMinute, 0), locale: LocaleType.en);
                          setState(() {});
                        },
                        child: Container(
                          alignment: Alignment.center,
                          height: 50.0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  Container(
                                    child: Row(
                                      children: <Widget>[
                                        Icon(
                                          Icons.access_time,
                                          size: 18.0,
                                          color: Colors.teal,
                                        ),
                                        Text(
                                          " $endTime",
                                          style: TextStyle(
                                              color: Colors.teal,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18.0),
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                              Text(
                                "  End",
                                style: TextStyle(
                                    color: Colors.teal,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18.0),
                              ),
                            ],
                          ),
                        ),
                        color: Colors.white,
                      )

                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: TextFormField(
                  controller: additionalNotes,
                  minLines: 3,
                  maxLines: 7,
                  validator: (value) =>
                  (value.isEmpty) ? "Enter Any Additional Notes For The Event" : null,
                  style: style,
                  decoration: InputDecoration(
                      labelText: "Additional Notes",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
                ),
              ),


              SizedBox(height: 10.0),
              processing
                  ? Center(child: CircularProgressIndicator())
                  : Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Material(
                        elevation: 5.0,
                        borderRadius: BorderRadius.circular(30.0),
                        color: Theme.of(context).primaryColor,
                        child: MaterialButton(
                          onPressed: () async {
                            foundOldEventWithTitle=false;

                            for(int i =0; i<EventTitles.length; i++){
                              if (EventTitles[i] ==_title.text){
                                foundOldEventWithTitle=true;
                              }
                            }
                            int startTime = DateTime(startingYear, startingMonth, startingDay, startingHour, startingMinute).millisecondsSinceEpoch.toInt();
                            int endTime = DateTime(endingYear, endingMonth, endingDay, endingHour, endingMinute).millisecondsSinceEpoch.toInt();
                            if ((_formKey.currentState.validate()) && (_title.text.length!=0) && (_location.text.length!=0)&& (_description.text.length!=0) &&(startTime <= endTime)&&(eventCoordinator != null)&&(typeOfEvent != null)&&(int.tryParse(_nights.text) != null)&&(int.tryParse(_minimumAdults.text) != null)&&(int.tryParse(_minimumSeats.text) != null)&&(int.tryParse(_maximumScouts.text) != null)&&(fee.text.length != 0)&&(double.tryParse(_hours.text) != null)&& !foundOldEventWithTitle) {
                              setState(() {
                                processing = true;
                              });
                              //if(widget.note != null) {
                                for (int x = 0; x<membersList.length; x++){
                                  if (membersList[x].firstName + " " + membersList[x].lastName + "\n" + membersList[x].email == eventCoordinator){
                                    email = membersList[x].email;
                                  }
                                }
                                EventModel event = new EventModel(_title.text, _description.text, int.parse(_minimumAdults.text), int.parse(_minimumSeats.text), int.parse(_maximumScouts.text), _location.text, DateTime(startingYear, startingMonth, startingDay, startingHour, startingMinute).millisecondsSinceEpoch.toInt(), DateTime(endingYear, endingMonth, endingDay, endingHour, endingMinute).millisecondsSinceEpoch.toInt(), userId, fee.text, additionalNotes.text, email, typeOfEvent, troop, council, int.parse((double.parse((double.parse(_hours.text)).toStringAsFixed(1)) * 10).round().toString()), (int.parse(_nights.text)).round(), false);
                                _database.reference().child("EventModel").push().set(event.toJson());
                                print("done setting the database");
                              //}
                              Navigator.pop(context);
                              setState(() {
                                processing = false;
                              });
                            }
                            else
                              {
                                if (foundOldEventWithTitle){
                                  showAlertDialog(context, "There is an old event with the same title. Please enter a unique title");
                                }
                                else if (startTime > endTime) {
                                  showAlertDialog(context, "The end time should be after the start time");
                                }
                                else if(eventCoordinator == null) {
                                  showAlertDialog(context, "Please select an Event Coordinator");
                                }
                                else if(typeOfEvent == null) {
                                  showAlertDialog(context, "Please select the type of event");
                                }
                                else if (_title.text.length == 0){
                                  showAlertDialog(context, "Please enter a title");
                                }
                                else if (_description.text.length == 0){
                                  showAlertDialog(context, "Please enter a description");
                                }
                                else if (_location.text.length == 0){
                                  showAlertDialog(context, "Please enter a location");
                                }
                                else if ((int.tryParse(_nights.text) == null)||(int.tryParse(_minimumAdults.text) == null)||(int.tryParse(_maximumScouts.text) == null)||(int.tryParse(_hours.text) == null)||(int.tryParse(_minimumSeats.text) == null)||(int.tryParse(fee.text) == null)){
                                  showAlertDialog(context, "One or more of the fields that is supposed to hold an number has a string. Please fix this.");
                                }
                              }
                          },
                          child: Text(
                            "Save",
                            style: style.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _location.dispose();
    _maximumScouts.dispose();
    _minimumAdults.dispose();
    _minimumSeats.dispose();
    additionalNotes.dispose();
    _onEventAddedSubscription.cancel();
    _onEventChangedSubscription.cancel();
    super.dispose();
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
    title: Text("Invalid Entry"),
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
