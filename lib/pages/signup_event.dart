import 'package:flutter_login_demo/models/EventModel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_login_demo/models/members.dart';
import 'package:flutter_login_demo/models/eventsignup.dart';
import 'package:flutter_login_demo/models/drivers.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter_login_demo/pages/driverRegistration.dart';
import 'package:flutter_login_demo/pages/editScoutCredit.dart';
import 'package:flutter_login_demo/pages/moveToTopOfList.dart';
import 'dart:async';

import 'package:flutter_login_demo/pages/main_menu.dart';

String displayTextForDriver = "Register As Driver";
bool isThisGuyAScoutmaster = false;
bool isAParent = false;

class ListElement {
  String displayString;
  EventSignUp _eventSignUp;
  bool isScout;
  String firstName;
  String lastName;
  String email;
  String userId;

  ListElement(this.displayString, this._eventSignUp, this.isScout, this.firstName, this.lastName, this.email, this.userId);
}

class SignupEventPage extends StatefulWidget {
  SignupEventPage({Key key, this.note, this.userId,this.membersList, this.troop, this.council, this.initialDate, this.currentEvent, this.pageCameFrom}):super(key: key);
  final EventModel currentEvent;
  final EventModel note;
  Query authMemberQuery;
  List<Members> membersList;
  String userId;
  String troop;
  String council;
  DateTime initialDate;
  String pageCameFrom;

  @override
  _SignupEventPageState createState() => _SignupEventPageState(userId,membersList, troop, council,initialDate,currentEvent,pageCameFrom);
}

class _SignupEventPageState extends State<SignupEventPage> {
  _SignupEventPageState(this.userId,this.membersList, this.troop, this.council,this.initialDate, this.currentEvent, this.pageCameFrom);
  List<EventSignUp> _listOfSignedUpPeople = [];
  List<Drivers> _listOfDrivers = [];
  List<String> infoOfDrivers = [];

  TextStyle style = TextStyle(fontFamily: 'Montserrat', fontSize: 20.0);
  TextEditingController _title;
  TextEditingController _description;
  TextEditingController _location;
  TextEditingController _minimumAdults;
  TextEditingController _minimumSeats;
  TextEditingController _maximumScouts;
  TextEditingController fee;
  TextEditingController _hours;
  TextEditingController _nights;
  List<EventModel> EventTitles = [];
  bool foundOldEventWithTitle;

  StreamSubscription<Event> _onEventAddedSubscription;
  StreamSubscription<Event> _onEventChangedSubscription;

  Query _EventQuery;


  TextEditingController additionalNotes;
  EventModel currentEvent;
  String eventCoordinator;
  List<Members> membersList;
  List<ListElement> _confirmedList=[];
  List<ListElement> _waitlistedList=[];
  String userId;
  String troop;
  String council;
  DateTime startDateAsDateTime;
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
  int endingMinute;
  bool allowedToEdit;
  bool alreadyRegistered = false;
  bool alreadyRegisteredAsDriver = false;

  int seqNumberOfCurrentScout;
  String pageCameFrom;

  String typeOfEvent;
  String buttonSignUpDropOffText;
  String buttonSignUpDriverDropOffText;
  String buttonMarkCompleteText;
  String currentSignupKey;
  String currentSignupDriverKey;

  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final databaseReference = FirebaseDatabase.instance.reference();

  StreamSubscription<Event> _onPersonSignedUpAddedSubscription;
  StreamSubscription<Event> _onPersonSignedUpChangedSubscription;
  StreamSubscription<Event> _onPersonSignedUpRemovedSubscription;
  StreamSubscription<Event> _onDriverSignedUpAddedSubscription;
  StreamSubscription<Event> _onDriverSignedUpChangedSubscription;

  Query onSignedUpQuery;
  Query onDriverQuery;

  String _date = "Not set";
  String startTime = "Not set";
  String endTime = "Not set";
  String startDate = "Not set";
  String endDate = "Not set";
  List<String> _ListOfTroopMember = [];
  String formTitle;

  DateTime _eventDate;
  final _formKey = GlobalKey<FormState>();
  final _key = GlobalKey<ScaffoldState>();
  bool processing;

