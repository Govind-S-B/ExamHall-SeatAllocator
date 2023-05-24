import 'package:flutter/material.dart';

class StudentsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Students Page'),
      ),
      body: Column(
            children: <Widget>[
              Expanded(
                child: Container(
                  color: Colors.blue,
                  child: Center(
                    child: Text('Students Data Cards', style: TextStyle(fontSize: 24)),
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  color: Colors.green,
                  child: Center(
                    child: Text('DB Table View', style: TextStyle(fontSize: 24)),
                  ),
                ),
              ),
            ],
          ),
    );
  }
}
