import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter_login_demo/models/eventsignup.dart';




class EditScoutCreditPage extends StatefulWidget {
  EditScoutCreditPage({this.displayString, this.eventSignup, this.firstName, this.lastName, this.email}):super();
  final String displayString;
  final EventSignUp eventSignup;
  final String firstName;
  final String lastName;
  final String email;

  //EditScoutCreditPage({Key key, this.note}) : super(key: key);

  @override
  _EditScoutCreditPageState createState() => _EditScoutCreditPageState(displayString, eventSignup, firstName, lastName, email);
}

class _EditScoutCreditPageState extends State<EditScoutCreditPage> {
  _EditScoutCreditPageState(this.displayString, this.eventSignup, this.firstName, this.lastName, this.email);
  String displayString;
  EventSignUp eventSignup;
   String firstName;
   String lastName;
   String email;
  TextStyle style = TextStyle(fontFamily: 'Montserrat', fontSize: 20.0);
  TextEditingController _title;
  TextEditingController _name;
  TextEditingController _email;
  TextEditingController _hours;
  TextEditingController _nights;

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

    _hours = TextEditingController(text:  eventSignup.hours != null ? (eventSignup.hours.toDouble()/10).toString() : "");
    _nights = TextEditingController(text:  eventSignup.nights != null ? eventSignup.nights.toString() : "");
    _name = TextEditingController(text:  firstName != null ? (firstName+" "+lastName) : "");
    _email = TextEditingController(text:  email != null ? email : "");

    _eventDate = DateTime.now();
    processing = false;

  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Service Hours or Camping Nights"),
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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: TextFormField(
                  controller: _hours,
                  minLines: 1,
                  maxLines: 1,
                  validator: (value) =>
                  ((value.isEmpty)||(double.tryParse(_hours.text) == null)) ? "Please Enter Valid # Of Hours for the Event" : null,
                  style: style,
                  decoration: InputDecoration(
                      labelText: "Hours of Service To Credit",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: TextFormField(
                  controller: _nights,
                  minLines: 1,
                  maxLines: 1,
                  validator: (value) =>
                  ((value.isEmpty)||(int.tryParse(_nights.text) == null)) ? "Please Enter Valid # Of Nights for the Event" : null,
                  style: style,
                  decoration: InputDecoration(
                      labelText: "Nights of Camping To Credit",
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
                      if (_formKey.currentState.validate()) {
                        setState(() {
                          processing = true;
                        });
                        if((_hours.text != null)&&(_nights.text != null)) {
                          EventSignUp event = eventSignup;
                          event.nights = (int.parse(_nights.text)).round();
                          event.hours = int.parse((double.parse((double.parse(_hours.text)).toStringAsFixed(1)) * 10).round().toString());
                          _database.reference().child("EventSignUp").child(event.key).set(event.toJson());
                        }
                        Navigator.of(context).popUntil((route) => route.isFirst);
                        setState(() {
                          processing = false;
                        });
                      }
                    },
                    child: Text(
                      "Update Hours/Nights",
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
    _hours.dispose();
    _nights.dispose();
    super.dispose();
  }
}