import 'package:flutter/material.dart';

import 'generate_page.dart';
import 'hall_page.dart';
import 'students_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  MyAppState createState() => MyAppState();
}

enum Page {
  halls,
  students,
  generate,
}

class MyAppState extends State<MyApp> {
  Page _selectedPage = Page.halls;

  final Map<Page, GlobalKey<NavigatorState>> _navigatorKeys = {
    Page.halls: GlobalKey<NavigatorState>(),
    Page.students: GlobalKey<NavigatorState>(),
    Page.generate: GlobalKey<NavigatorState>(),
  };

  void _selectPage(Page page) {
    setState(() {
      _selectedPage = page;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EHSA',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          selectedItemColor: Colors.green,
        ),
      ),
      home: Scaffold(
        body: Stack(
          children: [
            _buildOffstageNavigator(Page.halls),
            _buildOffstageNavigator(Page.students),
            _buildOffstageNavigator(Page.generate),
          ],
        ),
        bottomNavigationBar: Theme(
          data: ThemeData(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
          ),
          child: BottomNavigationBar(
          currentIndex: _selectedPage.index,
          onTap: (index) => _selectPage(Page.values[index]),
          
          items: [
            BottomNavigationBarItem(
              backgroundColor: Colors.white,
              icon: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: _selectedPage == Page.halls ? Colors.green : Colors.grey,
                  shape: BoxShape.circle,
                ),
              ),
              label: 'Halls',
            ),
            BottomNavigationBarItem(
              backgroundColor: Colors.white,
              icon: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: _selectedPage == Page.students ? Colors.green : Colors.grey,
                  shape: BoxShape.circle,
                ),
              ),
              label: 'Students',
            ),
            BottomNavigationBarItem(
              backgroundColor: Colors.white,
              icon: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: _selectedPage == Page.generate ? Colors.green : Colors.grey,
                  shape: BoxShape.circle,
                ),
              ),
              label: 'Generate',
            ),
          ],
        ),
      ),
    ));
  }

  Widget _buildOffstageNavigator(Page page) {
    return Offstage(
      offstage: _selectedPage != page,
      child: Navigator(
        key: _navigatorKeys[page],
        onGenerateRoute: (routeSettings) {
          return MaterialPageRoute(builder: (context) {
            switch (page) {
              case Page.halls:
                return const HallPage();
              case Page.students:
                return const StudentsPage();
              case Page.generate:
                return GeneratePage();
              default:
                return Container();
            }
          });
        },
      ),
    );
  }
}