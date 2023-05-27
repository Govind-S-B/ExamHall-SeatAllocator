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

  final TextEditingController _formtextController1 = TextEditingController();
  final TextEditingController _formtextController2 = TextEditingController();

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
                child: Container(
                    child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _formtextController1,
                        decoration: InputDecoration(
                          labelText: 'Hall Name',
                        ),
                      ),
                    ),
                    Expanded(
                      child: TextField(
                        controller: _formtextController2,
                        decoration: InputDecoration(
                          labelText: 'Capacity',
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        _database.insert('HALLS', {"HALL_NAME":_formtextController1.text,"CAPACITY":int.parse(_formtextController2.text)});
                        _formtextController1.clear();
                        _formtextController2.clear();
                        _getData();
                      },
                      child: Icon(Icons.arrow_circle_right_sharp),
                    ),
                  ],
                ))),
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
                                        {'CAPACITY': int.parse(value)},
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
