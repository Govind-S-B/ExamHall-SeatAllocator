import 'dart:io';
import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class HallPage extends StatefulWidget {
  const HallPage({super.key});

  @override
  State<HallPage> createState() => _HallPageState();
}

class _HallPageState extends State<HallPage> {
  var databaseFactory = databaseFactoryFfi;
  late Database _database;

  List<Map<String, dynamic>> _data = [];
  Map<int, Map<String, dynamic>> _originalData = {};
  Map<int, bool> _isEditing = {};

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
    var data = await _database.query('HALLS');
    setState(() {
      _data = data;
      _originalData = Map<int, Map<String, dynamic>>.fromIterable(
        _data.asMap().keys,
        key: (index) => index,
        value: (index) => Map<String, dynamic>.from(data[index]),
      );
      _isEditing = Map<int, bool>.fromIterable(
        _data.asMap().keys,
        key: (index) => index,
        value: (index) => false,
      );
    });
  }

  Future<void> _updateData(int index, String column, dynamic value) async {
    await _database.update(
      'HALLS',
      {column: value},
      where: 'HALL_NAME = ?',
      whereArgs: [_data[index]['HALL_NAME']],
    );
  }

  Future<void> _deleteData(int index) async {
    await _database.delete(
      'HALLS',
      where: 'HALL_NAME = ?',
      whereArgs: [_data[index]['HALL_NAME']],
    );
    _getData();
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
          Container(
              color: Colors.blue,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                    child: Row(
                  children: [
                    SizedBox(
                      width: 200,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextField(
                          controller: _formtextController1,
                          decoration: InputDecoration(
                            labelText: 'Hall Name',
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 150,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextField(
                          controller: _formtextController2,
                          decoration: InputDecoration(
                            labelText: 'Capacity',
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton(
                        onPressed: () {
                          _database.insert('HALLS', {
                            "HALL_NAME": _formtextController1.text,
                            "CAPACITY": int.parse(_formtextController2.text)
                          });
                          _formtextController1.clear();
                          _formtextController2.clear();
                          _getData();
                        },
                        child: Icon(Icons.arrow_circle_right_sharp),
                      ),
                    ),
                  ],
                )),
              )),
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
                        DataColumn(label: Text('Actions')),
                      ],
                      rows: _data
                .asMap()
                .entries
                .map(
                  (entry) => DataRow(
                    color: _isEditing[entry.key]!
                        ? MaterialStateColor.resolveWith(
                            (states) => Colors.grey.withOpacity(0.8))
                        : MaterialStateColor.resolveWith(
                            (states) => Colors.transparent),
                    cells: [
                      _isEditing[entry.key]!
                          ? DataCell(
                              EditableText(
                                controller: TextEditingController(
                                    text: entry.value['HALL_NAME']),
                                focusNode: FocusNode(),
                                style: TextStyle(),
                                cursorColor: Colors.blue,
                                backgroundCursorColor: Colors.grey,
                                onSubmitted: (value) async {
                                  await _updateData(entry.key, 'HALL_NAME', value);
                                },
                              ),
                            )
                          : DataCell(Text(entry.value['HALL_NAME'])),
                      _isEditing[entry.key]!
                          ? DataCell(
                              EditableText(
                                controller: TextEditingController(
                                    text: entry.value['CAPACITY'].toString()),
                                focusNode: FocusNode(),
                                style: TextStyle(),
                                cursorColor: Colors.blue,
                                backgroundCursorColor: Colors.grey,
                                onSubmitted: (value) async {
                                  await _updateData(
                                      entry.key, 'CAPACITY', int.parse(value));
                                },
                              ),
                            )
                          : DataCell(Text(entry.value['CAPACITY'].toString())),
                      DataCell(
                        Row(
                          children: [
                            _isEditing[entry.key]!
                                ? Row(
                                    children: [
                                      IconButton(
                                        icon: Icon(Icons.cancel),
                                        color: Colors.red,
                                        onPressed: () {
                                          setState(() {
                                            _data[entry.key] =
                                                Map<String, dynamic>.from(
                                                    _originalData[entry.key]!);
                                            _isEditing[entry.key] = false;
                                          });
                                        },
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.check),
                                        color: Colors.green,
                                        onPressed: () {
                                          setState(() {
                                            _getData();
                                            _isEditing[entry.key] = false;
                                          });
                                        },
                                      ),
                                    ],
                                  )
                                : IconButton(
                                    icon: Icon(Icons.edit),
                                    color: Colors.blue,
                                    onPressed: () {
                                      setState(() {
                                        _isEditing[entry.key] = true;
                                      });
                                    },
                                  ),
                            IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () {
                                _deleteData(entry.key);
                              },
                            ),
                          ],
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
