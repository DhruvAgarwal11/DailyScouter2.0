import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_login_demo/services/authentication.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_login_demo/models/troops.dart';
import 'package:flutter_login_demo/models/members.dart';
import 'package:flutter_login_demo/pages/main_menu.dart';
import 'dart:async';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:mailer/smtp_server/amazon.dart';

String thissitherealemail = "";

class AssociateSMPage extends StatefulWidget {
  AssociateSMPage({Key key, this.auth, this.userId, this.logoutCallback})
      : super(key: key);

  Query authMemberQuery;

  final BaseAuth auth;
  final VoidCallback logoutCallback;
  final String userId;

  @override
  State<StatefulWidget> createState() => new _AssociateSMPageState(userId: userId,
      auth: auth,
      logoutCallback: logoutCallback);
}

class _AssociateSMPageState extends State<AssociateSMPage> {
  _AssociateSMPageState({this.auth, this.userId, this.logoutCallback});

  final BaseAuth auth;
  final VoidCallback logoutCallback;
  final String userId;
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

    _troopsQuery = _database
        .reference()
        .child("troops");

    _onTroopsAddedSubscription = _troopsQuery.onChildAdded.listen(onEntryAdded);
    _onTroopsChangedSubscription = _troopsQuery.onChildChanged.listen(onEntryChanged);

    _membersList = new List();

    _membersQuery = _database
        .reference()
        .child("members");

    _onMembersAddedSubscription =  _membersQuery.onChildAdded.listen(onMemberEntryAdded);
    _onMembersChangedSubscription = _membersQuery.onChildChanged.listen(onMemberEntryChanged);
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
  String _SelectedSM;

  addNewTroops(String troopsItem1, String troopsItem2, bool isSMasterAssigned) {
    if ((troopsItem1.length > 0) && (troopsItem2.length > 0))
    {
      Troops troops = new Troops(troopsItem1.toString(), troopsItem2.toString(),isSMasterAssigned);
      _database.reference().child("troops").push().set(troops.toJson());
    }
  }

  updateTroops(Troops troops) {
    //Toggle completed
    if (troops != null) {
      _database.reference().child("troops").child(troops.key).set(troops.toJson());
    }
  }

