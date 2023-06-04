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
  String _sessionId = "";

  var databaseFactory = databaseFactoryFfi;
  late Database _database;

  @override
  void initState() {
    super.initState();
    sqfliteFfiInit();
    _initDatabase();
  }

  Future<void> _initDatabase() async {
    final path = ('${Directory.current.path}/input.db');
    _database = await databaseFactory.openDatabase(path);
    _database.execute("""CREATE TABLE IF NOT EXISTS metadata
                (key TEXT PRIMARY KEY NOT NULL,
                value TEXT NOT NULL)""");
    _setSessionIdValue();
  }

  Future<void> _setSessionIdValue() async {
    //function to check if the metadata table has a key containing SESSION_NAME
    var val = await _database.query("metadata", where: "key = 'session_name'");
    _sessionId = (val.isEmpty ? "Undefined" : val[0]["value"]).toString();
    setState(() {});
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
                      labelText: 'Session : ' + _sessionId,
                    ),
                  ),
                ), // enter session name
                ElevatedButton(
                    onPressed: () {
                      var input = _sessionIdFieldController.text.trim();
                      if (RegExp(r'\d\d-\d\d-\d\d\d\d [AF]N').hasMatch(input) &&
                          input.length == 13) {
                        _sessionId = input;
                      } else {
                        _sessionId = "INVALID SESSION ID";
                      }
                      // write a function to update the metadata table with the new session name
                      _database.execute(
                          "INSERT OR REPLACE INTO metadata (key, value) VALUES ('session_name', '$_sessionId')");
                      _sessionIdFieldController.clear();
                      setState(() {});
                    },
                    child: Icon(Icons.settings)),
              ],
            ), // set session name
            ElevatedButton(
                onPressed: () async {
                  // async function to launch rust allocator and wait for its response exit code
                  // if exit code is 0 then show a success message
                  // else show an error message

                  try {
                    final result = await Process.run(
                        '${Directory.current.path}\\allocator.exe', []);

                    if (result.exitCode == 0) {
                      // Executable executed successfully
                      // launch pdf generator

                      final result2 = await Process.run(
                          '${Directory.current.path}\\pdf_generator.exe', []);
                    } else {
                      // Executable failed
                    }
                  } catch (e) {
                    // Handle any exceptions here
                  }
                },
                child: Text("Generate")) // generate button
          ],
        )));
  }
}
