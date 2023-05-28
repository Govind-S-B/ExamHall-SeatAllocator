import 'package:flutter/material.dart';

class StudentsPage extends StatefulWidget {
  const StudentsPage({super.key});

  @override
  State<StudentsPage> createState() => _StudentsPageState();
}

class _StudentsPageState extends State<StudentsPage> {
  final List<String> subjects = [];

  List<String> filteredSubjects = [];
  TextEditingController _textEditingController = TextEditingController();
  String selectedSubject = '';

  @override
  void initState() {
    super.initState();
    filteredSubjects = subjects;
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

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
                child: Row(
                  children: [
                    Column(
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
                          width: 250,
                          height: 200,
                          child: TextField(
                            maxLines: null,
                          ),
                        )
                      ],
                    ),
                    SizedBox(
                      width: 500,
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _textEditingController,
                                  onChanged: (value) {
                                    setState(() {
                                      filteredSubjects = subjects
                                          .where((subject) => subject
                                              .toLowerCase()
                                              .contains(value.toLowerCase()))
                                          .toList();
                                    });
                                  },
                                  decoration: InputDecoration(
                                    hintText: 'Enter a subject',
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.add),
                                onPressed: () {
                                  String newSubject =
                                      _textEditingController.text.trim();
                                  if (newSubject.isNotEmpty &&
                                      !subjects.contains(newSubject)) {
                                    setState(() {
                                      subjects.add(newSubject);
                                      filteredSubjects = subjects;
                                      _textEditingController.clear();
                                    });
                                  }
                                },
                              ),
                              ElevatedButton(
                                child: Text('Submit'),
                                onPressed: () {
                                  print(selectedSubject);
                                },
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                          if (filteredSubjects.isNotEmpty)
                            SizedBox(
                              height: 150,
                              child: SingleChildScrollView(
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: filteredSubjects.length,
                                  itemBuilder: (context, index) {
                                    return ListTile(
                                      title: Text(filteredSubjects[index]),
                                      onTap: () {
                                        setState(() {
                                          selectedSubject =
                                              filteredSubjects[index];
                                          _textEditingController.text =
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
