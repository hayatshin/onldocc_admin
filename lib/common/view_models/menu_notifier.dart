import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:onldocc_admin/features/event/view/event_screen.dart';
import 'package:onldocc_admin/features/ca/view/ca_screen.dart';
import 'package:onldocc_admin/features/ranking/view/ranking_screen.dart';
import 'package:onldocc_admin/features/ranking/view/ranking_users_screen.dart';
import 'package:onldocc_admin/features/users/view/users_screen.dart';

class MenuNotifier extends ChangeNotifier {
  int _selectedMenu = 0;

  int get selectedMenu => _selectedMenu;

  void setSelectedMenu(int menu, BuildContext context) {
    _selectedMenu = menu;

    if (menu == 0) context.goNamed(UsersScreen.routeName);
    if (menu == 1) context.goNamed(RankingScreen.routeName);
    if (menu == 2) context.goNamed(RankingUsersScreen.stepRouteName);
    if (menu == 3) context.goNamed(RankingUsersScreen.diaryRouteName);
    if (menu == 4) context.goNamed(CaScreen.routeName);
    if (menu == 5) context.goNamed(EventScreen.routeName);

    notifyListeners();
  }
}

final menuNotifier = MenuNotifier();
