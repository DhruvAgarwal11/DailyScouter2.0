import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter_login_demo/models/drivers.dart';
import 'package:flutter_login_demo/pages/associatescoutmaster.dart';




class DriverRegistrationPage extends StatefulWidget {
  DriverRegistrationPage({this.userId, this.eventKey}):super();
  final String eventKey;

  final String userId;


  //DriverRegistrationPage({Key key, this.note}) : super(key: key);

  @override
  _DriverRegistrationPageState createState() => _DriverRegistrationPageState(userId, eventKey);
}

class _DriverRegistrationPageState extends State<DriverRegistrationPage> {
  _DriverRegistrationPageState(this.userId, this.eventKey);
  String userId;
  String eventKey;
  String displayString;
   String firstName;
   String lastName;
   String email;
  TextStyle style = TextStyle(fontFamily: 'Montserrat', fontSize: 20.0);
  TextEditingController _seats;

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

    _seats = TextEditingController(text:"");


    _eventDate = DateTime.now();
    processing = false;

  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text("Register As Driver"),
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
                  controller: _seats,
                  minLines: 1,
                  maxLines: 1,
                  validator: (value) =>
                  ((value.isEmpty)||(int.tryParse(_seats.text) == null) ) ? "Please Enter Valid # Of Seats" : null,
                  style: style,
                  decoration: InputDecoration(
                      labelText: "# Of Seats",
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
                      if (_formKey.currentState.validate() ) {
                        if (int.parse(_seats.text)>0){
                        setState(() {
                          processing = true;
                        });
                        if((_seats.text != null)) {
                          Drivers event = new Drivers(userId, eventKey, int.parse(_seats.text));
                          _database.reference().child("Drivers").push().set(event.toJson());

                        }
                        Navigator.of(context).popUntil((route) => route.isFirst);
                        setState(() {
                          processing = false;
                        });
                      }
                      else{
                      showAlertDialog(context, "Please enter a number that is greater than 0");}
                      }
                    },
                    child: Text(
                      "Submit",
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
    _seats.dispose();
    super.dispose();
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
    title: Text("Invalid Entry"),
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
