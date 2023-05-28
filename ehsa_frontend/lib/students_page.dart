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
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Container(
                        child: Row(
                          children: [
                            SizedBox(
                              width: 250,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: TextField(),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ElevatedButton(
                                onPressed: () {
                                  // add to list of subjects
                                },
                                child: Icon(Icons.add),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      child: Row(
                        children: [],
                      ),
                    ),
                  ],
                )),
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
