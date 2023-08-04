import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class HallsDatabase {
  late Database _database;
  HallsDatabase();

  Future<void> initHallsDatabase(String input_path) async {
    // final path = ('${Directory.current.path}/input.db');
    _database = await databaseFactory.openDatabase(input_path);
    _database.execute("""CREATE TABLE IF NOT EXISTS halls
                (name CHAR(8) PRIMARY KEY NOT NULL,
                capacity INT NOT NULL)""");
  }


  Future<List> _fetchHalls() async {
    return await _database.query('halls');
  }
}
