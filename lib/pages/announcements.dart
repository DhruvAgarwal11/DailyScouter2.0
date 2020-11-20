import 'package:flutter/material.dart';
import 'package:flutter_login_demo/services/authentication.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_login_demo/models/members.dart';
import 'package:flutter_login_demo/models/Merit_Badges_Earned.dart';
import 'package:flutter_login_demo/models/meritbadges.dart';
import 'package:flutter_login_demo/models/eventsignup.dart';
import 'package:flutter_login_demo/models/EventModel.dart';
import 'package:flutter_login_demo/models/announcementsDatabase.dart';
import 'package:flutter_login_demo/pages/createAnnouncement.dart';




import 'dart:async';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

String subject;
String emailBody;
String subjectFromDatabase;
String firstName;
String lastName;
String emailOfPerson;
ScrollController _scrollController = new ScrollController();




bool showComposeMessage = false;
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



class AnnouncementsPage extends StatefulWidget {
  AnnouncementsPage({Key key, this.auth, this.userId, this.logoutCallback, this.membersList, this.meritBadgesList, this.meritBadgesEarnedList, this.listOfEvents})
      : super(key: key);

  final BaseAuth auth;
  final VoidCallback logoutCallback;
  final String userId;
  final List<Members> membersList;
  final List<MeritBadges> meritBadgesList;
  final List<Merit_Badges_Earned> meritBadgesEarnedList;
  final List<EventModel> listOfEvents;

  @override
  State<StatefulWidget> createState() => new _AnnouncementsPageState(userId: userId,
      auth: auth,
      logoutCallback: logoutCallback, membersList: membersList, meritBadgesList: meritBadgesList, meritBadgesEarnedList: meritBadgesEarnedList, listOfEvents: listOfEvents);
}

class _AnnouncementsPageState extends State<AnnouncementsPage> {
  _AnnouncementsPageState({this.auth, this.userId, this.logoutCallback, this.membersList, this.meritBadgesList, this.meritBadgesEarnedList, this.listOfEvents });

  final BaseAuth auth;
  final VoidCallback logoutCallback;
  final String userId;
  final List<Members> membersList;
  final List<MeritBadges> meritBadgesList;
  final List<Merit_Badges_Earned> meritBadgesEarnedList;
  final List<EventModel> listOfEvents;


  List<AnnouncementsDatabase> listOfAnnouncements = [];
  List<TextEditingController> listOfNewAnnouncement = [];
  List<TextEditingController> listOfSubjects = [];



  List<EventSignUp> _listOfSignedUpEvents = [];
  List<EventModel> _listOfGoodEvents = [];


  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final databaseReference = FirebaseDatabase.instance.reference();
  String _date = "Not set";
  String _time = "Not set";
  StreamSubscription<Event> _onAnnouncementAddedSubscription;
  StreamSubscription<Event> _onAnnouncementChangedSubscription;
  StreamSubscription<Event> _onAnnouncementRemovedSubscription;

  Query onAnnouncementQuery;


  @override
  void initState() {
    super.initState();
    //AnnouncementsDatabase newSignUp = new AnnouncementsDatabase("DKzGP4jA1vNFylPGd4u8PC9FbP63", "SVMBC","296", DateTime.now().millisecondsSinceEpoch,"This is the subject",true);
    //_database.reference().child("AnnouncementsDatabase").push().set(newSignUp.toJson());
showComposeMessage=false;

    onAnnouncementQuery = _database
        .reference()
        .child("AnnouncementsDatabase");
    _onAnnouncementAddedSubscription =  onAnnouncementQuery.onChildAdded.listen(onAnnouncementAdded);
    _onAnnouncementChangedSubscription = onAnnouncementQuery.onChildChanged.listen(onAnnouncementChanged);
    _onAnnouncementRemovedSubscription = onAnnouncementQuery.onChildRemoved.listen(onAnnouncementRemoved);




    String tempDate=DateTime(1971,5,31).toString();
  }

