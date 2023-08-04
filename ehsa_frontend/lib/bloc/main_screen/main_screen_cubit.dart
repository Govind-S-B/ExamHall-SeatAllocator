import 'package:bloc/bloc.dart';
import 'package:ehsa_frontend/enums/page_type.dart';
import 'package:flutter/material.dart';

part 'main_screen_state.dart';

class MainScreenCubit extends Cubit<MainScreenInitial> {
  MainScreenCubit()
      : super(MainScreenInitial(
            isOverlayOpen: true,
            isDrawerOpen: false,
            pagesection: Pages.HALLS));

  void showOverlay(bool show) {
    emit(state.copyWith(isOverlayOpen: show));
  }

  void openDrawer(bool open) {
    emit(state.copyWith(isDrawerOpen: open));
  }

  void setPageSection(Pages pagesection) {
    emit(state.copyWith(pagesection: pagesection));
  }
}
