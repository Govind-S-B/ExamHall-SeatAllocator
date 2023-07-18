import 'dart:io';
import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class ManualEdit extends StatefulWidget {
  const ManualEdit({super.key});

  @override
  State<ManualEdit> createState() => _ManualEditState();
}

class _ManualEditState extends State<ManualEdit> {
  var databaseFactory = databaseFactoryFfi;
  var halls_info;

  // return data of format [{name: SJ210, capacity: 60}, {name: SJ112, capacity: 323}]
  void getHallsInfo() async {
    final path = ('${Directory.current.path}/input.db');
    var _database = await databaseFactory.openDatabase(path);
    halls_info = await _database.rawQuery('SELECT * FROM HALLS');
    _database.close();
  }

  @override
  void initState() {
    super.initState();
    sqfliteFfiInit();
    getHallsInfo();
  }

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
