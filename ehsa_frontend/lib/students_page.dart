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

class ClassViewRow {
  String
      className; // variable name cant be a keyword, so can't use just 'class'
  String subject;
  String rollList;
  String editedClassName; // holds edited class
  String editedSubject; // hold edited Subject
  String editedRollList; // hold edited Roll list

  ClassViewRow(this.className, this.subject, this.rollList)
      : editedClassName = className,
        editedSubject = subject,
        editedRollList = rollList;

  Map<String, dynamic> toMap() {
    return {
      'class': editedClassName, // Use edited Student  in toMap method
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

  List<ClassViewRow> classViewRows = [];
  List<ClassViewRow> editedClassViewRows = [];

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
                subject TEXT NOT NULL,
                class CHAR(8),
                rollno CHAR(8))""");
    _fetchTableViewRows();
    _subjectListinit();
    _fetchClassViewRows();
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

  Future<void> _fetchClassViewRows() async {
    List<Map<String, dynamic>> tableData = await _database.rawQuery('''
    SELECT class, subject, GROUP_CONCAT(rollno) AS rolls
    FROM students
    GROUP BY class, subject;
  ''');
    print(tableData);
    setState(() {
      classViewRows = tableData.map((row) {
        return ClassViewRow(
          row['class'],
          row['subject'],
          sortedRollList(row['rolls']),
        );
      }).toList();
    });
  }

  Future<void> _updateTableViewRow(TableViewRow row) async {
    List<String> sID = row.editedStudent_id.split('-');
    await _database.execute(
        "UPDATE students SET id = '${row.editedStudent_id}' , subject = '${row.editedSubject}' , class = '${sID[0]}' , rollno = '${sID[1]}' WHERE id = '${row.student_id}'");
    if (row.subject != row.editedSubject) {
      subjects.add(row.editedSubject);
    }
    _fetchTableViewRows();
    _fetchSubjectViewRows();
    _fetchClassViewRows();
  }

  Future<void> _updateSubjectViewRow(SubjectViewRow row) async {
    await _database.execute(
        "UPDATE students SET subject = '${row.editedSubject}' WHERE subject = '${row.subject}'");
    if (row.subject != row.editedSubject) {
      subjects.add(row.editedSubject);
    }
    _fetchTableViewRows();
    _fetchSubjectViewRows();
    _fetchClassViewRows();
  }

  Future<void> _updateClassViewRowClass(ClassViewRow row) async {
    await _database.execute(
        "UPDATE students SET class = '${row.editedClassName}'  WHERE subject = '${row.editedSubject}' AND rollno IN (${row.editedRollList})");
    List<int> updateClass = convertStringToList(row.editedRollList);
    for (int value in updateClass) {
      await _database.execute(
          "UPDATE students SET id = '${row.editedClassName}-$value'  WHERE subject = '${row.editedSubject}' AND rollno = $value");
    }

    // if (row.className != row.editedClassName) {
    //   subjects.add(row.editedSubject);
    // }
    _fetchTableViewRows();
    _fetchSubjectViewRows();
    _fetchClassViewRows();
  }

  Future<void> _updateClassViewRowSubject(ClassViewRow row) async {
    await _database.execute(
        "UPDATE students SET subject = '${row.editedSubject}' WHERE class = '${row.editedClassName}' AND rollno IN (${row.editedRollList})");
    if (row.subject != row.editedSubject) {
      subjects.add(row.editedSubject);
    }
    _fetchTableViewRows();
    _fetchSubjectViewRows();
    _fetchClassViewRows();
  }

  String expandRanges(String string) {
    List<String> result = [];
    List<String> ranges = string.split(",");
    for (String r in ranges) {
      if (r.trim().isNotEmpty) {
        // Ignore empty elements
        if (r.contains("-")) {
          List<String> parts = r.split("-");
          int start = int.parse(parts[0]);
          int end = int.parse(parts[1]);
          for (int i = start; i <= end; i++) {
            result.add(i.toString());
          }
        } else {
          result.add(r);
        }
      }
    }
    return result.join(",");
  }

  List<List<int>> compareLists(List<int> oldList, List<int> newList) {
    List<int> commonValues = [];
    List<int> removedValues = [];
    List<int> addedValues = [];

    // Find common values
    for (int value in oldList) {
      if (newList.contains(value)) {
        commonValues.add(value);
      } else {
        removedValues.add(value);
      }
    }

    // Find added values
    for (int value in newList) {
      if (!oldList.contains(value)) {
        addedValues.add(value);
      }
    }

    return [commonValues, removedValues, addedValues];
  }

  Future<void> _updateClassViewRowrollList(ClassViewRow row) async {
    List<int> oldList = convertStringToList(row.rollList);
    List<int> newList = convertStringToList(row.editedRollList);
    List<List<int>> rollIdentifier = compareLists(oldList, newList);
    // List<int> commonValues = rollIdentifier[0];
    List<int> removedValues = rollIdentifier[1];
    List<int> addedValues = rollIdentifier[2];

    //delete removed students from db
    for (int value in removedValues) {
      await _database.execute("DELETE FROM students WHERE rollno = '$value' AND subject = '${row.editedSubject}'");
    }
    //insert students into db
    for (int value in addedValues) {
      await _database.execute(
          "INSERT INTO students (id, subject, class, rollno) VALUES ('${row.editedClassName}-$value', '${row.editedSubject}', '${row.editedClassName}', $value)");
    }

    if (row.subject != row.editedSubject) {
      subjects.add(row.editedSubject);
    }
    _fetchTableViewRows();
    _fetchSubjectViewRows();
    _fetchClassViewRows();
  }

  Future<void> _dropTable() async {
    await _database.execute("DELETE FROM students");
    _fetchTableViewRows();
    _subjectListinit();
    _fetchClassViewRows();
  }

  Future<void> _deleteTableViewRow(String studentId) async {
    await _database.delete(
      'students',
      where: 'id = ?',
      whereArgs: [studentId],
    );
    _fetchTableViewRows();
    _fetchSubjectViewRows();
    _fetchClassViewRows();
  }

  Future<void> _deleteClassViewRow(List rollList) async {
    await _database.execute(
        "DELETE FROM students WHERE rollno IN (${rollList.join(',')})");
    _fetchTableViewRows();
    _fetchSubjectViewRows();
    _fetchClassViewRows();
  }

  void sortList(List<String> values) {
    values.sort((a, b) {
      final aValue = _getSortValue(a);
      final bValue = _getSortValue(b);
      return aValue.compareTo(bValue);
    });
  }

  int _getSortValue(String value) {
    final hyphenIndex = value.indexOf('-');
    if (hyphenIndex != -1) {
      final beforeHyphen = value.substring(0, hyphenIndex);
      return int.parse(beforeHyphen);
    } else {
      return int.parse(value);
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

  List<int> convertStringToList(String numbersString) {
    // Remove trailing comma if present
    if (numbersString.endsWith(',')) {
      numbersString = numbersString.substring(0, numbersString.length - 1);
    }

    // Split the string into individual numbers
    List<String> numberStrings = numbersString.split(',');

    // Convert each number string to an integer
    List<int> numbers =
        numberStrings.map((numberString) => int.parse(numberString)).toList();

    // Sort the numbers in ascending order
    numbers.sort();

    return numbers;
  }

  String sortedRollList(String numberString) {
    List list = convertStringToList(numberString);
    list.sort();
    return list.join(',');
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
                                      value; // Update editedStudent_id
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
                                      value; // Update editedSubject
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
                                    if (!editedTableViewRows.contains(row)) {
                                      setState(() {
                                        editedTableViewRows.add(row);
                                      });
                                    }
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
          child: DataTable(
            columns: const [
              DataColumn(label: Text('Classes')),
              DataColumn(label: Text('Subjects')),
              DataColumn(label: Text('Roll List')),
              DataColumn(label: Text('Actions')),
            ],
            rows: [
              for (var row in classViewRows)
                DataRow(
                  color: editedClassViewRows.contains(row)
                      ? MaterialStateColor.resolveWith(
                          (states) => Colors.grey.withOpacity(0.8))
                      : MaterialStateColor.resolveWith(
                          (states) => Colors.transparent),
                  cells: [
                    DataCell(
                      editedClassViewRows.contains(row)
                          ? Row(
                              children: [
                                SizedBox(
                                  width: MediaQuery.of(context).size.width *
                                      1 /
                                      16,
                                  child: TextFormField(
                                    initialValue: row.editedClassName,
                                    onChanged: (value) {
                                      setState(() {
                                        row.editedClassName =
                                            value; // Update editedClassName
                                      });
                                    },
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.done),
                                  onPressed: () {
                                    // Save changes
                                    setState(() {
                                      row.className = row.editedClassName;
                                      // Update the changes in the database
                                      _updateClassViewRowClass(row);
                                      editedClassViewRows.remove(row);
                                    });
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.cancel),
                                  onPressed: () {
                                    // Cancel edit
                                    setState(() {
                                      row.editedClassName = row.className;
                                      row.editedSubject = row.subject;
                                      row.editedRollList = row.rollList;
                                      editedClassViewRows.remove(row);
                                    });
                                  },
                                ),
                              ],
                            )
                          : Row(
                              children: [
                                Text(row.editedClassName),
                                const SizedBox(width: 30),
                                Container(
                                  constraints: const BoxConstraints(
                                      maxHeight: 25, maxWidth: 50),
                                  child: ElevatedButton(
                                    child: const Icon(Icons.edit, size: 18),
                                    onPressed: () {
                                      setState(() {
                                        editedClassViewRows.add(row);
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                    ),
                    DataCell(
                      editedClassViewRows.contains(row)
                          ? Row(
                              children: [
                                SizedBox(
                                  width: MediaQuery.of(context).size.width *
                                      1 /
                                      16,
                                  child: TextFormField(
                                    initialValue: row.editedSubject,
                                    onChanged: (value) {
                                      setState(() {
                                        row.editedSubject =
                                            value; // Update editedSubject
                                      });
                                    },
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.done),
                                  onPressed: () {
                                    // Save changes
                                    setState(() {
                                      row.rollList = row.editedRollList;
                                      // Update the changes in the database
                                      _updateClassViewRowSubject(row);
                                      editedClassViewRows.remove(row);
                                    });
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.cancel),
                                  onPressed: () {
                                    // Cancel edit
                                    setState(() {
                                      row.editedClassName = row.className;
                                      row.editedSubject = row.subject;
                                      row.editedRollList = row.rollList;
                                      editedClassViewRows.remove(row);
                                    });
                                  },
                                ),
                              ],
                            )
                          : Row(
                              children: [
                                Text(row.editedSubject),
                                const SizedBox(width: 30),
                                Container(
                                  constraints: const BoxConstraints(
                                      maxHeight: 25, maxWidth: 50),
                                  child: ElevatedButton(
                                    child: const Icon(Icons.edit, size: 18),
                                    onPressed: () {
                                      setState(() {
                                        editedClassViewRows.add(row);
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                    ),
                    DataCell(
                      editedClassViewRows.contains(row)
                          ? Row(
                              children: [
                                SizedBox(
                                  height: double.infinity,
                                  width: 320,
                                  child: TextFormField(
                                    initialValue: row.editedRollList,
                                    onChanged: (value) {
                                      setState(() {
                                        row.editedRollList =
                                            value; // Update editedRollList
                                      });
                                    },
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.done),
                                  onPressed: () {
                                    // Save changes
                                    setState(() {
                                      row.editedRollList =
                                          expandRanges(row.editedRollList);
                                      row.editedRollList =
                                          sortedRollList(row.editedRollList);
                                      // Update the changes in the database
                                      // left to implement
                                      _updateClassViewRowrollList(row);
                                      editedClassViewRows.remove(row);
                                    });
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.cancel),
                                  onPressed: () {
                                    // Cancel edit
                                    setState(() {
                                      row.editedRollList = row.rollList;
                                      editedClassViewRows.remove(row);
                                    });
                                  },
                                ),
                              ],
                            )
                          : Row(
                              children: [
                                Container(
                                    constraints: const BoxConstraints(
                                        maxWidth: 350, minWidth: 350),
                                    child: Text(
                                      row.editedRollList,
                                      overflow: TextOverflow.visible,
                                    )),
                                const SizedBox(width: 30),
                                Container(
                                  constraints: const BoxConstraints(
                                      maxHeight: 25, maxWidth: 50),
                                  child: ElevatedButton(
                                    child: const Icon(Icons.edit, size: 18),
                                    onPressed: () {
                                      setState(() {
                                        editedClassViewRows.add(row);
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                    ),
                    DataCell(
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          setState(() {
                            // Remove the row from the database
                            // ...
                            _deleteClassViewRow(
                                convertStringToList(row.editedRollList));
                          });
                        },
                      ),
                    ),
                  ],
                ),
            ],
          ),
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
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
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
                                    sortList(rollList);

                                    for (var roll in rollList) {
                                      if (roll.contains("-")) {
                                        var rollNumRange = roll.split("-");

                                        for (var i = int.parse(rollNumRange[0]);
                                            i <= int.parse(rollNumRange[1]);
                                            i++) {
                                          _database.insert('students', {
                                            "id": "$studentClass-$i",
                                            "subject": selectedSubject,
                                            "class": studentClass,
                                            "rollno": i,
                                          });
                                        }
                                      } else {
                                        _database.insert('students', {
                                          "id": "$studentClass-$roll",
                                          "subject": selectedSubject,
                                          "class": studentClass,
                                          "rollno": roll,
                                        });
                                      }
                                    }

                                    _classTextEditingController.clear();
                                    _rollsTextEditingController.clear();
                                    _subjectTextEditingController.clear();
                                    filteredSubjects = subjects;
                                    _fetchSubjectViewRows();
                                    _fetchTableViewRows();
                                    _fetchClassViewRows();
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
            height: 25,
            child: ToggleButtons(
              borderRadius: const BorderRadius.all(Radius.elliptical(8, 8)),
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
              padding:
                  const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 8),
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
