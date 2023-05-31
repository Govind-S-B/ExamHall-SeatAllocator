import 'dart:io';
import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';


class GeneratePage extends StatefulWidget {
  const GeneratePage({super.key});

  @override
  State<GeneratePage> createState() => _GeneratePageState();
}

class _GeneratePageState extends State<GeneratePage> {

  TextEditingController _sessionIdFieldController = TextEditingController();
  String _sessionId = "" ;

  var databaseFactory = databaseFactoryFfi;
  late Database _database;

  @override
  void initState () {
    super.initState();
    sqfliteFfiInit();
    _initDatabase();
  }

  Future<void> _initDatabase() async {
    final path = ('${Directory.current.path}/input.db');
    _database = await databaseFactory.openDatabase(path);
     _database.execute("""CREATE TABLE IF NOT EXISTS METADATA
                (KEY TEXT PRIMARY KEY NOT NULL,
                VALUE TEXT NOT NULL)""");
    _setSessionIdValue();
  }

  Future<void> _setSessionIdValue() async {
    //function to check if the metadata table has a key containing SESSION_NAME 
    var val = await _database.query("METADATA");
    _sessionId =  (val.isEmpty ? "Undefined" : val[0]["VALUE"]).toString()  ;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Generate Page'),
      ),
      body: Container(
        child: Column(
          children: [
            Row(
              children: [
                SizedBox(
                  width: 300,
                  child: TextField(
                    controller: _sessionIdFieldController,
                    decoration: InputDecoration(
                      labelText: 'Session : ' + _sessionId ,
                    ),
                  ),
                  ),// enter session name
                ElevatedButton(onPressed: (){
                  _sessionId = _sessionIdFieldController.text;
                  // write a function to update the metadata table with the new session name
                  _database.execute("INSERT OR REPLACE INTO METADATA (KEY, VALUE) VALUES ('SESSION_NAME', '$_sessionId')");
                  _sessionIdFieldController.clear();
                  setState(() {});
                }, child: Icon(Icons.settings)),
              ],
            ), // set session name
            ElevatedButton(onPressed: (){}, child: Text("Generate")) // generate button , makes API CA
          ],
        )
      )
    );
  }
}