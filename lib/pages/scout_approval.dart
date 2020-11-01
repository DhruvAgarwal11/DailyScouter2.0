import 'package:flutter/material.dart';
import 'package:flutter_login_demo/services/authentication.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_login_demo/models/members.dart';
import 'package:flutter_login_demo/pages/main_menu.dart';
import 'dart:async';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:mailer/smtp_server/amazon.dart';

String email;
String profilePhoneNumber;
String profileAddress;
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
String troopOfScoutmaster;
String councilOfScoutmaster;

class ScoutApprovalPage extends StatefulWidget {
  ScoutApprovalPage({Key key, this.auth, this.userId, this.logoutCallback, this.username, this.password})
      : super(key: key);

  final BaseAuth auth;
  final VoidCallback logoutCallback;
  final String userId;
  final String username;
  final String password;

  @override
  State<StatefulWidget> createState() => new _ScoutApprovalPageState(userId: userId,
      auth: auth,
      logoutCallback: logoutCallback, username: username, password: password);
}

class _ScoutApprovalPageState extends State<ScoutApprovalPage> {
  _ScoutApprovalPageState({this.auth, this.userId, this.logoutCallback, this.username, this.password});

  final BaseAuth auth;
  final VoidCallback logoutCallback;
  final String userId;
  final username;
  final password;

  List<Members> _membersList;

  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final databaseReference = FirebaseDatabase.instance.reference();

  StreamSubscription<Event> _onMembersAddedSubscription;
  StreamSubscription<Event> _onMembersChangedSubscription;

  Query _membersQuery;

  @override
  void initState() {
    super.initState();

    _membersList = new List();

    _membersQuery = _database
        .reference()
        .child("members");
    //.orderByChild("council");
    //.orderByChild("*");
    //.equalTo(widget.userId);
    //.equalTo("55");
    _onMembersAddedSubscription = _membersQuery.onChildAdded.listen(onEntryAdded);
    _onMembersChangedSubscription = _membersQuery.onChildChanged.listen(onEntryChanged);

  }

  @override
  void dispose() {
    _onMembersAddedSubscription.cancel();
    _onMembersChangedSubscription.cancel();
    super.dispose();
  }

  onEntryChanged(Event event) {
    var oldEntry = _membersList.singleWhere((entry) {
      return entry.key == event.snapshot.key;
    });

    setState(() {
      _membersList[_membersList.indexOf(oldEntry)] =
          Members.fromSnapshot(event.snapshot);
    });
  }

