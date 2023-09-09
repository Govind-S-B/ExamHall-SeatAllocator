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

class _ManualEditState extends State<ManualEdit> {
  String selectedIndex = '';
  var databaseFactory = databaseFactoryFfi;
  var halls_info;

  // return data of format [{name: SJ210, capacity: 60}, {name: SJ112, capacity: 323}]
  // void getHallsInfo() async {
  //   final path = ('${Directory.current.path}/input.db');
  //   var _database = await databaseFactory.openDatabase(path);
  //   halls_info = await _database.rawQuery('SELECT * FROM HALLS');
  //   _database.close();
  // }

  void getHallsInfo() async {
    final path = ('${Directory.current.path}/report.db');
    try {
      var database = await databaseFactory.openDatabase(path);
      halls_info = await database.rawQuery('SELECT hall FROM report');
      database.close();
      Set<String> uniqueValues = {};
      // myList.clear();

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
                      //Dropdown for selecting the allocated halls
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
