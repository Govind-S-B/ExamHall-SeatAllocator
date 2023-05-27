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
    final path = ('${Directory.current.path}/input.db');
    _database = await databaseFactory.openDatabase(path);
    _database.execute("""CREATE TABLE IF NOT EXISTS HALLS
                (HALL_NAME CHAR(8) PRIMARY KEY NOT NULL,
                CAPACITY INT NOT NULL)""");
    _getData();
  }

  Future<void> _getData() async {
    final data = await _database.query('HALLS');
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
                        DataColumn(label: Text('Hall')),
                        DataColumn(label: Text('Capacity')),
                      ],
                      rows: _data
                          .map(
                            (e) => DataRow(
                              cells: [
                                DataCell(
                                  EditableText(
                                    controller: TextEditingController(
                                        text: e['HALL_NAME']),
                                    focusNode: FocusNode(),
                                    style: TextStyle(),
                                    cursorColor: Colors.blue,
                                    backgroundCursorColor: Colors.grey,
                                    onChanged: (value) async {
                                      await _database.update(
                                        'report',
                                        {'HALL_NAME': value},
                                        where: 'HALL_NAME = ?',
                                        whereArgs: [e['HALL_NAME']],
                                      );
                                    },
                                  ),
                                ),
                                DataCell(
                                  EditableText(
                                    controller: TextEditingController(
                                        text: e['CAPACITY'].toString()),
                                    focusNode: FocusNode(),
                                    style: TextStyle(),
                                    cursorColor: Colors.blue,
                                    backgroundCursorColor: Colors.grey,
                                    onChanged: (value) async {
                                      await _database.update(
                                        'report',
                                        {'CAPACITY': int.parse(value) },
                                        where: 'HALL_NAME = ?',
                                        whereArgs: [e['HALL_NAME']],
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
