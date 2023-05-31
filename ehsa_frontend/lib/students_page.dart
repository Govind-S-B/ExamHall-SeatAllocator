import 'dart:io';
import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class TableViewRow {
  final String student_id;
  final String subject;
  String editedStudent_id; // Added variable to hold edited hallName
  String editedSubject; // Added variable to hold edited capacity

  TableViewRow(this.student_id, this.subject)
      : editedStudent_id = student_id,
        editedSubject = subject; // Initialize editedHallName and editedCapacity

  Map<String, dynamic> toMap() {
    return {
      'id': editedStudent_id, // Use editedHallName in toMap method
      'subject': editedSubject, // Use editedCapacity in toMap method
    };
  }
}

class StudentsPage extends StatefulWidget {
  const StudentsPage({super.key});

  @override
  State<StudentsPage> createState() => _StudentsPageState();
}

class _StudentsPageState extends State<StudentsPage> {
  var databaseFactory = databaseFactoryFfi;
  late Database _database;

  List<String> subjects = [];

  List<String> filteredSubjects = [];
  TextEditingController _subjectTextEditingController = TextEditingController();
  String selectedSubject = '';

  TextEditingController _classTextEditingController = TextEditingController();
  TextEditingController _rollsTextEditingController = TextEditingController();

  List<TableViewRow> tableViewRows = [];
  List<TableViewRow> editedTableViewRows = [];

  @override
  void initState () {
    super.initState();
    sqfliteFfiInit();
    _initDatabase();
    
  }

  Future<void> _subjectListinit() async{
    var x =  (await _database.query('students',columns: ['subject'],distinct: true));
    subjects = x.map((e) => e['subject'].toString()).toList();
    filteredSubjects = subjects;
  }

  Future<void> _initDatabase() async {
    final path = ('${Directory.current.path}/input.db');
    _database = await databaseFactory.openDatabase(path);
    _database.execute("""CREATE TABLE IF NOT EXISTS students
                (id CHAR(8) PRIMARY KEY NOT NULL,
                subject TEXT NOT NULL)""");
    _fetchTableViewRows();
    _subjectListinit();
  }

  Future<void> _fetchTableViewRows() async {
    final List<Map<String, dynamic>> table_data = await _database.query('students');
    setState(() {
      tableViewRows = table_data.map((row) {
        return TableViewRow(
          row['id'],
          row['subject'],
        );
      }).toList();
    });
  }

  Future<void> _updateTableViewRow(TableViewRow row) async {
    await _database.update(
      'students',
      row.toMap(),
      where: 'id = ?',
      whereArgs: [row.student_id],
    );
    _fetchTableViewRows();
  }

  Future<void> _deleteTableViewRow(String student_id) async {
    await _database.delete(
      'students',
      where: 'id = ?',
      whereArgs: [student_id],
    );
    _fetchTableViewRows();
  }

  void updateTableViewRow(TableViewRow row) {
    if (!editedTableViewRows.contains(row)) {
      setState(() {
        editedTableViewRows.add(row);
      });
    }
  }

  void cancelEdit(TableViewRow row) {
    if (editedTableViewRows.contains(row)) {
      setState(() {
        row.editedStudent_id = row.student_id; // Restore original hallName
        row.editedSubject = row.subject; // Restore original capacity
        editedTableViewRows.remove(row);
      });
    }
  }

  void saveChanges(TableViewRow row) {
    if (editedTableViewRows.contains(row)) {
      _updateTableViewRow(row);
      setState(() {
        editedTableViewRows.remove(row);
      });
    }
  }