  onAnnouncementChanged(Event event) {
    var oldEntry = listOfAnnouncements.singleWhere((entry) {
      return entry.key == event.snapshot.key;
    });

    setState(() {
      if(userId == AnnouncementsDatabase.fromSnapshot(event.snapshot).userId) {
        listOfAnnouncements[listOfAnnouncements.indexOf(oldEntry)] = AnnouncementsDatabase.fromSnapshot(event.snapshot);
        listOfNewAnnouncement[listOfAnnouncements.indexOf(oldEntry)].text = AnnouncementsDatabase.fromSnapshot(event.snapshot).message;
        listOfSubjects[listOfAnnouncements.indexOf(oldEntry)].text = AnnouncementsDatabase.fromSnapshot(event.snapshot).subject;
      }});


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
        listOfNewAnnouncement.add(TextEditingController(text: AnnouncementsDatabase.fromSnapshot(event.snapshot).message.toString()));
      }

    });
  }
  onAnnouncementRemoved(Event event) {
    var oldEntry = listOfAnnouncements.singleWhere((entry) {
      return entry.key == event.snapshot.key;
    });


    setState(() {
      listOfAnnouncements.removeAt(listOfAnnouncements.indexOf(oldEntry));
      listOfNewAnnouncement.removeAt(listOfAnnouncements.indexOf(oldEntry));
    });
  }

  @override
  void dispose() {
    super.dispose();
    _onAnnouncementAddedSubscription.cancel();
    _onAnnouncementChangedSubscription.cancel();
    _onAnnouncementRemovedSubscription.cancel();

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



    if (listOfAnnouncements.length > 0) {
      Timer(
        Duration(milliseconds: 10),
            () => _scrollController.jumpTo(_scrollController.position.maxScrollExtent),
      );


    return ListView.builder(
        controller: _scrollController,
        shrinkWrap: true,
        itemCount: listOfAnnouncements.length,
        itemBuilder: (BuildContext context, int index) {
          String confirmedToString;
          String announcementInfo;
          DateTime dateToSend;

          AnnouncementsDatabase currentEvent;

          String date= (DateTime.fromMillisecondsSinceEpoch(listOfAnnouncements[index].date).month.toString() + "/" + DateTime.fromMillisecondsSinceEpoch(listOfAnnouncements[index].date).day.toString()+"/"+DateTime.fromMillisecondsSinceEpoch(listOfAnnouncements[index].date).year.toString() + " " + DateTime.fromMillisecondsSinceEpoch(listOfAnnouncements[index].date).hour.toString() + ":"+ DateTime.fromMillisecondsSinceEpoch(listOfAnnouncements[index].date).minute.toString());
String eventOrganizer;
              dateToSend=  DateTime.fromMillisecondsSinceEpoch(listOfAnnouncements[index].date);
              for (int s = 0; s<membersList.length; s++){
                if (membersList[s].userId==listOfAnnouncements[index].userId){
                  eventOrganizer = membersList[s].firstName + " " + membersList[s].lastName + " " + membersList[s].email;
                }
              }
              announcementInfo = (date + "   " + listOfAnnouncements[index].subject + "\nby "  + eventOrganizer + "\n"+ listOfAnnouncements[index].message);
                currentEvent = listOfAnnouncements[index];

          if(true){
            final emailKey = GlobalKey<FormState>();
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  RichText(
                    text: TextSpan(
                      text: date + "   " ,
                      style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold, fontSize: 16),
                      children: <TextSpan>[
                        TextSpan(text: listOfAnnouncements[index].subject, style: TextStyle(color: Colors.blue[800], fontWeight: FontWeight.bold, fontSize: 16)),
                        TextSpan(text: "\nby ", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),

                        TextSpan(text: eventOrganizer + "\n", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 16)),

                      ],
                    ),
                  ),
                  TextFormField(
                    readOnly: true,
                    controller: listOfNewAnnouncement[index],
                    minLines: 1,
                    maxLines: 20,
                    validator: (value) =>
                    (value.isEmpty) ? "Enter An Announcement" : null,
                    //style: style,
                    decoration: InputDecoration(
                        labelText: "Announcement: " + eventOrganizer + " " + listOfAnnouncements[index].subject,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
                  ),
                  RichText(
                    text: TextSpan(
                      text: "\n" ,
                      style: TextStyle(color: Colors.black, fontSize: 5),

                    ),
                  ),
                  if( listOfAnnouncements[index].userId == userId)RaisedButton(
                    onPressed: () {
                      for (int zz=0;zz<listOfAnnouncements.length;zz++)
                        _database.reference().child("AnnouncementsDatabase").child(listOfAnnouncements[index].key).remove();
                    },
                    textColor: Colors.white,
                    color: Colors.blue,

                    child: const Text('Delete Announcement', style: TextStyle(fontSize: 20)),
                  ),
                ],
              ),

//              child: TextFormField(
//                readOnly: true,
//                controller: listOfNewAnnouncement[index],
//                minLines: 1,
//                maxLines: 20,
//                validator: (value) =>
//                (value.isEmpty) ? "Enter An Announcement" : null,
//                //style: style,
//                decoration: InputDecoration(
//                    labelText: "Announcement: " + eventOrganizer + " " + listOfAnnouncements[index].subject,
//                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
//              ),
            );

            /*return DataTable (
              headingRowHeight: 20,
              dataRowHeight: 200, // fix this so that it automatically becomes that large
              columnSpacing:0,
              columns: <DataColumn>[
                DataColumn(

                  label: Text(
                    '     ',
                    style: TextStyle(
                        fontStyle: FontStyle.italic, fontSize: 50, ),
                  ),

                ),

              ],
              rows: <DataRow>[

                DataRow(

                  cells: <DataCell>[

                    DataCell(

                        Container(

                            child: RichText(
                              text: TextSpan(
                                text: date + "   " ,
                                style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold, fontSize: 13),
                                children: <TextSpan>[
                                  TextSpan(text: listOfAnnouncements[index].subject, style: TextStyle(color: Colors.blue[800], fontWeight: FontWeight.bold, fontSize: 14)),
                                  TextSpan(text: "\nby ", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 13)),

                                  TextSpan(text: eventOrganizer, style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 13)),

                                  TextSpan(text: "\n"+ listOfAnnouncements[index].message, style: TextStyle(color: Colors.black, fontWeight: FontWeight.normal, fontSize: 13)),
                                ],
                              ),
                            ))

                    ),

                  ],
                ),
                if( listOfAnnouncements[index].userId == userId)DataRow(

                  cells: <DataCell>[

                    DataCell(

                        Container(

                          child: RaisedButton(
                            onPressed: () {
                              for (int zz=0;zz<listOfAnnouncements.length;zz++)
                              _database.reference().child("AnnouncementsDatabase").child(listOfAnnouncements[index].key).remove();
                            },
                            textColor: Colors.white,
                            color: Colors.blue,

                            child: const Text('Delete Announcement', style: TextStyle(fontSize: 20)),
                          ),
                        )
                    ),
                  ],
                ),
              ],
            );*/
          }
          else{
            return Container();
          }
        }
    );

    } else {
      return Center(
          child: Text(
            "There are currently no announcements.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 30.0),
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
          title: new Text('Announcements'),
      ),
      body: findAnnouncement(),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => CreateAnnouncement( //EventDetailsPage(
                        userId: userId,
                        auth: auth,
                        logoutCallback: logoutCallback, membersList: membersList, meritBadgesList: meritBadgesList, meritBadgesEarnedList: meritBadgesEarnedList, listOfEvents: listOfEvents
                      //event: event,
                    )));
            setState(() {
              showComposeMessage = true;
            });
          },
          tooltip: 'Add Announcement',
          child: Icon(Icons.add),
        )
    );
  }
}

