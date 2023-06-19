import 'dart:io';
import 'package:flutter/material.dart';
import 'generate_page.dart';
import 'hall_page.dart';
import 'students_page.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:window_manager/window_manager.dart'; 

void main() async { 
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();
  if (Platform.isWindows) {
    WindowManager.instance.setMinimumSize(const Size(950, 700));
    
  }
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
  bool _showCreditsOverlay = true;

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

  void _closeCreditsOverlay() {
    setState(() {
      _showCreditsOverlay = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final Uri url1 = Uri.parse("https://github.com/Govind-S-B");
    final Uri url2 = Uri.parse("https://github.com/officiallyaninja");
    final Uri url3 = Uri.parse("https://github.com/sibycr18");
    final Uri url4 = Uri.parse("https://github.com/jydv402");
    final Uri url5 = Uri.parse("https://github.com/Karthi-R-K");
    final Uri url6 = Uri.parse("https://github.com/aminafayaz");
    final Uri url7 = Uri.parse("https://github.com/tsuAquila");
    final Uri url8 = Uri.parse("https://github.com/Ameer-Al-Hisham");

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
                      child: Center(
                        child: TextButton(
                          style: ButtonStyle(
                              fixedSize: MaterialStateProperty.all(
                                  const Size(600, 300))),
                          onPressed: () {
                            _showCreditsOverlay = true;
                            setState(() {});
                            _scaffoldKey.currentState?.closeDrawer();
                          },
                          child: const Text(
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
        body: Stack(
          children: [
            _buildOffstageNavigator(Page.halls),
            _buildOffstageNavigator(Page.students),
            _buildOffstageNavigator(Page.generate),
            if (_showCreditsOverlay)
              GestureDetector(
                onTap: _closeCreditsOverlay,
                child: Container(
                  color: Colors.black.withOpacity(0.5),
                  child: Center(
                    child: Container(
                      height: MediaQuery.of(context).size.height * 0.4,
                      width: MediaQuery.of(context).size.width * 0.4,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(
                          top: 20,
                        ),
                        child: Column(
                          children: [
                            const SizedBox(
                              height: 10,
                            ),
                            const Text(
                              'EHSA',
                              style: TextStyle(
                                fontSize: 50,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Text(
                              "by protoRes",
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 50),
                            Wrap(
                              children: [
                                TextButton(
                                    onPressed: () {
                                      launchUrl(url1);
                                    },
                                    child: const Text("Govind S B")),
                                TextButton(
                                    onPressed: () {
                                      launchUrl(url2);
                                    },
                                    child: const Text("Arjun Pratap")),
                                TextButton(
                                    onPressed: () {
                                      launchUrl(url3);
                                    },
                                    child: const Text("Siby C.R")),
                                TextButton(
                                    onPressed: () {
                                      launchUrl(url4);
                                    },
                                    child: const Text("Jayadev B.S")),
                                TextButton(
                                    onPressed: () {
                                      launchUrl(url5);
                                    },
                                    child: const Text("Karthik Kumar")),
                                TextButton(
                                    onPressed: () {
                                      launchUrl(url6);
                                    },
                                    child: const Text("Amina Fayaz")),
                                TextButton(
                                    onPressed: () {
                                      launchUrl(url8);
                                    },
                                    child: const Text("Ameer Al Hisham")),
                                TextButton(
                                    onPressed: () {
                                      launchUrl(url7);
                                    },
                                    child: const Text("Aasish R R")),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
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
