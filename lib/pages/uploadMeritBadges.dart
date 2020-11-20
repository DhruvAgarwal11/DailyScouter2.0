import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_login_demo/services/authentication.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_login_demo/models/members.dart';
import 'package:flutter_login_demo/models/Merit_Badges_Earned.dart';
import 'package:flutter_login_demo/models/ScoutBook_DB_Badges.dart';
import 'package:flutter_login_demo/models/ScoutBook_DB_Ranks.dart';
import 'package:flutter_login_demo/models/meritbadges.dart';
import 'package:flutter_login_demo/models/Ranks.dart';
import 'package:flutter_login_demo/pages/main_menu.dart';
import 'dart:async';
import 'dart:core';
import 'package:file_picker/file_picker.dart';

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
int col = 500;
int row = 500;
int currentRow = 0;

var arrayOfData = List.generate(row, (i) => List(col), growable: false);

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

class UploadMeritBadgePage extends StatefulWidget {
  UploadMeritBadgePage({Key key, this.auth, this.userId, this.logoutCallback, this.membersList, this.meritBadgesList, this.meritBadgesEarnedList, this.scoutBookList, this.ranksList, this.scoutBookRanksList, this.council, this.troop})
      : super(key: key);

  final BaseAuth auth;
  final VoidCallback logoutCallback;
  final String userId;
  final String council;
  final String troop;
  final List<Members> membersList;
  final List<MeritBadges> meritBadgesList;
  final List<Ranks> ranksList;
  final List<Merit_Badges_Earned> meritBadgesEarnedList;
  final List<ScoutBook_DB_Badges> scoutBookList;
  final List<ScoutBook_DB_Ranks> scoutBookRanksList;

  @override
  State<StatefulWidget> createState() => new _UploadMeritBadgePageState(userId: userId,
      auth: auth,
      logoutCallback: logoutCallback, membersList: membersList, meritBadgesList: meritBadgesList, meritBadgesEarnedList: meritBadgesEarnedList, scoutBookList: scoutBookList, ranksList: ranksList, scoutBookRanksList: scoutBookRanksList, council: council, troop: troop);
}

class _UploadMeritBadgePageState extends State<UploadMeritBadgePage> {
  _UploadMeritBadgePageState({this.auth, this.userId, this.logoutCallback, this.membersList, this.meritBadgesList, this.meritBadgesEarnedList, this.scoutBookList, this.ranksList, this.scoutBookRanksList, this.council, this.troop });

  final BaseAuth auth;
  final VoidCallback logoutCallback;
  final String userId;
  final String council;
  final String troop;
  final List<Members> membersList;
  final List<MeritBadges> meritBadgesList;
  final List<Ranks> ranksList;
  final List<Merit_Badges_Earned> meritBadgesEarnedList;
  final List<ScoutBook_DB_Badges> scoutBookList;
  final List<ScoutBook_DB_Ranks> scoutBookRanksList;

  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final databaseReference = FirebaseDatabase.instance.reference();
  String _date = "Not set";
  String _time = "Not set";
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String _fileName;
  List<PlatformFile> _paths;
  String _directoryPath;
  String _extension;
  bool _loadingPath = false;
  bool _multiPick = false;
  FileType _pickingType = FileType.any;
  TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(() => _extension = _controller.text);

    if(!initMeritBadgesList) {
      for (int i = 0; i < meritBadgesList.length; i++)
        if(meritBadgesList[i].Eagle)
          _ListOfMeritBadges.add(meritBadgesList[i].key);
      for (int i = 0; i < meritBadgesList.length; i++)
        if(!meritBadgesList[i].Eagle)
          _ListOfMeritBadges.add(meritBadgesList[i].key);
    }
    initMeritBadgesList = true;
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

  Future<String> _openFileExplorer() async {
    setState(() => _loadingPath = true);
    try {
      _directoryPath = null;
      _paths = (await FilePicker.platform.pickFiles(
        type: FileType.any,
      ))
          ?.files;

      String p;
      if(_paths[0].extension == 'csv')
        print("Is csv with path:"+_paths[0].path.toString());
      else {
        print("Incorrect format" + _paths[0].extension + _paths[0].path.toString());
        return("Failed");
      }

      currentRow = 0;
      arrayOfData = List.generate(row, (i) => List(col), growable: false);
      //arrayOfData.length = 0;

      final file = File(_paths[0].path);
      String contents = await file.readAsString();
      await file.readAsLines().then((lines) =>
          lines.forEach((l) /*=>*/  {
            arrayOfData[currentRow]=l.split("\",\"");
            if(arrayOfData[currentRow][0]!=null)
              {
                arrayOfData[currentRow][0] = arrayOfData[currentRow][0].substring(1);
              }
            if(arrayOfData[currentRow][arrayOfData[currentRow].length - 1]!=null)
            {
              arrayOfData[currentRow][arrayOfData[currentRow].length - 1] = arrayOfData[currentRow][arrayOfData[currentRow].length - 1].substring(0,(arrayOfData[currentRow][arrayOfData[currentRow].length - 1].length - 1));
            }
            currentRow = currentRow+1;
          }));
      return("Done");
    } on PlatformException catch (e) {
      print("Unsupported operation" + e.toString());
    } catch (ex) {
      print(ex);
    }
    if (!mounted) return("Failed");
    setState(() {
      _loadingPath = false;
      _fileName = _paths != null ? _paths.map((e) => e.name).toString() : '...';
    });
  }

