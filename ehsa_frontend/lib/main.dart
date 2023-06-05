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
  String _getPageTitle(Page page) {
    switch (page) {
      case Page.halls:
        return 'Halls Page';
      case Page.students:
        return 'Students Page';
      case Page.generate:
        return 'Generate Page';
      default:
        return '';
    }
  }

  Page _selectedPage = Page.halls;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

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
        listTileTheme: ListTileThemeData(
          selectedTileColor: Colors.blue.withAlpha(50),
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(16))),
        ),
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          elevation: 0,
          centerTitle: true,
          title: Text(_getPageTitle(_selectedPage)),
        ),
        drawer: Padding(
          padding: const EdgeInsets.only(
            bottom: 14,
            top: 14,
          ),
          child: Drawer(
            elevation: 0,
            width: 275,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                  bottomRight: Radius.circular(16),
                  topRight: Radius.circular(16)),
            ),
            child: ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                    top: 8,
                    right: 8,
                    left: 8,
                  ),
                  child: SizedBox(
                    height: 145,
                    child: DrawerHeader(
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(16)),
                        color: Colors.blue,
                      ),
                      child: GestureDetector(
                        onTap: () {
                          _scaffoldKey.currentState?.closeDrawer();
                        },
                        child: const Center(
                          child: Text(
                            'EHSA',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 40,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    left: 8,
                    right: 8,
                    top: 1,
                    bottom: 4,
                  ),
                  child: ListTile(
                    leading: _selectedPage == Page.halls
                        ? const Icon(Icons.add_home_rounded)
                        : const Icon(Icons.add_home_outlined),
                    title: const Text('Halls'),
                    selected: _selectedPage == Page.halls,
                    onTap: () {
                      _selectPage(Page.halls);
                      _scaffoldKey.currentState?.closeDrawer();
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    left: 8,
                    right: 8,
                    top: 4,
                    bottom: 4,
                  ),
                  child: ListTile(
                    leading: _selectedPage == Page.students
                        ? const Icon(Icons.person_add_alt_1_rounded)
                        : const Icon(Icons.person_add_alt_1_outlined),
                    title: const Text('Students'),
                    selected: _selectedPage == Page.students,
                    onTap: () {
                      _selectPage(Page.students);
                      _scaffoldKey.currentState?.closeDrawer();
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    left: 8,
                    right: 8,
                    top: 4,
                    bottom: 4,
                  ),
                  child: ListTile(
                    leading: _selectedPage == Page.generate
                        ? const Icon(Icons.create_rounded)
                        : const Icon(Icons.create_outlined),
                    title: const Text('Generate'),
                    selected: _selectedPage == Page.generate,
                    onTap: () {
                      _selectPage(Page.generate);
                      _scaffoldKey.currentState?.closeDrawer();
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        body: SizedBox(
          height: MediaQuery.of(context).size.height - kToolbarHeight - 24,
          width: MediaQuery.of(context).size.width,
          child: Stack(
            children: [
              _buildOffstageNavigator(Page.halls),
              _buildOffstageNavigator(Page.students),
              _buildOffstageNavigator(Page.generate),
            ],
          ),
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
