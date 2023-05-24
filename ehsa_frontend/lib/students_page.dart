import 'package:flutter/material.dart';

class StudentsPage extends StatelessWidget {
  const StudentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Students Page'),
      ),
      body: Column(
            children: <Widget>[
              Expanded(
                child: Container(
                  color: Colors.blue,
                  child: const Center(
                    child: Text('Students Data Cards', style: TextStyle(fontSize: 24)),
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  color: Colors.green,
                  child: const Center(
                    child: Text('DB Table View', style: TextStyle(fontSize: 24)),
                  ),
                ),
              ),
            ],
          ),
    );
  }
}
