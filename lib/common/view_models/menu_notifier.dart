import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:onldocc_admin/features/ca/view/alzheimer_test_screen.dart';
import 'package:onldocc_admin/features/ca/view/depression_test_screen.dart';
import 'package:onldocc_admin/features/ca/view/quiz_screen.dart';
import 'package:onldocc_admin/features/care/view/care_screen.dart';
import 'package:onldocc_admin/features/event/view/event_screen.dart';
import 'package:onldocc_admin/features/invitation/%08view/invitation_screen.dart';
import 'package:onldocc_admin/features/notice/views/notice_screen.dart';
import 'package:onldocc_admin/features/ranking/view/ranking_screen.dart';
import 'package:onldocc_admin/features/ranking/view/ranking_users_screen.dart';
import 'package:onldocc_admin/features/tv/view/tv_screen.dart';
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
    if (menu == 4) context.goNamed(QuizScreen.routeName);
    if (menu == 5) context.goNamed(AlzheimerTestScreen.routeName);
    if (menu == 6) context.goNamed(DepressionTestScreen.routeName);
    if (menu == 7) context.goNamed(InvitationScreen.routeName);
    if (menu == 8) context.goNamed(NoticeScreen.routeName);
    if (menu == 9) context.goNamed(EventScreen.routeName);
    if (menu == 10) context.goNamed(CareScreen.routeName);
    if (menu == 11) context.goNamed(TvScreen.routeName);
    if (menu == 12) context.goNamed(TvScreen.routeName);

    notifyListeners();
  }
}

final menuNotifier = MenuNotifier();
