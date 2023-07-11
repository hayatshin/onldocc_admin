import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:onldocc_admin/features/event/view/event_screen.dart';
import 'package:onldocc_admin/features/mood/view/mood_screen.dart';
import 'package:onldocc_admin/features/ranking/view/ranking_diary_screen.dart';
import 'package:onldocc_admin/features/ranking/view/ranking_screen.dart';
import 'package:onldocc_admin/features/ranking/view/ranking_step_screen.dart';
import 'package:onldocc_admin/features/users/view/users_screen.dart';

class MenuNotifier extends ChangeNotifier {
  int _selectedMenu = 0;

  int get selectedMenu => _selectedMenu;

  void setSelectedMenu(int menu, BuildContext context) {
    _selectedMenu = menu;

    if (menu == 0) context.goNamed(UsersScreen.routeName);
    if (menu == 1) context.goNamed(RankingScreen.routeName);
    if (menu == 2) context.goNamed(RankingStepScreen.routeName);
    if (menu == 3) context.goNamed(RankingDiaryScreen.routeName);
    if (menu == 4) context.goNamed(MoodScreen.routeName);
    if (menu == 5) context.goNamed(EventScreen.routeName);

    notifyListeners();
  }
}

final menuNotifier = MenuNotifier();