  @override
  void initState() {
    super.initState();
    isAParent=false;
    isThisGuyAScoutmaster = false;

    displayTextForDriver = "Register As Driver";

    onSignedUpQuery = _database
        .reference()
        .child("EventSignUp");
    onDriverQuery = _database
        .reference()
        .child("Drivers");
    _onPersonSignedUpAddedSubscription =  onSignedUpQuery.onChildAdded.listen(onPersonEntryAdded);
    _onPersonSignedUpChangedSubscription = onSignedUpQuery.onChildChanged.listen(onPersonEntryChanged);
    _onPersonSignedUpRemovedSubscription = onSignedUpQuery.onChildRemoved.listen(onPersonEntryRemoved);
    _onDriverSignedUpAddedSubscription =  onDriverQuery.onChildAdded.listen(onDriverEntryAdded);
    _onDriverSignedUpChangedSubscription = onDriverQuery.onChildChanged.listen(onDriverEntryChanged);
    _title = TextEditingController(text: widget.note != null ? widget.note.title : "");
    _description = TextEditingController(text:  widget.note != null ? widget.note.description : "");
    _location = TextEditingController(text:  widget.note != null ? widget.note.location : "");
    _minimumAdults = TextEditingController(text:  widget.note != null ? widget.note.minimumAdults : "");
    _minimumSeats = TextEditingController(text:  widget.note != null ? widget.note.minimumSeats : "");
    _maximumScouts = TextEditingController(text:  widget.note != null ? widget.note.maximumScouts : "");
    _hours = TextEditingController(text:  widget.note != null ? widget.note.hours : "");
    _nights = TextEditingController(text:  widget.note != null ? widget.note.nights : "");

    additionalNotes = TextEditingController(text:  widget.note != null ? widget.note.additionalNotes : "");
    fee = TextEditingController(text:  widget.note != null ? widget.note.fee : "");


    buttonSignUpDropOffText = "Register";
    if(currentEvent.completed) {
      buttonMarkCompleteText = "Mark Event Incomplete";
    }
    else
    {
      buttonMarkCompleteText = "Mark Event Complete";
    }
    _listOfSignedUpPeople.length = 0;

    getSignedUpList();
    getDriverSignedUpList();

    _ListOfTroopMember.length = 0;
    _confirmedList.length = 0;
    _waitlistedList.length = 0;
    bool foundExistingMember = false;
    for(int x = 0; x<membersList.length; x++) {
      if (membersList[x].active){
      for (int i = 0; i<_ListOfTroopMember.length; i++) {
        if (_ListOfTroopMember[i] == membersList[x].firstName + " " + membersList[x].lastName + "\n" + membersList[x].email) {
          foundExistingMember = true;

        }
      }
      if (!foundExistingMember){
        _ListOfTroopMember.add(membersList[x].firstName + " " + membersList[x].lastName + "\n" + membersList[x].email);
      }}
    }

    DateTime fromDateTime = DateTime.fromMillisecondsSinceEpoch(currentEvent.startDate);
    DateTime toDateTime = DateTime.fromMillisecondsSinceEpoch(currentEvent.endDate);

    startDate = fromDateTime.year.toString()+" - "+fromDateTime.month.toString()+" - "+fromDateTime.day.toString();
    endDate = toDateTime.year.toString()+" - "+toDateTime.month.toString()+" - "+toDateTime.day.toString();
    startingYear = fromDateTime.year;
    startingMonth = fromDateTime.month;
    startingDay = fromDateTime.day;
    endingYear = toDateTime.year;
    endingMonth = toDateTime.month;
    endingDay = toDateTime.day;
    startingHour = fromDateTime.hour;
    startingMinute = fromDateTime.minute;
    endingHour = toDateTime.hour;
    endingMinute = toDateTime.minute;
    startTime = fromDateTime.hour.toString()+" : "+fromDateTime.minute.toString();
    endTime = toDateTime.hour.toString()+" : "+toDateTime.minute.toString();
    typeOfEvent = currentEvent.typeOfEvent;
    for (int i =0; i<membersList.length; i++){
      if (currentEvent.eventCoordinator==(membersList[i].email)){
        eventCoordinator = membersList[i].firstName + " " + membersList[i].lastName + "\n" + membersList[i].email;
      }
    }
    _title.text = currentEvent.title;
    _description.text = currentEvent.description;
    _minimumAdults.text = currentEvent.minimumAdults.toString();
    _minimumSeats.text = currentEvent.minimumSeats.toString();
    _maximumScouts.text = currentEvent.maximumScouts.toString();
    _location.text = currentEvent.location;
    _hours.text = (currentEvent.hours.toDouble()/10).toString();
    _nights.text = currentEvent.nights.toString();
    fee.text = currentEvent.fee;
    additionalNotes.text = currentEvent.additionalNotes;
    allowedToEdit = false;

    for (int j = 0; j < membersList.length; j++) {
      if (currentEvent.eventCoordinator == ("${membersList[j].email}"))
        if(userId == membersList[j].userId) {
          allowedToEdit = true;
        }
    }

    if (isScoutmaster)
      allowedToEdit = true;

    _eventDate = DateTime.now();
    processing = false;
    if(allowedToEdit)
    {
      formTitle = "Signup/Drop/Update Event";
    }
    else
    {
      formTitle = "Signup/Drop Event";
    }

    for (int x = 0; x<membersList.length; x++){
      if (userId==membersList[x].userId && membersList[x].isScoutmaster){
        isThisGuyAScoutmaster = true;
      }
    }
    _database.reference().child("EventModel").once().then((DataSnapshot snapshot){
      Map<dynamic, dynamic> values = snapshot.value;
      if(values != null) {
        values.forEach((key, values) {
          bool found = false;
          for(int i=0;i<EventTitles.length;i++)
          {
            if(EventTitles[i].key == EventModel.fromSnapshot(snapshot).key)
              found = true;
          }
          if (!found)
            EventTitles.add(EventModel.fromSnapshot(snapshot));
        });
      }
    });

    _EventQuery = _database
        .reference()
        .child("EventModel");
    _onEventAddedSubscription =  _EventQuery.onChildAdded.listen(onEventEntryAdded);
    _onEventChangedSubscription = _EventQuery.onChildChanged.listen(onEventEntryChanged);
  }

  onPersonEntryChanged(Event event) {
    try {
    var oldEntry = _listOfSignedUpPeople.singleWhere((entry) {
      return entry.key == event.snapshot.key;
    });

    setState(() {
      _listOfSignedUpPeople[_listOfSignedUpPeople.indexOf(oldEntry)] = EventSignUp.fromSnapshot(event.snapshot);
      generateConfirmedAndWaitingList();
       });
    } catch (e)
    {
      print(e);
    }
  }

