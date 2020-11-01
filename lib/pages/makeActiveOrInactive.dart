import 'package:flutter/material.dart';
import 'package:flutter_login_demo/services/authentication.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_login_demo/models/members.dart';
import 'package:flutter_login_demo/pages/main_menu.dart';
import 'package:flutter_login_demo/pages/profile_edit.dart';
import 'package:flutter_login_demo/pages/leadership_setup.dart';
import 'package:flutter_login_demo/pages/home_page.dart';
import 'dart:async';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

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
int theRealIndex;
bool onlyDoOnce = true;
int sum = 0;
List<int> _validIndex = new List();
int oldValidLength=0;
var checkboxClickedIsTrue = new List (2000);
List<TextEditingController> lastNameController = new List(2000);
List<TextEditingController> firstNameController = new List(2000);


//List<Members> _membersList;

class MakeActiveOrInactivePage extends StatefulWidget {
  MakeActiveOrInactivePage({Key key, this.auth, this.userId, this.membersList, this.validIndex, this.checkboxClickedIsTrue})
      : super(key: key);

  final BaseAuth auth;
  final String userId;
  final List<Members> membersList;
  var checkboxClickedIsTrue;
  final List<int> validIndex;

  @override
  State<StatefulWidget> createState() => new _MakeActiveOrInactivePageState(userId: userId,
      auth: auth, membersList: membersList, validIndex: validIndex, checkboxClickedIsTrue: checkboxClickedIsTrue);
}

class _MakeActiveOrInactivePageState extends State<MakeActiveOrInactivePage> {
  _MakeActiveOrInactivePageState({this.auth, this.userId, this.membersList, this.validIndex, this.checkboxClickedIsTrue});

  final BaseAuth auth;
  final String userId;
  var checkboxClickedIsTrue;
  final List<int> validIndex;

  final List<Members> membersList;

  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final databaseReference = FirebaseDatabase.instance.reference();

  @override
  void initState() {
    super.initState();

    for (int i = 0; i<membersList.length; i++){
      if (membersList[i].userId == userId){
        profileIsScoutmaster = membersList[i].isScoutmaster;
        profileIsAdmin = membersList[i].isAdmin;
        profileIsScout=membersList[i].isScout;

      }
    }
  }

  @override
  void dispose() {
    super.dispose();
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

  Widget showMembersList() {

    if (validIndex.length > 0) {
      return ListView.builder(
          shrinkWrap: true,
          itemCount: validIndex.length,
          itemBuilder: (BuildContext context, int index) {
            String firstName = membersList[validIndex[index]].firstName;
            String lastName = membersList[validIndex[index]].lastName;
            String email = membersList[validIndex[index]].email;
            String leadershipPosition = membersList[validIndex[index]].leadershipPosition;
            String rank = membersList[validIndex[index]].rank;
            bool active = membersList[validIndex[index]].active;
            String displayActive;
            if (active){
                displayActive = "Active";
            }
            else{
              displayActive="Inactive";
            }


            if(checkboxClickedIsTrue[index]){
      firstNameController[index] = TextEditingController(text: membersList[validIndex[index]].firstName);
      lastNameController[index] = TextEditingController(text: membersList[validIndex[index]].lastName);

      return DataTable (
        headingRowHeight: 20,
        columnSpacing:0,
        columns: <DataColumn>[
          DataColumn(

            label: Text(
              '     ',
              style: TextStyle(
                  fontStyle: FontStyle.italic, fontSize: 50, backgroundColor: Colors.grey),
            ),

          ),
          DataColumn(
            label: Text(
              '     ',
              style: TextStyle(
                  fontStyle: FontStyle.italic, fontSize: 50, backgroundColor: Colors.grey),
            ),
          ),
        ],
        rows: <DataRow>[

          DataRow(
            cells: <DataCell>[
              DataCell(
                Container(
                  width: 100,
                  child: Text("First: ", style: TextStyle(fontStyle: FontStyle.italic, fontSize: 17)))),
              DataCell(
                TextField(
                  controller: firstNameController[index],
                  onChanged: (text) {
                    membersList[validIndex[index]].firstName = text;
                  },
                ),),
            ],
          ),
          DataRow(
            cells: <DataCell>[
              DataCell(
                  Text("Last: ", style: TextStyle(fontStyle: FontStyle.italic, fontSize: 17))),
              DataCell(
                TextField(
                  controller: lastNameController[index],
                  onChanged: (text) {
                    membersList[validIndex[index]].lastName = text;
                  },
                ),),
            ],
          ),
          DataRow(
            cells: <DataCell>[
              DataCell(
                  Text(" ", style: TextStyle(fontStyle: FontStyle.italic, fontSize: 17))),
              DataCell(
                DropdownButton(
                  value: displayActive,
                  onChanged: (value) {
                    setState(() {
                      displayActive = value;
                      if (displayActive=="Active") {
                        membersList[validIndex[index]].active = true;
                      }
                      else{
                        membersList[validIndex[index]].active=false;
                      }
                    });
                  },
            items: <String>["Active", "Inactive"].map(
            (String value) {
              return DropdownMenuItem(
                value: value,
                child: new Text(value, style: TextStyle(fontSize: 14)),
                );
              },
            ).toList(),
                ),),
            ],
          ),
        ],
      );
              }
else{
  return Container();
}
          }
          );

    } else {
      return Center(
          child: Text(
            "No scouts or parents in your troop.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 30.0),
          ));
    }
  }


  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('Update Info'),
          actions: <Widget>[
            SizedBox(height: 20), RaisedButton(
              onPressed:(){
                for(int i=0;i<validIndex.length;i++) {
                  _database.reference().child("members").child(membersList[validIndex[i]].key).set(membersList[validIndex[i]].toJson());
                }
                showAlertDialog(context, "You have successfully updated the members of your troop!");
              },
              textColor: Colors.white,
              color: Colors.blue,
              child: const Text('Save', style: TextStyle(fontSize: 15)),)
          ]

      ),
      body: showMembersList(),



    );
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
    title: Text("Successful Update"),
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
