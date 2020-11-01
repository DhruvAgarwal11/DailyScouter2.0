import 'package:flutter/material.dart';
import 'package:flutter_login_demo/services/authentication.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_login_demo/models/troops.dart';
import 'package:flutter_login_demo/models/members.dart';
import 'package:flutter_login_demo/models/Merit_Badges_Earned.dart';
import 'package:flutter_login_demo/models/ScoutBook_DB_Badges.dart';
import 'package:flutter_login_demo/models/ScoutBook_DB_Ranks.dart';
import 'package:flutter_login_demo/pages/main_menu.dart';
import 'dart:async';

String thissitherealemail = "";

class ProfileEditPage extends StatefulWidget {
  ProfileEditPage({Key key, this.auth, this.userId, this.logoutCallback, this.scoutBookList, this.meritBadgesEarnedList, this.scoutBookRanksList})
      : super(key: key);

  Query authMemberQuery;
  final List<ScoutBook_DB_Badges> scoutBookList;
  final List<Merit_Badges_Earned> meritBadgesEarnedList;
  final List<ScoutBook_DB_Ranks> scoutBookRanksList;

  final BaseAuth auth;
  final VoidCallback logoutCallback;
  final String userId;

  @override
  State<StatefulWidget> createState() => new _ProfileEditPageState(userId: userId,
      auth: auth,
      logoutCallback: logoutCallback, scoutBookList: scoutBookList, meritBadgesEarnedList: meritBadgesEarnedList, scoutBookRanksList: scoutBookRanksList);
}

class _ProfileEditPageState extends State<ProfileEditPage> {
  _ProfileEditPageState({this.auth, this.userId, this.logoutCallback, this.scoutBookList, this.meritBadgesEarnedList, this.scoutBookRanksList});

  final BaseAuth auth;
  final VoidCallback logoutCallback;
  final String userId;
  final List<ScoutBook_DB_Badges> scoutBookList;
  final List<Merit_Badges_Earned> meritBadgesEarnedList;
  final List<ScoutBook_DB_Ranks> scoutBookRanksList;

  bool meatloaf = true;

  List<Troops> _troopsList;
  List<Members> _membersList;

  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final databaseReference = FirebaseDatabase.instance.reference();

  StreamSubscription<Event> _onTroopsAddedSubscription;
  StreamSubscription<Event> _onTroopsChangedSubscription;
  StreamSubscription<Event> _onMembersAddedSubscription;
  StreamSubscription<Event> _onMembersChangedSubscription;

  Query _troopsQuery;
  Query _membersQuery;

  @override
  void initState() {
    super.initState();

    _troopsList = new List();
    initialize_flag = false;

    _troopsQuery = _database
        .reference()
        .child("troops");

    _onTroopsAddedSubscription = _troopsQuery.onChildAdded.listen(onEntryAdded);
    _onTroopsChangedSubscription =
        _troopsQuery.onChildChanged.listen(onEntryChanged);

    _membersList = new List();
    _membersQuery = _database
        .reference()
        .child("members");

    _onMembersAddedSubscription =
        _membersQuery.onChildAdded.listen(onMemberEntryAdded);
    _onMembersChangedSubscription =
        _membersQuery.onChildChanged.listen(onMemberEntryChanged);

  }

