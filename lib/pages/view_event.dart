import 'package:flutter/material.dart';
import 'package:flutter_login_demo/models/EventModel.dart';
import 'package:firebase_database/firebase_database.dart';

class EventDetailsPage extends StatelessWidget {
  final EventModel event;

  const EventDetailsPage({Key key, this.event}) : super(key: key);

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text('Event details'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(event.title, style: Theme.of(context).textTheme.headline4,),
            SizedBox(height: 20.0),
            Text(event.description),
            Text(event.startDate.toString()),

          ],
        ),
      ),
    );
  }
}