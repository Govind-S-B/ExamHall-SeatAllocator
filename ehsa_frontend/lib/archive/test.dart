import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

enum Page {
  home,
  settings,
  profile,
}

class _MyAppState extends State<MyApp> {
  Page _selectedPage = Page.home;

  final Map<Page, GlobalKey<NavigatorState>> _navigatorKeys = {
    Page.home: GlobalKey<NavigatorState>(),
    Page.settings: GlobalKey<NavigatorState>(),
    Page.profile: GlobalKey<NavigatorState>(),
  };

  void _selectPage(Page page) {
    setState(() {
      _selectedPage = page;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Bottom Navigation Bar Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          selectedItemColor: Colors.green,
        ),
      ),
      home: Scaffold(
        body: Stack(
          children: [
            _buildOffstageNavigator(Page.home),
            _buildOffstageNavigator(Page.settings),
            _buildOffstageNavigator(Page.profile),
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
                  color: _selectedPage == Page.home ? Colors.green : Colors.grey,
                  shape: BoxShape.circle,
                ),
              ),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              backgroundColor: Colors.white,
              icon: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: _selectedPage == Page.settings ? Colors.green : Colors.grey,
                  shape: BoxShape.circle,
                ),
              ),
              label: 'Settings',
            ),
            BottomNavigationBarItem(
              backgroundColor: Colors.white,
              icon: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: _selectedPage == Page.profile ? Colors.green : Colors.grey,
                  shape: BoxShape.circle,
                ),
              ),
              label: 'Profile',
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
              case Page.home:
                return HomePage();
              case Page.settings:
                return SettingsPage();
              case Page.profile:
                return ProfilePage();
              default:
                return Container();
            }
          });
        },
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
      ),
      body: Center(
        child: Text('Home Page'),
      ),
    );
  }
}

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: Center(
        child: Text('Settings Page'),
      ),
    );
  }
}

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
      ),
      body: Center(
        child: Text('Profile Page'),
      ),
    );
  }
}