  generateConfirmedAndWaitingList()
  {
    try{
      _confirmedList.length = 0;
      _waitlistedList.length = 0;

      for(int i=0;i<_listOfSignedUpPeople.length;i++)
        {
          for (int j=0; j < membersList.length; j++) {
            if (membersList[j].userId == _listOfSignedUpPeople[i].userId) {
              for (int k = 0; k < _listOfSignedUpPeople.length; k++) {
                if (i != k) {
                  if (_listOfSignedUpPeople[i].sequenceNum == _listOfSignedUpPeople[k].sequenceNum) {
                    _listOfSignedUpPeople[i].sequenceNum++;
                    if ((_listOfSignedUpPeople[i].sequenceNum >= currentEvent.maximumScouts)&&(currentEvent.maximumScouts != 0)) {
                      _listOfSignedUpPeople[i].confirmed = false;
                    }
                    else{
                      _listOfSignedUpPeople[i].confirmed = true;
                    }
                    _database.reference().child("EventSignUp").child(_listOfSignedUpPeople[i].key).set(_listOfSignedUpPeople[i].toJson());


                  }
                }
              }
              //_database.reference().child("EventSignUp").child(_listOfSignedUpPeople[i].key).set(_listOfSignedUpPeople[i].toJson());
              if(_listOfSignedUpPeople[i].confirmed)
                {
                  _confirmedList.add(ListElement((_listOfSignedUpPeople[i].sequenceNum + 1).toString() + """ ${membersList[j].firstName} ${membersList[j].lastName} 
${membersList[j].email}""", _listOfSignedUpPeople[i], membersList[j].isScout, membersList[j].firstName, membersList[j].lastName,membersList[j].email, membersList[j].userId));
                }
              else
                {
                 _waitlistedList.add((ListElement((_listOfSignedUpPeople[i].sequenceNum + 1).toString() + """ ${membersList[j].firstName} ${membersList[j].lastName} 
${membersList[j].email}""", _listOfSignedUpPeople[i], membersList[j].isScout, membersList[j].firstName, membersList[j].lastName,membersList[j].email, membersList[j].userId)));
                }
            }
          }
        }
    } catch (e) {
      print(e);
    }
  }

  onPersonEntryRemoved(Event event) {
    try {
      var oldEntry = _listOfSignedUpPeople.singleWhere((entry) {
        return entry.key == event.snapshot.key;
      });

      setState(() {
        generateConfirmedAndWaitingList();
        int saveIndex = _listOfSignedUpPeople[_listOfSignedUpPeople.indexOf(oldEntry)].sequenceNum;
        _listOfSignedUpPeople.removeAt(_listOfSignedUpPeople.indexOf(oldEntry));
        updateSignedUpList(saveIndex);
        generateConfirmedAndWaitingList();
      });
    } catch (e)
    {
      print(e);
    }
  }

  onPersonEntryAdded(Event event) {
    try {
    setState(() {
      bool foundExisting = false;
      bool sameEvent=(EventSignUp.fromSnapshot(event.snapshot).eventKey == currentEvent.key);
      for(int i=0;i<_listOfSignedUpPeople.length;i++)
      {
        if ((_listOfSignedUpPeople[i].eventKey == EventSignUp.fromSnapshot(event.snapshot).eventKey)&&(_listOfSignedUpPeople[i].userId == EventSignUp.fromSnapshot(event.snapshot).userId))
          foundExisting = true;
      }
      generateConfirmedAndWaitingList();
      if ((!foundExisting)&&(sameEvent))
      {
        _listOfSignedUpPeople.add(EventSignUp.fromSnapshot(event.snapshot));
      }
      generateConfirmedAndWaitingList();
    });
    } catch (e)
    {
      print(e);
    }
  }

  onDriverEntryChanged(Event event) {
    var oldEntry = _listOfDrivers.singleWhere((entry) {
      return entry.key == event.snapshot.key;
    });

    setState(() {
      _listOfDrivers[_listOfDrivers.indexOf(oldEntry)] = Drivers.fromSnapshot(event.snapshot);

      for(int i = 0; i<membersList.length; i++){
        if (membersList[i].userId==Drivers.fromSnapshot(event.snapshot).userId){
          infoOfDrivers.add(membersList[i].firstName + " " + membersList[i].lastName + " [# Of Seats: "+Drivers.fromSnapshot(event.snapshot).seatsAvailable.toString()+"]\n" + membersList[i].email);
        }
      }
    });
  }

  onDriverEntryAdded(Event event) {
    setState(() {
      bool foundExisting = false;
      bool sameEvent=false;
      for(int i=0;i<_listOfDrivers.length;i++)
     {

        if ((_listOfDrivers[i].eventKey == Drivers.fromSnapshot(event.snapshot).eventKey)&&(_listOfSignedUpPeople[i].userId == EventSignUp.fromSnapshot(event.snapshot).userId)) {
          foundExisting = true;
        }
        if (_listOfSignedUpPeople[i].eventKey == currentEvent.key)
          {
            sameEvent = true;
          }

      }
      Map<dynamic, dynamic> values = event.snapshot.value;
      if ((!foundExisting)&&(sameEvent)) {
        _listOfDrivers.add(Drivers.fromSnapshot(event.snapshot));
        for(int i = 0; i<membersList.length; i++){
          if (membersList[i].userId==Drivers.fromSnapshot(event.snapshot).userId){
            infoOfDrivers.add(membersList[i].firstName + " " + membersList[i].lastName + " [# Of Seats:"+Drivers.fromSnapshot(event.snapshot).seatsAvailable.toString()+"]\n" + membersList[i].email);

          }
        }

        if (values["userId"]==userId.toString())
        {

          alreadyRegisteredAsDriver = true;
          displayTextForDriver = "De-register As Driver";

        }


      }
    });
  }

