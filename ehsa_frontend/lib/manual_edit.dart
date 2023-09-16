// ignore_for_file: avoid_print

import 'dart:io';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class ManualEdit extends StatefulWidget {
  const ManualEdit({super.key});

  @override
  State<ManualEdit> createState() => _ManualEditState();
}

List<String> myList = [];
List<Map<String, dynamic>> seatsList = [];

class _ManualEditState extends State<ManualEdit> {
  String? sourceSide;

  Set<Map<String, dynamic>> transferredSet = {};

  String selectedIndex = '';
  var databaseFactory = databaseFactoryFfi;
  var halls_info;

  //To add to the database while drag n drop
  Future<void> addToDatabase(Map<String, dynamic> seat) async {
    final path = ('${Directory.current.path}/report.db');
    try {
      final database = await openDatabase(path, version: 1,
          onCreate: (Database db, int version) async {
        await db.execute(
            'CREATE TABLE IF NOT EXISTS report (id TEXT, class TEXT, roll_no TEXT, hall TEXT, seat_no TEXT, subject TEXT)');
      });

      await database.insert('report', seat,
          conflictAlgorithm: ConflictAlgorithm.replace);

      await database.close();
      print('Seat added to the database: $seat');
    } catch (e) {
      print('Error adding seat to the database: $e');
    }
  }

  //To remove to the database while drag n drop
  Future<void> removeFromDatabase(Map<String, dynamic> seat) async {
    final path = ('${Directory.current.path}/report.db');
    try {
      final database = await openDatabase(path, version: 1,
          onCreate: (Database db, int version) async {
        await db.execute(
            'CREATE TABLE IF NOT EXISTS report (id TEXT, class TEXT, roll_no TEXT, hall TEXT, seat_no TEXT, subject TEXT)');
      });

      await database.delete('report',
          where:
              'id = ? AND class = ? AND roll_no = ? AND hall = ? AND seat_no = ? AND subject = ?',
          whereArgs: [
            seat['id'],
            seat['class'],
            seat['roll_no'],
            seat['hall'],
            seat['seat_no'],
            seat['subject'],
          ]);

      await database.close();
      print('Seat removed from the database: $seat');
    } catch (e) {
      print('Error removing seat from the database: $e');
    }
  }

  void updateSeatsList(Map<String, dynamic> transferredItem,
      {bool isReverting = false}) {
    final seatNo = transferredItem['seat_no'].toString();
    final updatedSeatsList = List<Map<String, dynamic>>.from(seatsList);
    final index = updatedSeatsList
        .indexWhere((seat) => seat['seat_no'].toString() == seatNo);

    if (index != -1) {
      updatedSeatsList[index] = isReverting
          ? transferredItem
          : {
              'id': 'Unallocated',
              'class': transferredItem['class'],
              'roll_no': transferredItem['roll_no'],
              'hall': transferredItem['hall'],
              'seat_no': seatNo,
              'subject': 'Unallocated',
            };
      setState(() {
        seatsList = updatedSeatsList;
      });
    }
  }

  void getHallsInfo() async {
    final path = ('${Directory.current.path}/report.db');
    try {
      var database = await databaseFactory.openDatabase(path);
      halls_info = await database.rawQuery('SELECT hall FROM report');
      database.close();
      Set<String> uniqueValues = {};

      for (var hallInfo in halls_info) {
        uniqueValues.add(hallInfo['hall'].toString());
      }
      myList = uniqueValues.toList();
      setState(() {});

      print('Updated List: $myList');
    } catch (e) {
      print('Error fetching data from database: $e');
    }
  }

