import 'package:flutter/material.dart';
import 'package:flutter_login_demo/pages/edit_troop_info.dart';
import 'package:flutter_login_demo/services/authentication.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_login_demo/models/members.dart';
import 'package:flutter_login_demo/pages/main_menu.dart';
import 'package:flutter_login_demo/models/Merit_Badges_Earned.dart';
import 'package:flutter_login_demo/models/ScoutBook_DB_Badges.dart';
import 'package:flutter_login_demo/models/ScoutBook_DB_Ranks.dart';

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

class LeadershipSetupPage extends StatefulWidget {
  LeadershipSetupPage({Key key, this.auth, this.userId, this.logoutCallback, this.membersList, this.scoutBookList, this.meritBadgesEarnedList, this.councilFromDatabase, this.troopFromDatabase, this.scoutBookRanksList})
      : super(key: key);

  final BaseAuth auth;
  final VoidCallback logoutCallback;
  final String userId;
  final List<Members> membersList;
  final List<ScoutBook_DB_Badges> scoutBookList;
  final List<ScoutBook_DB_Ranks> scoutBookRanksList;
  final List<Merit_Badges_Earned> meritBadgesEarnedList;
  final String councilFromDatabase;
  final String troopFromDatabase;


  @override
  State<StatefulWidget> createState() => new _LeadershipSetupPageState(userId: userId,
      auth: auth,
      logoutCallback: logoutCallback, membersList: membersList, scoutBookList: scoutBookList, meritBadgesEarnedList: meritBadgesEarnedList, councilFromDatabase: councilFromDatabase, troopFromDatabase: troopFromDatabase, scoutBookRanksList: scoutBookRanksList);
}

class _LeadershipSetupPageState extends State<LeadershipSetupPage> {
  _LeadershipSetupPageState({this.auth, this.userId, this.logoutCallback, this.membersList, this.scoutBookList, this.meritBadgesEarnedList, this.councilFromDatabase, this.troopFromDatabase, this.scoutBookRanksList});

  final BaseAuth auth;
  final VoidCallback logoutCallback;
  final String userId;
  final List<ScoutBook_DB_Badges> scoutBookList;
  final List<ScoutBook_DB_Ranks> scoutBookRanksList;
  final List<Merit_Badges_Earned> meritBadgesEarnedList;
  final String councilFromDatabase;
  final String troopFromDatabase;


  final List<Members> membersList;

  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final databaseReference = FirebaseDatabase.instance.reference();

  @override
  void initState() {
    super.initState();
    for (int i =0; i<checkboxClickedIsTrue.length; i++){
      checkboxClickedIsTrue[i]=false;
    }
 }

  @override
  void dispose() {
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

  showMainMenu() async {
    try {
      print("About to call MenuPage");
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

    for (int j = 0; j < membersList.length; j++) {
      if (membersList[j].userId == userId) {
        troopOfScoutmaster = membersList[j].troop;
        councilOfScoutmaster = membersList[j].council;
      }}
    _validIndex.length = 0;
    for (int j = 0; j < membersList.length; j++) {
      if ((membersList[j].troop == troopOfScoutmaster) && (membersList[j].council == councilOfScoutmaster) &&
            (membersList[j].troopApproved==true) && (membersList[j].active) && (!membersList[j].isScoutmaster)) {
            _validIndex.add(j);
      }}
    for (int i = oldValidLength; i < _validIndex.length; i++) {
        checkboxClickedIsTrue[i] = false;
      }
    oldValidLength=_validIndex.length;
    onlyDoOnce = false;

    if (_validIndex.length > 0) {
      return ListView.builder(
          shrinkWrap: true,
          itemCount: _validIndex.length,
          itemBuilder: (BuildContext context, int index) {

            String firstName = membersList[_validIndex[index]].firstName;
            String lastName = membersList[_validIndex[index]].lastName;
            String membersId = membersList[_validIndex[index]].key;
            String email = membersList[_validIndex[index]].email;
            bool isAdmin = membersList[_validIndex[index]].isAdmin;

            void toggleCheckbox(bool value) {
              if(checkboxClickedIsTrue[index] == false)
              {
                // Put your code here which you want to execute on CheckBox Checked event.
                setState(() {
                  checkboxClickedIsTrue[index] = true;
                });
              }
              else
              {
                // Put your code here which you want to execute on CheckBox Un-Checked event.
                setState(() {
                  checkboxClickedIsTrue[index] = false;
                });
              }
            }


            return DataTable (
              key: Key(membersId),
              headingRowHeight: 20,
              dataRowHeight: 70,
              columns: <DataColumn>[
                DataColumn(
                  label: Text(
                    '',
                    style: TextStyle(
                        fontStyle: FontStyle.italic, fontSize: 20),
                  ),
                ),
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
                        Checkbox(tristate: false ,value: checkboxClickedIsTrue[index], activeColor: Colors.blue, onChanged: (value){toggleCheckbox(value);})),

                    DataCell(
                        //(isAdmin)? Text("$firstName $lastName\n$email\nAdmin", style: TextStyle(fontSize: 17)):
                        (isAdmin)?RichText(text: TextSpan(text: "$firstName $lastName\n$email\n" , style: TextStyle(color: Colors.black, fontSize: 17), children: <TextSpan>[TextSpan(text: "Admin", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 17)),
            ],
            ),
            ):
                          Text("$firstName $lastName\n$email\n", style: TextStyle(fontSize: 17))),



                  ],
                ),


              ],
            );
          });
    } else {
      return Center(
          child: Text(
            "Welcome. No scouts or parents to edit.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 30.0),
          ));
    }
  }


  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('Select Members'),
        actions: <Widget>[
          SizedBox(height: 5, width: 1,), RaisedButton(
            onPressed: () {
              try {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => EditTroopInfoPage(userId: userId,
                      auth: auth,
                      logoutCallback: logoutCallback, membersList: membersList, validIndex: _validIndex, checkboxClickedIsTrue: checkboxClickedIsTrue, scoutBookList: scoutBookList, meritBadgesEarnedList:meritBadgesEarnedList, councilFromDatabase: councilFromDatabase, troopFromDatabase: troopFromDatabase, scoutBookRanksList: scoutBookRanksList)),
                );
              } catch (e) {
                print(e);
              }
            },
            textColor: Colors.white,
            color: Colors.blue,

            child: const Text('Select', style: TextStyle(fontSize: 15)),),

        ],
      ),
      body: showMembersList(),


    );
  }
}
