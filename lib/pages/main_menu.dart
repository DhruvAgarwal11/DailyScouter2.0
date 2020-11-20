import 'package:flutter/material.dart';
import 'package:flutter_login_demo/models/drivers.dart';
import 'package:flutter_login_demo/pages/mainCalendarPage.dart';
import 'package:flutter_login_demo/pages/scout_approval.dart';
import 'package:flutter_login_demo/services/authentication.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_login_demo/pages/super_admin.dart';
import 'package:flutter_login_demo/pages/associatescoutmaster.dart';
import 'package:flutter_login_demo/pages/input_merit_badges.dart';
import 'package:flutter_login_demo/pages/uploadMeritBadges.dart';
import 'package:flutter_login_demo/pages/profile.dart';
import 'package:flutter_login_demo/models/members.dart';
import 'package:flutter_login_demo/models/eventsignup.dart';
import 'package:flutter_login_demo/models/ScoutBook_DB_Badges.dart';
import 'package:flutter_login_demo/models/ScoutBook_DB_Ranks.dart';
import 'package:flutter_login_demo/models/Merit_Badges_Earned.dart';
import 'package:flutter_login_demo/models/EventModel.dart';
import 'package:flutter_login_demo/models/meritbadges.dart';
import 'package:flutter_login_demo/models/Ranks.dart';
import 'package:flutter_login_demo/models/troops.dart';
import 'package:flutter_login_demo/pages/leadership_setup.dart';
import 'package:flutter_login_demo/pages/myEventsPage.dart';
import 'package:flutter_login_demo/pages/myMeritBadges.dart';
import 'package:flutter_login_demo/pages/roster.dart';
import 'package:flutter_login_demo/pages/allEventsPage.dart';
import 'package:flutter_login_demo/pages/announcements.dart';
import 'package:flutter_login_demo/pages/myServiceHours.dart';
import 'package:flutter_login_demo/pages/myCampingNights.dart';
import 'package:flutter_login_demo/pages/attendanceChose.dart';
import 'package:flutter_login_demo/pages/chooseActiveOrInactive.dart';
import 'dart:async';

bool thePersonIsActive = false;
String username;
String password;
String smtpUsername;
String emailOfScoutmaster;


class MenuPage extends StatefulWidget {
  MenuPage({Key key, this.auth, this.userId, this.logoutCallback})
      : super(key: key);

  Query authMemberQuery;

  final BaseAuth auth;
  final VoidCallback logoutCallback;
  final String userId;

  @override
  State<StatefulWidget> createState() => new _MenuPageState(userId: userId,
      auth: auth,
      logoutCallback: logoutCallback);


}
bool hasAllInfo = true;
bool isSuperAdmin = false;
bool isScoutmaster = false;
bool isAdmin = false;
bool troopApproved = false;
bool isScout = false;

class _MenuPageState extends State<MenuPage> {
  _MenuPageState({Key key, this.auth, this.userId, this.logoutCallback});
  final BaseAuth auth;
  final VoidCallback logoutCallback;
  final String userId;
  String troopId;
  String councilId;

  List<Members> _membersList;
  List<Members> _thisTroopMembersList;
  List<Troops> _troopsList;
  List<MeritBadges> _meritBadgesList;
  List<Ranks> _ranksList;
  List<Merit_Badges_Earned> _meritBadgesEarnedList;
  List<EventModel> _listOfEvents;
  List <EventSignUp> eventSignUpList;
  List<Drivers> _listOfDrivers;
  List<ScoutBook_DB_Badges> _listOfScoutBook;
  List<ScoutBook_DB_Ranks> _listOfScoutBookRanks;

  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final databaseReference = FirebaseDatabase.instance.reference();
  StreamSubscription<Event> _onMembersAddedSubscription;
  StreamSubscription<Event> _onMembersChangedSubscription;
  StreamSubscription<Event> _onMembersRemovedSubscription;
  StreamSubscription<Event> _onEventAddedSubscription;
  StreamSubscription<Event> _onEventChangedSubscription;
  StreamSubscription<Event> _onTroopsAddedSubscription;
  StreamSubscription<Event> _onTroopsChangedSubscription;
  StreamSubscription<Event> _onTroopsRemovedSubscription;
  StreamSubscription<Event> _onMeritBadgesAddedSubscription;
  StreamSubscription<Event> _onMeritBadgesChangedSubscription;
  StreamSubscription<Event> _onMeritBadgesRemovedSubscription;
  StreamSubscription<Event> _onRanksAddedSubscription;
  StreamSubscription<Event> _onRanksChangedSubscription;
  StreamSubscription<Event> _onRanksRemovedSubscription;
  StreamSubscription<Event> _onMeritBadgesEarnedAddedSubscription;
  StreamSubscription<Event> _onMeritBadgesEarnedChangedSubscription;
  StreamSubscription<Event> _onEventSignUpAddedSubscription;
  StreamSubscription<Event> _onEventRemovedSubscription;
  StreamSubscription<Event> _onEventSignUpRemovedSubscription;
  StreamSubscription<Event> _onEventSignUpChangedSubscription;
  StreamSubscription<Event> _onMeritBadgesEarnedRemovedSubscription;
  StreamSubscription<Event> _onDriverAddedSubscription;
  StreamSubscription<Event> _onDriverChangedSubscription;
  StreamSubscription<Event> _onDriverRemovedSubscription;
  StreamSubscription<Event> _onScoutBookAddedSubscription;
  StreamSubscription<Event> _onScoutBookChangedSubscription;
  StreamSubscription<Event> _onScoutBookRemovedSubscription;
  StreamSubscription<Event> _onScoutBookRanksAddedSubscription;
  StreamSubscription<Event> _onScoutBookRanksChangedSubscription;
  StreamSubscription<Event> _onScoutBookRanksRemovedSubscription;

  Query _membersQuery;
  Query _troopsQuery;
  Query _EventQuery;
  Query _meritBadgesQuery;
  Query _ranksQuery;
  Query _meritBadgesEarnedQuery;
  Query onEventSignUpQuery;
  Query onDriverQuery;
  Query onScoutBookQuery;
  Query onScoutBookRanksQuery;

