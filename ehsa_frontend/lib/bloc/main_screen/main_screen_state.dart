part of 'main_screen_cubit.dart';

@immutable
class MainScreenInitial {
  bool isOverlayOpen;
  bool isDrawerOpen;
  Pages pagesection;

  MainScreenInitial(
      {required this.isOverlayOpen,
      required this.isDrawerOpen,
      required this.pagesection});

  MainScreenInitial copyWith({
    bool? isOverlayOpen,
    bool? isDrawerOpen,
    Pages? pagesection,
  }) {
    return MainScreenInitial(
      isOverlayOpen: isOverlayOpen ?? this.isOverlayOpen,
      isDrawerOpen: isDrawerOpen ?? this.isDrawerOpen,
      pagesection: pagesection ?? this.pagesection,
    );
  }
}
