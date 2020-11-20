import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/gestures.dart';
import 'package:url_launcher/url_launcher.dart';




class HelpPage extends StatelessWidget {

  const HelpPage({Key key}) : super(key: key);


  @override
  Widget build(BuildContext context){
    TapGestureRecognizer trainingVideosLink;
    trainingVideosLink = TapGestureRecognizer()
      ..onTap = () {
        launch('https://dailyscouter.com');
      };




  return Scaffold(
      appBar: AppBar(
        title: Text('Help'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: 20.0),
            Text("Welcome to the Daily Scouter! This app is used for managing and scheduling Boy Scouts activities. \n\n\nIf you are a scout or parent whose troop is already using this app:\n\n1. Create an account\n\n2. Verify your email\n\n3. Fill out your profile and submit, which should send a request to your scoutmaster that you would like to join the troop\n\n4. You should be able to view your troop's events, roster, and more. Enjoy!"),
            Text("\n\nIf you are a new troop interested in using this app:\n\n1. Have your scoutmaster create an account\n\n2. Send email to dailyscouter@gmail.com with his email that he used to create the account, the council, and the troop number. \n\n3. Scoutmaster should receive email when the troop is approved and can login.\n\nTraining videos available at:"),
        RichText(
            text: TextSpan(
                children: [
                  TextSpan(
                      text: 'DailyScouter.com',
                      style: TextStyle(color: Colors.blue),
                      recognizer: trainingVideosLink
                  )
                ]
            )
        ),
            Text("\n\nv2.0 of the app introduces some key enhancements: \n\n1. Ability to sync merit badge and rank data from ScoutBook.\n\n2. Support for Cub Scout Ranks to enable better user experience for Cub Scout packs.\n\n3. Introduction of \"Board of Review\" for scheduling/registering to ease parent sign-ups for these events."),

          ],
        ),
      ),
    );
  }


}