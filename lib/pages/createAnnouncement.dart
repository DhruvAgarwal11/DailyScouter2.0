import 'package:flutter/material.dart';
import 'package:flutter_login_demo/services/authentication.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_login_demo/models/members.dart';
import 'package:flutter_login_demo/models/Merit_Badges_Earned.dart';
import 'package:flutter_login_demo/models/meritbadges.dart';
import 'package:flutter_login_demo/pages/main_menu.dart';
import 'package:flutter_login_demo/models/eventsignup.dart';
import 'package:flutter_login_demo/models/EventModel.dart';
import 'package:flutter_login_demo/models/announcementsDatabase.dart';
import 'package:flutter/services.dart';



import 'dart:async';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:mailer/smtp_server/amazon.dart';

String subject;
String emailBody;
String subjectFromDatabase;
String firstName;
String lastName;
String emailOfPerson;
final emailKey = GlobalKey<FormState>();



bool announcementAdded = false;

bool Eagle;


String troopFromDatabase;
bool isScoutFromDatabase;
String troop;
String rank;
String meritBadges;
String currentMeritBadges;


String council;
int theRealIndex;
bool onlyDoOnce = true;
int sum = 0;
List<int> validIndex = new List();
var checkboxClickedIsTrue = new List (2000);
List<TextEditingController> lastNameController = new List(2000);
List<TextEditingController> firstNameController = new List(2000);



class CreateAnnouncement extends StatefulWidget {
  CreateAnnouncement({Key key, this.auth, this.userId, this.logoutCallback, this.membersList, this.meritBadgesList, this.meritBadgesEarnedList, this.listOfEvents})
      : super(key: key);

  final BaseAuth auth;
  final VoidCallback logoutCallback;
  final String userId;
  final List<Members> membersList;
  final List<MeritBadges> meritBadgesList;
  final List<Merit_Badges_Earned> meritBadgesEarnedList;
  final List<EventModel> listOfEvents;

  @override
  State<StatefulWidget> createState() => new _CreateAnnouncementState(userId: userId,
      auth: auth,
      logoutCallback: logoutCallback, membersList: membersList, meritBadgesList: meritBadgesList, meritBadgesEarnedList: meritBadgesEarnedList, listOfEvents: listOfEvents);
}

class _CreateAnnouncementState extends State<CreateAnnouncement> {
  _CreateAnnouncementState({this.auth, this.userId, this.logoutCallback, this.membersList, this.meritBadgesList, this.meritBadgesEarnedList, this.listOfEvents });

  final BaseAuth auth;
  final VoidCallback logoutCallback;
  final String userId;
  final List<Members> membersList;
  final List<MeritBadges> meritBadgesList;
  final List<Merit_Badges_Earned> meritBadgesEarnedList;
  final List<EventModel> listOfEvents;


  List<AnnouncementsDatabase> listOfAnnouncements = [];



  List<EventSignUp> _listOfSignedUpEvents = [];
  List<EventModel> _listOfGoodEvents = [];


  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final databaseReference = FirebaseDatabase.instance.reference();
  String _date = "Not set";
  String _time = "Not set";
  StreamSubscription<Event> _onAnnouncementAddedSubscription;
  StreamSubscription<Event> _onAnnouncementChangedSubscription;
  Query onAnnouncementQuery;


  @override
  void initState() {
    super.initState();
    //AnnouncementsDatabase newSignUp = new AnnouncementsDatabase("DKzGP4jA1vNFylPGd4u8PC9FbP63", "SVMBC","296", DateTime.now().millisecondsSinceEpoch,"This is the subject",true);
    //_database.reference().child("AnnouncementsDatabase").push().set(newSignUp.toJson());
    announcementAdded = false;

    onAnnouncementQuery = _database
        .reference()
        .child("AnnouncementsDatabase");
    _onAnnouncementAddedSubscription =  onAnnouncementQuery.onChildAdded.listen(onAnnouncementAdded);
    _onAnnouncementChangedSubscription = onAnnouncementQuery.onChildChanged.listen(onAnnouncementChanged);



    String tempDate=DateTime(1971,5,31).toString();
  }

  onAnnouncementChanged(Event event) {
    var oldEntry = listOfAnnouncements.singleWhere((entry) {
      return entry.key == event.snapshot.key;
    });

    setState(() {
      if(userId == AnnouncementsDatabase.fromSnapshot(event.snapshot).userId)
        listOfAnnouncements[listOfAnnouncements.indexOf(oldEntry)] = AnnouncementsDatabase.fromSnapshot(event.snapshot);
    });
  }

  onAnnouncementAdded(Event event) {
    setState(() {
      bool duplicateEntry = false;
      Map<dynamic, dynamic> values = event.snapshot.value;
      for (int i = 0; i<membersList.length; i++){
        if (membersList[i].userId==userId){
          troop = membersList[i].troop;
          council = membersList[i].council;
        }
      }
      for(int y = 0; y<listOfAnnouncements.length; y++) {
        if (listOfAnnouncements[y].key==event.snapshot.key){
          duplicateEntry = true;
        }
      }
      if ((council == values["council"])&& (troop == values["troop"]) && !duplicateEntry && ((DateTime.now().millisecondsSinceEpoch-values["date"])<1296000000)) {
        listOfAnnouncements.add(AnnouncementsDatabase.fromSnapshot(event.snapshot));
      }

    });
  }

  @override
  void dispose() {
    super.dispose();
    _onAnnouncementAddedSubscription.cancel();
    _onAnnouncementChangedSubscription.cancel();
  }

  signOut() async {
    try {
      await widget.auth.signOut();
      widget.logoutCallback();
    } catch (e) {
      print(e);
    }
  }



