import 'dart:io';
import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class ManualEdit extends StatefulWidget {
  const ManualEdit({super.key});

  @override
  State<ManualEdit> createState() => _ManualEditState();
}

class _ManualEditState extends State<ManualEdit> {
  var databaseFactory = databaseFactoryFfi;
  var halls_info;

  // return data of format [{name: SJ210, capacity: 60}, {name: SJ112, capacity: 323}]
  void getHallsInfo() async {
    final path = ('${Directory.current.path}/input.db');
    var _database = await databaseFactory.openDatabase(path);
    halls_info = await _database.rawQuery('SELECT * FROM HALLS');
    _database.close();
  }

  @override
  void initState() {
    super.initState();
    sqfliteFfiInit();
    getHallsInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: const Text("Manual Edit"),
      ),
      body: Row(
        children: [
          Expanded(
            flex: 13,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                    bottom: Radius.circular(16),
                  ),
                  color: Colors.blue.shade300.withAlpha(50),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 7,
            child: Column(
              children: [
                Expanded(
                    flex: 27,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(0, 8, 8, 8),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(16),
                            bottom: Radius.circular(16),
                          ),
                          color: Colors.blue.shade300.withAlpha(50),
                        ),
                      ),
                    )),
                Expanded(
                    flex: 3,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(0, 0, 8, 8),
                      child: GestureDetector(
                        onTap: () {},
                        child: Container(
                            width: double.infinity,
                            decoration: const BoxDecoration(
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(16),
                                bottom: Radius.circular(16),
                              ),
                              color: Colors.blue,
                            ),
                            child: const Center(
                              child: Text("Generate",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 20)),
                            )),
                      ),
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
