import 'dart:io';
import 'package:ehsa_frontend/bloc/main_screen/main_screen_cubit.dart';
import 'package:ehsa_frontend/widgets/stateless/contributor_grid.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'generate_page.dart';
import 'hall_page.dart';
import 'students_page.dart';

import 'package:window_manager/window_manager.dart';
import "./enums/page_type.dart";

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();
  if (Platform.isWindows) {
    WindowManager.instance.setMinimumSize(const Size(950, 700));
  }
  runApp(BlocProvider<MainScreenCubit>.value(
    value: MainScreenCubit(),
    child: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);

  Pages _selectedPage = Pages.HALLS;
  bool _showCreditsOverlay = true;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // final Map<Pages, GlobalKey<NavigatorState>> _navigatorKeys = {
  //   Pages.HALLS: GlobalKey<NavigatorState>(),
  //   Pages.STUDENTS: GlobalKey<NavigatorState>(),
  //   Pages.GENERATE: GlobalKey<NavigatorState>(),
  // };

  String getPageSectionTitle(Pages pagesection) {
    switch (pagesection) {
      case Pages.HALLS:
        return 'Halls Pages';
      case Pages.STUDENTS:
        return 'Students Pages';
      case Pages.GENERATE:
        return 'Generate Pages';
      default:
        return '';
    }
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
        onDrawerChanged: (isOpened) =>
            context.read<MainScreenCubit>().openDrawer(isOpened),
        onEndDrawerChanged: (isOpened) =>
            context.read<MainScreenCubit>().openDrawer(false),
        key: _scaffoldKey,
        appBar: AppBar(
            elevation: 0,
            centerTitle: true,
            title: BlocBuilder<MainScreenCubit, MainScreenInitial>(
              builder: (context, state) =>
                  Text(getPageSectionTitle(state.pagesection)),
            )),
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
                            context.read<MainScreenCubit>().showOverlay(true);

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
                drawerItem(
                    text: "Halls",
                    section: Pages.HALLS,
                    icon: Icon(Icons.add_home_rounded),
                    activeIcon: const Icon(Icons.add_home_outlined)),
                drawerItem(
                    text: "Students",
                    section: Pages.STUDENTS,
                    icon: Icon(Icons.person_add_alt_1_rounded),
                    activeIcon: const Icon(Icons.person_add_alt_1_outlined)),
                drawerItem(
                    text: "Generate",
                    section: Pages.GENERATE,
                    icon: Icon(Icons.create_rounded),
                    activeIcon: const Icon(Icons.create_outlined)),
              ],
            ),
          ),
        ),
        body: Stack(
          children: [
            //DrawerTabs
            BlocBuilder<MainScreenCubit, MainScreenInitial>(
                builder: (context, state) {
              return IndexedStack(
                index: state.pagesection.index,
                children: const [HallPage(), StudentsPage(), GeneratePage()],
              );
            }),

            //contributors grid
            BlocBuilder<MainScreenCubit, MainScreenInitial>(
               builder: (context, state) {
                if (state.isOverlayOpen) {
                  return GestureDetector(
                    onTap: () {
                      context.read<MainScreenCubit>().showOverlay(false);
                    },
                    child: Container(
                      color: Colors.black.withOpacity(0.5),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [ContributorGrid()],
                        ),
                      ),
                    ),
                  );
                } else {
                  return Text("");
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget drawerItem(
      {required String text,
      required Pages section,
      required Icon icon,
      required Icon activeIcon}) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 8,
        right: 8,
        top: 1,
        bottom: 4,
      ),
      child: BlocBuilder<MainScreenCubit, MainScreenInitial>(
        builder: (context, state) {
          return ListTile(
            leading: state.pagesection == section ? icon : activeIcon,
            title: Text(text),
            selected: state.pagesection == section,
            onTap: () {
              context.read<MainScreenCubit>().setPageSection(section);

              context.read<MainScreenCubit>().openDrawer(false);
              // _selectPage(Pages.HALLS);
              _scaffoldKey.currentState?.closeDrawer();
            },
          );
        },
      ),
    );
  }
}