  getSignedUpList() async {
    //_listOfSignedUpPeople.length = 0;
    await _database.reference().child("EventSignUp").once().then((DataSnapshot snapshot){
      Map<dynamic, dynamic> values = snapshot.value;
      if(values != null) {
        values.forEach((key, values) {
          if(currentEvent.key == values["eventKey"]) {
            bool foundExisting = false;
            for(int i=0;i<_listOfSignedUpPeople.length;i++)
            {
              if ((_listOfSignedUpPeople[i].eventKey == values["eventKey"])&&(_listOfSignedUpPeople[i].userId == values["userId"]))
                foundExisting = true;
            }
            if(!foundExisting)
            {
              _listOfSignedUpPeople.add(EventSignUp(values["userId"], values["eventKey"], values["hours"], values["nights"], values["sequenceNum"], values["confirmed"], values["completed"]));
              _listOfSignedUpPeople[_listOfSignedUpPeople.length - 1].key=key;
            }

            //_listOfSignedUpPeople.add(EventSignUp.fromSnapshot(snapshot));
              if (values["userId"]==userId.toString())
              {
                alreadyRegistered = true;
                buttonSignUpDropOffText = "De-register";
                currentSignupKey = key;
                seqNumberOfCurrentScout = values["sequenceNum"];
              }
          }
        });
      }
    });
    for(int i=0;i<_listOfSignedUpPeople.length;i++)
    {
      if (_listOfSignedUpPeople[i].eventKey == currentEvent.key) {
        if ((_listOfSignedUpPeople[i].sequenceNum < currentEvent.maximumScouts)||(currentEvent.maximumScouts == 0)) {
          for (int j = 0; j < membersList.length; j++) {
            if (membersList[j].userId == _listOfSignedUpPeople[i].userId) {
              _confirmedList.add(ListElement((_listOfSignedUpPeople[i].sequenceNum + 1).toString() + """ ${membersList[j].firstName} ${membersList[j].lastName} 
${membersList[j].email}""",_listOfSignedUpPeople[i], membersList[j].isScout, membersList[j].firstName, membersList[j].lastName,membersList[j].email, membersList[j].userId));
            }
          }
        }
        else {
          for (int j = 0; j < membersList.length; j++) {
            if (membersList[j].userId == _listOfSignedUpPeople[i].userId) {
              _waitlistedList.add(ListElement((_listOfSignedUpPeople[i].sequenceNum + 1).toString() + """ ${membersList[j].firstName} ${membersList[j].lastName} 
${membersList[j].email}""", _listOfSignedUpPeople[i], membersList[j].isScout, membersList[j].firstName, membersList[j].lastName,membersList[j].email, membersList[j].userId));;
            }
          }
        }
      }
    }
    generateConfirmedAndWaitingList();
  }

  getDriverSignedUpList() async {
    _listOfDrivers.length = 0;
    await _database.reference().child("Drivers").once().then((DataSnapshot snapshot){
      Map<dynamic, dynamic> values = snapshot.value;
      if(values != null) {
        values.forEach((key, values) {
          if(currentEvent.key == values["eventKey"]) {
            _listOfDrivers.add(Drivers(values["userId"], values["eventKey"], values["seatsAvailable"]));
            for(int i = 0; i<membersList.length; i++){
              if (membersList[i].userId==values["userId"]){
                infoOfDrivers.add(membersList[i].firstName + " " + membersList[i].lastName + " [# Of Seats: " + values["seatsAvailable"].toString()+ "]\n" + membersList[i].email );
              }
            }
            if (values["userId"]==userId.toString())
            {
              alreadyRegisteredAsDriver = true;
              if (values["seatsAvailable"]>0) {
                displayTextForDriver = "De-register As Driver";
              }
              currentSignupDriverKey = key;
            }
          }
        });
      }
    });

  }

  updateSignedUpList(int fromSeqNum) async {

    await _database.reference().child("EventSignUp").once().then((DataSnapshot snapshot){
      Map<dynamic, dynamic> values = snapshot.value;
      _listOfSignedUpPeople.length = 0;
      if(values != null) {
        values.forEach((key, values) {
          bool newConfirm = values["confirmed"];
          if((currentEvent.key == values["eventKey"])&&(values["sequenceNum"] > fromSeqNum))
          {
            if((values["sequenceNum"]-1) == fromSeqNum) newConfirm = true;
            EventSignUp updateSignUp = new EventSignUp(values["userId"], values["eventKey"], currentEvent.hours, currentEvent.nights, (values["sequenceNum"]-1), newConfirm, values["completed"]);
            _database.reference().child("EventSignUp").child(key).set(updateSignUp.toJson());
          }
        });
      }
    });
  }