  void getSeatsInfo(String hall) async {
    final path = ('${Directory.current.path}/report.db');
    try {
      var database = await databaseFactory.openDatabase(path);

      seatsList = await database
          .rawQuery('SELECT * FROM report WHERE hall = ?', [hall]);
      database.close();

      int maxSeatNumber = seatsList.isEmpty
          ? 0
          : seatsList
              .map<int>(
                  (entry) => int.tryParse(entry['seat_no'].toString()) ?? 0)
              .reduce((value, element) => value > element ? value : element);

      List<Map<String, dynamic>> fullSeatsList = [];

      for (var i = 1; i <= maxSeatNumber; i++) {
        var foundSeat = seatsList.firstWhere(
            (seat) => int.tryParse(seat['seat_no'].toString()) == i,
            orElse: () => {});

        if (foundSeat.isEmpty) {
          fullSeatsList.add({
            'id': 'Unallocated',
            'class': 'Unallocated',
            'roll_no': 'Unallocated',
            'hall': hall,
            'seat_no': i.toString(),
            'subject': 'Unallocated'
          });
        } else {
          fullSeatsList.add(foundSeat);
        }
      }

      seatsList = fullSeatsList;

      setState(() {});
    } catch (e) {
      print('Error fetching seats data from database: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    sqfliteFfiInit();
    getHallsInfo();
  }

  @override
  Widget build(BuildContext context) {
    if (myList.isNotEmpty && selectedIndex.isEmpty) {
      selectedIndex = myList.first;
      getSeatsInfo(selectedIndex);
    }

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
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      DropdownButton<String>(
                        focusColor: Colors.transparent,
                        menuMaxHeight: MediaQuery.of(context).size.height * 0.6,
                        elevation: 4,
                        dropdownColor: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(16),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        value: selectedIndex,
                        onChanged: (String? value) {
                          setState(() {
                            selectedIndex = value!;
                          });
                          getSeatsInfo(selectedIndex);
                        },
                        items: myList
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            alignment: Alignment.center,
                            value: value,
                            child: Text(
                              value,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: 17),
                            ),
                          );
                        }).toList(),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(4),
                        child: Container(
                          height: 60,
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                                style: BorderStyle.solid,
                                width: 1,
                                color: Colors.blue),
                            color: Colors.white,
                          ),
                          child: const Row(
                            children: [
                              Expanded(
                                  flex: 2,
                                  child: Text(
                                    "   Seat No.",
                                    style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 18,
                                        color: Colors.black),
                                  )),
                              Expanded(
                                  flex: 2,
                                  child: Text(
                                    "Roll No.",
                                    style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 18,
                                        color: Colors.black),
                                  )),
                              Expanded(
                                  flex: 4,
                                  child: Text(
                                    "  Subject",
                                    style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 18,
                                        color: Colors.black),
                                  )),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          itemCount: seatsList.length,
                          itemBuilder: (context, index) {
                            final seat = seatsList[index];
                            bool isUnallocated = seat['id'] == 'Unallocated' &&
                                seat['subject'] == 'Unallocated';
                            return Card(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0)),
                              elevation: 4.0,
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 4.0, vertical: 4.0),
                              color:
                                  isUnallocated ? Colors.blue.shade100 : null,
                              child: isUnallocated
                                  ? DragTarget<Map<String, dynamic>>(
                                      onWillAccept: (data) => isUnallocated,
                                      onAccept: (transferredItem) {
                                        if (sourceSide == 'right') {
                                          setState(() {
                                            final newSeat = {
                                              'id': transferredItem['id'],
                                              'class': transferredItem['class'],
                                              'roll_no':
                                                  transferredItem['roll_no'],
                                              'hall': seat['hall'],
                                              'seat_no': seat['seat_no'],
                                              'subject':
                                                  transferredItem['subject']
                                            };
                                            seatsList[index] = newSeat;
                                            transferredSet
                                                .remove(transferredItem);
                                            addToDatabase(newSeat);
                                          });
                                        }
                                      },
                                      builder: (context, candidateData,
                                          rejectedData) {
                                        return ListTile(
                                          contentPadding:
                                              const EdgeInsets.all(4),
                                          title: Row(
                                            children: [
                                              Text(
                                                "        ${seat['seat_no']}",
                                                textAlign: TextAlign.start,
                                              ),
                                              const Expanded(
                                                child: Text(
                                                  "Unallocated",
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    )
                                  : Draggable<Map<String, dynamic>>(
                                      onDragStarted: () {
                                        setState(() {
                                          sourceSide = 'left';
                                        });
                                      },
                                      dragAnchorStrategy:
                                          (draggable, context, position) {
                                        return const Offset(0, 0);
                                      },
                                      data: seat,
                                      feedback: Material(
                                        borderRadius: BorderRadius.circular(16),
                                        elevation: 8,
                                        child: Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                              color: Colors.blue.shade100,
                                              borderRadius:
                                                  BorderRadius.circular(16)),
                                          child: Text(
                                            "${seat['id']}   -   ${seat['subject']}",
                                            style: const TextStyle(
                                              color: Colors.black,
                                              fontSize: 16.0,
                                            ),
                                          ),
                                        ),
                                      ),
                                      child: ListTile(
                                        contentPadding: const EdgeInsets.all(4),
                                        title: Row(
                                          children: [
                                            Expanded(
                                                flex: 2,
                                                child: Text(
                                                    "        ${seat['seat_no']}")),
                                            Expanded(
                                                flex: 2,
                                                child: Text(
                                                  "${seat['id']}",
                                                )),
                                            Expanded(
                                                flex: 4,
                                                child: Text(
                                                  "${seat['subject']}",
                                                )),
                                          ],
                                        ),
                                      ),
                                    ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
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
                        child: DragTarget<Map<String, dynamic>>(
                          onAccept: (transferredItem) {
                            if (sourceSide == 'left') {
                              setState(() {
                                transferredSet.add(transferredItem);
                                updateSeatsList(transferredItem);
                                removeFromDatabase(transferredItem);
                              });
                            }
                          },
                          builder: (context, candidateData, rejectedData) {
                            return transferredSet.isEmpty
                                ? const Center(
                                    child: Text(
                                      "Drag and Drop here",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16),
                                    ),
                                  )
                                : ListView.builder(
                                    itemCount: transferredSet.length,
                                    itemBuilder: (context, index) {
                                      final transferredItem =
                                          transferredSet.elementAt(index);
                                      return Card(
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(16),
                                        ),
                                        elevation: 4.0,
                                        margin: const EdgeInsets.symmetric(
                                          vertical: 4.0,
                                          horizontal: 4.0,
                                        ),
                                        child: Draggable<Map<String, dynamic>>(
                                          onDragStarted: () {
                                            setState(() {
                                              sourceSide = 'right';
                                            });
                                          },
                                          // onDragCompleted: () {
                                          //   setState(() {
                                          //     transferredSet
                                          //         .remove(transferredItem);
                                          //     addToDatabase(transferredItem);
                                          //   });
                                          // },
                                          dragAnchorStrategy:
                                              (draggable, context, position) {
                                            return const Offset(0, 0);
                                          },
                                          data: transferredItem,
                                          feedback: Material(
                                            borderRadius:
                                                BorderRadius.circular(16),
                                            elevation: 8,
                                            child: Container(
                                              padding: const EdgeInsets.all(12),
                                              decoration: BoxDecoration(
                                                color: Colors.blue.shade100,
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                              ),
                                              child: Text(
                                                "${transferredItem['id']} - ${transferredItem['subject']}",
                                                style: const TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 16.0,
                                                ),
                                              ),
                                            ),
                                          ),
                                          child: ListTile(
                                            contentPadding:
                                                const EdgeInsets.all(4),
                                            title: Center(
                                              child: Text(
                                                "${transferredItem['id']}  -  ${transferredItem['subject']}",
                                                style: const TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 16.0,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  );
                          },
                        ),
                      ),
                    )),
                Expanded(
                    flex: 3,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(0, 0, 8, 8),
                      child: SizedBox(
                        width: double.infinity,
                        height: double.infinity,
                        child: FilledButton(
                            style: FilledButton.styleFrom(
                                shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            )),
                            onPressed: () async {
                              try {
                                final result = await Process.run(
                                  '${Directory.current.path}\\pdf_generator.exe',
                                  ['report.db'],
                                );

                                if (result.exitCode == 0) {
                                  // pdf generated successfully
                                  var title = "PDF Generated";
                                  var msg =
                                      "PDF Generated, please check the output folder.";
                                  var contentType = ContentType.success;

                                  final snackBar = SnackBar(
                                    elevation: 0,
                                    behavior: SnackBarBehavior.floating,
                                    backgroundColor: Colors.transparent,
                                    content: AwesomeSnackbarContent(
                                      title: title,
                                      message: msg,
                                      contentType: contentType,
                                    ),
                                  );

                                  ScaffoldMessenger.of(context)
                                    ..hideCurrentSnackBar()
                                    ..showSnackBar(snackBar);
                                } else {
                                  // pdf generation failed
                                  var title = "PDF Generation Failed";
                                  var msg =
                                      "PDF Generator Failed: ${result.exitCode} ${result.stderr}";
                                  var contentType = ContentType.failure;

                                  final snackBar = SnackBar(
                                    elevation: 0,
                                    behavior: SnackBarBehavior.floating,
                                    backgroundColor: Colors.transparent,
                                    content: AwesomeSnackbarContent(
                                      title: title,
                                      message: msg,
                                      contentType: contentType,
                                    ),
                                  );

                                  ScaffoldMessenger.of(context)
                                    ..hideCurrentSnackBar()
                                    ..showSnackBar(snackBar);
                                }
                              } catch (e) {
                                // Handle any exceptions here
                                var msg = "You shouldn't be seeing this: $e";

                                final snackBar = SnackBar(
                                  elevation: 0,
                                  behavior: SnackBarBehavior.floating,
                                  backgroundColor: Colors.transparent,
                                  content: AwesomeSnackbarContent(
                                    title: "Error",
                                    message: msg,
                                    contentType: ContentType.failure,
                                  ),
                                );

                                ScaffoldMessenger.of(context)
                                  ..hideCurrentSnackBar()
                                  ..showSnackBar(snackBar);
                              }
                            },
                            child: const Text(
                              'Generate',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                                fontSize: 18,
                              ),
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