  void _inputOrDeleteDataFile() async{
    if(scoutBookList.length > 0)
      {
        // First remove the current existing data from earlier upload
        if(await removeCurrentDataForTroop())
          {
            showAlertDialog(context, "Successfully Deleted Previous ScoutBook Reference Data!");
            return;
          }
        else
          {
            showAlertDialog(context, "Error Deleting Previous ScoutBook Reference Data!");
            return;
          }
      }

    if(await _openFileExplorer() == "Failed")
      {
        showAlertDialog(context, "Error: File type is incorrect!");
        return;
      }
    if(validFileContents())
      {
         // Start processing the new file now

        // First, process the merit badges info
         for(int localRow=3;localRow<currentRow;localRow++)
         {
           String badgeNameToStore;
           bool eagleRequired;
           bool found_merit_badge_mapping;

           found_merit_badge_mapping = false;
           // Get the Merit badge details
           for (int i=0;i<meritBadgesList.length;i++)
             if(meritBadgesList[i].DB == arrayOfData[localRow][0])
               {
                 badgeNameToStore = meritBadgesList[i].key;
                 eagleRequired = meritBadgesList[i].Eagle;
                 found_merit_badge_mapping = true;
                 break;
               }

           for(int localCol=1;(localCol<arrayOfData[localRow].length) && found_merit_badge_mapping;localCol++)
           {
             if(arrayOfData[localRow][localCol] != "Not Started")
             {
               // Check if this is a date
               List<String> subStringsList = arrayOfData[localRow][localCol].split("/");
               if(subStringsList.length == 3)
               {
                 String date_earned = "20"+subStringsList[2]+" - "+subStringsList[0]+" - "+subStringsList[1];

                 ScoutBook_DB_Badges scoutBook_DB_Badges = new ScoutBook_DB_Badges(council, troop, arrayOfData[1][localCol].toString(),date_earned,badgeNameToStore, eagleRequired);
                 _database.reference().child("ScoutBook_DB_Badges").push().set(scoutBook_DB_Badges.toJson());
               }
             }
           }
         }

         //Now, let's process the Rank info
         for(int localCol=1;localCol<arrayOfData[2].length;localCol++)
         {
           if(arrayOfData[2][localCol] != "")
           {
             String rankToStore;
             for(int i=0; i<ranksList.length;i++)
             {
               if(ranksList[i].DB == arrayOfData[2][localCol])
                 {
                   //Found rank string mapping
                   ScoutBook_DB_Ranks scoutBook_DB_Ranks = new ScoutBook_DB_Ranks(council, troop, arrayOfData[1][localCol].toString(),ranksList[i].key);
                   _database.reference().child("ScoutBook_DB_Ranks").push().set(scoutBook_DB_Ranks.toJson());
                 }
             }
           }
         }

         showAlertDialog(context, "Successfully Uploaded Reference ScoutBook Data!");
      }
    else
      {
        showAlertDialog2(context, "Invalid file!");
      }
  }

  void _updateRecordsPerBsaReference() async{
      // Process new data for all scouts in troop who have bsaId populated
      for(int i=0;i<membersList.length;i++) {
        if(membersList[i].bsaId != null) {
          await checkAndUpdateForBsaId(membersList[i].bsaId);
        }
      }
      print("Finished processing all troop members");
      showAlertDialog(context, "Successfully Updated Records Per ScoutBook Reference!");
  }

