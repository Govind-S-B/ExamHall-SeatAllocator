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

  @override
  void initState() {
    super.initState();
    sqfliteFfiInit();
    _initDatabase();
  }

  Future<void> _initDatabase() async {
    final path = ('${Directory.current.path}/report.db');
    _database = await databaseFactory.openDatabase(path);
    _getData();
  }

  Future<void> _getData() async {
    final data = await _database.query('report');
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
              child: const Center(
                child: Text('Halls Entry Card', style: TextStyle(fontSize: 24)),
              ),
            ),
          ),
          Expanded(
            child: Container(
              color: Colors.green,
              child: Center(
                child: ListView(
                  children: [
                    DataTable(
                      columns: [
                        DataColumn(label: Text('ID')),
                        DataColumn(label: Text('Class')),
                        DataColumn(label: Text('Roll')),
                        DataColumn(label: Text('Hall')),
                        DataColumn(label: Text('Seat')),
                        DataColumn(label: Text('Subject')),
                      ],
                      rows: _data
                          .map(
                            (e) => DataRow(
                              cells: [
                                DataCell(Text(e['ID'])),
                                DataCell(Text(e['CLASS'])),
                                DataCell(Text(e['ROLL'].toString())),
                                DataCell(Text(e['HALL'])),
                                DataCell(Text(e['SEAT_NO'].toString())),
                                DataCell(Text(e['SUBJECT'])),
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
