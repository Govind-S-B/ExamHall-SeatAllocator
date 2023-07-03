import 'dart:io';
import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';

class GeneratePage extends StatefulWidget {
  const GeneratePage({super.key});

  @override
  State<GeneratePage> createState() => _GeneratePageState();
}

class _GeneratePageState extends State<GeneratePage> {
  final TextEditingController _sessionIdFieldController =
      TextEditingController();
  String _sessionId = "";

  bool is_randomisation_enabled = false;

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

  void toggleButton() {
    setState(() {
      is_randomisation_enabled = !is_randomisation_enabled;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16), bottom: Radius.circular(16)),
            color: Colors.blue.shade300.withAlpha(50),
          ),
          child: Column(
            children: [
              SizedBox(
                height: 200,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Container(
                        width: 300,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.blue.shade300),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: TextField(
                          controller: _sessionIdFieldController,
                          decoration: InputDecoration(
                            labelText: 'Session : $_sessionId',
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.all(10),
                          ),
                        ),
                      ),
                    ), // enter session name
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: ElevatedButton(
                        onPressed: () {
                          var input = _sessionIdFieldController.text.trim();
                          if (RegExp(r'\d\d-\d\d-\d\d\d\d [AF]N')
                              .hasMatch(input)) {
                            _sessionId = input;
                          } else {
                            final snackBar = SnackBar(
                              /// need to set following properties for best effect of awesome_snackbar_content
                              elevation: 0,
                              behavior: SnackBarBehavior.floating,
                              backgroundColor: Colors.transparent,
                              content: AwesomeSnackbarContent(
                                title: 'Invalid Session ID',
                                message:
                                    'Please Recheck the Session ID entered if of proper format and try again.',

                                /// change contentType to ContentType.success, ContentType.warning or ContentType.help for variants
                                contentType: ContentType.failure,
                              ),
                            );

                            ScaffoldMessenger.of(context)
                              ..hideCurrentSnackBar()
                              ..showSnackBar(snackBar);
                          }

                          // write a function to update the metadata table with the new session name
                          _database.execute(
                            "INSERT OR REPLACE INTO metadata (key, value) VALUES ('session_name', '$_sessionId')",
                          );
                          _sessionIdFieldController.clear();
                          setState(() {});
                        },
                        child: const Icon(Icons.settings),
                      ),
                    )
                  ],
                ),
              ), // set session name

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Enable Randomisation ?'),
                  Checkbox(
                    value: is_randomisation_enabled,
                    onChanged: (value) => toggleButton(),
                  )
                ],
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                        onPressed: () async {
                          // async function to launch rust allocator and wait for its response exit code
                          // if exit code is 0 then show a success message
                          // else show an error message

                          // by default show failure message
                          var content_type = ContentType.failure;
                          var title = "PDF Generation Failed";
                          var msg = "PDF Generation Failed";

                          List<String> allocator_args;

                          if (is_randomisation_enabled) {
                            allocator_args = [
                              "input.db",
                              "report.db",
                              "--randomize",
                              "5"
                            ];
                          } else {
                            allocator_args = ["input.db", "report.db"];
                          }

                          try {
                            final result = await Process.run(
                                '${Directory.current.path}\\allocator.exe',
                                allocator_args);

                            if (result.exitCode == 0) {
                              // Executable executed successfully
                              // launch pdf generator

                              final result2 = await Process.run(
                                  '${Directory.current.path}\\pdf_generator.exe',
                                  []);

                              if (result2.exitCode == 0) {
                                // pdf generated successfully

                                content_type = ContentType.success;
                                title = "PDF Generated";
                                msg =
                                    "PDF Generated , please check the output folder.";
                              } else {
                                // pdf generation failed

                                msg = "PDF Generator Failed : ${result2.exitCode} ${result2.stderr}";
                              }
                            }
                            else if(result.exitCode == 101){ // THIS IS NOT WORKING AS ARJUN SAID IT WOULD . FIX IT OR REMOVE IT

                              msg = "Allocator Failed : " + result.stderr;

                            }
                            else {
                              // Executable failed

                              msg = "Allocator Failed : Unhandled exception ${result.exitCode} ${result.stderr}";
                            }
                          } catch (e) {
                            // Handle any exceptions here

                            msg = "You shouldnt be seeing this : $e";

                          }

                          final snackBar = SnackBar(
                            elevation: 0,
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: Colors.transparent,
                            content: AwesomeSnackbarContent(
                              title: title,
                              message: msg,
                              contentType: content_type,
                            ),
                          );

                          ScaffoldMessenger.of(context)
                            ..hideCurrentSnackBar()
                            ..showSnackBar(snackBar);
                        },
                        child: const Text("Generate")),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                        onPressed: () {
                          final Uri fileLocation = Uri.parse(
                              "file:" '${Directory.current.path}/../output/');
                          launchUrl(fileLocation);
                        },
                        child: const Icon(Icons.folder_open)),
                  )
                ],
              ) // generate button
            ],
          )),
    ));
  }
}