  @override
  void dispose() {
    _onTroopsAddedSubscription.cancel();
    _onTroopsChangedSubscription.cancel();
    _onMembersAddedSubscription.cancel();
    _onMembersChangedSubscription.cancel();
    super.dispose();
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

  onEntryAdded(Event event) {
    setState(() {
      _troopsList.add(Troops.fromSnapshot(event.snapshot));
      int x=_troopsList.length;
    });
  }

  onMemberEntryChanged(Event event) {
    var oldEntry = _membersList.singleWhere((entry) {
      return entry.key == event.snapshot.key;
    });

    setState(() {
      _membersList[_membersList.indexOf(oldEntry)] =
          Members.fromSnapshot(event.snapshot);
    });
  }

  onMemberEntryAdded(Event event) {
    setState(() {
      _membersList.add(Members.fromSnapshot(event.snapshot));
    });
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

  String _SelectedCouncil;
  String _SelectedTroop;
  String email;
  String profilePhoneNumber;
  String profileAddress;
  String profileBsaId;
  String profileRank;
  bool profileIsScout;
  String profileLeadership;
  bool profileActive;
  bool profileTroopApproved;
  bool profileIsScoutmaster;
  bool profileIsAdmin;
  String firstName;
  String lastName;
  String ScoutorParent;
  String councilFromDatabase;
  String troopFromDatabase;
  bool isScoutFromDatabase;

  bool initialize_flag;
  bool init_once = false;
  final myController = TextEditingController();
  final myController2 = TextEditingController();
  final myController3 = TextEditingController();
  final myController4 = TextEditingController();
  final myController5 = TextEditingController();

  @override
  Widget build(BuildContext context) {
    List<String> _locations = ['A', 'B', 'C', 'D'];
    List<String> _ListOfCouncil = [];
    List<String> _ListOfTroops = [];
    List<String> _ListOfMembers = [];
    String _selectedTroop;


    if(init_once == false)
    {
      for (int j = 0; j < _membersList.length; j++) {
        if (_membersList[j].userId == userId) {
          email = _membersList[j].email;
          profileTroopApproved = _membersList[j].troopApproved;
          profilePhoneNumber = _membersList[j].phoneNumber;
          profileIsAdmin = _membersList[j].isAdmin;
          profileActive = _membersList[j].active;
          profileRank = _membersList[j].rank;
          profileLeadership = _membersList[j].leadershipPosition;
          profileAddress = _membersList[j].address;
          profileBsaId = _membersList[j].bsaId;
          profileIsScoutmaster = _membersList[j].isScoutmaster;
          firstName = _membersList[j].firstName;
          lastName = _membersList[j].lastName;
          councilFromDatabase = _membersList[j].council;
          troopFromDatabase = _membersList[j].troop;
          isScoutFromDatabase = _membersList[j].isScout;
          if(isScoutFromDatabase == null)
          {
            profileIsScout = true;
          }
          else
          {
            profileIsScout = isScoutFromDatabase;
          }

          if (!initialize_flag) {
            initialize_flag = true;
            myController.text = firstName;
            myController2.text = lastName;
            myController3.text = profileAddress;
            myController5.text = profileBsaId;
            myController4.text = profilePhoneNumber;
            if(councilFromDatabase!="") {
              _SelectedCouncil = councilFromDatabase;
            }
            if(troopFromDatabase!="") {
              _SelectedTroop = troopFromDatabase;
            }
            if (isScoutFromDatabase == true) {
              ScoutorParent = "Scout";
            }
            else {
              ScoutorParent = "Parent";
            }
          }
        }
      }
    }

    bool showScoutmasterRemoveButton = false;
    int numScoutmaster =0;
    for (int x = 0; x<_membersList.length; x++){
      if ((_membersList[x].isScoutmaster)&&(_membersList[x].troop == troopFromDatabase)&&(_membersList[x].council==councilFromDatabase)){
        numScoutmaster++;
      }
      }
      if (numScoutmaster>1){
        setState(() {
          showScoutmasterRemoveButton = true;
        });
      }

    int x=_troopsList.length;
    int cindex = 0, tindex = 0;
    bool cbool = false, tbool = false;

    int length_array=(_troopsList.length).toInt();
    if(length_array > 0) {
      for (int index = 0; index < length_array; index++) {
        for(int i=0; i<cindex ; i++) {
          if (_troopsList[index].council.toString() == _ListOfCouncil[i]) {
            cbool = true;
          }
        }
        for(int i=0; i<tindex ; i++) {
          if (_troopsList[index].troop.toString() == _ListOfTroops[i]) {
            tbool = true;
          }
        }
        if(!cbool){
          _ListOfCouncil.add(_troopsList[index].council.toString());
          cindex++;
        }
        if(!tbool){
          _ListOfTroops.add(_troopsList[index].troop.toString());
          tindex++;
        }
        cbool = false;
        tbool = false;
      }
    }

    int next_index = 0;
    _database.reference().child("members").once().then((DataSnapshot snapshot){
      Map<dynamic, dynamic> values = snapshot.value;
      if(values != null) {
        values.forEach((key, values) {
          _ListOfMembers.add(_membersList[next_index++].email.toString());
        });
      }
    });

    bool found_duplicate = false;
    length_array=(_membersList.length).toInt();
    if(length_array > 0) {
      for (int index = 0; index < length_array; index++) {
        for(int temp_index=0;temp_index<index;temp_index++) {
          if (_ListOfMembers[temp_index] == _membersList[index].email.toString())
            found_duplicate = true;
        }
        if (!found_duplicate) _ListOfMembers.add(_membersList[index].email.toString());
      }
    }

    String scouter;
    if (profileIsScout == null)
    {
      scouter = "You are a Scout";
    }
    else
    {
      if(profileIsScout)
      {
        scouter = "You are a Scout";
      }
      else
        scouter = "You are a Parent";
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: new AppBar(
          title: new Text('Edit Your Profile'),
          leading: IconButton(icon:Icon(Icons.arrow_back_ios),
            onPressed:() => Navigator.pop(context, false),
          ),

        ),

        body: ListView(
          children: <Widget>[
            if (profileTroopApproved==true && profileIsScoutmaster)Row(

              children: <Widget>[
                Text('      First Name:       ', style: TextStyle( fontSize: 17, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic)),

                Expanded(
                  child: TextField(
                    controller: myController,
                  ),
                ),
              ],
            ),
            if (profileTroopApproved==true && profileIsScoutmaster)Row(

              children: <Widget>[
                Text('      Last Name:       ', style: TextStyle( fontSize: 17, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic)),
                Expanded(
                  child: TextField(
                    controller: myController2,

                  ),
                ),

              ],
            ),

            if (profileTroopApproved==true && !profileIsScoutmaster)Row(
              children: <Widget>[
                Text('\n      Name: ', style: TextStyle( fontSize: 17, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic)),
                Expanded(child: Text('\n$firstName $lastName     ', style: TextStyle( fontSize: 17)),),
              ],
            ),

            if (profileTroopApproved==true)Row(
              children: <Widget>[
                Text('\n      Troop: ', style: TextStyle( fontSize: 17, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic)),
                Expanded(child: Text('\n$troopFromDatabase', style: TextStyle( fontSize: 17)),),
              ],
            ),
            if (profileTroopApproved==true )Row(
              children: <Widget>[
                Text('\n      Council: ', style: TextStyle( fontSize: 17, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic)),
                Expanded(child: Text('\n$councilFromDatabase', style: TextStyle( fontSize: 17)),),
              ],
            ),
            Row(

              children: <Widget>[
                Text('\n      BSA ID:       ', style: TextStyle( fontSize: 17, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic)),
                Expanded(
                  child: TextField(
                    controller: myController5,
                  ),
                ),
              ],
            ),
            Row(

              children: <Widget>[
                Text('\n      Address:       ', style: TextStyle( fontSize: 17, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic)),
                Expanded(
                  child: TextField(
                    controller: myController3,
                  ),
                ),
              ],
            ),
            Row(
              children: <Widget>[
                Text('\n      Phone Number:       ', style: TextStyle( fontSize: 17, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic)),
                Expanded(
                  child: TextField(
                    controller: myController4,
                  ),
                ),
              ],
            ),
            if (profileTroopApproved==true && isScoutFromDatabase)Row(
              children: <Widget>[
                Text('\n      Leadership Position: ', style: TextStyle( fontSize: 17, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic)),
                Expanded(child: Text('\n$profileLeadership', style: TextStyle( fontSize: 17)),),
              ],
            ),
            if (profileTroopApproved==true && isScoutFromDatabase)Row(
              children: <Widget>[
                Text('\n      Rank: ', style: TextStyle( fontSize: 17, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic)),
                Expanded(child: Text('\n$profileRank', style: TextStyle( fontSize: 17)),),
              ],
            ),
            if (profileTroopApproved==true )Row(

              children: <Widget>[
                Text('\n      Email: ', style: TextStyle( fontSize: 17, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic)),
                Expanded(child: Text('\n$email', style: TextStyle( fontSize: 17)),),
              ],
            ),

            if (profileTroopApproved==true )Row(
              children: <Widget>[
                Text('\n      $scouter ', style: TextStyle( fontSize: 17, color: Colors.blue, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic)),
              ],
            ),
            if (profileTroopApproved==true && (profileIsAdmin==true) )Row(
              children: <Widget>[
                Text('\n      You have admin privileges.     ', style: TextStyle( fontSize: 17, color: Colors.green, fontWeight: FontWeight.bold)),
              ],
            ),
            if (profileTroopApproved==true && (profileIsScoutmaster==true))Row(
              children: <Widget>[
                Text('\n      You are the Scoutmaster.     ', style: TextStyle( fontSize: 17, color: Colors.green, fontWeight: FontWeight.bold)),
              ],
            ),

            const SizedBox(height: 30),
            RaisedButton(
              onPressed: () {
                profileAddress = myController3.text;
                profilePhoneNumber = myController4.text;
                profileBsaId = myController5.text;
                if (profileIsScoutmaster){
                  firstName=myController.text;
                  lastName=myController2.text;
                }

                if(!((_SelectedCouncil == null) || (_SelectedTroop == null) || (firstName=="") || (lastName == "") || (profilePhoneNumber == "")|| (profileAddress == "")))
                {
                      for(int j=0;j<_membersList.length;j++)
                        if(_membersList[j].email == email)
                        {
                          _membersList[j].phoneNumber = profilePhoneNumber;
                          _membersList[j].address = profileAddress;
                          _membersList[j].bsaId = profileBsaId;
                          _membersList[j].firstName = myController.text;
                          _membersList[j].lastName = myController2.text;

                          _database.reference().child("members").child(_membersList[j].key).set(_membersList[j].toJson());

                          //Let's also update the users merit badges info from reference ScoutBook data, if available
                          if(profileBsaId!="")
                            {
                              for(int scoutBookEntryIndex=0;scoutBookEntryIndex<scoutBookList.length;scoutBookEntryIndex++)
                              {
                                if((councilFromDatabase == scoutBookList[scoutBookEntryIndex].council)&&(troopFromDatabase == scoutBookList[scoutBookEntryIndex].troop)
                                    &&(profileBsaId == scoutBookList[scoutBookEntryIndex].bsaId)) {
                                  // Found a merit badge for this person in ScoutBook_DB_Badges
                                  // If there is an existing record, update it if needed
                                  // else add a new record

                                  bool foundExistingMeritBadgeRecord = false;
                                  for(int j=0;j<meritBadgesEarnedList.length;j++)
                                  {
                                    if((meritBadgesEarnedList[j].userId == userId)&&(meritBadgesEarnedList[j].meritBadge == scoutBookList[scoutBookEntryIndex].meritBadge))
                                    {
                                      //Found existing record for this scout for this badge
                                      foundExistingMeritBadgeRecord = true;

                                      // If date matches, then nothing to do, else update record
                                      if(meritBadgesEarnedList[j].date_earned != scoutBookList[scoutBookEntryIndex].date_earned)
                                      {
                                        print("Need to update "+meritBadgesEarnedList[j].meritBadge+" for "+profileBsaId+" with date"+scoutBookList[scoutBookEntryIndex].date_earned+" from earlier date "+meritBadgesEarnedList[j].date_earned);
                                        meritBadgesEarnedList[j].date_earned = scoutBookList[scoutBookEntryIndex].date_earned;
                                        _database.reference().child("Merit_Badges_Earned").child(meritBadgesEarnedList[j].key).set(meritBadgesEarnedList[j].toJson());
                                      }
                                      break;
                                    }
                                  }

                                  // Did not find existing badge entry, and so add new record
                                  if(!foundExistingMeritBadgeRecord)
                                  {
                                    print("Need to add "+scoutBookList[scoutBookEntryIndex].meritBadge+" for "+profileBsaId+" with date"+scoutBookList[scoutBookEntryIndex].date_earned);
                                    Merit_Badges_Earned meritBadgeToAdd = new Merit_Badges_Earned(userId.toString(), scoutBookList[scoutBookEntryIndex].date_earned,scoutBookList[scoutBookEntryIndex].meritBadge,scoutBookList[scoutBookEntryIndex].eagle);
                                    _database.reference().child("Merit_Badges_Earned").push().set(meritBadgeToAdd.toJson());
                                  }
                                }
                              }

                              //Now, let's process the Rank info
                              for(int localCol=0;localCol<scoutBookRanksList.length;localCol++)
                              {
                                if((scoutBookRanksList[localCol].rank != _membersList[j].rank)&&(councilFromDatabase == scoutBookRanksList[localCol].council)&&
                                    (troopFromDatabase == scoutBookRanksList[localCol].troop) &&(profileBsaId == scoutBookRanksList[localCol].bsaId))
                                {
                                  print("Need to update rank for "+profileBsaId+" from "+_membersList[j].rank+" to "+scoutBookRanksList[localCol].rank);
                                  _membersList[j].rank = scoutBookRanksList[localCol].rank;
                                  _database.reference().child("members").child(_membersList[j].key).set(_membersList[j].toJson());
                                  break;
                                }
                              }
                            }

                          showAlertDialog2(context);
                        }

                }
                else {
                  showAlertDialog(context);
                }
              },
              textColor: Colors.white,
              color: Colors.blue,

              child: const Text('Save', style: TextStyle(fontSize: 20)),
            ),

            if (showScoutmasterRemoveButton && profileIsScoutmaster)const SizedBox(height: 30),
            if (showScoutmasterRemoveButton && profileIsScoutmaster)RaisedButton(
              onPressed: () {
                showAlertDialog3(context, _membersList, userId, _database);
              },
              textColor: Colors.white,
              color: Colors.red,

              child: const Text('Remove Myself From SM', style: TextStyle(fontSize: 20)),
            ),
          ],
        ),
      ),
    );
  }
}


showAlertDialog(BuildContext context) {
  // set up the button
  Widget okButton = FlatButton(
    child: Text("OK"),
    onPressed: () {Navigator.of(context).pop(); },
  );
  // set up the AlertDialog
  AlertDialog alert = AlertDialog(
    title: Text("Invalid Attempt"),
    content: Text("The information you entered is invalid. It may be a duplicate, a field may be empty, or it may be an invalid combination."),
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

showAlertDialog2(BuildContext context) {
  // set up the button
  Widget okButton = FlatButton(
    child: Text("OK"),
    onPressed: () {Navigator.of(context).popUntil((route) => route.isFirst); },
  );
  // set up the AlertDialog
  AlertDialog alert = AlertDialog(
    title: Text("Update Successful"),
    content: Text("You have successfully updated your profile!"),
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

showAlertDialog3(BuildContext context, List<Members> membersList, String userId,FirebaseDatabase _database ) {
  // set up the button
  Widget cancelButton = FlatButton(
    child: Text("Cancel"),
    onPressed: () {Navigator.of(context).pop(); },
  );
  Widget confirmButton = FlatButton(
    child: Text("Confirm"),
    onPressed: () {
      for (int i = 0; i<membersList.length; i++){
        if (membersList[i].userId==userId){
          membersList[i].isScoutmaster=false;
          membersList[i].isAdmin=true;
          _database.reference().child("members").child(membersList[i].key).set(membersList[i].toJson());
        }
      }
      Navigator.of(context).popUntil((route) => route.isFirst);
      },
  );
  // set up the AlertDialog
  AlertDialog alert = AlertDialog(
    title: Text("Are you sure?"),
    content: Text("This will remove your scoutmaster privileges. You will still be an admin."),
    actions: [
      cancelButton,
      confirmButton

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