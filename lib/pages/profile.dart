import 'package:flutter/material.dart';
import 'package:flutter_login_demo/models/ScoutBook_DB_Badges.dart';
import 'package:flutter_login_demo/models/ScoutBook_DB_Ranks.dart';
import 'package:flutter_login_demo/services/authentication.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_login_demo/models/troops.dart';
import 'package:flutter_login_demo/models/members.dart';
import 'package:flutter_login_demo/models/Merit_Badges_Earned.dart';
import 'package:flutter_login_demo/pages/profile_edit.dart';
import 'package:flutter_login_demo/pages/main_menu.dart';
import 'dart:async';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:mailer/smtp_server/amazon.dart';
import 'package:mailer/smtp_server/yahoo.dart';
import 'package:flutter/rendering.dart';
import "package:http/http.dart" as http;
import 'dart:convert';

String thissitherealemail = "";

class ProfilePage extends StatefulWidget {
  ProfilePage({Key key, this.auth, this.userId, this.logoutCallback, this.membersList, this.scoutBookList, this.meritBadgesEarnedList, this.scoutBookRanksList})
      : super(key: key);

  Query authMemberQuery;

  final BaseAuth auth;
  final VoidCallback logoutCallback;
  final String userId;
  final List<Members> membersList;
  final List<ScoutBook_DB_Badges> scoutBookList;
  final List<Merit_Badges_Earned> meritBadgesEarnedList;
  final List<ScoutBook_DB_Ranks> scoutBookRanksList;

  @override
  State<StatefulWidget> createState() => new _ProfilePageState(userId: userId,
      auth: auth,
      logoutCallback: logoutCallback, membersList: membersList, scoutBookList: scoutBookList, meritBadgesEarnedList: meritBadgesEarnedList, scoutBookRanksList: scoutBookRanksList);
}

class _ProfilePageState extends State<ProfilePage> {
  _ProfilePageState({this.auth, this.userId, this.logoutCallback, this.membersList, this.scoutBookList, this.meritBadgesEarnedList, this.scoutBookRanksList});

  final BaseAuth auth;
  final VoidCallback logoutCallback;
  final String userId;
  final   List<Members> membersList;
  final List<ScoutBook_DB_Badges> scoutBookList;
  final List<Merit_Badges_Earned> meritBadgesEarnedList;
  final List<ScoutBook_DB_Ranks> scoutBookRanksList;
  bool meatloaf = true;

  List<Troops> _troopsList;

  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final databaseReference = FirebaseDatabase.instance.reference();

  StreamSubscription<Event> _onTroopsAddedSubscription;
  StreamSubscription<Event> _onTroopsChangedSubscription;

  Query _troopsQuery;

  @override
  void initState() {
    /*GoogleSignInAccount _currentUser;
    super.initState();

    try{
      googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount account) {
      print(account.toString());
      setState(() {
      _currentUser = account;
    });
    if (_currentUser != null) {
      print(_currentUser.toString());
      //_handleGetContact();
    }
    });
    googleSignIn.signInSilently();
  } catch (error) {
  print(error);
  }*/

    _troopsList = new List();
    initialize_flag = false;

    _troopsQuery = _database
        .reference()
        .child("troops");
    _onTroopsAddedSubscription = _troopsQuery.onChildAdded.listen(onEntryAdded);
    _onTroopsChangedSubscription =
        _troopsQuery.onChildChanged.listen(onEntryChanged);

    for (int j = 0; j < membersList.length; j++) {
      if (membersList[j].userId == userId) {
        email = membersList[j].email;
        profileTroopApproved = membersList[j].troopApproved;
        profilePhoneNumber = membersList[j].phoneNumber;
        profileIsAdmin = membersList[j].isAdmin;
        profileActive = membersList[j].active;
        profileRank = membersList[j].rank;
        profileLeadership = membersList[j].leadershipPosition;
        profileBsaId = membersList[j].bsaId;
        profileAddress = membersList[j].address;
        profileIsScoutmaster = membersList[j].isScoutmaster;
        firstName = membersList[j].firstName;
        lastName = membersList[j].lastName;
        councilFromDatabase = membersList[j].council;
        troopFromDatabase = membersList[j].troop;
        isScoutFromDatabase = membersList[j].isScout;
        if(membersList[j].isScout == null)
        {
          profileIsScout = true;
        }
        else
        {
          profileIsScout = membersList[j].isScout;
        }
        if (!initialize_flag) {
          initialize_flag = true;
          myController.text = firstName;
          myController2.text = lastName;
          myController5.text = profileBsaId;
          myController3.text = profileAddress;
          myController4.text = profilePhoneNumber;
          if(councilFromDatabase!="") {
            _SelectedCouncil = councilFromDatabase;
          }
          if(troopFromDatabase!="") {
            _SelectedTroop = troopFromDatabase;
          }
          if (profileIsScout == true) {
            ScoutorParent = "Scout";
          }
          else {
            ScoutorParent = "Parent";
          }
        }
      }
    }
  }

