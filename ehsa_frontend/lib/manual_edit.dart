// ignore_for_file: avoid_print

import 'dart:io';
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
  double xAxis = 0.0;
  double yAxis = 0.0;

  List<Map<String, dynamic>> transferredList = [];

  String selectedIndex = '';
  var databaseFactory = databaseFactoryFfi;
  var halls_info;

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
              'seat_no': seatNo,
              'id': 'Unallocated',
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
            'seat_no': i.toString(),
            'id': 'Unallocated',
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
                        elevation: 2,
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
                            child: Text(value),
                          );
                        }).toList(),
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
                                  vertical: 4.0, horizontal: 4.0),
                              color:
                                  isUnallocated ? Colors.blue.shade100 : null,
                              child: isUnallocated
                                  ? DragTarget<Map<String, dynamic>>(
                                      onWillAccept: (data) => isUnallocated,
                                      onAccept: (transferredItem) {
                                        setState(() {
                                          final newSeat = {
                                            'seat_no': seat['seat_no'],
                                            'id': transferredItem['id'],
                                            'subject':
                                                transferredItem['subject']
                                          };
                                          seatsList[index] = newSeat;
                                          transferredList
                                              .remove(transferredItem);
                                        });
                                      },
                                      builder: (context, candidateData,
                                          rejectedData) {
                                        return ListTile(
                                          contentPadding:
                                              const EdgeInsets.all(8.0),
                                          title: Text(
                                            "       ${seat['seat_no']}                                                           Unallocated",
                                          ),
                                        );
                                      },
                                    )
                                  : Draggable<Map<String, dynamic>>(
                                      dragAnchorStrategy:
                                          (draggable, context, position) {
                                        return Offset(0, 0);
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
                                        contentPadding:
                                            const EdgeInsets.all(8.0),
                                        title: Text(
                                            "       ${seat['seat_no']}       ${seat['id']}        ${seat['subject']}"),
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
                            setState(() {
                              transferredList.add(transferredItem);
                              updateSeatsList(transferredItem);
                            });
                          },
                          onLeave: (transferredItem) {
                            setState(() {
                              if (!transferredList.contains(transferredItem)) {
                                transferredList.add(transferredItem!);
                              }
                            });
                          },
                          builder: (context, candidateData, rejectedData) {
                            return transferredList.isEmpty
                                ? const Center(
                                    child: Text("Drag and Drop here"),
                                  )
                                : ListView.builder(
                                    itemCount: transferredList.length,
                                    itemBuilder: (context, index) {
                                      final transferredItem =
                                          transferredList[index];
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
                                                const EdgeInsets.all(8),
                                            title: Text(
                                              "${transferredItem['id']} - ${transferredItem['subject']}",
                                              style: const TextStyle(
                                                color: Colors.black,
                                                fontSize: 16.0,
                                              ),
                                            ),
                                            // trailing:
                                            //     Draggable<Map<String, dynamic>>(
                                            //   dragAnchorStrategy:
                                            //       (draggable, context, position) {
                                            //     return Offset(0, 0);
                                            //   },
                                            //   data: transferredItem,
                                            //   child: Icon(Icons.drag_indicator),
                                            //   feedback: Material(
                                            //     borderRadius:
                                            //         BorderRadius.circular(16),
                                            //     elevation: 8,
                                            //     child: Container(
                                            //       padding:
                                            //           const EdgeInsets.all(12),
                                            //       decoration: BoxDecoration(
                                            //         color: Colors.blue.shade100,
                                            //         borderRadius:
                                            //             BorderRadius.circular(16),
                                            //       ),
                                            //       child: Text(
                                            //         "${transferredItem['id']} - ${transferredItem['subject']}",
                                            //         style: const TextStyle(
                                            //           color: Colors.black,
                                            //           fontSize: 16.0,
                                            //         ),
                                            //       ),
                                            //     ),
                                            //   ),
                                            // ),
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
                            onPressed: () {},
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
