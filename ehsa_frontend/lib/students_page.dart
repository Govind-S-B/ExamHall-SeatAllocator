import 'dart:io';
import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class TableViewRow {
  // Table View Row refers to Students View
  final String student_id;
  final String subject;
  String editedStudent_id; // Added variable to hold edited Student_id
  String editedSubject; // Added variable to hold edited Subject

  TableViewRow(this.student_id, this.subject)
      : editedStudent_id = student_id,
        editedSubject = subject; // Initialize edited Student_id and Subject

  Map<String, dynamic> toMap() {
    return {
      'id': editedStudent_id, // Use edited Student  in toMap method
      'subject': editedSubject, // Use edited Subject in toMap method
    };
  }
}

class SubjectViewRow {
  final String subject;
  String editedSubject; // hold edited Subject

  SubjectViewRow(this.subject) : editedSubject = subject;

  Map<String, dynamic> toMap() {
    return {
      'subject': editedSubject, // Use edited Subject in toMap method
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

  final TextEditingController _subjectTextEditingController =
      TextEditingController();
  String selectedSubject = '';

  final TextEditingController _classTextEditingController =
      TextEditingController();
  final TextEditingController _rollsTextEditingController =
      TextEditingController();

  List<bool> isSelected = [true, false, false];
  int selectedOption = 1;

  List<SubjectViewRow> subjectViewRows = [];
  List<SubjectViewRow> editedSubjectViewRows = [];

  List<TableViewRow> tableViewRows = [];
  List<TableViewRow> editedTableViewRows = [];

  @override
  void initState() {
    super.initState();
    sqfliteFfiInit();
    _initDatabase();
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

  Future<void> _subjectListinit() async {
    var x = (await _database.query('students',
        columns: ['subject'], distinct: true));
    subjects = x
        .map((e) => e['subject'].toString())
        .toList(); // subjects only needs to be updated from the database once when we initialise the tables
    filteredSubjects = subjects;
    subjectViewRows = x.map((e) {
      return SubjectViewRow(
        e['subject'].toString(),
      );
    }).toList(); // but the rows need to be updated every time the db is changed
  }

  Future<void> _fetchSubjectViewRows() async {
    var x = (await _database.query('students',
        columns: ['subject'], distinct: true));
    setState(() {
      subjectViewRows = x.map((e) {
        return SubjectViewRow(
          e['subject'].toString(),
        );
      }).toList();
    });
  }

  Future<void> _fetchTableViewRows() async {
    final List<Map<String, dynamic>> tableData =
        await _database.query('students');
    setState(() {
      tableViewRows = tableData.map((row) {
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
    if (row.subject != row.editedSubject) {
      subjects.add(row.editedSubject);
    }
    _fetchTableViewRows();
    _fetchSubjectViewRows();
  }

  Future<void> _updateSubjectViewRow(SubjectViewRow row) async {
    await _database.execute(
        "UPDATE students SET subject = '${row.editedSubject}' WHERE subject = '${row.subject}'");
    if (row.subject != row.editedSubject) {
      subjects.add(row.editedSubject);
    }
    _fetchTableViewRows();
    _fetchSubjectViewRows();
  }

  Future<void> _dropTable() async {
    await _database.execute("DELETE FROM students");
    _fetchTableViewRows();
    _subjectListinit();
  }

  Future<void> _deleteTableViewRow(String studentId) async {
    await _database.delete(
      'students',
      where: 'id = ?',
      whereArgs: [studentId],
    );
    _fetchTableViewRows();
    _fetchSubjectViewRows();
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

  void saveSubjectChanges(SubjectViewRow row) {
    if (editedSubjectViewRows.contains(row)) {
      _updateSubjectViewRow(row);
      setState(() {
        editedSubjectViewRows.remove(row);
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

  Widget buildOptionContainer(int option) {
    switch (option) {
      case 1:
        return SizedBox(
          width: double.infinity,
          child: DataTable(
            columns: const [
              DataColumn(label: Text('ID')),
              DataColumn(label: Text('Subject')),
              DataColumn(label: Text('Actions')),
            ],
            rows: [
              for (var row in tableViewRows)
                DataRow(
                  color: editedTableViewRows.contains(row)
                      ? MaterialStateColor.resolveWith(
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
                                  row.editedStudent_id =
                                      value; // Update editedHallName
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
                                  row.editedSubject =
                                      value; // Update editedCapacity
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
                                  icon: const Icon(Icons.done),
                                  onPressed: () {
                                    saveChanges(row);
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.cancel),
                                  onPressed: () {
                                    cancelEdit(row);
                                  },
                                ),
                              ],
                            )
                          : Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () {
                                    updateTableViewRow(row);
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete),
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
        );
      case 2:
        return SizedBox(
          width: double.infinity,
          child: DataTable(
            columns: const [
              DataColumn(label: Text('Subject')),
              DataColumn(label: Text('Actions')),
            ],
            rows: [
              for (var row in subjectViewRows)
                DataRow(
                  color: editedSubjectViewRows.contains(row)
                      ? MaterialStateColor.resolveWith(
                          (states) => Colors.grey.withOpacity(0.8))
                      : MaterialStateColor.resolveWith(
                          (states) => Colors.transparent),
                  cells: [
                    DataCell(
                      editedSubjectViewRows.contains(row)
                          ? TextFormField(
                              initialValue: row.editedSubject,
                              onChanged: (value) {
                                setState(() {
                                  row.editedSubject =
                                      value; // Update editedHallName
                                });
                              },
                            )
                          : Text(row.editedSubject),
                    ),
                    DataCell(
                      editedSubjectViewRows.contains(row)
                          ? Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.done),
                                  onPressed: () {
                                    saveSubjectChanges(row);
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.cancel),
                                  onPressed: () {
                                    if (editedSubjectViewRows.contains(row)) {
                                      setState(() {
                                        row.editedSubject = row
                                            .subject; // Restore original hallName
                                        editedSubjectViewRows.remove(row);
                                      });
                                    }
                                  },
                                ),
                              ],
                            )
                          : Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () {
                                    // updateTableViewRow(row); -> updateSubjectViewRow(row); make a function later ig
                                    if (!editedSubjectViewRows.contains(row)) {
                                      setState(() {
                                        editedSubjectViewRows.add(row);
                                      });
                                    }
                                  },
                                ),
                              ],
                            ),
                    ),
                  ],
                ),
            ],
          ),
        );
      case 3:
        return SizedBox(
          width: double.infinity,
          child: DataTable(columns: const [
            DataColumn(label: Text('Classes')),
            DataColumn(label: Text('Subjects')),
            DataColumn(label: Text('Roll List')),
            DataColumn(label: Text('Actions')),
          ], rows: const []),
        );
      default:
        return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16), bottom: Radius.circular(16)),
                  color: Colors.blue.shade300.withAlpha(50),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20, top: 8),
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
                              decoration: const InputDecoration(
                                hintText: 'Enter Class',
                              ),
                            ),
                            TextField(
                              controller: _rollsTextEditingController,
                              decoration: const InputDecoration(
                                hintText: 'Enter Roll List',
                              ),
                              maxLines: null,
                            )
                          ],
                        ),
                      ),
                      const SizedBox(
                        width: 30,
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
                                    decoration: const InputDecoration(
                                      hintText: 'Enter Subject',
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.add),
                                  onPressed: () {
                                    String newSubject =
                                        _subjectTextEditingController.text
                                            .trim();
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
                                  child: const Text('Submit'),
                                  onPressed: () {
                                    var studentClass =
                                        _classTextEditingController.text;
                                    var rollList = _rollsTextEditingController
                                        .text
                                        .split(",");

                                    for (var roll in rollList) {
                                      if (roll.contains("-")) {
                                        var rollNumRange = roll.split("-");

                                        for (var i = int.parse(rollNumRange[0]);
                                            i <= int.parse(rollNumRange[1]);
                                            i++) {
                                          _database.insert('students', {
                                            "id": "$studentClass-$i",
                                            "subject": selectedSubject,
                                          });
                                        }
                                      } else {
                                        _database.insert('students', {
                                          "id": "$studentClass-$roll",
                                          "subject": selectedSubject,
                                        });
                                      }
                                    }

                                    _classTextEditingController.clear();
                                    _rollsTextEditingController.clear();
                                    _subjectTextEditingController.clear();
                                    filteredSubjects = subjects;
                                    _fetchSubjectViewRows();
                                    _fetchTableViewRows();
                                    setState(() {});
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            SizedBox(
                              height: 90,
                              child: SingleChildScrollView(
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: filteredSubjects.length,
                                  itemBuilder: (context, index) {
                                    return ListTile(
                                      visualDensity: const VisualDensity(
                                          horizontal: 0, vertical: -4),
                                      style: ListTileStyle.list,
                                      title: Text(
                                        filteredSubjects[index],
                                        style: const TextStyle(fontSize: 12),
                                      ),
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
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
            width: 150,
            height: 40,
            child: ToggleButtons(
              isSelected: isSelected,
              onPressed: (index) {
                setState(() {
                  for (int i = 0; i < isSelected.length; i++) {
                    isSelected[i] = i == index;
                  }
                  selectedOption = index + 1;
                });
              },
              children: const [
                Text('1'), // Students
                Text('2'),
                Text('3'), // Subjects
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.only(
                  left: 16, right: 16, top: 16, bottom: 8),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16), bottom: Radius.circular(16)),
                  color: Colors.blue.shade300.withAlpha(50),
                ),
                child: SingleChildScrollView(
                  child: Stack(
                    children: [
                      buildOptionContainer(selectedOption),
                      Align(
                          alignment: Alignment.topRight,
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: ElevatedButton(
                                onPressed: _dropTable,
                                child: const Text('Clear Table')),
                          )),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
