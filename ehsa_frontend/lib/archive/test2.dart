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

  bool _isBottomNavVisible = false;

  void _toggleBottomNavVisibility() {
    setState(() {
      _isBottomNavVisible = !_isBottomNavVisible;
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
        bottomNavigationBar: _isBottomNavVisible
            ? BottomNavigationBar(
                currentIndex: _selectedPage.index,
                onTap: (index) => _selectPage(Page.values[index]),
                items: [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.home),
                    label: 'Home',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.settings),
                    label: 'Settings',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.person),
                    label: 'Profile',
                  ),
                ],
              )
            : null,
        floatingActionButton: FloatingActionButton(
          onPressed: _toggleBottomNavVisibility,
          child: Icon(Icons.menu),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.startTop,

      ),
    );
  }

  Widget _buildBottomAppBar() {
    return BottomAppBar(
      shape: CircularNotchedRectangle(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
            onPressed: () => _selectPage(Page.home),
            icon: Icon(Icons.home),
          ),
          IconButton(
            onPressed: () => _selectPage(Page.settings),
            icon: Icon(Icons.settings),
          ),
          IconButton(
            onPressed: () => _selectPage(Page.profile),
            icon: Icon(Icons.person),
          ),
        ],
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