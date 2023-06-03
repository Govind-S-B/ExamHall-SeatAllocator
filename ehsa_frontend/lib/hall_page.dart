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
        editedCapacity =
            capacity; // Initialize editedHallName and editedCapacity

  Map<String, dynamic> toMap() {
    return {
      'name': editedHallName, // Use editedHallName in toMap method
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
    _database.execute("""CREATE TABLE IF NOT EXISTS halls
                (name CHAR(8) PRIMARY KEY NOT NULL,
                capacity INT NOT NULL)""");
    _fetchHalls();
  }

  Future<void> _fetchHalls() async {
    final List<Map<String, dynamic>> hallData = await _database.query('halls');
    setState(() {
      halls = hallData.map((hall) {
        return Hall(
          hall['name'],
          hall['capacity'],
        );
      }).toList();
    });
  }

  Future<void> _updateHall(Hall hall) async {
    await _database.update(
      'halls',
      hall.toMap(),
      where: 'name = ?',
      whereArgs: [hall.hallName],
    );
    _fetchHalls();
  }

  Future<void> _deleteHall(String hallName) async {
    await _database.delete(
      'halls',
      where: 'name = ?',
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
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 2,
            child: Container(
                child: Container(
                    child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 200,
                  child: TextField(
                    controller: _formtextController1,
                    decoration: const InputDecoration(
                      labelText: 'Hall Name',
                    ),
                  ),
                ),
                SizedBox(
                  width: 150,
                  child: TextField(
                    controller: _formtextController2,
                    decoration: const InputDecoration(
                      labelText: 'Capacity',
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    _database.insert('halls', {
                      "name": _formtextController1.text,
                      "capacity": int.parse(_formtextController2.text)
                    });
                    _formtextController1.clear();
                    _formtextController2.clear();
                    _fetchHalls();
                  },
                  child: const Icon(Icons.arrow_circle_right_sharp),
                ),
              ],
            ))),
          ),
          Expanded(
            flex: 3,
            child: SizedBox(
              width: double.infinity,
              child: SingleChildScrollView(
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('Hall Name')),
                    DataColumn(label: Text('Capacity')),
                    DataColumn(label: Text('Actions')),
                  ],
                  rows: [
                    for (var hall in halls)
                      DataRow(
                        color: editedHalls.contains(hall)
                            ? MaterialStateColor.resolveWith(
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
                                        hall.editedHallName =
                                            value; // Update editedHallName
                                      });
                                    },
                                  )
                                : Text(hall.hallName),
                          ),
                          DataCell(
                            editedHalls.contains(hall)
                                ? TextFormField(
                                    initialValue:
                                        hall.editedCapacity.toString(),
                                    onChanged: (value) {
                                      setState(() {
                                        hall.editedCapacity =
                                            int.tryParse(value) ??
                                                0; // Update editedCapacity
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
                                        icon: const Icon(Icons.done),
                                        onPressed: () {
                                          saveChanges(hall);
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.cancel),
                                        onPressed: () {
                                          cancelEdit(hall);
                                        },
                                      ),
                                    ],
                                  )
                                : Row(
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit),
                                        onPressed: () {
                                          updateHall(hall);
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete),
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