  bool confirmOrDeny() {

    //bool foundExisting = false;
    bool confirm = false;

    /*for(int i=0;i<_listOfSignedUpPeople.length;i++)
    {
      if ((_listOfSignedUpPeople[i].eventKey == currentEvent.key)&&(_listOfSignedUpPeople[i].userId == currentEvent.userID))
        foundExisting = true;
    }*/
    //if (!foundExisting) {
      if ((currentEvent.maximumScouts == 0)||(currentEvent.maximumScouts > _listOfSignedUpPeople.length)) {
        confirm = true;
      }
   // }
    return confirm;
  }

  onEventEntryChanged(Event event) {
    setState(() {
      int foundIndex = -1;
      for(int i=0;i<EventTitles.length;i++)
      {
        if(EventTitles[i].key == EventModel.fromSnapshot(event.snapshot).key)
          foundIndex = i;
      }
      if (foundIndex == -1) {
        EventTitles.add(EventModel.fromSnapshot(event.snapshot));
      }
      else
        {
          EventTitles[foundIndex] = EventModel.fromSnapshot(event.snapshot);
        }
    });
  }

  onEventEntryAdded(Event event) {
    setState(() {
      int foundIndex = -1;
      for(int i=0;i<EventTitles.length;i++)
      {
        if(EventTitles[i].key == EventModel.fromSnapshot(event.snapshot).key)
          foundIndex = i;
      }
      if (foundIndex == -1) {
        EventTitles.add(EventModel.fromSnapshot(event.snapshot));
      }
      else
      {
        EventTitles[foundIndex] = EventModel.fromSnapshot(event.snapshot);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    for (int i = 0; i<membersList.length; i++){
      if (membersList[i].userId==userId && !membersList[i].isScout){
        isAParent=true;
      }
    }
    int numOfSeats = 0;
    for (int i = 0; i<_listOfDrivers.length; i++){
      numOfSeats+=_listOfDrivers[i].seatsAvailable;
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(formTitle),
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
                      if (allowedToEdit) typeOfEvent = value;
                    });
                  },
                  items: <String>["Troop Meeting","Campout", "Service Project", "PLC", "Patrol Meeting","Court of Honor", "Board of Review", "Other"].map(
                        (String value) {
                      return DropdownMenuItem(
                        value: value,
                        child: new AutoSizeText(value, maxLines: 1, style: TextStyle(color: Colors.grey[600]), overflow: TextOverflow.ellipsis),
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
                      if (allowedToEdit) eventCoordinator= value;
                    });
                  },
                  items: _ListOfTroopMember.map(
                        (value) {
                      return DropdownMenuItem(
                        value: value,
                        //child: new Text(value, style: TextStyle(fontSize: 20, color: Colors.grey[600])),
                        child: new AutoSizeText(value, maxLines: 2, style: TextStyle(color: Colors.grey[600]), overflow: TextOverflow.ellipsis),
                      );},
                  ).toList(),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: TextFormField(
                  enabled: allowedToEdit,
                  controller: _title,
                  validator: (value) =>
                  (value.isEmpty) ? "Please Enter The Title Of The Event" : null,
                  style: style,
                  decoration: InputDecoration(
                      labelText: "Title",
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: TextFormField(
                  enabled: allowedToEdit,
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
                  enabled: allowedToEdit,
                  controller: _minimumAdults,
                  minLines: 1,
                  maxLines: 1,
                  validator: (value) =>
                  (value.isEmpty) ? "Please Enter The Minimum Number Of Adults" : null,
                  style: style,
                  decoration: InputDecoration(
                      labelText: "Minimum # of Adults",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: TextFormField(
                  enabled: allowedToEdit,
                  controller: _minimumSeats,
                  minLines: 1,
                  maxLines: 1,
                  validator: (value) =>
                  (value.isEmpty) ? "Please Enter The Minimum Number Of Seats" : null,
                  style: style,
                  decoration: InputDecoration(
                      labelText: "Minimum # of Seats",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: TextFormField(
                  enabled: allowedToEdit,
                  controller: _maximumScouts,
                  minLines: 1,
                  maxLines: 1,
                  validator: (value) =>
                  (value.isEmpty) ? "Please Enter The Maximum Number Of Attendees" : null,
                  style: style,
                  decoration: InputDecoration(
                      labelText: "Maximum # of Attendees (No limit=0)",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: TextFormField(
                  enabled: allowedToEdit,
                  controller: _location,
                  minLines: 1,
                  maxLines: 4,
                  validator: (value) =>
                  (value.isEmpty) ? "Please Enter The Location of the Event" : null,
                  style: style,
                  decoration: InputDecoration(
                      labelText: "Location of Event",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: TextFormField(
                  enabled: allowedToEdit,
                  controller: fee,
                  minLines: 1,
                  maxLines: 4,
                  validator: (value) =>
                  (value.isEmpty) ? "Please Enter The Fee of the Event" : null,
                  style: style,
                  decoration: InputDecoration(
                      labelText: "Fee (\$)",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: TextFormField(
                  enabled: allowedToEdit,
                  controller: _hours,
                  minLines: 1,
                  maxLines: 1,
                  validator: (value) =>
                  (value.isEmpty) ? "Please Enter The # Of Hours of the Event" : null,
                  style: style,
                  decoration: InputDecoration(
                      labelText: "Hours of Service To Credit",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: TextFormField(
                  enabled: allowedToEdit,
                  controller: _nights,
                  minLines: 1,
                  maxLines: 1,
                  validator: (value) =>
                  (value.isEmpty) ? "Please Enter The # Of Nights of the Event" : null,
                  style: style,
                  decoration: InputDecoration(
                      labelText: "Nights of Camping To Credit",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
                ),
              ),

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
                          if(allowedToEdit)
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
                          if(allowedToEdit)
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
                          if(allowedToEdit)
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
                          if(allowedToEdit)
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
                  readOnly: !allowedToEdit,
                  controller: additionalNotes,
                  minLines: 1,
                  maxLines: 5,
                  validator: (value) =>
                  (value.isEmpty) ? "Enter Any Additional Notes For The Event" : null,
                  style: style,
                  decoration: InputDecoration(
                      labelText: "Additional Notes",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
                ),
              ),

              (!(currentEvent.completed))? SizedBox(height: 10.0):SizedBox(height: 0.0),
              processing
                  ? Center(child: CircularProgressIndicator())
                  : Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Material(
                  elevation: 5.0,
                  borderRadius: BorderRadius.circular(30.0),
                  color: Theme.of(context).primaryColor,
                  child: (!(currentEvent.completed))? MaterialButton(
                    onPressed: () async {
                      if (!alreadyRegistered){
                        alreadyRegistered=true;

                        EventSignUp newSignUp = new EventSignUp(userId, currentEvent.key.toString(),currentEvent.hours, currentEvent.nights,_listOfSignedUpPeople.length,confirmOrDeny(),currentEvent.completed);
                        _database.reference().child("EventSignUp").push().set(newSignUp.toJson());
                        buttonSignUpDropOffText = "De-register";
                      }
                      else {
                        alreadyRegistered=false;
                        updateSignedUpList(seqNumberOfCurrentScout);
                        _database.reference().child("EventSignUp").child(currentSignupKey).remove();
                        generateConfirmedAndWaitingList();
                      }
                      if (_formKey.currentState.validate()) {
                        setState(() {
                          processing = true;
                        });

                        if(pageCameFrom=="myEventsPage"){
                          Navigator.of(context).popUntil((route) => route.isFirst);
                        }
                        if (pageCameFrom=="mainCalendarPage") {
                          Navigator.pop(context);
                        }
                        setState(() {
                          processing = false;
                        });
                      }
                    },
                    child: Text(
                      buttonSignUpDropOffText,
                      style: style.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    ),
                  ):null,
                ),
              ),

              (isAParent && !(currentEvent.completed))? SizedBox(height: 10.0):SizedBox(height: 0.0),
              processing
                  ? Center(child: CircularProgressIndicator())
                  : Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Material(
                  elevation: 5.0,
                  borderRadius: BorderRadius.circular(30.0),
                  color: Theme.of(context).primaryColor,
                  child: (isAParent  && !(currentEvent.completed))? MaterialButton(
                    onPressed: () {
                      if(displayTextForDriver == "Register As Driver"){try {

                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => DriverRegistrationPage(userId: userId, eventKey: currentEvent.key)),
                          );
                      } catch (e) {
                        print(e);
                      }
                    }
                      else{
                        _database.reference().child("Drivers").child(currentSignupDriverKey).remove();
                        Navigator.of(context).popUntil((route) => route.isFirst);
                      }
                    },
                    child: Text(
                      displayTextForDriver,
                      style: style.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    ),
                  ):null,
                ),
              ),
              allowedToEdit? SizedBox(height: 10.0):SizedBox(height: 0.0),
              processing
                  ? Center(child: CircularProgressIndicator())
                  : Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Material(
                  elevation: 5.0,
                  borderRadius: BorderRadius.circular(30.0),
                  color: Theme.of(context).primaryColor,
                  child: allowedToEdit? MaterialButton(
                    onPressed: () async {
                      foundOldEventWithTitle=false;
                      for(int i =0; i<EventTitles.length; i++){
                        if ((EventTitles[i].title ==_title.text) &&(EventTitles[i].key != currentEvent.key)){
                          foundOldEventWithTitle=true;
                        }
                      }
                      int startTime = DateTime(startingYear, startingMonth, startingDay, startingHour, startingMinute).millisecondsSinceEpoch.toInt();
                      int endTime = DateTime(endingYear, endingMonth, endingDay, endingHour, endingMinute).millisecondsSinceEpoch.toInt();
                      if ((_formKey.currentState.validate())&&(startTime <= endTime) && (int.tryParse((double.parse((double.parse(_hours.text)).toStringAsFixed(1)) * 10).round().toString()) != null) &&(!(int.tryParse(_nights.text) == null) && !(int.tryParse(_minimumSeats.text) == null)&& !(int.tryParse(_maximumScouts.text) == null)&& !(int.tryParse(_minimumAdults.text) == null)) && !foundOldEventWithTitle) {
                        setState(() {
                          processing = true;
                        });
                        if(widget.note == null) {
                          String emailOfThisGuy;
                          for (int i = 0; i<membersList.length; i++){
                            if ((membersList[i].firstName + " " + membersList[i].lastName + "\n" + membersList[i].email) == eventCoordinator){
                              emailOfThisGuy = membersList[i].email;
                            }
                          }
                          EventModel event = new EventModel(_title.text, _description.text, int.parse(_minimumAdults.text), int.parse(_minimumSeats.text), int.parse(_maximumScouts.text), _location.text, DateTime(startingYear, startingMonth, startingDay, startingHour, startingMinute).millisecondsSinceEpoch.toInt(), DateTime(endingYear, endingMonth, endingDay, endingHour, endingMinute).millisecondsSinceEpoch.toInt(), userId, fee.text, additionalNotes.text, emailOfThisGuy, typeOfEvent, troop, council, int.parse((double.parse((double.parse(_hours.text)).toStringAsFixed(1)) * 10).round().toString()), (int.parse(_nights.text)).round(), currentEvent.completed);
                          _database.reference().child("EventModel").child(currentEvent.key).set(event.toJson());
                          for(int zz=0; zz<_listOfSignedUpPeople.length;zz++)
                          {
                            bool newConfirmed = false;
                            if ((_listOfSignedUpPeople[zz].sequenceNum < int.parse(_maximumScouts.text))||(int.parse(_maximumScouts.text) == 0))
                            {
                              newConfirmed = true;
                            }
                            EventSignUp updateSignUp = new EventSignUp(_listOfSignedUpPeople[zz].userId, _listOfSignedUpPeople[zz].eventKey, int.parse((double.parse((double.parse(_hours.text)).toStringAsFixed(1)) * 10).round().toString()), (int.parse(_nights.text)).round(), _listOfSignedUpPeople[zz].sequenceNum, newConfirmed, currentEvent.completed);
                            _database.reference().child("EventSignUp").child(_listOfSignedUpPeople[zz].key).set(updateSignUp.toJson());
                          }
                        }
                        Navigator.of(context).popUntil((route) => route.isFirst);
                        setState(() {
                          processing = false;
                        });
                      }
                      else
                      {

                        if (startTime > endTime) {
                          showAlertDialog(context, "The end time should be after the start time");
                        }
                        else if (foundOldEventWithTitle){
                          showAlertDialog(context, "There is an old event with the same title. Please enter a unique title");
                        }
                        else if(eventCoordinator == null) {
                          showAlertDialog(context, "Please select an Event Coordinator");
                        }
                        else if(typeOfEvent == null) {
                          showAlertDialog(context, "Please select the type of event");
                        }
                        else if ((int.tryParse((double.parse((double.parse(_hours.text)).toStringAsFixed(1)) * 10).round().toString()) == null) || (int.tryParse(_nights.text) == null) ||(int.tryParse(_minimumSeats.text) == null) || (int.tryParse(_maximumScouts.text) == null) || (int.tryParse(_minimumAdults.text) == null)){
                          showAlertDialog(context, "Please enter valid numbers for all fields.");
                        }
                      }
                    },
                    child: Text(
                      "Update Event",
                      style: style.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    ),
                  ):null,
                ),
              ),


              allowedToEdit? SizedBox(height: 10.0):SizedBox(height: 0.0),
              processing
                  ? Center(child: CircularProgressIndicator())
                  : Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Material(
                  elevation: 5.0,
                  borderRadius: BorderRadius.circular(30.0),
                  color: Theme.of(context).primaryColor,
                  child: allowedToEdit? MaterialButton(
                    onPressed: () async {
                      if (_formKey.currentState.validate()) {
                        setState(() {
                          processing = true;
                        });
                        if(widget.note == null) {
                          String emailOfThisGuy;
                          for (int i = 0; i<membersList.length; i++){
                            if ((membersList[i].firstName + " " + membersList[i].lastName + "\n" + membersList[i].email) == eventCoordinator){
                            emailOfThisGuy = membersList[i].email;
                          }}
                          EventModel event = new EventModel(_title.text, _description.text, int.parse(_minimumAdults.text), int.parse(_minimumSeats.text), int.parse(_maximumScouts.text), _location.text, DateTime(startingYear, startingMonth, startingDay, startingHour, startingMinute).millisecondsSinceEpoch.toInt(), DateTime(endingYear, endingMonth, endingDay, endingHour, endingMinute).millisecondsSinceEpoch.toInt(), userId, fee.text, additionalNotes.text, emailOfThisGuy, typeOfEvent, troop, council, int.parse((double.parse((double.parse(_hours.text)).toStringAsFixed(1)) * 10).round().toString()), (int.parse(_nights.text)).round(), !(currentEvent.completed));
                          _database.reference().child("EventModel").child(currentEvent.key).set(event.toJson());
                          for(int zz=0; zz<_listOfSignedUpPeople.length;zz++)
                          {
                            EventSignUp updateSignUp = new EventSignUp(_listOfSignedUpPeople[zz].userId, _listOfSignedUpPeople[zz].eventKey, _listOfSignedUpPeople[zz].hours, _listOfSignedUpPeople[zz].nights, _listOfSignedUpPeople[zz].sequenceNum, _listOfSignedUpPeople[zz].confirmed, !(currentEvent.completed));
                            _database.reference().child("EventSignUp").child(_listOfSignedUpPeople[zz].key).set(updateSignUp.toJson());
                          }
                          for(int zz=0; zz<_listOfSignedUpPeople.length;zz++)
                          {if (_listOfSignedUpPeople[zz].confirmed==false) {
                            _database.reference().child("EventSignUp").child(_listOfSignedUpPeople[zz].key).remove();
                            _listOfSignedUpPeople.removeAt(zz);
                          } }
                        }
                        Navigator.of(context).popUntil((route) => route.isFirst);
                        setState(() {
                          processing = false;
                        });
                      }
                    },
                    child: Text(
                      buttonMarkCompleteText,
                      style: style.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    ),
                  ):null,
                ),
              ),


              allowedToEdit? SizedBox(height: 10.0):SizedBox(height: 0.0),
              processing
                  ? Center(child: CircularProgressIndicator())
                  : Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Material(
                  elevation: 5.0,
                  borderRadius: BorderRadius.circular(30.0),
                  color: Theme.of(context).primaryColor,
                  child: allowedToEdit? MaterialButton(
                    onPressed: () async {
                      if (_formKey.currentState.validate()) {
                        setState(() {
                          processing = true;
                        });
                        showAlertDialogDelete(context, currentEvent, _database, pageCameFrom);
                        setState(() {
                          processing = false;
                        });
                      }
                    },
                    child: Text(
                      "Delete Event",
                      style: style.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    ),
                  ):null,
                ),
              ),


              //Padding(
              //  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              // child:
              SizedBox(height: 40),
              SizedBox(height: 40, child: Text("  Totals:  Confirmed - " + _confirmedList.length.toString() + "   Waitlisted - " + _waitlistedList.length.toString() + "\n                Drivers - " + _listOfDrivers.length.toString() + "   Seats - " + numOfSeats.toString(),  style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18))),

              SizedBox(height: 20),

              if(_confirmedList.length>0)SizedBox(height: 20, child: Text("  Confirmed:", style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18))),



              if(_confirmedList.length>0) ..._confirmedList.map((event) => ListTile(
                  contentPadding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 10.0),
                  dense:true,
                  title: Text(event.displayString, style: TextStyle( fontSize: 16)),
                  trailing: ((((allowedToEdit)||(userId == event.userId))&&(event.isScout))? Icon(Icons.arrow_forward_ios):null),
                  onTap:(){
                    try {
                      if(((allowedToEdit)||(userId == event.userId))&&(event.isScout))
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => EditScoutCreditPage(displayString: event.displayString, eventSignup: event._eventSignUp, firstName: event.firstName, lastName: event.lastName
                              , email: event.email)),
                        );
                    } catch (e) {
                      print(e);
                    }

                  }

              )),
              SizedBox(height: 20),

              if(infoOfDrivers.length>0) SizedBox(height: 20, child: Text("  Drivers: ", style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18))),

              if(infoOfDrivers.length>0) ...infoOfDrivers.map((event) => ListTile(
                  contentPadding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 10.0),
                  dense:true,
                  title: Text(event, style: TextStyle( fontSize: 16)))
              ),
              SizedBox(height: 20),

              if(_waitlistedList.length>0) SizedBox(height: 20, child: Text("  Waitlisted: ", style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18))),