  Future<bool> checkAndUpdateForBsaId(String bsaId) async{
    bool scoutBsaIdMatched=false;
    //Check if this bsaId exists for a scout in the troop/council
    for(int i=0;i<membersList.length;i++)
      if(membersList[i].bsaId == bsaId)
        {
          //Found match!
          scoutBsaIdMatched = true;
          String userId = membersList[i].userId;

          // For all the merit badges earned in ScoutBook_DB_Badges for this member, update/add the Merit_Badges_Earned record
          for(int scoutBookEntryIndex=0;scoutBookEntryIndex<scoutBookList.length;scoutBookEntryIndex++)
            {
              if((council == scoutBookList[scoutBookEntryIndex].council)&&(troop == scoutBookList[scoutBookEntryIndex].troop)
                  &&(bsaId == scoutBookList[scoutBookEntryIndex].bsaId)) {
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
                      print("Need to update "+meritBadgesEarnedList[j].meritBadge+" for "+bsaId+" with date"+scoutBookList[scoutBookEntryIndex].date_earned+" from earlier date "+meritBadgesEarnedList[j].date_earned);
                      meritBadgesEarnedList[j].date_earned = scoutBookList[scoutBookEntryIndex].date_earned;
                      _database.reference().child("Merit_Badges_Earned").child(meritBadgesEarnedList[j].key).set(meritBadgesEarnedList[j].toJson());
                    }
                   break;
                  }
                }

                // Did not find existing badge entry, and so add new record
                if(!foundExistingMeritBadgeRecord)
                {
                  print("Need to add "+scoutBookList[scoutBookEntryIndex].meritBadge+" for "+bsaId+" with date"+scoutBookList[scoutBookEntryIndex].date_earned);
                  Merit_Badges_Earned meritBadgeToAdd = new Merit_Badges_Earned(userId.toString(), scoutBookList[scoutBookEntryIndex].date_earned,scoutBookList[scoutBookEntryIndex].meritBadge,scoutBookList[scoutBookEntryIndex].eagle);
                  _database.reference().child("Merit_Badges_Earned").push().set(meritBadgeToAdd.toJson());
                }
              }
            }

          // For the rank (if any) in ScoutBook_DB_Ranks for this member, update the Merit_Badges_Earned record
          for(int scoutBookRankEntryIndex=0;scoutBookRankEntryIndex<scoutBookRanksList.length;scoutBookRankEntryIndex++)
          {
            if((council == scoutBookRanksList[scoutBookRankEntryIndex].council)&&(troop == scoutBookRanksList[scoutBookRankEntryIndex].troop)
                &&(bsaId == scoutBookRanksList[scoutBookRankEntryIndex].bsaId)) {
              // Found the rank for this person in ScoutBook_DB_Ranks
              // If rank does not match the one listed in ScoutBook, update the scout member record
              if(scoutBookRanksList[scoutBookRankEntryIndex].rank != membersList[i].rank)
                {
                  print("Need to update rank for "+bsaId+" from "+membersList[i].rank+" to "+scoutBookRanksList[scoutBookRankEntryIndex].rank);
                  membersList[i].rank = scoutBookRanksList[scoutBookRankEntryIndex].rank;
                  _database.reference().child("members").child(membersList[i].key).set(membersList[i].toJson());
                  break;
                }
            }
          }
        }
    return(scoutBsaIdMatched);
  }

  bool validFileContents()
  {
        bool foundOneDate=false;
        if((currentRow < 4)||(arrayOfData[0].length < 2)) {
          return false;
        }

        if((arrayOfData[0][0] != "")||(arrayOfData[1][0] != "BSA Member #")||(arrayOfData[2][0] != "Current Rank")) {
          return false;
        }

        //Check that at least one of the merit badge records has a valid date
        for(int localRow=3;localRow<currentRow;localRow++)
          {
             for(int localCol=1;localCol<arrayOfData[localRow].length;localCol++)
               {
                 if(arrayOfData[localRow][localCol] != "Not Started")
                   {
                     // Check if this is a date
                     List<String> subStringsList = arrayOfData[localRow][localCol].split("/");
                     if(subStringsList.length == 3)
                       {
                         if((int.tryParse(subStringsList[0])==null)||(int.tryParse(subStringsList[1])==null)||(int.tryParse(subStringsList[2])==null))
                           return false;

                         int month = int.parse(subStringsList[0]);
                         int day = int.parse(subStringsList[1]);
                         int year = int.parse(subStringsList[2]);

                         if((month>12)||(month<1)||(day<1)||(day>31)||(year<0))
                           {
                             return false;
                           }
                         else
                           foundOneDate = true;
                       }
                   }
               }
          }
        return foundOneDate;
  }

  void _clearCachedFiles() {
    FilePicker.platform.clearTemporaryFiles().then((result) {
      _scaffoldKey.currentState.showSnackBar(
        SnackBar(
          backgroundColor: result ? Colors.green : Colors.red,
          content: Text((result
              ? 'Temporary files removed with success.'
              : 'Failed to clean temporary files')),
        ),
      );
    });
  }

  void _selectFolder() {
    FilePicker.platform.getDirectoryPath().then((value) {
      setState(() => _directoryPath = value);
    });
  }

  Future<bool> removeCurrentDataForTroop() async{
    bool foundEntries=false;

    await _database.reference().child("ScoutBook_DB_Badges").orderByChild("council").equalTo(council).once().then((DataSnapshot snapshot){
      Map<dynamic, dynamic> values = snapshot.value;
      if(values != null) {
        values.forEach((key, value) {
          if(troop == value["troop"].toString()) {
            _database.reference().child("ScoutBook_DB_Badges").child(key).remove();
            foundEntries = true;
          }
        });
      }
    });

    await _database.reference().child("ScoutBook_DB_Ranks").orderByChild("council").equalTo(council).once().then((DataSnapshot snapshot){
      Map<dynamic, dynamic> values = snapshot.value;
      if(values != null) {
        values.forEach((key, value) {
          if(troop == value["troop"].toString()) {
            _database.reference().child("ScoutBook_DB_Ranks").child(key).remove();
            foundEntries = true;
          }
        });
      }
    });

      return(foundEntries);
  }

  Widget updateMeritBadges() {
    String buttonLabel;
    if(scoutBookList.length > 0)
      {
        buttonLabel = "Delete ScoutBook Reference Data";
      }
    else
      {
        buttonLabel = "Upload New ScoutBook Data (.csv)";
      }

    return Padding(
              padding: const EdgeInsets.only(left: 10.0, right: 10.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(top: 20.0, bottom: 20.0),
                      child: Column(
                        children: <Widget>[
                          if(scoutBookList.length>0)RaisedButton(
                            elevation: 5.0,
                            color: Colors.green,
                            child: Text("Sync App Records Using ScoutBook Data", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16)),
                            onPressed: () => _updateRecordsPerBsaReference(),
                          ),
                          if(scoutBookList.length==0)RaisedButton(
                            elevation: 10.0,
                            color: Colors.green,
                            onPressed: () => _inputOrDeleteDataFile(),
                            child: Text(buttonLabel, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 17)),
                          ),
                          if(scoutBookList.length == 0) Builder(
                            builder: (BuildContext context) => _loadingPath
                                ? Padding(
                              padding: const EdgeInsets.only(bottom: 10.0),
                              child: const CircularProgressIndicator(),
                            )
                                : _directoryPath != null
                                ? ListTile(
                              title: Text('Directory path'),
                              subtitle: Text(_directoryPath),
                            )
                                : _paths != null
                                ? Container(
                              padding: const EdgeInsets.only(bottom: 30.0),
                              height:
                              MediaQuery.of(context).size.height * 0.50,
                              child: Scrollbar(
                                  child: ListView.separated(
                                    itemCount:
                                    _paths != null && _paths.isNotEmpty
                                        ? _paths.length
                                        : 1,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      final bool isMultiPath =
                                          _paths != null && _paths.isNotEmpty;
                                      final String name = 'File $index: ' +
                                          (isMultiPath
                                              ? _paths
                                              .map((e) => e.name)
                                              .toList()[index]
                                              : _fileName ?? '...');
                                      final path = _paths
                                          .map((e) => e.path)
                                          .toList()[index]
                                          .toString();

                                      return ListTile(

                                        title: Text(
                                          name,
                                        ),
                                        subtitle: Text(path),
                                      );
                                    },
                                    separatorBuilder:
                                        (BuildContext context, int index) =>
                                    const Divider(),
                                  )),
                            )
                                : const SizedBox(),
                          ),
                          if(scoutBookList.length==0)RichText(
                              text: TextSpan(
                                  text: '\n\nScoutBook data can be easily synced using an export/import option.\n\nTo ',
                                  style: TextStyle(fontSize: 15, color: Colors.black, fontStyle: FontStyle.normal ),
                                  children: <TextSpan>[
                                    TextSpan(
                                      text: 'import data, ',
                                      style: TextStyle(
                                          fontSize: 15,
                                          fontStyle: FontStyle.normal,
                                          fontWeight: FontWeight.bold
                                      ),
                                    ),
                                    TextSpan(
                                      text: 'follow these steps EXACTLY:\n\n1. Log into your ',
                                      style: TextStyle(
                                          fontSize: 15,
                                          fontStyle: FontStyle.normal,
                                      ),
                                    ),
                                    TextSpan(
                                      text: 'ScoutBook.com ',
                                      style: TextStyle(
                                          fontSize: 15,
                                          fontStyle: FontStyle.normal,
                                          fontWeight: FontWeight.bold
                                      ),
                                    ),
                                    TextSpan(
                                      text: 'Account\n2. Click “My Dashboard”. Then pick the “Reports Menu” option.\n3. Select “Report Builder Manager”.\n4. Select “New Scouts BSA Rpt”\n5. Select any “Report Title” string.\n6. Select the correct troop under the “All Scouts” option.\n7. Expand “Merit Badges” option and select “All Merit Badges”. DO NOT select “Merit Badge Requirements”.\n8. Under “Settings”, select ONLY “Show Dates”, “Show Current Rank”, and “Show BSA Member #” options.\n9. Click “Run” to generate the report on screen.\n10. On next screen, click the “CSV” option to generate the .csv file which will be used by the application.\n11. Ensure the file has the exact “.csv” extension.\n12. Download this file onto your phone using export through Google Drive, email, etc.\n13. Click the “Upload New ScoutBook Data (.csv)” button above.\n14. Once Step 13 is complete, you must come back to this screen and click on the “Update Records Per ScoutBook Data” button which will appear here to update all merit badge and rank data for scouts with BSA ID’s populated.\n\n\n',
                                      style: TextStyle(
                                          fontSize: 15,
                                          fontStyle: FontStyle.normal,
                                      ),
                                    ),
                                  ]
                              ),
                            ),
                          //if(scoutBookList.length>0) Text("""\n\nTo update reference data for all scouts with populated BSA ID’s:\n1. Click “Sync App Records With ScoutBook Data”\n2. Please note that the reference data used is the last version of ScoutBook uploaded for this troop. \n\n"""),
                          if(scoutBookList.length>0) RichText(
                            text: TextSpan(
                                text: '\n\nTo update reference data for all scouts with populated BSA ID’s:\n',
                                style: TextStyle(fontSize: 15, color: Colors.black, fontStyle: FontStyle.normal, fontWeight: FontWeight.bold ),
                                children: <TextSpan>[
                                  TextSpan(
                                    text: '1. Click the “Sync App Records Using ScoutBook Data” button above.\n2. Please note that the reference data used is the last version of ScoutBook uploaded for this troop. \n3. Additionally, note that this reference data will also be used to sync individual scouts’ records when they are updated through either the “Profile” or “Edit Troop Info” options.\n\n',
                                    style: TextStyle(
                                        fontSize: 15,
                                        fontStyle: FontStyle.normal,
                                        fontWeight: FontWeight.normal
                                    ),
                                  ),

                                ]
                            ),
                          ),
                          if(scoutBookList.length>0) RaisedButton(
                            elevation: 5.0,
                            color: Theme.of(context).primaryColor,
                            onPressed: () => _inputOrDeleteDataFile(),
                            child: Text(buttonLabel, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 18)),
                          ),
                          //if(scoutBookList.length>0) Text("""\n\n1. If changes have been made to ScoutBook data, please click “Delete ScoutBook Data” and import the updated ScoutBook data version using a new .csv file.\n2. Additionally, note that this reference data will also be used to sync individual scouts’ records when they are updated through either the “Profile” or “Edit Troop Info” options.\n\n"""),
                          if(scoutBookList.length>0) RichText(
                            text: TextSpan(
                                text: '\n\nIf changes have been made to ScoutBook data:\n',
                                style: TextStyle(fontSize: 15, color: Colors.black, fontStyle: FontStyle.normal, fontWeight: FontWeight.bold ),
                                children: <TextSpan>[
                                  TextSpan(
                                    text: 'Please click the “Delete ScoutBook Reference Data” button above and import the updated ScoutBook data version using a new .csv file.',
                                    style: TextStyle(
                                        fontSize: 15,
                                        fontStyle: FontStyle.normal,
                                        fontWeight: FontWeight.normal
                                    ),
                                  ),


                                ]
                            ),
                          ),

                        ],
                      ),
                    ),

                  ],
                ),
              ),
            );

  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
          title: new Text('Sync ScoutBook Data'),
      ),
      body: updateMeritBadges(),

    );
  }
}

showAlertDialog(BuildContext context, String displayString) {
  // set up the button
  Widget okButton = FlatButton(
    child: Text("OK"),
    onPressed: () {  Navigator.of(context).popUntil((route) => route.isFirst); },
    //onPressed: () {Navigator.of(context).pop(); },
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

showAlertDialog2(BuildContext context, String displayString) {
  // set up the button
  Widget okButton = FlatButton(
    child: Text("OK"),
  //onPressed: () {Navigator.of(context).pop(); },
  onPressed: () {Navigator.of(context).popUntil((route) => route.isFirst); },
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