  @override
  void dispose() {
    _onTroopsAddedSubscription.cancel();
    _onTroopsChangedSubscription.cancel();
   super.dispose();
  }

  onEntryChanged(Event event) {
    var oldEntry = _troopsList.singleWhere((entry) {
      return entry.key == event.snapshot.key;
    });

    setState(() {
      _troopsList[_troopsList.indexOf(oldEntry)] =
          Troops.fromSnapshot(event.snapshot);
    });
  }

  onEntryAdded(Event event) {
    setState(() {
      _troopsList.add(Troops.fromSnapshot(event.snapshot));
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

  String _SelectedCouncil;
  String _SelectedTroop;
  String email;
  String profilePhoneNumber;
  String profileAddress;
  String profileRank;
  bool profileIsScout;
  String profileLeadership;
  String profileBsaId;
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

  bool initialize_flag;
  bool init_once = false;
  final myController = TextEditingController();
  final myController2 = TextEditingController();
  final myController3 = TextEditingController();
  final myController4 = TextEditingController();
  final myController5 = TextEditingController();

  @override
  Widget build(BuildContext context) {
    List<String> _ListOfCouncil = [];
    List<String> _ListOfTroops = [];
    List<String> _ListOfMembers = [];


    int cindex = 0, tindex = 0;
    bool cbool = false, tbool = false;

    int length_array=(_troopsList.length).toInt();
    if(length_array > 0) {
      for (int index = 0; index < length_array; index++) {
        for(int i=0; i<cindex ; i++) {
          if (_troopsList[index].council.toString() == _ListOfCouncil[i]) {
            cbool = true;
          }
        }
        for(int i=0; i<tindex ; i++) {
          if (_troopsList[index].troop.toString() == _ListOfTroops[i]) {
            tbool = true;
          }
        }
        if(!cbool){
          _ListOfCouncil.add(_troopsList[index].council.toString());
          cindex++;
        }
        if(!tbool){
          _ListOfTroops.add(_troopsList[index].troop.toString());
          tindex++;
        }
        cbool = false;
        tbool = false;
      }
    }


    String scouter;
    if (profileIsScout == null)
      {
        scouter = "You are a Scout";
      }
    else
    {
      if(profileIsScout)
        {
          scouter = "You are a Scout";
        }
      else
        scouter = "You are a Parent";
    }


    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: new AppBar(
            title: new Text('Profile'),
            leading: IconButton(icon:Icon(Icons.arrow_back_ios),
              onPressed:() => Navigator.pop(context, false),
            ),
            actions: <Widget>[
        if (profileTroopApproved==true)IconButton(
                icon: const Icon(Icons.edit),
                tooltip: 'Edit Profile',
                onPressed: () {
                  try {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ProfileEditPage(userId: userId,
                          auth: auth,
                          logoutCallback: logoutCallback, scoutBookList: scoutBookList, meritBadgesEarnedList: meritBadgesEarnedList, scoutBookRanksList: scoutBookRanksList)),
                    );
                  } catch (e) {
                    print(e);
                  }
                },
              ),


            ],
        ),

        body:
           ListView(
          children: <Widget>[
            if (profileTroopApproved==false )Row(

              children: <Widget>[
                Text('      Council:       ', style: TextStyle( fontSize: 15)),

                Center(
                  child: DropdownButton(
                    value: _SelectedCouncil,
                    onChanged: (value) {
                      setState(() {
                        _SelectedCouncil = value;
                      });
                    },
                    items: _ListOfCouncil.map(
                          (item) {
                        return DropdownMenuItem(
                          value: item,
                          child: new Text(item),
                        );},
                    ).toList(),
                  ),
                ),
              ],
            ),
            if (profileTroopApproved==false)Row(
              children: <Widget>[
                Text('      Troop:       ', style: TextStyle( fontSize: 15)),
                Center(
                  child: DropdownButton(
                    value: _SelectedTroop,
                    onChanged: (value) {
                      setState(() {
                        _SelectedTroop = value;
                      });
                    },
                    items: _ListOfTroops.map(
                          (item) {
                        return DropdownMenuItem(
                          value: item,
                          child: new Text(item),
                        );},
                    ).toList(),
                  ),
                ),
              ],
            ),
            if (profileTroopApproved==false) Row(
              children: <Widget>[
                Text('      Scout or Parent:       ', style: TextStyle( fontSize: 15)),
                Center(
                  child: DropdownButton<String>(
                    value: ScoutorParent,
                    onChanged: (value) {
                      setState(() {
                        if(value=="Scout") {
                          profileIsScout = true;
                          ScoutorParent="Scout";
                        }
                        if(value=="Parent"){
                          profileIsScout=false;
                          ScoutorParent="Parent";
                        }
                      });
                    },
                    items: <String>["Scout", "Parent"].map(
                          (String value) {
                        return DropdownMenuItem(
                          value: value,
                          child: new Text(value),
                        );},
                    ).toList(),
                  ),
                ),
              ],
            ),
            if (profileTroopApproved==false)Row(

              children: <Widget>[
                Text('      First Name:       ', style: TextStyle( fontSize: 15)),
                Expanded(
                  child: TextField(
                    controller: myController,
                  ),
                ),
              ],
            ),
            if (profileTroopApproved==false)Row(

              children: <Widget>[
                Text('      Last Name:       ', style: TextStyle( fontSize: 15)),
                Expanded(
                    child: TextField(
                      controller: myController2,

                    ),
                  ),

              ],
            ),
            if (profileTroopApproved==false)Row(

              children: <Widget>[
                Text('      BSA ID:       ', style: TextStyle( fontSize: 15)),
                Expanded(
                  child: TextField(
                    controller: myController5,

                  ),
                ),

              ],
            ),
            if (profileTroopApproved==false)Row(

              children: <Widget>[
                Text('      Address:       ', style: TextStyle( fontSize: 15)),
                Expanded(
                  child: TextField(
                    controller: myController3,

                  ),
                ),
              ],
            ),
            if (profileTroopApproved==false)Row(

              children: <Widget>[
                Text('      Phone Number:       ', style: TextStyle( fontSize: 15)),
                Expanded(
                  child: TextField(
                    controller: myController4,

                  ),
                ),
              ],
            ),

            if (profileTroopApproved==true)Row(

              children: <Widget>[
                Text('\n      Name: ', style: TextStyle( fontSize: 17, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic)),
                Expanded(child: Text('\n$firstName $lastName     ', style: TextStyle( fontSize: 17)),),

              ],
                crossAxisAlignment: CrossAxisAlignment.start
            ),
            if (profileTroopApproved==true)Row(

              children: <Widget>[
                Text('\n      Troop: ', style: TextStyle( fontSize: 17, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic)),
                Expanded(child: Text('\n$troopFromDatabase', style: TextStyle( fontSize: 17)),),

              ],
                crossAxisAlignment: CrossAxisAlignment.start
            ),
            if (profileTroopApproved==true )Row(

              children: <Widget>[
                Text('\n      Council: ', style: TextStyle( fontSize: 17, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic)),
                Expanded(child: Text('\n$councilFromDatabase', style: TextStyle( fontSize: 17)),),

              ],
                crossAxisAlignment: CrossAxisAlignment.start
            ),
            if (profileTroopApproved==true )Row(

                children: <Widget>[
                  Text('\n      BSA ID: ', style: TextStyle( fontSize: 17, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic)),
                  Expanded(child: Text('\n$profileBsaId', style: TextStyle( fontSize: 17)),),
                ],
                crossAxisAlignment: CrossAxisAlignment.start
            ),
            if (profileTroopApproved==true )Row(

              children: <Widget>[
                Text('\n      Address: ', style: TextStyle( fontSize: 17, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic)),
                Expanded(child: Text('\n$profileAddress', style: TextStyle( fontSize: 17)),),
              ],
                crossAxisAlignment: CrossAxisAlignment.start
            ),
            if (profileTroopApproved==true)Row(

              children: <Widget>[
                Text('\n      Phone Number: ', style: TextStyle( fontSize: 17, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic)),
                Expanded(child: Text('\n$profilePhoneNumber', style: TextStyle( fontSize: 17)),),
              ],
                crossAxisAlignment: CrossAxisAlignment.start
            ),
            if (profileTroopApproved==true && profileIsScout)Row(

              children: <Widget>[
                Text('\n      Leadership Position: ', style: TextStyle( fontSize: 17, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic)),
                Expanded(child: Text('\n$profileLeadership', style: TextStyle( fontSize: 17)),),
              ],
                crossAxisAlignment: CrossAxisAlignment.start
            ),
            if (profileTroopApproved==true && profileIsScout)Row(

              children: <Widget>[
                Text('\n      Rank: ', style: TextStyle( fontSize: 17, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic)),
                Expanded(child: Text('\n$profileRank', style: TextStyle( fontSize: 17)),),
              ],
                crossAxisAlignment: CrossAxisAlignment.start
            ),
            if (profileTroopApproved==true )Row(

              children: <Widget>[
                Text('\n      Email: ', style: TextStyle( fontSize: 17, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic)),
                Expanded(child: Text('\n$email', style: TextStyle( fontSize: 17)),),
              ],
                crossAxisAlignment: CrossAxisAlignment.start
            ),

            if (profileTroopApproved==true )Row(

              children: <Widget>[
                Text('\n      $scouter ', style: TextStyle( fontSize: 17, color: Colors.blue, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic)),
              ],
                crossAxisAlignment: CrossAxisAlignment.start
            ),
            if (profileTroopApproved==true && (profileIsAdmin==true) )Row(

              children: <Widget>[
                Text('\n      You have admin privileges.     ', style: TextStyle( fontSize: 17, color: Colors.green, fontWeight: FontWeight.bold)),

              ],
            ),
            if (profileTroopApproved==true && (profileIsScoutmaster==true))Row(

              children: <Widget>[
                Text('\n      You are the Scoutmaster.     ', style: TextStyle( fontSize: 17, color: Colors.green, fontWeight: FontWeight.bold)),

              ],
            ),

            if (profileTroopApproved==false )const SizedBox(height: 30),
            if (profileTroopApproved==false )RaisedButton(
              onPressed: () {
                profileBsaId = myController5.text;
                profileAddress = myController3.text;
                profilePhoneNumber = myController4.text;
                firstName = myController.text;
                lastName = myController2.text;
                List<Address> xx = [];
                xx.length = 0;

                if((_SelectedCouncil.length != 0) && (_SelectedTroop.length != 0) && ( firstName.length != 0) && (lastName.length != 0) && (profilePhoneNumber.length != 0) && (profileAddress.length != 0))
                {
                  for(int i = 0; i<_troopsList.length; i++)
                  {
                    if ((_troopsList[i].council.toString()==_SelectedCouncil) && (_troopsList[i].troop.toString()==_SelectedTroop))
                  {

                    for(int j=0;j<membersList.length;j++) {
                      if (membersList[j].troop == _SelectedTroop &&
                          membersList[j].council == _SelectedCouncil &&
                          membersList[j].isScoutmaster == true) {
                        //main(membersList[j].email, email);
                        xx.add(Address(membersList[j].email,(membersList[j].firstName + " " + membersList[j].lastName)));
                      }
                    }
                  if (xx.length>0){
                    main(email,xx);
                  }
                  for(int j=0;j<membersList.length;j++){
                    if(membersList[j].email == email){
                      membersList[j].troop = _SelectedTroop;
                      membersList[j].council = _SelectedCouncil;
                      membersList[j].firstName = firstName;
                      membersList[j].lastName = lastName;
                      membersList[j].phoneNumber = profilePhoneNumber;
                      membersList[j].address = profileBsaId;
                      membersList[j].address = profileAddress;
                      membersList[j].isAdmin=false;
                      membersList[j].isScout=profileIsScout;
                      membersList[j].leadershipPosition = "None";
                      membersList[j].rank = "None";
                      for(int k=0; k<_troopsList.length; k++)
                      {
                        if ((_troopsList[k].council==_SelectedCouncil) && (_troopsList[k].troop==_SelectedTroop))
                         {
                          meatloaf = false;
                          }
                      }

                      _database.reference().child("members").child(membersList[j].key).set(membersList[j].toJson());
                      showAlertDialog2(context);
                  }
                  }
                    }

                  }

                }
                if (meatloaf){
                  showAlertDialog(context);
                }
                meatloaf = true;
              },
              textColor: Colors.white,
              color: Colors.blue,

              child: const Text('Submit', style: TextStyle(fontSize: 20)),
            ),
            if (profileTroopApproved==false)Row(

              children: <Widget>[
                Text('\n      All fields are required. \n      Address and phone number can be N/A', style: TextStyle( fontSize: 15)),
              ],
            ),

          ],

      ),
      ),
    );
  }
}


