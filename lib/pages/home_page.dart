import 'package:flutter/material.dart';
import 'package:flutter_login_demo/services/authentication.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_login_demo/models/members.dart';
import 'package:flutter_login_demo/pages/main_menu.dart';
import 'dart:async';
import 'dart:io';

class HomePage extends StatefulWidget {
  HomePage({Key key, this.auth, this.userId, this.email, this.logoutCallback})
      : super(key: key);

  final BaseAuth auth;
  final VoidCallback logoutCallback;
  final String userId;
  final String email;

  @override
  State<StatefulWidget> createState() => new _HomePageState(userId: userId, email: email,
    auth: auth,
    logoutCallback: logoutCallback);
}

class _HomePageState extends State<HomePage> {
  _HomePageState({this.auth, this.userId, this.email, this.logoutCallback});

  final BaseAuth auth;
  final VoidCallback logoutCallback;
  final String userId;
  final String email;

  List<Members> _membersList;

  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final databaseReference = FirebaseDatabase.instance.reference();

  StreamSubscription<Event> _onMembersAddedSubscription;
  StreamSubscription<Event> _onMembersChangedSubscription;

  Query _membersQuery;

  bool _isEmailVerified = false;

  @override
  void initState() {
    super.initState();
    _checkEmailVerification();

    _membersList = new List();

    _membersQuery = _database
        .reference()
        .child("members");

    _onMembersAddedSubscription =  _membersQuery.onChildAdded.listen(onEntryAdded);
    _onMembersChangedSubscription = _membersQuery.onChildChanged.listen(onEntryChanged);
 }

  void _checkEmailVerification() async {
    _isEmailVerified = await widget.auth.isEmailVerified();
    if (!_isEmailVerified) {
      _showVerifyEmailDialog();
    }
    else
    {
      bool foundExistingMember = false;

      await _database.reference().child("members").once().then((DataSnapshot snapshot){
          Map<dynamic, dynamic> values = snapshot.value;
          if(values != null) {
          values.forEach((key, values) {
            if (values["email"] == email)
              foundExistingMember = true;
          });
        }
      });

      if (!foundExistingMember)
        {
          addNewMembers();
          int x=_membersList.length;
        }
     }
  }

  void _resentVerifyEmail(){
    widget.auth.sendEmailVerification();
    _showVerifyEmailSentDialog();
  }

  void _showVerifyEmailDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
         //return object of type Dialog
        return AlertDialog(
          title: new Text("Verify your account"),
          content: new Text("Please verify account in the link sent to email"),
          actions: <Widget>[
            new FlatButton(
              child: new Text("Resend link"),
              onPressed: () {
                Navigator.of(context).pop();
                _resentVerifyEmail();
              },
            ),
            new FlatButton(
              child: new Text("Logout"),
              onPressed: () {
                signOut();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showVerifyEmailSentDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
         //return object of type Dialog
        return AlertDialog(
          title: new Text("Verify your account"),
          content: new Text("Link to verify account has been sent to your email"),
          actions: <Widget>[
            new FlatButton(
              child: new Text("Logout"),
              onPressed: () {
                signOut();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
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

  addNewMembers() {
  //  if (membersItem.length > 0) {
      Members members = new Members(widget.email, widget.userId,"","","","","","", "", "", false, false,false,false,false, null,"");
      _database.reference().child("members").push().set(members.toJson());
   // }
  }

  deleteMembers(String membersId, int index) {
    _database.reference().child("members").child(membersId).remove().then((_) {
      setState(() {
        _membersList.removeAt(index);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return new MenuPage(userId: userId,
        auth: widget.auth,
        logoutCallback: logoutCallback);
  }
}
