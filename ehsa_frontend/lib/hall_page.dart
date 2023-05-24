import 'package:flutter/material.dart';

class HallPage extends StatelessWidget {
  const HallPage({super.key});

  @override
  Widget build(BuildContext context,) {
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