  @override
  void initState(){
    super.initState();

    _database.reference().child("Login").once().then((DataSnapshot snapshot) {
      Map<dynamic, dynamic> values = snapshot.value;
      values.forEach((key, value) {
        username = value["login"].toString();
        password = value["password"].toString();
        smtpUsername = value["smtpUsername"].toString();
      });
    });

    //print("Trying to find troop and council "+userId.toString());
    _database.reference().child("members").once().then((DataSnapshot snapshot) {
      Map<dynamic, dynamic> values = snapshot.value;
      if (values != null) {
        values.forEach((key, values) {
          if (values["userId"] == userId) {
            troopId = values["troop"];
            councilId = values["council"];
            print("Initialized troopId="+troopId.toString()+" councilId="+councilId.toString());
          }
        });
      }
    });

    registerAllCallbacks();
    registerSBCallbacks();

    if (userId=="NKRw3jI3B2Y3ZQmixox4hr3PWWL2"){
      isSuperAdmin=true;
    }
    else{
      isSuperAdmin=false;
    }

  }

  registerAllCallbacks () {
    _membersList = new List();
    _thisTroopMembersList = new List();
    _listOfEvents = new List();
    eventSignUpList = new List();
    _listOfDrivers = new List();
    _listOfScoutBook = new List();
    _listOfScoutBookRanks = new List();

    _membersQuery = _database
        .reference()
        .child("members");
    _onMembersAddedSubscription =  _membersQuery.onChildAdded.listen(onMemberEntryAdded);
    _onMembersChangedSubscription = _membersQuery.onChildChanged.listen(onMemberEntryChanged);
    _onMembersRemovedSubscription = _membersQuery.onChildRemoved.listen(onMemberEntryRemoved);

    _EventQuery = _database
        .reference()
        .child("EventModel");
    _onEventAddedSubscription =  _EventQuery.onChildAdded.listen(onEventEntryAdded);
    _onEventChangedSubscription = _EventQuery.onChildChanged.listen(onEventEntryChanged);
    _onEventRemovedSubscription = _EventQuery.onChildRemoved.listen(onEventEntryRemoved);

    _troopsList = new List();
    _troopsQuery = _database
        .reference()
        .child("troops");

    _onTroopsAddedSubscription = _troopsQuery.onChildAdded.listen(onEntryAdded);
    _onTroopsChangedSubscription = _troopsQuery.onChildChanged.listen(onEntryChanged);
    _onTroopsRemovedSubscription = _troopsQuery.onChildRemoved.listen(onEntryRemoved);

    _meritBadgesList = new List();
    _database.reference().child("MeritBadges").once().then((DataSnapshot snapshot) {
    });
    _meritBadgesQuery = _database
        .reference()
        .child("MeritBadges");
    _onMeritBadgesAddedSubscription =  _meritBadgesQuery.onChildAdded.listen(onMeritBadgesEntryAdded);
    _onMeritBadgesChangedSubscription = _meritBadgesQuery.onChildChanged.listen(onMeritBadgesEntryChanged);
    _onMeritBadgesRemovedSubscription = _meritBadgesQuery.onChildChanged.listen(onMeritBadgesEntryRemoved);

    _ranksList = new List();
    _database.reference().child("Ranks").once().then((DataSnapshot snapshot) {
    });
    _ranksQuery = _database
        .reference()
        .child("Ranks");
    _onRanksAddedSubscription =  _ranksQuery.onChildAdded.listen(onRanksEntryAdded);
    _onRanksChangedSubscription = _ranksQuery.onChildChanged.listen(onRanksEntryChanged);
    _onRanksRemovedSubscription = _ranksQuery.onChildChanged.listen(onRanksEntryRemoved);

    _meritBadgesEarnedList = new List();
    _database.reference().child("Merit_Badges_Earned").once().then((DataSnapshot snapshot) {
    });
    _meritBadgesEarnedQuery = _database
        .reference()
        .child("Merit_Badges_Earned");
    _onMeritBadgesEarnedAddedSubscription =  _meritBadgesEarnedQuery.onChildAdded.listen(onMeritBadgesEarnedEntryAdded);
    _onMeritBadgesEarnedChangedSubscription = _meritBadgesEarnedQuery.onChildChanged.listen(onMeritBadgesEarnedEntryChanged);
    _onMeritBadgesEarnedRemovedSubscription = _meritBadgesEarnedQuery.onChildRemoved.listen(onMeritBadgesEarnedEntryRemoved);

    onEventSignUpQuery = _database
        .reference()
        .child("EventSignUp");
    _onEventSignUpAddedSubscription =  onEventSignUpQuery.onChildAdded.listen(onEventSignUpAdded);
    _onEventSignUpChangedSubscription =  onEventSignUpQuery.onChildChanged.listen(onEventSignUpChanged);
    _onEventSignUpRemovedSubscription = onEventSignUpQuery.onChildRemoved.listen(onEventSignUpRemoved);

    onDriverQuery = _database
        .reference()
        .child("Drivers");
    _onDriverAddedSubscription =  onDriverQuery.onChildAdded.listen(onDriverAdded);
    _onDriverChangedSubscription = onDriverQuery.onChildChanged.listen(onDriverChanged);
    _onDriverRemovedSubscription = onDriverQuery.onChildRemoved.listen(onDriverRemoved);

  }

  registerSBCallbacks() {
    _listOfScoutBook = new List();
    onScoutBookQuery = _database
        .reference()
        .child("ScoutBook_DB_Badges");
    _onScoutBookAddedSubscription =  onScoutBookQuery.onChildAdded.listen(onScoutBookAdded);
    _onScoutBookChangedSubscription = onScoutBookQuery.onChildChanged.listen(onScoutBookChanged);
    _onScoutBookRemovedSubscription = onScoutBookQuery.onChildRemoved.listen(onScoutBookRemoved);

    _listOfScoutBookRanks = new List();
    onScoutBookRanksQuery = _database
        .reference()
        .child("ScoutBook_DB_Ranks");
    _onScoutBookRanksAddedSubscription =  onScoutBookRanksQuery.onChildAdded.listen(onScoutBookRanksAdded);
    _onScoutBookRanksChangedSubscription = onScoutBookRanksQuery.onChildChanged.listen(onScoutBookRanksChanged);
    _onScoutBookRanksRemovedSubscription = onScoutBookRanksQuery.onChildRemoved.listen(onScoutBookRanksRemoved);
  }

  onEntryChanged(Event event) {
    var oldEntry = _troopsList.singleWhere((entry) {
      return entry.key == event.snapshot.key;
    });

    setState(() {
      _troopsList[_troopsList.indexOf(oldEntry)] =
          Troops.fromSnapshot(event.snapshot);
    });
  }