  deleteTroops(String troopsId, int index) {
    _database.reference().child("troops").child(troopsId).remove().then((_) {
      setState(() {
        _troopsList.removeAt(index);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    List<String> _locations = ['A', 'B', 'C', 'D'];
    List<String> _ListOfCouncil = [];
    List<String> _ListOfTroops = [];
    List<String> _ListOfMembers = [];
    String _selectedTroop;

    int x=_troopsList.length;
    int cindex = 0, tindex = 0;
    bool cbool = false, tbool = false;

    int length_array=(_troopsList.length).toInt();
    if(length_array > 0) {
      for (int index = 0; index < length_array; index++) {
        print(_troopsList[index].council.toString()+_troopsList[index].troop.toString());
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


    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: new AppBar(
          title: new Text('Designate ScoutMaster'),
          leading: IconButton(icon:Icon(Icons.arrow_back_ios),
          onPressed:() => Navigator.pop(context, false),
    )
        ),

        body: ListView(
              children: <Widget>[

                Row(

                  children: <Widget>[
                    Text('      Council:       ', style: TextStyle( fontSize: 15)),

                    Center(
                      child: DropdownButton(
                        value: _SelectedCouncil,
                        onChanged: (value) {
                          setState(() {
                            _SelectedCouncil = value;
                          });
                        },
                        items: _ListOfCouncil.map(
                              (item) {
                            return DropdownMenuItem(
                              value: item,
                              child: new Text(item),
                            );},
                        ).toList(),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: <Widget>[
                    Text('      Troop:       ', style: TextStyle( fontSize: 15)),
                    Center(
                      child: DropdownButton(
                        value: _SelectedTroop,
                        onChanged: (value) {
                          setState(() {
                            _SelectedTroop = value;
                          });
                        },
                        items: _ListOfTroops.map(
                              (item) {
                            return DropdownMenuItem(
                              value: item,
                              child: new Text(item),
                            );},
                        ).toList(),
                      ),
                    ),
                  ],
                ),
                Row(

                  children: <Widget>[
                    Text('      SM:       ', style: TextStyle( fontSize: 15)),
                    Center(
                      child: DropdownButton(
                        value: _SelectedSM,
                        onChanged: (value) {
                          setState(() {
                            _SelectedSM = value;
                          });
                        },
                        items: _ListOfMembers.map(
                              (item) {
                            return DropdownMenuItem(
                              value: item,
                              child: new AutoSizeText(item, maxLines: 1,),

                            );},
                        ).toList(),
                      ),

                    ),
                  ],
                ),

                    const SizedBox(height: 30),
                    RaisedButton(
                        onPressed: () {

                          if(!(_SelectedCouncil==null || _SelectedTroop==null || _SelectedSM==null))
                          {
                            for(int i = 0; i<_troopsList.length; i++)
                            {
                              if ((_troopsList[i].council.toString()==_SelectedCouncil) && (_troopsList[i].troop.toString()==_SelectedTroop))
                              {
                                for(int j=0;j<_membersList.length;j++)
                                  if(_membersList[j].email == _SelectedSM)
                                  {
                                    _membersList[j].troop = _SelectedTroop;
                                    _membersList[j].council = _SelectedCouncil;
                                    _membersList[j].troopApproved = true;
                                    _membersList[j].isAdmin = true;
                                    _membersList[j].isScoutmaster= true;
                                    _membersList[j].isApprovedOrRejected=true;
                                    _membersList[j].active=true;



                                    for(int k=0; k<_troopsList.length; k++)
                                    {
                                      if ((_troopsList[k].council==_SelectedCouncil) && (_troopsList[k].troop==_SelectedTroop))
                                      {
                                        _troopsList[k].isSMasterAssigned=true;
                                        _database.reference().child("troops").child(_troopsList[k].key).set(_troopsList[k].toJson());
                                        meatloaf = false;
                                      }

                                    }
                                    _database.reference().child("members").child(_membersList[j].key).set(_membersList[j].toJson());
                                    main(_SelectedSM.toString(), username, password);
                                    showAlertDialog2(context);
                                  }
                              }

                            }
                          }
                          if (meatloaf){
                            showAlertDialog(context);
                          }
                          meatloaf = true;
                        },
                      textColor: Colors.white,
                      color: Colors.blue,

                      child: const Text('Submit', style: TextStyle(fontSize: 20)),
                    ),



              ],
        ),
      ),
    );
  }
}


void _showResetPasswordEmailSentDialog() {
  showDialog(

    builder: (BuildContext context) {
      // return object of type Dialog
      return AlertDialog(
        title: new Text("Invalid Attempt"),
        content:
        new Text("The information you entered is invalid. It may be a duplicate or an invalid combination."),
        actions: <Widget>[
          new FlatButton(
            child: new Text("Dismiss"),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
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
    onPressed: () {Navigator.of(context).pop(); },
  );
  // set up the AlertDialog
  AlertDialog alert = AlertDialog(
    title: Text("Update Successful"),
    content: Text("You have successfully designated a scoutmaster."),
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

main(String SelectedSM, String username, String password) async {
  String emailOfScoutmaster = '$SelectedSM';

  final smtpServer = amazon(smtpUsername, password);
  // Use the SmtpServer class to configure an SMTP server:
  // final smtpServer = SmtpServer('smtp.domain.com');
  // See the named arguments of SmtpServer for further configuration
  // options.

  // Create our message.
  final message = Message()

  ..from = Address(username, 'Daily Scouter')
    ..recipients.add(emailOfScoutmaster)
    ..subject = 'Your Troop Has Been Created'
    ..html = "<p>Hello,</p>\n<p>Your troop has been created and you have been assigned as the scoutmaster of your troop and may now login to your account. The scouts and parents of your troop may now start to create accounts and login.</p>\n<p>Thanks again for deciding to use the Daily Scouter. Here is a breakdown of how the app works:</p>\n<p>- Anyone who is active in the troop can add an event, view the events that they have signed up for, see any upcoming events, see the troop calendar, register for events, view the roster, and edit their profile</p>\n<p>- Scouts are able to view their camping nights and the service projects they have attended</p>\n<p>- Admins are able to edit information about the scouts such as their rank and leadership position</p>\n<p>- Admins are also able to input merit badges for the scouts</p>\n<p>- You, the scoutmaster, or any other scoutmasters that you assign, will be able to make scouts active or inactive (meaning they are no longer part of the troop) and view meeting attendance for scouts</p>\n\n<p>- There are many more features, though these are the basics. Training videos are available at https://DailyScouter.com.</p>\n<p>Feel free to reach out to us at dailyscouter@gmail.com for any questions. I hope you and your troop enjoy using the app!</p><p>-The Daily Scouter</p> ";

  try {
    final sendReport = await send(message, smtpServer);
  } on MailerException catch (e) {
    for (var p in e.problems) {
      print('Problem: ${p.code}: ${p.msg}');
    }
  }
}