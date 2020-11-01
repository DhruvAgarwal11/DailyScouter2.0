import 'package:flutter/material.dart';
import 'package:flutter_login_demo/services/authentication.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_login_demo/models/members.dart';
import 'package:flutter_login_demo/models/Merit_Badges_Earned.dart';
import 'package:flutter_login_demo/models/meritbadges.dart';
import 'package:flutter_login_demo/pages/main_menu.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
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
String userIDOfSelected;
String firstName;
String lastName;
bool shouldShowTable = false;
bool showSuccessfulDialog = false;
String ScoutorParent;
String councilFromDatabase;
List<String> _ListOfValidName = new List();
List<String> _ListOfMeritBadges = new List();
List<String> _ListOfEarnedMeritBadges = new List();
List<String> listOfEarnedMeritBadges = new List();
List<String> listOfDateEarned = new List();
List<bool> listOfIsEagle = new List();
bool initMeritBadgesList=false;
bool initAlreadyEarnedMeritBadgesList=false;

bool Eagle;


String troopFromDatabase;
bool isScoutFromDatabase;
String troop;
String rank;
String meritBadges;
String currentMeritBadges;
String _errorMessage = "";
bool _errorCondition = true;


String council;
int theRealIndex;
bool onlyDoOnce = true;
int sum = 0;
List<int> validIndex = new List();
var checkboxClickedIsTrue = new List (2000);
List<TextEditingController> lastNameController = new List(2000);
List<TextEditingController> firstNameController = new List(2000);


//List<Members> _membersList;

class InputMeritBadgePage extends StatefulWidget {
  InputMeritBadgePage({Key key, this.auth, this.userId, this.logoutCallback, this.membersList, this.meritBadgesList, this.meritBadgesEarnedList})
      : super(key: key);

  final BaseAuth auth;
  final VoidCallback logoutCallback;
  final String userId;
  final List<Members> membersList;
  final List<MeritBadges> meritBadgesList;
  final List<Merit_Badges_Earned> meritBadgesEarnedList;



  @override
  State<StatefulWidget> createState() => new _InputMeritBadgePageState(userId: userId,
      auth: auth,
      logoutCallback: logoutCallback, membersList: membersList, meritBadgesList: meritBadgesList, meritBadgesEarnedList: meritBadgesEarnedList);
}

class _InputMeritBadgePageState extends State<InputMeritBadgePage> {
  _InputMeritBadgePageState({this.auth, this.userId, this.logoutCallback, this.membersList, this.meritBadgesList, this.meritBadgesEarnedList });

  final BaseAuth auth;
  final VoidCallback logoutCallback;
  final String userId;
  final List<Members> membersList;
  final List<MeritBadges> meritBadgesList;
  final List<Merit_Badges_Earned> meritBadgesEarnedList;

  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final databaseReference = FirebaseDatabase.instance.reference();
  String _date = "Not set";
  String _time = "Not set";

