import 'package:flutter/material.dart';

class StudentsPage extends StatefulWidget {
  const StudentsPage({super.key});

  @override
  State<StudentsPage> createState() => _StudentsPageState();
}

class _StudentsPageState extends State<StudentsPage> {
  final List<String> subjects = [];

  List<String> filteredSubjects = [];
  TextEditingController _subjectTextEditingController = TextEditingController();
  String selectedSubject = '';

  TextEditingController _classTextEditingController = TextEditingController();
  TextEditingController _rollsTextEditingController = TextEditingController();



  @override
  void initState() {
    super.initState();
    filteredSubjects = subjects;
  }

  @override
  void dispose() {
    _subjectTextEditingController.dispose();
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
                child: Row(
                  children: [
                    SizedBox(
                      width: 300,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextField(
                            controller: _classTextEditingController,
                            decoration: InputDecoration(
                                    hintText: 'Enter Class',
                                  ),
                          ),
                          TextField(
                            controller: _rollsTextEditingController,
                            decoration: InputDecoration(
                                    hintText: 'Enter Roll List',
                                  ),
                            maxLines: null,
                          )
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 500,
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _subjectTextEditingController,
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
                                    hintText: 'Enter Subject',
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.add),
                                onPressed: () {
                                  String newSubject =
                                      _subjectTextEditingController.text.trim();
                                  if (newSubject.isNotEmpty &&
                                      !subjects.contains(newSubject)) {
                                    setState(() {
                                      subjects.add(newSubject);
                                      filteredSubjects = subjects;
                                      _subjectTextEditingController.clear();
                                    });
                                  }
                                },
                              ),
                              ElevatedButton(
                                child: Text('Submit'),
                                onPressed: () {

                                  var student_class =  _classTextEditingController.text;
                                  var roll_list = _rollsTextEditingController.text.split(",");

                                  for (var roll in roll_list) {
                                    if(roll.contains("-")){
                                      var roll_num_range = roll.split("-");

                                      for (var i = int.parse(roll_num_range[0]); i <= int.parse(roll_num_range[1]); i++) {
                                        // to write into db
                                        print(  student_class + "-" + i.toString()); // id
                                        print( selectedSubject ); // subject
                                      }

                                    }
                                    else{
                                      // to write into db
                                      print(  student_class + "-" + roll); // id
                                      print( selectedSubject ); // subject
                                    }
                                  }

                                  
                                  _classTextEditingController.clear();
                                  _rollsTextEditingController.clear();
                                  _subjectTextEditingController.clear();
                                  filteredSubjects = subjects;
                                  setState(() {});
                                },
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
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
                                          _subjectTextEditingController.text =
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