  onEntryRemoved(Event event) {
    var oldEntry = _troopsList.singleWhere((entry) {
      return entry.key == event.snapshot.key;
    });
    setState(() {
      _troopsList.removeAt(_troopsList.indexOf(oldEntry));
    });
  }

  onEntryAdded(Event event) {
    setState(() {
      _troopsList.add(Troops.fromSnapshot(event.snapshot));
      int x=_troopsList.length;
    });
  }

  onDriverAdded(Event event) {
    setState(() {
      Map<dynamic, dynamic> values = event.snapshot.value;
      //if (userId == values["userId"])
      {
        for (int i = 0; i<_listOfEvents.length; i++){
          if ((_listOfEvents[i].key == values["eventKey"]) && !_listOfEvents[i].completed){
            _listOfDrivers.add(Drivers.fromSnapshot(event.snapshot));
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

  onScoutBookChanged(Event event) {
    var oldEntry = _listOfScoutBook.singleWhere((entry) {
      return entry.key == event.snapshot.key;
    });

    setState(() {
      _listOfScoutBook[_listOfScoutBook.indexOf(oldEntry)] =
          ScoutBook_DB_Badges.fromSnapshot(event.snapshot);
    });
  }

  onScoutBookRemoved(Event event) {
    try{
    var oldEntry = _listOfScoutBook.singleWhere((entry) {
      return entry.key == event.snapshot.key;
    });
    setState(() {
      _listOfScoutBook.removeAt(_listOfScoutBook.indexOf(oldEntry));
    });
    } catch (e) {
      print(e);
    }
  }

  onScoutBookAdded(Event event)  {
      setState(() {
        if(((ScoutBook_DB_Badges.fromSnapshot(event.snapshot).troop==troopId) && (ScoutBook_DB_Badges.fromSnapshot(event.snapshot).council==councilId))||(troopId == null)||(councilId == null))
        {
              _listOfScoutBook.add(ScoutBook_DB_Badges.fromSnapshot(event.snapshot));
              int x = _listOfScoutBook.length;
        }
      });
  }

  onScoutBookRanksChanged(Event event) {
    var oldEntry = _listOfScoutBookRanks.singleWhere((entry) {
      return entry.key == event.snapshot.key;
    });

    setState(() {
      _listOfScoutBookRanks[_listOfScoutBookRanks.indexOf(oldEntry)] =
          ScoutBook_DB_Ranks.fromSnapshot(event.snapshot);
    });
  }

  onScoutBookRanksRemoved(Event event) {
    try{
      var oldEntry = _listOfScoutBookRanks.singleWhere((entry) {
        return entry.key == event.snapshot.key;
      });
      setState(() {
        _listOfScoutBookRanks.removeAt(_listOfScoutBookRanks.indexOf(oldEntry));
      });
    } catch (e) {
      print(e);
    }
  }

  onScoutBookRanksAdded(Event event)  {
    setState(() {
      if(((ScoutBook_DB_Ranks.fromSnapshot(event.snapshot).troop==troopId) && (ScoutBook_DB_Ranks.fromSnapshot(event.snapshot).council==councilId))||(troopId == null)||(councilId == null))
      {
        _listOfScoutBookRanks.add(ScoutBook_DB_Ranks.fromSnapshot(event.snapshot));
        int x = _listOfScoutBookRanks.length;
      }
    });
  }

  onEventSignUpChanged(Event event) {
    var oldEntry = eventSignUpList.singleWhere((entry) {
      return entry.key == event.snapshot.key;
    });

    setState(() {
        eventSignUpList[eventSignUpList.indexOf(oldEntry)] = EventSignUp.fromSnapshot(event.snapshot);
    });
  }

  onDriverRemoved(Event event) {
    var oldEntry = _listOfDrivers.singleWhere((entry) {
      return entry.key == event.snapshot.key;
    });
    setState(() {
      _listOfDrivers.removeAt(_listOfDrivers.indexOf(oldEntry));
    });
  }


  @override
  void dispose() {

    _onMembersAddedSubscription.cancel();
    _onMembersChangedSubscription.cancel();
    _onMembersRemovedSubscription.cancel();
    _onEventAddedSubscription.cancel();
    _onEventChangedSubscription.cancel();
    _onTroopsAddedSubscription.cancel();
    _onTroopsChangedSubscription.cancel();
    _onMeritBadgesAddedSubscription.cancel();
    _onMeritBadgesChangedSubscription.cancel();
    _onMeritBadgesRemovedSubscription.cancel();
    _onRanksAddedSubscription.cancel();
    _onRanksChangedSubscription.cancel();
    _onRanksRemovedSubscription.cancel();
    _onEventSignUpChangedSubscription.cancel();
    _onMeritBadgesRemovedSubscription.cancel();
    _onMeritBadgesEarnedAddedSubscription.cancel();
    _onMeritBadgesEarnedChangedSubscription.cancel();
    _onEventSignUpAddedSubscription.cancel();
    _onMeritBadgesEarnedRemovedSubscription.cancel();
    _onEventSignUpRemovedSubscription.cancel();
    _onEventRemovedSubscription.cancel();
    _onEventSignUpRemovedSubscription.cancel();
    _onDriverAddedSubscription.cancel();
    _onDriverChangedSubscription.cancel();
    _onDriverRemovedSubscription.cancel();
    _onTroopsRemovedSubscription.cancel();
    _onScoutBookAddedSubscription.cancel();
    _onScoutBookChangedSubscription.cancel();
    _onScoutBookRemovedSubscription.cancel();
    _onScoutBookRanksAddedSubscription.cancel();
    _onScoutBookRanksChangedSubscription.cancel();
    _onScoutBookRanksRemovedSubscription.cancel();

    super.dispose();
  }

  signOut() async {
    try {
      await widget.auth.signOut();
      widget.logoutCallback();
    } catch (e) {
      print(e);
    }
  }

  onMemberEntryChanged(Event event) {
    var oldEntry = _membersList.singleWhere((entry) {
      return entry.key == event.snapshot.key;
    });

    setState(() {
      int i=_membersList.indexOf(oldEntry);
      _membersList[i] = Members.fromSnapshot(event.snapshot);
      if(_membersList[i].userId == userId)
        {
          if (_membersList[i].active == true) {
            thePersonIsActive = true;
            if((_membersList[i].firstName.length != 0) && (_membersList[i].lastName.length != 0) &&(_membersList[i].troop.length != 0) && (_membersList[i].council.length != 0) && (_membersList[i].troopApproved==true) && (_membersList[i].active==true) ){
              hasAllInfo=true;
            }
          } else {
            thePersonIsActive = false;
          }
          isScoutmaster=_membersList[i].isScoutmaster;
          isAdmin = _membersList[i].isAdmin;
        }
      for (int a = 0; a<_thisTroopMembersList.length; a++){
        if (_thisTroopMembersList[a].userId==_membersList[i].userId){
          _thisTroopMembersList[a]=Members.fromSnapshot(event.snapshot);
        }
      }
    });
  }


  onMemberEntryAdded(Event event) {
    setState(() {
      bool foundExisting = false;
      for(int i=0;i<_membersList.length;i++)
        {
          if (_membersList[i].email == Members.fromSnapshot(event.snapshot).email)
            foundExisting = true;
        }
      if (!foundExisting) {
        _membersList.add(Members.fromSnapshot(event.snapshot));
        if((Members.fromSnapshot(event.snapshot).council==councilId)&&(Members.fromSnapshot(event.snapshot).troop==troopId) && Members.fromSnapshot(event.snapshot).troopApproved )
          {
            _thisTroopMembersList.add(Members.fromSnapshot(event.snapshot));
            if(Members.fromSnapshot(event.snapshot).isScoutmaster)
              emailOfScoutmaster = Members.fromSnapshot(event.snapshot).email;
          }
      }
    });
  }

  onEventEntryChanged(Event event) {
    var oldEntry = _listOfEvents.singleWhere((entry) {
      return entry.key == event.snapshot.key;
    });

    setState(() {
      _listOfEvents[_listOfEvents.indexOf(oldEntry)] = EventModel.fromSnapshot(event.snapshot);
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
      if (!foundExisting) {
        _listOfEvents.add(EventModel.fromSnapshot(event.snapshot));
        int x = _listOfEvents.length;
      }
    });
  }
  onEventEntryRemoved(Event event) {
    var oldEntry = _listOfEvents.singleWhere((entry) {
      return entry.key == event.snapshot.key;
    });
    setState(() {
      _listOfEvents.removeAt(_listOfEvents.indexOf(oldEntry));
    });
  }

  onMeritBadgesEntryChanged(Event event) {
    var oldEntry = _meritBadgesList.singleWhere((entry) {
      return entry.key == event.snapshot.key;
    });

    setState(() {
      _meritBadgesList[_meritBadgesList.indexOf(oldEntry)] =
          MeritBadges.fromSnapshot(event.snapshot);
    });
  }

  onMeritBadgesEntryRemoved(Event event) {
    var oldEntry = _meritBadgesList.singleWhere((entry) {
      return entry.key == event.snapshot.key;
    });

    setState(() {
      _meritBadgesList.removeAt(_meritBadgesList.indexOf(oldEntry));
    });
  }

  onRanksEntryChanged(Event event) {
    var oldEntry = _ranksList.singleWhere((entry) {
      return entry.key == event.snapshot.key;
    });

    setState(() {
      _ranksList[_ranksList.indexOf(oldEntry)] =
          Ranks.fromSnapshot(event.snapshot);
    });
  }

  onRanksEntryRemoved(Event event) {
    var oldEntry = _ranksList.singleWhere((entry) {
      return entry.key == event.snapshot.key;
    });

    setState(() {
      _ranksList.removeAt(_ranksList.indexOf(oldEntry));
    });
  }

  onMeritBadgesEarnedEntryRemoved(Event event) {
    var oldEntry = _meritBadgesEarnedList.singleWhere((entry) {
      return entry.key == event.snapshot.key;
    });

    setState(() {
      _meritBadgesEarnedList.removeAt(_meritBadgesEarnedList.indexOf(oldEntry));
    });
  }

  onMeritBadgesEntryAdded(Event event) {
    setState(() {
      _meritBadgesList.add(MeritBadges.fromSnapshot(event.snapshot));
    });
  }

  onRanksEntryAdded(Event event) {
    setState(() {
      _ranksList.add(Ranks.fromSnapshot(event.snapshot));
    });
  }

  onMeritBadgesEarnedEntryChanged(Event event) {
    var oldEntry = _meritBadgesEarnedList.singleWhere((entry) {
      return entry.key == event.snapshot.key;
    });

    setState(() {
      _meritBadgesEarnedList[_meritBadgesEarnedList.indexOf(oldEntry)] =
          Merit_Badges_Earned.fromSnapshot(event.snapshot);
    });
  }

  onMeritBadgesEarnedEntryAdded(Event event) {

    setState(() {
      _meritBadgesEarnedList.add(Merit_Badges_Earned.fromSnapshot(event.snapshot));
    });
  }

  createAlertDialog(BuildContext context) {
    TextEditingController customcontroller = new TextEditingController();
    return showDialog(context: context, builder: (context) {
      return AlertDialog(
        title: Text("Your name"),
        content: TextField(
          controller: customcontroller,
        ),
        actions:<Widget>[
          MaterialButton(
              elevation: 5.0,
              child: Text("Submit"),
              onPressed:(){
                Navigator.pop(context);
              }
          )
        ],
      );
    });
  }

  Widget _showForm() {
    return new Container(
        padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
        child: new Form(
          child: new ListView(
            shrinkWrap: true,
            children: <Widget>[
              if (hasAllInfo && thePersonIsActive) showMainCalendarButton(),
              if (hasAllInfo && thePersonIsActive) showMyEventsButton(),
              if (hasAllInfo && thePersonIsActive) showAllEventsButton(),
              if (hasAllInfo && thePersonIsActive) showAnnouncementsButton(),
              if (hasAllInfo && isScout && thePersonIsActive) showMyMeritBadgesButton(),
              if (hasAllInfo && isScout && thePersonIsActive) showMyServiceHoursButton(),
              if (hasAllInfo && isScout && thePersonIsActive) showMyCampingNightsButton(),
              showProfileButton(),
              if (hasAllInfo && thePersonIsActive) showRosterButton(),
              if ((isAdmin || isScoutmaster) && thePersonIsActive ) showInputMeritBadgeButton(),
              if ((isAdmin || isScoutmaster) && thePersonIsActive) showLeadershipSetupButton(),
              if (isAdmin || isScoutmaster) showUploadMeritBadgesButton(),
              if (isScoutmaster && thePersonIsActive)showScoutApprovalButton(),
              if (isScoutmaster && thePersonIsActive) showAttendanceChooseButton(),
              if (isScoutmaster && thePersonIsActive) showChooseActiveOrInactiveButton(),
              if (isSuperAdmin) showAddTroopButton(),
              if (isSuperAdmin)showAssociateSMButton(),
              showFifthButton()
            ],
          ),
        ));
  }

  showSuperAdminPage() async {
    try {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => SuperAdminPage(userId: userId,
            auth: auth,
            logoutCallback: logoutCallback)),
      );
    } catch (e) {
      print(e);
    }
  }

  showMainCalendarPage() async {
    try {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => MainCalendarPage(
            userId: userId, membersList: _thisTroopMembersList, troop: troopId, council: councilId)),
      );
    } catch (e) {
      print(e);
    }
  }

  showAssociateSMPage() async {
    try {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => AssociateSMPage(userId: userId,
            auth: auth,
            logoutCallback: logoutCallback)),
      );
    } catch (e) {
      print(e);
    }
  }