  onEntryAdded(Event event) {
    setState(() {
      _membersList.add(Members.fromSnapshot(event.snapshot));
      int x=_membersList.length;
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



  updateMembers(Members members) {
    //Toggle completed
    if (members != null) {
      _database.reference().child("members").child(members.key).set(members.toJson());
    }
  }

  /*deleteMembers(String membersId, int index) {
    _database.reference().child("members").child(membersId).remove().then((_) {
      setState(() {
        _membersList.removeAt(index);
      });
    });
  }*/


    Widget showMembersList() {
      List<Members> listToDisplay = [];
      int indexToFindCorrectPerson = 0;
      int savedIndexFromLast=0;
      for (int j = 0; j < _membersList.length; j++) {
        if (_membersList[j].userId == userId) {
          troopOfScoutmaster = _membersList[j].troop;
          councilOfScoutmaster = _membersList[j].council;
        }}
      int sum = 0;
      for (int j = 0; j < _membersList.length; j++) {
        if ((_membersList[j].troop == troopOfScoutmaster) && (_membersList[j].council == councilOfScoutmaster) && (_membersList[j].troopApproved==false)) {
          sum++;
          listToDisplay.add(_membersList[j]);
        }}
    if (sum > 0) {
        return ListView.builder(
            shrinkWrap: true,
            itemCount: listToDisplay.length,
            itemBuilder: (BuildContext context, int index) {
                String membersId = listToDisplay[index].key;
                String firstName = listToDisplay[index].firstName;
                String lastName = listToDisplay[index].lastName;
                String phoneNumber = listToDisplay[index].phoneNumber;
                String address = listToDisplay[index].address;
                bool scoutOrParent = listToDisplay[index].isScout;
                String email = listToDisplay[index].email;
                String ScoutOrParent;
                if (scoutOrParent == true) {
                  ScoutOrParent = "Scout";
                }
                if (scoutOrParent == false) {
                  ScoutOrParent = "Parent";
                }

              return DataTable (
                key: Key(membersId),
                headingRowHeight: 20,

                  columns: <DataColumn>[
                    DataColumn(
                      label: Text(
                        '',
                        style: TextStyle(
                            fontStyle: FontStyle.italic, fontSize: 20),

                      ),
                    ),


                  ],
                  rows: <DataRow>[
                    DataRow(
                      cells: <DataCell>[
                        DataCell(
                            Text("Name: $firstName $lastName", style: TextStyle(fontSize: 17))),


                      ],
                    ),
                    DataRow(
                      cells: <DataCell>[
                        DataCell(
                            Text("Email: $email", style: TextStyle(fontSize: 17))),


                      ],
                    ),
                    DataRow(
                      cells: <DataCell>[
                        DataCell(
                            Text("Phone: $phoneNumber", style: TextStyle(fontSize: 17))),


                      ],
                    ),
                    DataRow(
                      cells: <DataCell>[
                        DataCell(
                            Text("Address: $address", style: TextStyle(fontSize: 17))),


                      ],
                    ),
                    DataRow(
                      cells: <DataCell>[
                        DataCell(
                            Text("Scout or Parent: $ScoutOrParent", style: TextStyle(fontSize: 17))),


                      ],
                    ),

                    DataRow(
                      cells: <DataCell>[
                        DataCell(
              Center(child:RaisedButton(onPressed: (){
                listToDisplay[index].isApprovedOrRejected = true;
                listToDisplay[index].troopApproved = true;
                listToDisplay[index].active = true;
                main(listToDisplay[index].email, username, password);
                _database.reference().child("members").child(listToDisplay[index].key).set(listToDisplay[index].toJson());
              },textColor: Colors.white,
                color: Colors.blue,

                child: const Text('Approve', style: TextStyle(fontSize: 20)),)
                        ),)


                      ],
                    ),
                    DataRow(
                      cells: <DataCell>[
                        DataCell(
                          Center(child:RaisedButton(onPressed: (){
                            listToDisplay[index].troop = "";
                            listToDisplay[index].council = "";
                            _database.reference().child("members").child(listToDisplay[index].key).set(listToDisplay[index].toJson());
                                main2(listToDisplay[index].email, username, password);
                          },textColor: Colors.white,
                            color: Colors.blue,

                            child: const Text('Reject', style: TextStyle(fontSize: 20)),)
                          ),)


                      ],
                    ),

                  ],

              );
            });
      } else {
        return Center(
            child: Text(
              "Welcome. No scouts or parents to be approved.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 30.0),
            ));
      }
    }


  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          title: new Text('Approve Scouts & Parents'),
        ),
        body: showMembersList(),

    );
  }
}

main(String SelectedSM, String username, String password) async {

  String emailOfScout = '$SelectedSM';

  final smtpServer = amazon(smtpUsername, password);


  // Create our message.
  final message = Message()

    ..from = Address(username, 'Daily Scouter')
    ..recipients.add(emailOfScout)
    ..subject = 'You Have Been Approved For Your Troop!'
    ..text = 'This is the plain text.\nThis is line 2 of the text part.'
    ..html = "<p>Hello,</p>\n<p>Your scoutmaster has approved you to be part of their troop! You may now login and start using the app's other features.</p>\n\n<p>-The Daily Scouter</p> ";

  try {
    final sendReport = await send(message, smtpServer);
  } on MailerException catch (e) {
    for (var p in e.problems) {
      print('Problem: ${p.code}: ${p.msg}');
    }
  }
}

main2(String SelectedSM, String username, String password) async {
  String emailOfScout = '$SelectedSM';

  final smtpServer = amazon(smtpUsername, password);

  final message = Message()
    ..from = Address(username, 'Daily Scouter')
    ..recipients.add(emailOfScout)
    ..subject = 'The Scoutmaster Rejected Your Request'
    ..text = 'This is the plain text.\nThis is line 2 of the text part.'
    ..html = "<p>Hello,</p>\n<p>Unfortunately, you were not accepted into the troop you applied for. If you believe this is a mistake, please contact your scoutmaster, make necessary changes, and submit your application again.</p>\n\n<p>-The Daily Scouter</p> ";

  try {
    final sendReport = await send(message, smtpServer);
  } on MailerException catch (e) {
    for (var p in e.problems) {
      print('Problem: ${p.code}: ${p.msg}');
    }
  }
}