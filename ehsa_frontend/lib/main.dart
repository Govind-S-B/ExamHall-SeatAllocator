import 'package:flutter/material.dart';
import 'generate_page.dart';
import 'hall_page.dart';
import 'students_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

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
        navigationRailTheme: const NavigationRailThemeData(
          minWidth: 56,
          labelType: NavigationRailLabelType.selected,
          groupAlignment: 0,
          unselectedLabelTextStyle: TextStyle(color: Colors.transparent),
          selectedIconTheme: IconThemeData(color: Colors.green),
          selectedLabelTextStyle:
              TextStyle(color: Colors.green, fontSize: 11.5),
        ),
      ),
      home: Scaffold(
        body: Row(
          children: [
            NavigationRail(
              minWidth: 56,
              selectedIndex: _selectedPage.index,
              onDestinationSelected: (int index) {
                setState(() {
                  _selectedPage = Page.values[index];
                });
              },
              labelType: NavigationRailLabelType.all,
              destinations: const [
                NavigationRailDestination(
                  padding: EdgeInsets.only(bottom: 16, top: 16),
                  icon: Icon(Icons.home),
                  label: Text('Halls'),
                ),
                NavigationRailDestination(
                  padding: EdgeInsets.only(bottom: 16, top: 16),
                  icon: Icon(Icons.person),
                  label: Text('Students'),
                ),
                NavigationRailDestination(
                  padding: EdgeInsets.only(bottom: 16, top: 16),
                  icon: Icon(Icons.create),
                  label: Text('Generate'),
                ),
              ],
            ),
            Expanded(
              child: Stack(
                children: [
                  _buildOffstageNavigator(Page.halls),
                  _buildOffstageNavigator(Page.students),
                  _buildOffstageNavigator(Page.generate),
                ],
              ),
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
              case Page.halls:
                return const HallPage();
              case Page.students:
                return const StudentsPage();
              case Page.generate:
                return const GeneratePage();
              default:
                return Container();
            }
          });
        },
      ),
    );
  }
}
