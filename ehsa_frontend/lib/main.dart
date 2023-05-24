import 'package:flutter/material.dart';

import 'generate_page.dart';
import 'hall_page.dart';
import 'students_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

enum Page {
  Halls,
  Students,
  Generate,
}

class _MyAppState extends State<MyApp> {
  Page _selectedPage = Page.Halls;

  final Map<Page, GlobalKey<NavigatorState>> _navigatorKeys = {
    Page.Halls: GlobalKey<NavigatorState>(),
    Page.Students: GlobalKey<NavigatorState>(),
    Page.Generate: GlobalKey<NavigatorState>(),
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
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          selectedItemColor: Colors.green,
        ),
      ),
      home: Scaffold(
        body: Stack(
          children: [
            _buildOffstageNavigator(Page.Halls),
            _buildOffstageNavigator(Page.Students),
            _buildOffstageNavigator(Page.Generate),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedPage.index,
          onTap: (index) => _selectPage(Page.values[index]),
          items: [
            BottomNavigationBarItem(
              backgroundColor: Colors.white,
              icon: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: _selectedPage == Page.Halls ? Colors.green : Colors.grey,
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
                  color: _selectedPage == Page.Students ? Colors.green : Colors.grey,
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
                  color: _selectedPage == Page.Generate ? Colors.green : Colors.grey,
                  shape: BoxShape.circle,
                ),
              ),
              label: 'Generate',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOffstageNavigator(Page page) {
    return Offstage(
      offstage: _selectedPage != page,
      child: Navigator(
        key: _navigatorKeys[page],
        onGenerateRoute: (routeSettings) {
          return MaterialPageRoute(builder: (context) {
            switch (page) {
              case Page.Halls:
                return HallPage();
              case Page.Students:
                return StudentsPage();
              case Page.Generate:
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