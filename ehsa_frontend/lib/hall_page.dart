import 'dart:io';
import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class Hall {
  final String hallName;
  final int capacity;
  String editedHallName; // Added variable to hold edited hallName
  int editedCapacity; // Added variable to hold edited capacity

  Hall(this.hallName, this.capacity)
      : editedHallName = hallName,
        editedCapacity = capacity; // Initialize editedHallName and editedCapacity

  Map<String, dynamic> toMap() {
    return {
      'hall_name': editedHallName, // Use editedHallName in toMap method
      'capacity': editedCapacity, // Use editedCapacity in toMap method
    };
  }
}
class HallPage extends StatefulWidget {
  const HallPage({super.key});

  @override
  State<HallPage> createState() => _HallPageState();
}

class _HallPageState extends State<HallPage> {
  var databaseFactory = databaseFactoryFfi;
  late Database _database;

  List<Hall> halls = [];
  List<Hall> editedHalls = [];

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
    _fetchHalls();
  }

  Future<void> _fetchHalls() async {
    final List<Map<String, dynamic>> hallData = await _database.query('HALLS');
    setState(() {
      halls = hallData.map((hall) {
        return Hall(
          hall['HALL_NAME'],
          hall['CAPACITY'],
        );
      }).toList();
    });
  }

  Future<void> _updateHall(Hall hall) async {
    await _database.update(
      'HALLS',
      hall.toMap(),
      where: 'HALL_NAME = ?',
      whereArgs: [hall.hallName],
    );
    _fetchHalls();
  }

  Future<void> _deleteHall(String hallName) async {
    await _database.delete(
      'HALLS',
      where: 'HALL_NAME = ?',
      whereArgs: [hallName],
    );
    _fetchHalls();
  }

  void updateHall(Hall hall) {
    if (!editedHalls.contains(hall)) {
      setState(() {
        editedHalls.add(hall);
      });
    }
  }

  void cancelEdit(Hall hall) {
    if (editedHalls.contains(hall)) {
      setState(() {
        hall.editedHallName = hall.hallName; // Restore original hallName
        hall.editedCapacity = hall.capacity; // Restore original capacity
        editedHalls.remove(hall);
      });
    }
  }

  void saveChanges(Hall hall) {
    if (editedHalls.contains(hall)) {
      _updateHall(hall);
      setState(() {
        editedHalls.remove(hall);
      });
    }
  }

  @override
  void dispose() {
    _database.close();
    super.dispose();
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
                          _fetchHalls();
                        },
                        child: Icon(Icons.arrow_circle_right_sharp),
                      ),
                    ),
                  ],
                )),
              )),
          Expanded(
            child: Container(
              width: double.infinity,
              color: Colors.green,
              child: SingleChildScrollView(
                child: DataTable(
                  columns: [
                    DataColumn(label: Text('Hall Name')),
                    DataColumn(label: Text('Capacity')),
                    DataColumn(label: Text('Actions')),
                  ],
                  rows: [
                    for (var hall in halls)
                      DataRow(
                        color: editedHalls.contains(hall) ? MaterialStateColor.resolveWith(
                                  (states) => Colors.grey.withOpacity(0.8))
                              : MaterialStateColor.resolveWith(
                                  (states) => Colors.transparent),
                        cells: [
                          DataCell(
                            editedHalls.contains(hall)
                                ? TextFormField(
                                    initialValue: hall.editedHallName,
                                    onChanged: (value) {
                                      setState(() {
                                        hall.editedHallName = value; // Update editedHallName
                                      });
                                    },
                                  )
                                : Text(hall.hallName),
                          ),
                          DataCell(
                            editedHalls.contains(hall)
                                ? TextFormField(
                                    initialValue: hall.editedCapacity.toString(),
                                    onChanged: (value) {
                                      setState(() {
                                        hall.editedCapacity = int.tryParse(value) ?? 0; // Update editedCapacity
                                      });
                                    },
                                  )
                                : Text(hall.capacity.toString()),
                          ),
                          DataCell(
                            editedHalls.contains(hall)
                                ? Row(
                                    children: [
                                      IconButton(
                                        icon: Icon(Icons.done),
                                        onPressed: () {
                                          saveChanges(hall);
                                        },
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.cancel),
                                        onPressed: () {
                                          cancelEdit(hall);
                                        },
                                      ),
                                    ],
                                  )
                                : Row(
                                    children: [
                                      IconButton(
                                        icon: Icon(Icons.edit),
                                        onPressed: () {
                                          updateHall(hall);
                                        },
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.delete),
                                        onPressed: () {
                                          _deleteHall(hall.hallName);
                                        },
                                      ),
                                    ],
                                  ),
                          ),
                        ],
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
