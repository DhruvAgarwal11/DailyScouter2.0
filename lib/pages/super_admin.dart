import 'package:flutter/material.dart';
import 'package:flutter_login_demo/services/authentication.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_login_demo/models/troops.dart';
import 'package:flutter_login_demo/pages/main_menu.dart';
import 'dart:async';


class SuperAdminPage extends StatefulWidget {
  SuperAdminPage({Key key, this.auth, this.userId, this.logoutCallback})
      : super(key: key);

  final BaseAuth auth;
  final VoidCallback logoutCallback;
  final String userId;

  @override
  State<StatefulWidget> createState() => new _SuperAdminPageState(userId: userId,
      auth: auth,
      logoutCallback: logoutCallback);
}

class _SuperAdminPageState extends State<SuperAdminPage> {
  _SuperAdminPageState({this.auth, this.userId, this.logoutCallback});

  final BaseAuth auth;
  final VoidCallback logoutCallback;
  final String userId;

  List<Troops> _troopsList;

  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final databaseReference = FirebaseDatabase.instance.reference();

  final _textEditingController1 = TextEditingController();
  final _textEditingController2 = TextEditingController();
  StreamSubscription<Event> _onTroopsAddedSubscription;
  StreamSubscription<Event> _onTroopsChangedSubscription;

  Query _troopsQuery;

  @override
  void initState() {
    super.initState();

    _troopsList = new List();

    _troopsQuery = _database
        .reference()
        .child("troops");

    _onTroopsAddedSubscription = _troopsQuery.onChildAdded.listen(onEntryAdded);
    _onTroopsChangedSubscription = _troopsQuery.onChildChanged.listen(onEntryChanged);

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

  addNewTroops(String troopsItem1, String troopsItem2, bool isSMasterAssigned) {
    if ((troopsItem1.length > 0) && (troopsItem2.length > 0))
    {
      Troops troops = new Troops(troopsItem1.toString(), troopsItem2.toString(),isSMasterAssigned);
      _database.reference().child("troops").push().set(troops.toJson());
    }
  }

  updateTroops(Troops troops) {
    //Toggle completed
    if (troops != null) {
      _database.reference().child("troops").child(troops.key).set(troops.toJson());
    }
  }

  deleteTroops(String troopsId, int index) {
    _database.reference().child("troops").child(troopsId).remove().then((_) {
      setState(() {
        _troopsList.removeAt(index);
      });
    });
  }

  showAddTroopsDialog(BuildContext context) async {
    _textEditingController1.clear();
    _textEditingController2.clear();

    await showDialog<String>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: new Row(
              children: <Widget>[
                new Expanded(
                    child: new TextField(
                      controller: _textEditingController1,
                      autofocus: true,
                      decoration: new InputDecoration(
                        labelText: 'Council',
                      ),
                    )),
                new Expanded(
                    child: new TextField(
                      controller: _textEditingController2,
                      autofocus: true,
                      decoration: new InputDecoration(
                        labelText: 'Troop',
                      ),
                    ))//,
                //new Expanded(
                //  child: new Text(
                //  "\n\nDuplicate entry",
                //style: TextStyle(
                //  fontSize: 13.0,
                //color: Colors.red,
                //height: 1.0,
                //fontWeight: FontWeight.w300),
                // )
                // )
              ],
            ),
            actions: <Widget>[
              new FlatButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    Navigator.pop(context);
                  }),
              new FlatButton(
                  child: const Text('Save'),
                  onPressed: () {
                    bool duplicateFlag = false;
                    //Check for duplicate entry, before allowing to push
                    int length_array=(_troopsList.length).toInt();
                    for (int index=0;index<length_array;index++) {
                      if((_troopsList[index].council == _textEditingController1.text.toString()) && (_troopsList[index].troop == _textEditingController2.text.toString()))
                      {
                        //Display error message
                        new Text(
                          "\n\nDuplicate entry",
                          style: TextStyle(
                              fontSize: 13.0,
                              color: Colors.red,
                              height: 1.0,
                              fontWeight: FontWeight.w300),
                        );
                        duplicateFlag = true;
                      }
                    }
                    if (!duplicateFlag) {
                      addNewTroops(_textEditingController1.text.toString(), _textEditingController2.text.toString(), false);
                      Navigator.pop(context);
                    }
                  })
            ],
          );
        });
  }

  _showDialog(BuildContext context) async {
    await showDialog<String>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: new Row(
              children: <Widget>[
                new Expanded(child: new TextField(
                  controller: _textEditingController1,
                  autofocus: true,
                  decoration: new InputDecoration(
                    labelText: 'Add new council',
                  ),
                )),
                new Expanded(child: new TextField(
                  controller: _textEditingController2,
                  autofocus: true,
                  decoration: new InputDecoration(
                    labelText: 'Add new troop',
                  ),
                ))
              ],
            ),
            actions: <Widget>[
              new FlatButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    Navigator.pop(context);
                  }),
              new FlatButton(
                  child: const Text('Save'),
                  onPressed: () {
                    addNewTroops(_textEditingController1.text.toString(),_textEditingController2.text.toString(), false);
                    int x=(_troopsList.length).toInt();
                    Navigator.pop(context);
                  })
            ],
          );
        }
    );
  }

  Widget showTroopsList() {
    if (_troopsList.length > 0) {
      return ListView.builder(
          shrinkWrap: true,
          itemCount: (_troopsList.length).toInt(),
          itemBuilder: (BuildContext context, int index) {
            String troopsId = _troopsList[index].key;
            String council = _troopsList[index].council;
            String troop = _troopsList[index].troop;
            return DataTable(
              key: Key(troopsId),

                headingRowHeight: 30,
                columns: <DataColumn>[
                  DataColumn(
                    label: Text(
                      '',
                      style: TextStyle(fontStyle: FontStyle.italic, fontSize: 20),

                    ),
                  ),
                  DataColumn(
                  numeric: true,
                  label: Text(
                      '',
                      style: TextStyle(fontStyle: FontStyle.italic, fontSize: 20),
                    ),
                  ),
                  ],
                  rows: <DataRow>[
                    DataRow(
                      cells: <DataCell>[
                        DataCell(Text(council, style: TextStyle( fontSize: 17))),
                        DataCell(Text(troop, style: TextStyle( fontSize: 17))),
                      ],
                    ),

                  ],
                /*mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                Text(
                  council,
                  style: TextStyle(fontSize: 20.0),
                ),
                 Text(
                  troop,
                  style: TextStyle(fontSize: 20.0),
                ),
                //trailing: IconButton(
                //  onPressed: () {
                //  updateTroops(_troopsList[index]);
                //}),
              ],*/
            );
          });
    } else {
      return Center(
          child: Text(
            "Welcome. No council/troops.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 30.0),
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          title: new Text('Super Admin'),
        ),
        body: showTroopsList(),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            showAddTroopsDialog(context);
          },
          tooltip: 'Add Troop',
          child: Icon(Icons.add),
        )
    );
  }
}