  @override
  void initState() {
    super.initState();
    if(!initMeritBadgesList) {
      for (int i = 0; i < meritBadgesList.length; i++)
        if(meritBadgesList[i].Eagle)
          _ListOfMeritBadges.add(meritBadgesList[i].key);
      for (int i = 0; i < meritBadgesList.length; i++)
        if(!meritBadgesList[i].Eagle)
          _ListOfMeritBadges.add(meritBadgesList[i].key);
    }
    initMeritBadgesList = true;

    String tempDate=DateTime(1971,5,31).toString();
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
  addNewMeritBadgeEarned(String date, String userID, String meritBadge, bool Eagle) {

      Merit_Badges_Earned meritBadgeEarned = new Merit_Badges_Earned(userID.toString(), date.toString(),meritBadge.toString(), Eagle);
      _database.reference().child("Merit_Badges_Earned").push().set(meritBadgeEarned.toJson());
  }

  Widget showErrorMessage() {
    if ((_errorMessage.length > 0) && (_errorMessage != null)) {
      if(_errorCondition) {
        return new Text(
          _errorMessage,
          style: TextStyle(
              fontSize: 18.0,
              color: Colors.red,
              height: 1.0,
              fontWeight: FontWeight.w300),
        );
      }
      else
        {
          return new Text(
            _errorMessage,
            style: TextStyle(
                fontSize: 18.0,
                color: Colors.green,
                height: 1.0,
                fontWeight: FontWeight.w300),
          );
        }
    } else {
      return new Container(
        height: 0.0,
      );
    }
  }

  Widget updateMeritBadges() {
    for (int j = 0; j < membersList.length; j++) {
      if (membersList[j].userId == userId){
        troop = membersList[j].troop;
        council = membersList[j].council;

      }
    }
    validIndex.length = 0;
    _ListOfValidName.length = 0;

    for (int j = 0; j < membersList.length; j++) {
      if ((membersList[j].isScout) && (membersList[j].council==council)&&(membersList[j].troop==troop)&&(membersList[j].troopApproved) && membersList[j].active){
        validIndex.add(j);

        _ListOfValidName.add(membersList[j].firstName+" " +membersList[j].lastName+ "\n"+membersList[j].email);
      }
    }

    if (validIndex.length > 0) {
    return ListView.builder(
          shrinkWrap: true,
          itemCount: 1,
          itemBuilder: (BuildContext context, int index) {
            String leadershipPosition = membersList[validIndex[index]].leadershipPosition;

            if(validIndex.length>0){
              firstNameController[index] = TextEditingController(text: membersList[validIndex[index]].firstName);
              lastNameController[index] = TextEditingController(text: membersList[validIndex[index]].lastName);

              return DataTable (
                headingRowHeight: 60,
                dataRowHeight: 100,
                columnSpacing:0,
                columns: <DataColumn>[
                  DataColumn(

                    label: Text(
                      'Select Scout: ',
                      style: TextStyle(
                          color: Colors.black,fontWeight: FontWeight.bold, fontSize: 15),
                    ),

                  ),

                ],
                rows: <DataRow>[
                  DataRow(
                    cells: <DataCell>[
                      DataCell(
                        DropdownButton(
                          value: rank,
                          onChanged: (value) {
                            setState(() {
                              currentMeritBadges=null;
                              rank = value;
                              for (int z=0; z< membersList.length; z++){
                                if ((membersList[z].firstName.toString()+" "+membersList[z].lastName.toString()+"\n"+membersList[z].email.toString())==rank){
                                  {
                                    userIDOfSelected = membersList[z].userId;
                                  }
                                }
                              }
                              listOfEarnedMeritBadges.length=0;
                              for (int i=0; i<meritBadgesEarnedList.length; i++){
                                if(userIDOfSelected==meritBadgesEarnedList[i].userId){
                                  listOfEarnedMeritBadges.add(meritBadgesEarnedList[i].meritBadge);
                                }
                              }
                            });
                          },
                          items: _ListOfValidName.map(
                                (String value) {
                              return DropdownMenuItem(
                                value: value,
                                child: new Text(value),
                              );},
                          ).toList(),
                        ),),
                    ],
                  ),
                  DataRow(
                    cells: <DataCell>[
                      DataCell(
                        Text(
                          'Choose Merit Badge: ',
                          style: TextStyle(
                              color: Colors.black, fontWeight: FontWeight.bold, fontSize: 15),
                        ),),
                    ],
                  ),
                  DataRow(
                    cells: <DataCell>[
                      DataCell(
                        DropdownButton(
                          value: meritBadges,
                          onChanged: (value) {
                            setState(() {

                              meritBadges = value;
                            });
                          },
                          items: _ListOfMeritBadges.map(
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
                  DataRow(
                    cells: <DataCell>[
                      DataCell(
                        Text(
                          'Date Earned: ',
                          style: TextStyle(
                              color: Colors.black, fontWeight: FontWeight.bold, fontSize: 15),
                        ),),
                    ],
                  ),
                  DataRow(
                    cells: <DataCell>[
                      DataCell(
                        Center(child: Padding(padding: const EdgeInsets.all(16.0),
                                child: Container(child: Column(mainAxisSize: MainAxisSize.max, mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[RaisedButton(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)), elevation: 4.0,
                                        onPressed: () {
                                            DatePicker.showDatePicker(context, theme: DatePickerTheme(containerHeight: 210.0,),
                                              showTitleActions: true, minTime: DateTime(2010, 1, 1), maxTime: DateTime.now(), onConfirm: (date) {
                                                    _date = '${date.year} - ${date.month} - ${date.day}';
                                                    setState(() {});
                                                    }, currentTime: DateTime.now(), locale: LocaleType.en);
                                            },
                                            child: Container(alignment: Alignment.center, height: 50.0,
                                                  child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      children: <Widget>[Row(
                                                        children: <Widget>[Container(
                                                          child: Row(children: <Widget>[
                                                            Icon(Icons.date_range, size: 18.0, color: Colors.blue,),
                                                              Text(" $_date", style: TextStyle(color: Colors.blue, fontSize: 18.0),),
                                                          ],),)],),
                                                      Text("  Change", style: TextStyle(color: Colors.blue, fontSize: 18.0),),],),),
                                                            color: Colors.white,),
                                    ],),),),),),],
                  ),
                  DataRow(
                    cells: <DataCell>[

                      DataCell(
                        Center(child:RaisedButton(onPressed: (){
                          bool doNotAddEntry = false;

                          for (int i = 0; i<meritBadgesList.length; i++){
                            if(meritBadgesList[i].key.toString()==meritBadges){
                              Eagle = meritBadgesList[i].Eagle;
                            }}


                         if(_date == "Not set") {
                            doNotAddEntry = true;
                            _errorMessage = "Date not set";
                            _errorCondition = true;
                            (context as Element).reassemble();
                          }

                          if(meritBadges == null) {
                            doNotAddEntry = true;
                            _errorMessage = "No badge selected";
                            _errorCondition = true;
                            (context as Element).reassemble();
                          }

                          if(rank == null) {
                            doNotAddEntry = true;
                            _errorMessage = "No scout selected";
                            _errorCondition = true;
                            (context as Element).reassemble();
                          }

                          for (int j = 0; j < membersList.length; j++) {
                            if ((membersList[j].firstName+" "+membersList[j].lastName+"\n"+membersList[j].email) == rank){
                              troop = membersList[j].troop;
                              userIDOfSelected = membersList[j].userId;
                              council = membersList[j].council;
                              for(int k=0;k<meritBadgesEarnedList.length;k++)
                                {
                                  if((meritBadgesEarnedList[k].userId == userIDOfSelected) && (meritBadgesEarnedList[k].meritBadge == meritBadges))
                                    {
                                      doNotAddEntry = true;
                                      _errorMessage = "Badge already exists";
                                      _errorCondition = true;
                                      (context as Element).reassemble();
                                      break;
                                    }
                                }
                              if (!doNotAddEntry) {
                                addNewMeritBadgeEarned(_date, userIDOfSelected, meritBadges, Eagle);
                                listOfEarnedMeritBadges.add(meritBadges);
                                (context as Element).reassemble();
                                _errorMessage = "Successfully added badge";
                                _errorCondition = false;
                                (context as Element).reassemble();
                              }
                              break;
                            }
                          }

                        },textColor: Colors.white,
                          color: Colors.blue,

                          child: const Text('Add Merit Badge', style: TextStyle(fontSize: 20)),)
                        ),)


                    ],
                  ),
                  DataRow(
                    cells: <DataCell>[
                      DataCell(
                        showErrorMessage(),),
                    ],
                  ),
                  DataRow(
                    cells: <DataCell>[
                      DataCell(
                        Text(
                          'Current Merit Badges: ',
                          style: TextStyle(
                              color: Colors.black, fontWeight: FontWeight.bold, fontSize: 15),
                        ),),
                    ],
                  ),
                  DataRow(
                    cells: <DataCell>[
                      DataCell(
                        DropdownButton(
                          value: currentMeritBadges,
                          onChanged: (value) {
                            setState(() {
                              currentMeritBadges = value;
                            });
                          },
                          items: listOfEarnedMeritBadges.map(
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
                  DataRow(
                    cells: <DataCell>[

                      DataCell(
                        Center(child:RaisedButton(onPressed: (){
                          for (int j = 0; j < membersList.length; j++) {
                            if ((membersList[j].firstName+" "+membersList[j].lastName+"\n"+membersList[j].email) == rank){
                              userIDOfSelected = membersList[j].userId;
                              for(int x=0;x<meritBadgesEarnedList.length;x++) {
                                if((meritBadgesEarnedList[x].userId==userIDOfSelected)&&(meritBadgesEarnedList[x].meritBadge==currentMeritBadges)) {
                                  _database.reference().child("Merit_Badges_Earned").child(meritBadgesEarnedList[x].key).remove();
                                  listOfEarnedMeritBadges.remove(currentMeritBadges);
                                  meritBadgesEarnedList.removeAt(x);
                                  if (listOfEarnedMeritBadges.length == 0) {
                                    currentMeritBadges = null;
                                  }
                                  else
                                    currentMeritBadges = listOfEarnedMeritBadges[0];
                                  _errorMessage = "";
                                  _errorCondition = false;
                                  (context as Element).reassemble();
                                }
                              }
                              break;
                            }
                          }

                        },textColor: Colors.white,
                          color: Colors.blue,

                          child: const Text('Remove Merit Badge', style: TextStyle(fontSize: 20)),)
                        ),)


                    ],
                  ),

                  /*DataRow(

                    cells: <DataCell>[

                      DataCell(
                        Visibility(
                         visible: shouldShowTable,
                          child: Expanded( child: SizedBox(
                              height: 10000000.0,
                              child: ListView.builder(shrinkWrap: true,itemCount: 3,itemBuilder: (BuildContext context, int index){
                            return ListTile(

                              title: Text("Citizenship in the Nation"),
                              subtitle: Text("HI" + "Meaty"),
                              isThreeLine: true,


                            );
                          })
                          ) ))
                        )
                    ],
                  ),*/
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
            "No scouts in your troop.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 30.0),
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
          title: new Text('Merit Badges'),


      ),
      body: updateMeritBadges(),

    );
  }
}