import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter_login_demo/models/eventsignup.dart';




class MoveToTopOfListPage extends StatefulWidget {
  MoveToTopOfListPage({this.displayString, this.eventSignup, this.firstName, this.lastName, this.email, this.listOfSignedUpPeople, this.maxAttendees}):super();
  final String displayString;
  final int maxAttendees;
  final List<EventSignUp> listOfSignedUpPeople;
  final EventSignUp eventSignup;
  final String firstName;
  final String lastName;
  final String email;

  //MoveToTopOfListPage({Key key, this.note}) : super(key: key);

  @override
  _MoveToTopOfListPageState createState() => _MoveToTopOfListPageState(displayString, eventSignup, firstName, lastName, email, listOfSignedUpPeople, maxAttendees);
}

class _MoveToTopOfListPageState extends State<MoveToTopOfListPage> {
  _MoveToTopOfListPageState(this.displayString, this.eventSignup, this.firstName, this.lastName, this.email, this.listOfSignedUpPeople, this.maxAttendees);
  String displayString;
  EventSignUp eventSignup;
   String firstName;
   String lastName;
   String email;
  final int maxAttendees;
  final List<EventSignUp> listOfSignedUpPeople;
  TextStyle style = TextStyle(fontFamily: 'Montserrat', fontSize: 20.0);
  TextEditingController _title;
  TextEditingController _name;
  TextEditingController _email;

  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final databaseReference = FirebaseDatabase.instance.reference();

  DateTime _eventDate;
  final _formKey = GlobalKey<FormState>();
  final _key = GlobalKey<ScaffoldState>();
  bool processing;

  @override
  void initState() {
    super.initState();

    _name = TextEditingController(text:  firstName != null ? (firstName+" "+lastName) : "");
    _email = TextEditingController(text:  email != null ? email : "");

    _eventDate = DateTime.now();
    processing = false;

  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text("Confirm For Event"),
      ),
      key: _key,
      body: Form(
        key: _formKey,
        child: Container(
          alignment: Alignment.center,
          child: ListView(
            children: <Widget>[
              SizedBox(
                height: 20.0,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: TextFormField(
                  controller: _name,
                  enabled: false,
                  minLines: 1,
                  maxLines: 1,
                  style: style,
                  decoration: InputDecoration(
                      labelText: "Name",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: TextFormField(
                  controller: _email,
                  enabled: false,
                  minLines: 1,
                  maxLines: 1,
                  style: style,
                  decoration: InputDecoration(
                      labelText: "Email",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
                ),
              ),


              SizedBox(height: 10.0),
              processing
                  ? Center(child: CircularProgressIndicator())
                  : Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Material(
                  elevation: 5.0,
                  borderRadius: BorderRadius.circular(30.0),
                  color: Theme.of(context).primaryColor,
                  child: MaterialButton(
                    onPressed: () async {

                        setState(() {
                          processing = true;
                        });

                          showAlertDialog(context, email, eventSignup, maxAttendees, listOfSignedUpPeople, _database);

                        setState(() {
                          processing = false;
                        });

                    },
                    child: Text(
                      "Move to Confirmed List",
                      style: style.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}


/*showAlertDialog(BuildContext context, String displayString, EventSignUp eventSignUpForDialog, int maxAttendees, List<EventSignUp> listOfSignedUpPeople, FirebaseDatabase _database) {
  // set up the button
  Widget okButton = FlatButton(
    child: Text("Cancel"),
    onPressed: () {Navigator.of(context).pop(); },
  );
  Widget confirmButton = FlatButton(
    child: Text("Confirm"),
    onPressed: () {
      for (int i = 0; i<listOfSignedUpPeople.length; i++){
        if (eventSignUpForDialog.userId==listOfSignedUpPeople[i].userId){
          listOfSignedUpPeople[i].sequenceNum=0;
          listOfSignedUpPeople[i].confirmed=true;
          _database.reference().child("EventSignUp").child(listOfSignedUpPeople[i].key).set(listOfSignedUpPeople[i].toJson());

        }
        else if (listOfSignedUpPeople[i].confirmed){
          listOfSignedUpPeople[i].sequenceNum +=1;
          if (listOfSignedUpPeople[i].sequenceNum==maxAttendees){
            listOfSignedUpPeople[i].confirmed=false;
          }
          _database.reference().child("EventSignUp").child(listOfSignedUpPeople[i].key).set(listOfSignedUpPeople[i].toJson());
        }
      }

      Navigator.of(context).popUntil((route) => route.isFirst);
      },
  );
  // set up the AlertDialog
  AlertDialog alert = AlertDialog(
    title: Text("Are you sure?"),
    content: Text("Moving this person to the top of the confirmed list will move the person at the bottom of the confirmed list onto the waitlist."),
    actions: [
      okButton,
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
}*/

showAlertDialog(BuildContext context, String displayString, EventSignUp eventSignUpForDialog, int maxAttendees, List<EventSignUp> listOfSignedUpPeople, FirebaseDatabase _database) {
  // set up the button
  Widget okButton = FlatButton(
    child: Text("Cancel"),
    onPressed: () {Navigator.of(context).pop(); },
  );
  Widget confirmButton = FlatButton(
    child: Text("Confirm"),
    onPressed: () {
      List<EventSignUp> sortedSignedUp = new List(listOfSignedUpPeople.length);
      for (int i = 0; i<listOfSignedUpPeople.length; i++) {
        sortedSignedUp[listOfSignedUpPeople[i].sequenceNum] = listOfSignedUpPeople[i];
      }
      int savedValue = eventSignUpForDialog.sequenceNum;
      for (int i = savedValue; i>=0; i--){
        if (eventSignUpForDialog.userId==sortedSignedUp[i].userId){
          sortedSignedUp[i].sequenceNum=sortedSignedUp.length;
          sortedSignedUp[i].confirmed=true;
          _database.reference().child("EventSignUp").child(sortedSignedUp[i].key).set(sortedSignedUp[i].toJson());
        }
        else if (sortedSignedUp[i].sequenceNum < savedValue){
          sortedSignedUp[i].sequenceNum +=1;
          if (sortedSignedUp[i].sequenceNum==maxAttendees){
            sortedSignedUp[i].confirmed=false;
          }
          _database.reference().child("EventSignUp").child(sortedSignedUp[i].key).set(sortedSignedUp[i].toJson());
        }
      }
      sortedSignedUp[savedValue].sequenceNum = 0;
      _database.reference().child("EventSignUp").child(sortedSignedUp[savedValue].key).set(sortedSignedUp[savedValue].toJson());

      Navigator.of(context).popUntil((route) => route.isFirst);
    },
  );
  // set up the AlertDialog
  AlertDialog alert = AlertDialog(
    title: Text("Are you sure?"),
    content: Text("Moving this person to the top of the confirmed list will move the person at the bottom of the confirmed list onto the waitlist."),
    actions: [
      okButton,
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