  Widget findAnnouncement() {

    validIndex.length = 0;


    for (int i = 0; i<membersList.length; i++){
      if (userId==membersList[i].userId){
        troop = membersList[i].troop;
        council = membersList[i].council;
      }
    }
    _listOfGoodEvents.length = 0;
    bool duplicateFlag = false;
    for (int l = 0; l<listOfEvents.length; l++){
      if (listOfEvents[l].troop==troop && listOfEvents[l].council==council && DateTime.now().millisecondsSinceEpoch<listOfEvents[l].startDate ){
        for (int w = 0; w<_listOfGoodEvents.length; w++){
          if (_listOfGoodEvents[w].key==listOfEvents[l].key){
            duplicateFlag =true;
          }
        }
        if (!duplicateFlag){
          _listOfGoodEvents.add(listOfEvents[l]);
        }
      }
    }

    return Form(
            key: emailKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                TextFormField(
                  inputFormatters: [
                    new LengthLimitingTextInputFormatter(50),
                  ],
                  minLines: 1,
                  maxLines: 1,
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Please enter the subject';
                    }
                    if(value.length>50){
                      return 'Please enter a shorter subject (Max 50 Characters)';
                    }
                    subject=value;
                    return null;
                  },
                  decoration: InputDecoration(
                      labelText: 'Enter the subject (Max 50 Chars)'
                  ),
                ),
    Container(
    padding: new EdgeInsets.all(7.0),
    child: new ConstrainedBox(
    constraints: new BoxConstraints(
    minHeight: 25.0,
    maxHeight: 200.0,
    ),

    child: new SingleChildScrollView(
    scrollDirection: Axis.vertical,
    reverse: true,
      child: new TextFormField(
    keyboardType: TextInputType.multiline,
    maxLines: null, //grow automatically
      validator: (value) {
        if (value.isEmpty) {
          return 'Please enter the message';
        }
        emailBody = value;
        return null;
      },decoration: InputDecoration(
          labelText: 'Enter your message'
      ),),
    ),
    ),
    ),
                /*TextFormField(
                  inputFormatters: [
                    new LengthLimitingTextInputFormatter(1000),
                  ],
                  minLines: 1,
                  maxLines: 500,
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Please enter the message';
                    }

                    if(value.length>1250){
                      return 'Please enter a shorter message (Max 1000 Characters)';
                    }
                    emailBody = value;
                    return null;
                  },
                  decoration: InputDecoration(
                      labelText: 'Enter the message (Max 1000 Chars)'
                  ),
                ),*/
                Center(child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: RaisedButton(
                    onPressed: () {
                      // Validate returns true if the form is valid, or false
                      // otherwise.
                      if (emailKey.currentState.validate()) {
                        for (int i = 0; i<membersList.length; i++){
                          if (userId == membersList[i].userId ){
                            firstName = membersList[i].firstName;
                            lastName = membersList[i].lastName;
                            emailOfPerson =membersList[i].email;
                          }
                        }
                        AnnouncementsDatabase event = new AnnouncementsDatabase(userId, council, troop, DateTime.now().millisecondsSinceEpoch, subject,emailBody, false);
                        _database.reference().child("AnnouncementsDatabase").push().set(event.toJson());
                        subjectFromDatabase=event.message;

                        // Send email in at max batches of 30 addresses
                        List<Address> emailListMaxLen30Members = [];
                        emailListMaxLen30Members.length=0;
                        for (int i = 0; i<membersList.length; i++){
                          if (council == membersList[i].council && troop == membersList[i].troop && membersList[i].active && membersList[i].troopApproved)
                          {
                            emailListMaxLen30Members.add(Address(membersList[i].email, (membersList[i].firstName + " " + membersList[i].lastName)));
                            print(membersList[i].email.toString());
                            //print(emailListMaxLen30Members[i].mailAddress.toString());
                            if (emailListMaxLen30Members.length >= 30)
                              {
                                print("resetting");

                                //main(emailListMaxLen30Members);
                                emailListMaxLen30Members = [];
                              }
                          }
                        }
                        if (emailListMaxLen30Members.length > 0)
                        {
                          print("finished whole loop");
                          //main(emailListMaxLen30Members);
                        }
                        announcementAdded = true;
                        Navigator.pop(context);
                      }
                    },
                    child: Text('Submit'),
                  ),
                ),),
                if (announcementAdded == true)Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Center(
                      child: Text("Successfully Sent!", style: TextStyle(fontSize: 20, color: Colors.green, fontWeight: FontWeight.bold)))
                ),
              ],
            ),
          );


  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
          title: new Text('Announcements'),
      ),
      body: findAnnouncement(),

    );
  }
}

main(List<Address> emailListMaxLen30Members) async {

  final smtpServer = amazon(smtpUsername, password);
  // Use the SmtpServer class to configure an SMTP server:
  // final smtpServer = SmtpServer('smtp.domain.com');
  // See the named arguments of SmtpServer for further configuration
  // options.

  // Create our message.
  final message = Message()
    ..from = Address(username, 'Daily Scouter')
    ..recipients.add(username)
    ..bccRecipients = emailListMaxLen30Members
    ..subject = subject
    ..text = emailBody + "\n\nMessage from: " + firstName + " " + lastName + " " + emailOfPerson;
   // ..html = "<p>$emailBody</p> ";

  try {
    final sendReport = await send(message, smtpServer);
    print(sendReport.toString());
  } on MailerException catch (e) {
    for (var p in e.problems) {
      print('Problem: ${p.code}: ${p.msg}');
    }
  }
}