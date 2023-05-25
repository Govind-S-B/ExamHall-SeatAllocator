import 'dart:io';
import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class HallPage extends StatefulWidget {
  const HallPage({super.key});

  @override
  State<HallPage> createState() => _HallPageState();
}

class _HallPageState extends State<HallPage> {
  late Database _database;
  List<Map<String, dynamic>> _data = [];
  var databaseFactory = databaseFactoryFfi;

  @override
  void initState() {
    super.initState();
    sqfliteFfiInit();
    _initDatabase();
  }

  Future<void> _initDatabase() async {
    final path = ('${Directory.current.path}/report.db');
    _database = await databaseFactory.openDatabase(path);
    _getData();
  }

  Future<void> _getData() async {
    final data = await _database.query('report');
    setState(() {
      _data = data;
    });
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Halls Page'),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: Container(
              color: Colors.blue,
              child: const Center(
                child: Text('Halls Entry Card', style: TextStyle(fontSize: 24)),
              ),
            ),
          ),
          Expanded(
            child: Container(
              color: Colors.green,
              child: Center(
                child: ListView(
                  children: [
                    DataTable(
                      columns: [
                        DataColumn(label: Text('ID')),
                        DataColumn(label: Text('Class')),
                        DataColumn(label: Text('Roll')),
                        DataColumn(label: Text('Hall')),
                        DataColumn(label: Text('Seat')),
                        DataColumn(label: Text('Subject')),
                      ],
                      rows: _data
                          .map(
                            (e) => DataRow(
                              cells: [
                                DataCell(
                                  EditableText(
                                    controller: TextEditingController(
                                        text: e['ID']),
                                    focusNode: FocusNode(),
                                    style: TextStyle(),
                                    cursorColor: Colors.blue,
                                    backgroundCursorColor: Colors.grey,
                                    onChanged: (value) async {
                                      await _database.update(
                                        'report',
                                        {'ID': value},
                                        where: 'ID = ?',
                                        whereArgs: [e['ID']],
                                      );
                                    },
                                  ),
                                ),
                                DataCell(
                                  EditableText(
                                    controller: TextEditingController(
                                        text: e['CLASS']),
                                    focusNode: FocusNode(),
                                    style: TextStyle(),
                                    cursorColor: Colors.blue,
                                    backgroundCursorColor: Colors.grey,
                                    onChanged: (value) async {
                                      await _database.update(
                                        'report',
                                        {'CLASS': value},
                                        where: 'ID = ?',
                                        whereArgs: [e['ID']],
                                      );
                                    },
                                  ),
                                ),
                                DataCell(
                                  EditableText(
                                    controller: TextEditingController(
                                        text: e['ROLL'].toString()),
                                    focusNode: FocusNode(),
                                    style: TextStyle(),
                                    cursorColor: Colors.blue,
                                    backgroundCursorColor: Colors.grey,
                                    onChanged: (value) async {
                                      await _database.update(
                                        'report',
                                        {'ROLL': int.parse(value)},
                                        where: 'ID = ?',
                                        whereArgs: [e['ID']],
                                      );
                                    },
                                  ),
                                ),
                                DataCell(
                                  EditableText(
                                    controller: TextEditingController(
                                        text: e['HALL']),
                                    focusNode: FocusNode(),
                                    style: TextStyle(),
                                    cursorColor: Colors.blue,
                                    backgroundCursorColor: Colors.grey,
                                    onChanged: (value) async {
                                      await _database.update(
                                        'report',
                                        {'HALL': value},
                                        where: 'ID = ?',
                                        whereArgs: [e['ID']],
                                      );
                                    },
                                  ),
                                ),
                                DataCell(
                                  EditableText(
                                    controller: TextEditingController(
                                        text: e['SEAT_NO'].toString()),
                                    focusNode: FocusNode(),
                                    style: TextStyle(),
                                    cursorColor: Colors.blue,
                                    backgroundCursorColor: Colors.grey,
                                    onChanged: (value) async {
                                      await _database.update(
                                        'report',
                                        {'SEAT_NO': int.parse(value)},
                                        where: 'ID = ?',
                                        whereArgs: [e['ID']],
                                      );
                                    },
                                  ),
                                ),
                                DataCell(
                                  EditableText(
                                    controller: TextEditingController(
                                        text: e['SUBJECT']),
                                    focusNode: FocusNode(),
                                    style: TextStyle(),
                                    cursorColor: Colors.blue,
                                    backgroundCursorColor: Colors.grey,
                                    onChanged: (value) async {
                                      await _database.update(
                                        'report',
                                        {'SUBJECT': value},
                                        where: 'ID = ?',
                                        whereArgs: [e['ID']],
                                      );
                                    },
                                  ),
                                ),

                              ],
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