void _showResetPasswordEmailSentDialog() {
  showDialog(

    builder: (BuildContext context) {
      // return object of type Dialog
      return AlertDialog(
        title: new Text("Invalid Attempt"),
        content:
        new Text("The information you entered is invalid. It may be a duplicate or an invalid combination."),
        actions: <Widget>[
          new FlatButton(
            child: new Text("Dismiss"),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}
showAlertDialog(BuildContext context) {
  // set up the button
  Widget okButton = FlatButton(
    child: Text("OK"),
    onPressed: () {Navigator.of(context).pop(); },
  );
  // set up the AlertDialog
  AlertDialog alert = AlertDialog(
    title: Text("Invalid Attempt"),
    content: Text("The information you entered is invalid. It may be a duplicate, a field may be empty, or it may be an invalid combination."),
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

showAlertDialog2(BuildContext context) {
  // set up the button
  Widget okButton = FlatButton(
    child: Text("OK"),
    onPressed: () {Navigator.of(context).pop(); },
  );
  // set up the AlertDialog
  AlertDialog alert = AlertDialog(
    title: Text("Update Successful"),
    content: Text("You have successfully applied to join a troop. You should receive an email when you have been approved by your troop's scoutmaster."),
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

/*GoogleSignIn googleSignIn = new GoogleSignIn(
  scopes: <String>[
    'https://www.googleapis.com/auth/gmail.send'
  ],
);

Future<Null> handleSignOut() async {
  googleSignIn.disconnect();
}
*/
//main(String emailOfScoutmaster, String email) async {
  //print(emailOfScoutmaster + " " + email);
  /*await googleSignIn.signIn().then((data) {
    data.authHeaders.then((result) {
      var header = {
        'Authorization': result['Authorization'],
        'X-Goog-AuthUser': result['X-Goog-AuthUser']
      };
      testingEmail(emailOfScoutmaster, header);
    });
  });*/


/*
@override
void initState() {
  super.initState();
  googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount account) {
    print(account.toString());
    /*setState(() {
      _currentUser = account;
    });
    if (_currentUser != null) {
      _handleGetContact();
    }*/
  });
  googleSignIn.signInSilently();
}*/

  /*Future<Null> testingEmail(String userId, Map header) async {
    header['Accept'] = 'application/json';
    header['Content-type'] = 'application/json';

    var from = username;
    var to = userId;
    var subject = 'test send email';
    //var message = 'worked!!!';
    var message = "Hi<br/>Html Email";
    var content = '''
    Content-Type: text/html; charset="us-ascii"
    MIME-Version: 1.0
    Content-Transfer-Encoding: 7bit
    to: ${to}
    from: ${from}
    subject: ${subject}

    ${message}''';

    var bytes = utf8.encode(content);
    var base64 = base64Encode(bytes);
    var body = json.encode({'raw': base64});

    String url = 'https://www.googleapis.com/gmail/v1/users/' + userId + '/messages/send';

    final http.Response response = await http.post(
        url,
        headers: header,
        body: body
    );
    if (response.statusCode != 200) {
      /*setState(() {
        print('error: ' + response.statusCode.toString());
      });*/
      print('error: ' + response.statusCode.toString());
      return;
    }
    final Map<String, dynamic> data = json.decode(response.body);
    print('ok: ' + response.statusCode.toString());
  }*/


// String emailOfScoutmaster = '$emailOfScoumaster';

  //final smtpServer = gmail(username, password);
  //try {final smtpServer = yahoo("dailyscouter@yahoo.com", "ognuhhwamdsjhntx");
 // try {final smtpServer = gmail("dailyscouter@yahoo.com", "lgwfcipehmwxhild");
//  print(smtpServer.toString() + smtpServer.username + " " + smtpServer.password);

  // Use the SmtpServer class to configure an SMTP server:

  // See the named arguments of SmtpServer for further configuration
  // options.

//  List<Address> xx = [Address(emailOfScoutmaster,emailOfScoutmaster)];
  // Create our message.
//  print("before message");
/*  final message = Message()
    ..from = Address("dailyscouter@yahoo.com", "Daily Scouter")
    ..recipients = xx
    ..subject = '$email would Like To Join Your Troop'
    ..text = 'This is the plain text.\nThis is line 2 of the text part.';
    ..html = "<p>Hello,</p>\n<p>$email would like to join your troop on the Daily Scouter. You may approve their request to join your troop through the app.</p>\n\n<p>-The Daily Scouter</p> ";

print("after message "+message.from.toString());
    final sendReport = await send(message, smtpServer);
    print(sendReport.toString());
    print("after send report");
  } on MailerException catch (e) {
    for (var p in e.problems) {
      print('Problem: ${p.code}: ${p.msg}');
    }
  }
}*/


main(String email, List<Address> listOfScoutmasterEmails) async {
//main(String emailOfScoutmaster, String email) async {
  final smtpServer = amazon(smtpUsername, password);
  //final smtpServer = hotmail(username, password);
  // Use the SmtpServer class to configure an SMTP server:
  // final smtpServer = SmtpServer('smtp.domain.com');
  // See the named arguments of SmtpServer for further configuration
  // options.

  // Create our message.

  final message = Message()
    ..from = Address(username, "Daily Scouter")
    ..recipients = listOfScoutmasterEmails
    //..recipients = [Address("rajata@gmail.com", "Rajat Agarwal")]
    ..subject = '$email would Like To Join Your Troop'
    //..text = emailBody + "\n\nMessage from: " + firstName + " " + lastName + " " + emailOfPerson
    ..html = "<p>Hello,</p>\n<p>$email would like to join your troop on the Daily Scouter. You may approve their request to join your troop through the app.</p>\n\n<p>-The Daily Scouter</p> ";

  // ..html = "<p>$emailBody</p> ";


  try {
    print("Before sending message:"+message.recipientsAsAddresses.toString()+" "+message.recipients[1].toString());

    final sendReport = await send(message, smtpServer);
    print("After sending message:"+sendReport.toString());
  } on MailerException catch (e) {
    for (var p in e.problems) {
      print('Problem: ${p.code}: ${p.msg}');
    }
  }
}