              if(_waitlistedList.length>0) ..._waitlistedList.map((event) => ListTile(
                  trailing: ((isThisGuyAScoutmaster)? Icon(Icons.arrow_forward_ios):null),
                  contentPadding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 10.0),
                  dense:true,
                  title: Text(event.displayString, style: TextStyle( fontSize: 16))
              , onTap:(){
                try {
                  if(isThisGuyAScoutmaster)
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => MoveToTopOfListPage(displayString: event.displayString, eventSignup: event._eventSignUp, firstName: event.firstName, lastName: event.lastName
                          , email: event.email, listOfSignedUpPeople: _listOfSignedUpPeople, maxAttendees: currentEvent.maximumScouts)),
                    );
                } catch (e) {
                  print(e);
                }

              })

              )
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
    fee.dispose();
    _onPersonSignedUpAddedSubscription.cancel();
    _onPersonSignedUpChangedSubscription.cancel();
    _onPersonSignedUpRemovedSubscription.cancel();
    _onDriverSignedUpAddedSubscription.cancel();
    _onDriverSignedUpChangedSubscription.cancel();
    _onEventChangedSubscription.cancel();
    _onEventAddedSubscription.cancel();
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
    title: Text("Invalid Update"),
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

showAlertDialogDelete(BuildContext context, EventModel currentEvent, FirebaseDatabase _database, String pageCameFrom) {
  // set up the button
  Widget confirmButton = FlatButton(
      child: Text("Confirm"),
      onPressed: () {
        _database.reference().child("EventSignUp").orderByChild("eventKey").equalTo(currentEvent.key).once().then((DataSnapshot snapshot){
          Map<dynamic, dynamic> values = snapshot.value;
          if(values != null) {
            values.forEach((key, values) {
              _database.reference().child("EventSignUp").child(key).remove();
            });
          }
        });
        _database.reference().child("Drivers").orderByChild("eventKey").equalTo(currentEvent.key).once().then((DataSnapshot snapshot){
          Map<dynamic, dynamic> values = snapshot.value;
          if(values != null) {
            values.forEach((key, values) {
              _database.reference().child("Drivers").child(key).remove();
            });
          }
        });
        _database.reference().child("EventModel").child(currentEvent.key).remove();
        if(pageCameFrom=="myEventsPage"){
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
        if (pageCameFrom=="mainCalendarPage") {
          Navigator.of(context).popUntil((route) => route.isFirst);
        }}
  );
  Widget cancelButton = FlatButton(
    child: Text("Cancel"),
    onPressed: () {Navigator.of(context).pop(); },
  );
  // set up the AlertDialog
  AlertDialog alert = AlertDialog(
    title: Text("Delete Event"),
    content: Text("Are you sure you want to delete this event? Any people registered will also be de-registered."),
    actions: [
      cancelButton,
      confirmButton,

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