  showScoutApprovalPage() async {
    try {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ScoutApprovalPage(userId: userId,
            auth: auth,
            logoutCallback: logoutCallback, username: username, password: password)),
      );
    } catch (e) {
      print(e);
    }
  }

  showLeadershipSetupPage() async {
    try {
      print("Main menu length "+_listOfScoutBook.length.toString()+" with councilId="+councilId.toString());
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => LeadershipSetupPage(userId: userId,
            auth: auth,
            logoutCallback: logoutCallback,membersList: _thisTroopMembersList, scoutBookList: _listOfScoutBook, meritBadgesEarnedList:_meritBadgesEarnedList, councilFromDatabase: councilId, troopFromDatabase: troopId, scoutBookRanksList: _listOfScoutBookRanks)),
      );
    } catch (e) {
      print(e);
    }
  }

  showAttendanceChoosePage() async {
    try {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => AttendanceChoosePage(userId: userId,
            auth: auth,
            logoutCallback: logoutCallback,membersList: _thisTroopMembersList, listOfEvents: _listOfEvents, eventSignUpList: eventSignUpList, )),
      );
    } catch (e) {
      print(e);
    }
  }

  showInputMeritBadges() async {
    try {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => InputMeritBadgePage(userId: userId,
            auth: auth,
            logoutCallback: logoutCallback,membersList: _thisTroopMembersList, meritBadgesList: _meritBadgesList, meritBadgesEarnedList: _meritBadgesEarnedList )),
      );
    } catch (e) {
      print(e);
    }
  }

  showMyEventsPage() async {
    try {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => MyEventsPage(userId: userId,
            auth: auth,
            logoutCallback: logoutCallback,membersList: _thisTroopMembersList, meritBadgesList: _meritBadgesList, meritBadgesEarnedList: _meritBadgesEarnedList, listOfEvents: _listOfEvents )),
      );
    } catch (e) {
      print(e);
    }
  }

  showChooseActiveOrInactivePage() async {
    try {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ChooseActiveOrInactivePage(userId: userId, auth: auth,
            logoutCallback: logoutCallback,membersList: _thisTroopMembersList, meritBadgesList: _meritBadgesList, meritBadgesEarnedList: _meritBadgesEarnedList, listOfEvents: _listOfEvents,
            listOfDrivers: _listOfDrivers, eventSignUpList: eventSignUpList, emailOfScoutmaster: emailOfScoutmaster)),
      );
    } catch (e) {
      print(e);
    }
  }
  showUploadMeritBadgesPage() async {
    try {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => UploadMeritBadgePage(council: councilId, troop: troopId, userId: userId, auth: auth,
            logoutCallback: logoutCallback,membersList: _thisTroopMembersList, meritBadgesList: _meritBadgesList, meritBadgesEarnedList: _meritBadgesEarnedList, scoutBookList: _listOfScoutBook, scoutBookRanksList: _listOfScoutBookRanks, ranksList: _ranksList,)),
      );
    } catch (e) {
      print(e);
    }
  }


  showAllEventsPage() async {
    try {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => AllEventsPage(userId: userId,
            auth: auth,
            logoutCallback: logoutCallback,membersList: _thisTroopMembersList, meritBadgesList: _meritBadgesList, meritBadgesEarnedList: _meritBadgesEarnedList, listOfEvents: _listOfEvents )),
      );
    } catch (e) {
      print(e);
    }
  }
  showAnnouncementsPage() async {
    try {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => AnnouncementsPage(userId: userId,
            auth: auth,
            logoutCallback: logoutCallback,membersList: _thisTroopMembersList, meritBadgesList: _meritBadgesList, meritBadgesEarnedList: _meritBadgesEarnedList, listOfEvents: _listOfEvents )),
      );
    } catch (e) {
      print(e);
    }
  }
  showMyMeritBadgesPage() async {
    try {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => MyMeritBadgesPage(userId: userId,
            auth: auth,
            logoutCallback: logoutCallback,membersList: _thisTroopMembersList, meritBadgesList: _meritBadgesList, meritBadgesEarnedList: _meritBadgesEarnedList, listOfEvents: _listOfEvents )),
      );
    } catch (e) {
      print(e);
    }
  }
  showMyServiceHoursPage() async {
    try {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => MyServiceHoursPage(userId: userId, listOfEvents: _listOfEvents )),
      );
    } catch (e) {
      print(e);
    }
  }
  showMyCampingNightsPage() async {
    try {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => MyCampingNightsPage(userId: userId, listOfEvents: _listOfEvents )),
      );
    } catch (e) {
      print(e);
    }
  }
  showRosterPage() async {
    try {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => RosterPage(userId: userId,
            auth: auth,
            logoutCallback: logoutCallback,membersList: _thisTroopMembersList, meritBadgesList: _meritBadgesList, meritBadgesEarnedList: _meritBadgesEarnedList, listOfEvents: _listOfEvents )),
      );
    } catch (e) {
      print(e);
    }
  }

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
          if(!duplicate) {
            if ((EventModel.fromSnapshot(snapshot).typeOfEvent!="PLC") && (EventModel.fromSnapshot(snapshot).typeOfEvent!="Troop Meeting")&&(EventModel.fromSnapshot(snapshot).typeOfEvent!="Patrol Meeting")) {
              _listOfEvents.add(EventModel.fromSnapshot(snapshot));
            }
          }
        });
        values.forEach((key, values) {
          bool duplicate=false;
          for (int i=0;i<_listOfEvents.length;i++)
          {
            if((_listOfEvents[i].title.toString() == values["title"].toString())&&(_listOfEvents[i].startDate.toString() == values["startDate"].toString())&&(_listOfEvents[i].endDate.toString() == values["endDate"].toString()))
              duplicate = true;
          }
          if(!duplicate) {
            if ((EventModel.fromSnapshot(snapshot).typeOfEvent=="PLC") || (EventModel.fromSnapshot(snapshot).typeOfEvent=="Troop Meeting")|| (EventModel.fromSnapshot(snapshot).typeOfEvent=="Patrol Meeting")) {
              _listOfEvents.add(EventModel.fromSnapshot(snapshot));
            }
          }
        });
      }
    });
  }

  onEventSignUpAdded(Event event) {
    setState(() {
      bool duplicateEntry = false;
      for (int i = 0; i < eventSignUpList.length; i++) {
        if (eventSignUpList[i].key == EventSignUp.fromSnapshot(event.snapshot).key) {
          duplicateEntry = true;
          break;
        }
      }
      if (!duplicateEntry) eventSignUpList.add(EventSignUp.fromSnapshot(event.snapshot));
    });
  }
  onEventSignUpRemoved(Event event) {
    var oldEntry = eventSignUpList.singleWhere((entry) {
      return entry.key == event.snapshot.key;
    });

    setState(() {
      eventSignUpList.removeAt(eventSignUpList.indexOf(oldEntry));
    });
  }

  onMemberEntryRemoved(Event event) {
    var oldEntry = _membersList.singleWhere((entry) {
      return entry.key == event.snapshot.key;
    });
    var oldEntry2 = _thisTroopMembersList.singleWhere((entry) {
      return entry.key == event.snapshot.key;
    });

    setState(() {
      _membersList.removeAt(_membersList.indexOf(oldEntry));
      _thisTroopMembersList.removeAt(_thisTroopMembersList.indexOf(oldEntry2));
    });
  }


  getMemberInfo() async {

    await _database.reference().child("members").once().then((DataSnapshot snapshot){
      Map<dynamic, dynamic> values = snapshot.value;
      if(values != null) {
        values.forEach((key, values) {
          bool duplicate = false;

          for (int i=0;i<_membersList.length;i++)
            {
              if(_membersList[i].email == values["email"])
                duplicate = true;
            }

          if (!duplicate) {
            _membersList.add(Members.fromSnapshot(snapshot));
          }

          if (values["userId"] == userId)
          {
            isScout = values["isScout"];
            troopId = values["troop"];
            councilId = values["council"];
            isScoutmaster = values["isScoutmaster"];
            isAdmin = values["isAdmin"];
            troopApproved = values["troopApproved"];
            if((values["firstName"].length ==0 ) || (values["lastName"].length ==0) ||(values["troop"].length ==0) || (values["council"].length ==0) || (values["troopApproved"] == false) || ((values["active"]) == false)){
                hasAllInfo = false;
            }
            else{
              hasAllInfo=true;
            }
            if(values["email"]==username)
            {
              isSuperAdmin=true;
            }
            if (values["active"]){
              thePersonIsActive = true;
            }
          }
        });
      }
    });
    _thisTroopMembersList.length = 0;
    for(int i=0;i<_membersList.length;i++)
      {
        if((_membersList[i].troop==troopId)&&(_membersList[i].council==councilId)&&(_membersList[i].troopApproved))
          {
            bool foundExisting=false;
            for(int j=0;j<_thisTroopMembersList.length;j++) {
              if (_thisTroopMembersList[j].userId == _membersList[i].userId) {
                foundExisting = true;
              }
            }
            if(!foundExisting && _membersList[i].isScout)
              {
                _thisTroopMembersList.add(_membersList[i]);
                if(_membersList[i].isScoutmaster)
                  emailOfScoutmaster = _membersList[i].email;
              }
          }
      }
    for(int i=0;i<_membersList.length;i++)
    {
      if((_membersList[i].troop==troopId)&&(_membersList[i].council==councilId)&&(_membersList[i].troopApproved))
      {
        bool foundExisting=false;
        for(int j=0;j<_thisTroopMembersList.length;j++) {
          if (_thisTroopMembersList[j].userId == _membersList[i].userId) {
            foundExisting = true;
          }
        }
        if(!foundExisting && !_membersList[i].isScout)
        {
          _thisTroopMembersList.add(_membersList[i]);
          if(_membersList[i].isScoutmaster)
            emailOfScoutmaster = _membersList[i].email;
        }
      }
    }

    /*await _database.reference().child("ScoutBook_DB_Badges").once().then((DataSnapshot snapshot){
      Map<dynamic, dynamic> values = snapshot.value;
      if(values != null) {
        values.forEach((key, values) {
          if((values["troop"]==troopId)&&(values["council"]==councilId)&&(troopId != null)&&(councilId != null))
          {
            _listOfScoutBook.add(ScoutBook_DB_Badges.fromSnapshot(snapshot));
          }
        });}
    });*/

   /*_database.reference().child("ScoutBook_DB_Badges").once().then((DataSnapshot snapshot){
      Map<dynamic, dynamic> values = snapshot.value;
      if(values != null) {
        values.forEach((key, values) {
          if((values["troop"]==troopId)&&(values["council"]==councilId)&&(troopId != null)&&(councilId != null))
          {
            bool existingEntryFound = false;
            for (int i=0;i<_listOfScoutBook.length;i++)
              if ((ScoutBook_DB_Badges.fromSnapshot(snapshot).bsaId == _listOfScoutBook[i].bsaId)&&(ScoutBook_DB_Badges.fromSnapshot(snapshot).meritBadge == _listOfScoutBook[i].meritBadge))
                existingEntryFound = true;

            if(!existingEntryFound) {
              _listOfScoutBook.add(ScoutBook_DB_Badges.fromSnapshot(snapshot));
              int x = _listOfScoutBook.length;
            }
          }
        });
      }
    });*/
  }

  Widget showAddTroopButton() {
    return new Padding(
        padding: EdgeInsets.fromLTRB(0.0, 45.0, 0.0, 0.0),
        child: SizedBox(
          height: 40.0,
          child: new RaisedButton(
            elevation: 5.0,
            shape: new RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(30.0)),
            color: Colors.green,
            disabledColor: Colors.green,
            child: new Text('Super Admin: Add New Troop',
                style: new TextStyle(fontSize: 20.0, color: Colors.white)),
            onPressed: showSuperAdminPage,
          ),
        ));
  }
  Widget showMainCalendarButton() {
    return new Padding(
        padding: EdgeInsets.fromLTRB(0.0, 45.0, 0.0, 0.0),
        child: SizedBox(
          height: 40.0,
          child: new RaisedButton(
            elevation: 5.0,
            shape: new RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(30.0)),
            color: Colors.green,
            disabledColor: Colors.green,
            child: new Text('Calendar',
                style: new TextStyle(fontSize: 20.0, color: Colors.white)),
            onPressed: showMainCalendarPage,
          ),
        ));
  }


  Widget showAssociateSMButton() {
    return new Padding(
        padding: EdgeInsets.fromLTRB(0.0, 45.0, 0.0, 0.0),
        child: SizedBox(
          height: 40.0,
          child: new RaisedButton(
            elevation: 5.0,
            shape: new RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(30.0)),
            color: Colors.green,
            disabledColor: Colors.green,
            child: new Text('Super Admin: Associate Scoutmaster',
                style: new TextStyle(fontSize: 20.0, color: Colors.white)),
            onPressed: showAssociateSMPage,
          ),
        ));
  }
  Widget showScoutApprovalButton() {
    return new Padding(
        padding: EdgeInsets.fromLTRB(0.0, 45.0, 0.0, 0.0),
        child: SizedBox(
          height: 40.0,
          child: new RaisedButton(
            elevation: 5.0,
            shape: new RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(30.0)),
            color: Colors.green,
            disabledColor: Colors.green,
            child: new Text('SM: Approve Scouts',
                style: new TextStyle(fontSize: 20.0, color: Colors.white)),
            onPressed: showScoutApprovalPage,
          ),
        ));
  }
  Widget showLeadershipSetupButton() {
    return new Padding(
        padding: EdgeInsets.fromLTRB(0.0, 45.0, 0.0, 0.0),
        child: SizedBox(
          height: 40.0,
          child: new RaisedButton(
            elevation: 5.0,
            shape: new RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(30.0)),
            color: Colors.green,
            disabledColor: Colors.green,
            child: new Text('Admin: Edit Troop Info',
                style: new TextStyle(fontSize: 20.0, color: Colors.white)),
            onPressed: showLeadershipSetupPage,
          ),
        ));
  }
  Widget showAttendanceChooseButton() {
    return new Padding(
        padding: EdgeInsets.fromLTRB(0.0, 45.0, 0.0, 0.0),
        child: SizedBox(
          height: 40.0,
          child: new RaisedButton(
            elevation: 5.0,
            shape: new RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(30.0)),
            color: Colors.green,
            disabledColor: Colors.green,
            child: new Text('SM: View Meeting Attendance',
                style: new TextStyle(fontSize: 20.0, color: Colors.white)),
            onPressed: showAttendanceChoosePage,
          ),
        ));
  }
  Widget showInputMeritBadgeButton() {
    return new Padding(
        padding: EdgeInsets.fromLTRB(0.0, 45.0, 0.0, 0.0),
        child: SizedBox(
          height: 40.0,
          child: new RaisedButton(
            elevation: 5.0,
            shape: new RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(30.0)),
            color: Colors.green,
            disabledColor: Colors.green,
            child: new Text('Admin: Input Merit Badges',
                style: new TextStyle(fontSize: 20.0, color: Colors.white)),
            onPressed: showInputMeritBadges,
          ),
        ));
  }

  showProfilePage() async {
    print("showProfilePage length "+_listOfScoutBook.length.toString());
    try {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ProfilePage(userId: userId,
            auth: auth,
            logoutCallback: logoutCallback,
            membersList: _membersList, scoutBookList: _listOfScoutBook, meritBadgesEarnedList:_meritBadgesEarnedList, scoutBookRanksList: _listOfScoutBookRanks)),
      );
    } catch (e) {
      print(e);
    }
  }

  Widget showProfileButton() {
    return new Padding(
        padding: EdgeInsets.fromLTRB(0.0, 45.0, 0.0, 0.0),
        child: SizedBox(
          height: 40.0,
          child: new RaisedButton(
            elevation: 5.0,
            shape: new RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(30.0)),
            color: Colors.green,
            disabledColor: Colors.green,
            child: new Text('Profile',
                style: new TextStyle(fontSize: 20.0, color: Colors.white)),
            onPressed: showProfilePage,
          ),
        ));
  }

  Widget showSecondButton() {
    return new Padding(
        padding: EdgeInsets.fromLTRB(0.0, 45.0, 0.0, 0.0),
        child: SizedBox(
          height: 40.0,
          child: new RaisedButton(
            elevation: 10.0,
            shape: new RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(30.0)),
            color: Colors.green,
            disabledColor: Colors.green,
            child: new Text('Events',
                style: new TextStyle(fontSize: 20.0, color: Colors.white)),
            onPressed: null,
          ),
        ));
  }

  Widget showMyEventsButton() {
    return new Padding(
        padding: EdgeInsets.fromLTRB(0.0, 45.0, 0.0, 0.0),
        child: SizedBox(
          height: 40.0,
          child: new RaisedButton(
            elevation: 5.0,
            shape: new RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(30.0)),
            color: Colors.green,
            disabledColor: Colors.green,
            child: RichText(
              text: TextSpan(
                  text: 'my',
                  style: TextStyle(fontSize: 20, color: Colors.white, fontStyle: FontStyle.italic, fontWeight: FontWeight.bold ),
                  children: <TextSpan>[
                    TextSpan(
                      text: 'Events',
                      style: TextStyle(
                        fontSize: 20,
                        fontStyle: FontStyle.normal,
                        fontWeight: FontWeight.bold
                      ),
                    ),
                  ]
              ),
            ),
           // child: new Text('myEvents',
              //  style: new TextStyle(fontSize: 20.0, color: Colors.white)),
            onPressed: showMyEventsPage,
          ),
        ));
  }
  Widget showChooseActiveOrInactiveButton() {
    return new Padding(
        padding: EdgeInsets.fromLTRB(0.0, 45.0, 0.0, 0.0),
        child: SizedBox(
          height: 40.0,
          child: new RaisedButton(
            elevation: 5.0,
            shape: new RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(30.0)),
            color: Colors.green,
            disabledColor: Colors.green,
            child: new Text('SM: Activate Scouts',
                style: new TextStyle(fontSize: 20.0, color: Colors.white)),
            // child: new Text('myEvents',
            //  style: new TextStyle(fontSize: 20.0, color: Colors.white)),
            onPressed: showChooseActiveOrInactivePage,
          ),
        ));
  }

  Widget showUploadMeritBadgesButton() {
    return new Padding(
        padding: EdgeInsets.fromLTRB(0.0, 45.0, 0.0, 0.0),
        child: SizedBox(
          height: 40.0,
          child: new RaisedButton(
            elevation: 5.0,
            shape: new RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(30.0)),
            color: Colors.green,
            disabledColor: Colors.green,
            child: new Text('Admin: Sync ScoutBook Data',
                style: new TextStyle(fontSize: 20.0, color: Colors.white)),
            // child: new Text('myEvents',
            //  style: new TextStyle(fontSize: 20.0, color: Colors.white)),
            onPressed: showUploadMeritBadgesPage,
          ),
        ));
  }


  Widget showAllEventsButton() {
    return new Padding(
        padding: EdgeInsets.fromLTRB(0.0, 45.0, 0.0, 0.0),
        child: SizedBox(
          height: 40.0,
          child: new RaisedButton(
            elevation: 5.0,
            shape: new RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(30.0)),
            color: Colors.green,
            disabledColor: Colors.green,
            child: new Text('Upcoming Events',
                style: new TextStyle(fontSize: 20.0, color: Colors.white)),
            // child: new Text('myEvents',
            //  style: new TextStyle(fontSize: 20.0, color: Colors.white)),
            onPressed: showAllEventsPage,
          ),
        ));
  }
  Widget showAnnouncementsButton() {
    return new Padding(
        padding: EdgeInsets.fromLTRB(0.0, 45.0, 0.0, 0.0),
        child: SizedBox(
          height: 40.0,
          child: new RaisedButton(
            elevation: 5.0,
            shape: new RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(30.0)),
            color: Colors.green,
            disabledColor: Colors.green,
            child: new Text('Announcements',
                style: new TextStyle(fontSize: 20.0, color: Colors.white)),
            // child: new Text('myEvents',
            //  style: new TextStyle(fontSize: 20.0, color: Colors.white)),
            onPressed: showAnnouncementsPage,
          ),
        ));
  }

  Widget showMyMeritBadgesButton() {
    return new Padding(
        padding: EdgeInsets.fromLTRB(0.0, 45.0, 0.0, 0.0),
        child: SizedBox(
          height: 40.0,
          child: new RaisedButton(
            elevation: 5.0,
            shape: new RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(30.0)),
            color: Colors.green,
            disabledColor: Colors.green,
            child: RichText(
              text: TextSpan(
                  text: 'my',
                  style: TextStyle(fontSize: 20, color: Colors.white, fontStyle: FontStyle.italic, fontWeight: FontWeight.bold ),
                  children: <TextSpan>[
                    TextSpan(
                      text: 'MeritBadges',
                      style: TextStyle(
                          fontSize: 20,
                          fontStyle: FontStyle.normal,
                          fontWeight: FontWeight.bold
                      ),
                    ),
                  ]
              ),
            ),
            // child: new Text('myEvents',
            //  style: new TextStyle(fontSize: 20.0, color: Colors.white)),
            onPressed: showMyMeritBadgesPage,
          ),
        ));
  }

  Widget showMyCampingNightsButton() {
    return new Padding(
        padding: EdgeInsets.fromLTRB(0.0, 45.0, 0.0, 0.0),
        child: SizedBox(
          height: 40.0,
          child: new RaisedButton(
            elevation: 5.0,
            shape: new RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(30.0)),
            color: Colors.green,
            disabledColor: Colors.green,
            child: RichText(
              text: TextSpan(
                  text: 'my',
                  style: TextStyle(fontSize: 20, color: Colors.white, fontStyle: FontStyle.italic, fontWeight: FontWeight.bold ),
                  children: <TextSpan>[
                    TextSpan(
                      text: 'CampingNights',
                      style: TextStyle(
                          fontSize: 20,
                          fontStyle: FontStyle.normal,
                          fontWeight: FontWeight.bold
                      ),
                    ),
                  ]
              ),
            ),
            // child: new Text('myEvents',
            //  style: new TextStyle(fontSize: 20.0, color: Colors.white)),
            onPressed: showMyCampingNightsPage,
          ),
        ));
  }

  Widget showMyServiceHoursButton() {
    return new Padding(
        padding: EdgeInsets.fromLTRB(0.0, 45.0, 0.0, 0.0),
        child: SizedBox(
          height: 40.0,
          child: new RaisedButton(
            elevation: 5.0,
            shape: new RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(30.0)),
            color: Colors.green,
            disabledColor: Colors.green,
            child: RichText(
              text: TextSpan(
                  text: 'my',
                  style: TextStyle(fontSize: 20, color: Colors.white, fontStyle: FontStyle.italic, fontWeight: FontWeight.bold ),
                  children: <TextSpan>[
                    TextSpan(
                      text: 'ServiceHours',
                      style: TextStyle(
                          fontSize: 20,
                          fontStyle: FontStyle.normal,
                          fontWeight: FontWeight.bold
                      ),
                    ),
                  ]
              ),
            ),
            // child: new Text('myEvents',
            //  style: new TextStyle(fontSize: 20.0, color: Colors.white)),
            onPressed: showMyServiceHoursPage,
          ),
        ));
  }

  Widget showRosterButton() {
    return new Padding(
        padding: EdgeInsets.fromLTRB(0.0, 45.0, 0.0, 0.0),
        child: SizedBox(
          height: 40.0,
          child: new RaisedButton(
            elevation: 5.0,
            shape: new RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(30.0)),
            color: Colors.green,
            disabledColor: Colors.green,
            child: new Text('Roster',
                style: new TextStyle(fontSize: 20.0, color: Colors.white)),
            onPressed: showRosterPage,
          ),
        ));
  }

  Widget showFifthButton() {
    return new Padding(
        padding: EdgeInsets.fromLTRB(0.0, 45.0, 0.0, 0.0),
        child: SizedBox(
          height: 40.0,
          child: new RaisedButton(
            elevation: 5.0,
            shape: new RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(30.0)),
            color: Colors.orange,
            disabledColor: Colors.orange,
            child: new Text('Logout',
                style: new TextStyle(fontSize: 20.0, color: Colors.white)),
            onPressed: signOut,
          ),
        ));
  }

  @override
  Widget build(BuildContext context) {
    getEventsInfo();
    getMemberInfo();

    return new Scaffold(
        appBar: new AppBar(
          title: new Text('Main Menu',
              style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        body: Stack(
            children: <Widget>[
              _showForm(),
            ]),
        );
  }

}

