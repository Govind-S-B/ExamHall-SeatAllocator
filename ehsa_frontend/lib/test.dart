import 'package:flutter/material.dart';

class MyWidget extends StatefulWidget {
  @override
  _MyWidgetState createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
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
    return Column(
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
                String newSubject = _textEditingController.text.trim();
                if (newSubject.isNotEmpty && !subjects.contains(newSubject)) {
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
                        selectedSubject = filteredSubjects[index];
                        _textEditingController.text = selectedSubject;
                        filteredSubjects = [];
                      });
                    },
                  );
                },
              ),
            ),
          ),
      ],
    );
  }
}