  @override
  void dispose() {
    _subjectTextEditingController.dispose();
    _database.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Students Page'),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 2,
            child: Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 300,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextField(
                            controller: _classTextEditingController,
                            decoration: InputDecoration(
                                    hintText: 'Enter Class',
                                  ),
                          ),
                          TextField(
                            controller: _rollsTextEditingController,
                            decoration: InputDecoration(
                                    hintText: 'Enter Roll List',
                                  ),
                            maxLines: null,
                          )
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 500,
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _subjectTextEditingController,
                                  onChanged: (value) {
                                    setState(() {
                                      filteredSubjects = subjects
                                          .where((subject) => subject
                                              .toLowerCase()
                                              .contains(value.toLowerCase()))
                                          .toList();
                                    });
                                  },
                                  decoration: InputDecoration(
                                    hintText: 'Enter Subject',
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.add),
                                onPressed: () {
                                  String newSubject =
                                      _subjectTextEditingController.text.trim();
                                  if (newSubject.isNotEmpty &&
                                      !subjects.contains(newSubject)) {
                                    setState(() {
                                      subjects.add(newSubject);
                                      filteredSubjects = subjects;
                                      _subjectTextEditingController.clear();
                                    });
                                  }
                                },
                              ),
                              ElevatedButton(
                                child: Text('Submit'),
                                onPressed: () {

                                  var student_class =  _classTextEditingController.text;
                                  var roll_list = _rollsTextEditingController.text.split(",");

                                  for (var roll in roll_list) {
                                    if(roll.contains("-")){
                                      var roll_num_range = roll.split("-");

                                      for (var i = int.parse(roll_num_range[0]); i <= int.parse(roll_num_range[1]); i++) {

                                        _database.insert('students', {
                                        "id": student_class + "-" + i.toString(),
                                        "subject": selectedSubject,
                                        });

                                      }

                                    }
                                    else{

                                      _database.insert('students', {
                                        "id": student_class + "-" + roll,
                                        "subject": selectedSubject,
                                        });

                                    }
                                  }

                                  
                                  _classTextEditingController.clear();
                                  _rollsTextEditingController.clear();
                                  _subjectTextEditingController.clear();
                                  filteredSubjects = subjects;
                                  _fetchTableViewRows();
                                  setState(() {});
                                },
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                            SizedBox(
                              height: 90,
                              child: SingleChildScrollView(
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: filteredSubjects.length,
                                  itemBuilder: (context, index) {
                                    return ListTile(
                                      visualDensity: VisualDensity(horizontal: 0, vertical: -4 ),
                                      style: ListTileStyle.list,
                                      title: Text(filteredSubjects[index],
                                      style: TextStyle(fontSize: 12),),
                                      dense: true,
                                      onTap: () {
                                        setState(() {
                                          selectedSubject =
                                              filteredSubjects[index];
                                          _subjectTextEditingController.text =
                                              selectedSubject;
                                          filteredSubjects = [];
                                        });
                                      },
                                    );
                                  },
                                ),
                              ),
                            ),
                        ],
                      ),
                    )
                  ],
                )),
          ),
          Expanded(
            flex: 3,
            child: Container(
              width: double.infinity,
              child: SingleChildScrollView(
                child: DataTable(
                  columns: [
                    DataColumn(label: Text('ID')),
                    DataColumn(label: Text('Subject')),
                    DataColumn(label: Text('Actions')),
                  ],
                  rows: [
                    for (var row in tableViewRows)
                      DataRow(
                        color: editedTableViewRows.contains(row) ? MaterialStateColor.resolveWith(
                                  (states) => Colors.grey.withOpacity(0.8))
                              : MaterialStateColor.resolveWith(
                                  (states) => Colors.transparent),
                        cells: [
                          DataCell(
                            editedTableViewRows.contains(row)
                                ? TextFormField(
                                    initialValue: row.editedStudent_id,
                                    onChanged: (value) {
                                      setState(() {
                                        row.editedStudent_id = value; // Update editedHallName
                                      });
                                    },
                                  )
                                : Text(row.student_id),
                          ),
                          DataCell(
                            editedTableViewRows.contains(row)
                                ? TextFormField(
                                    initialValue: row.editedSubject,
                                    onChanged: (value) {
                                      setState(() {
                                        row.editedSubject = value; // Update editedCapacity
                                      });
                                    },
                                  )
                                : Text(row.subject),
                          ),
                          DataCell(
                            editedTableViewRows.contains(row)
                                ? Row(
                                    children: [
                                      IconButton(
                                        icon: Icon(Icons.done),
                                        onPressed: () {
                                          saveChanges(row);
                                        },
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.cancel),
                                        onPressed: () {
                                          cancelEdit(row);
                                        },
                                      ),
                                    ],
                                  )
                                : Row(
                                    children: [
                                      IconButton(
                                        icon: Icon(Icons.edit),
                                        onPressed: () {
                                          updateTableViewRow(row);
                                        },
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.delete),
                                        onPressed: () {
                                          _deleteTableViewRow(row.student_id);
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
