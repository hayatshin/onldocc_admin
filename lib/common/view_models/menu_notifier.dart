import 'package:flutter/material.dart';
import 'package:onldocc_admin/features/dashboard/view/dashboard_screen.dart';
import 'package:onldocc_admin/features/ranking/view/ranking_screen.dart';
import 'package:onldocc_admin/features/users/view/users_screen.dart';

class MenuNotifier extends ChangeNotifier {
  int _selectedMenu = 0;

  int get selectedMenu => _selectedMenu;

  void setSelectedMenu(int menu, BuildContext context) {
    _selectedMenu = menu;

    notifyListeners();
  }
}

final menuNotifier = MenuNotifier();

class Menu {
  final int index;
  final String name;
  final String routeName;
  final Widget child;
  final bool backButton;
  final Color? colorButton;

  Menu({
    required this.index,
    required this.name,
    required this.routeName,
    required this.child,
    required this.backButton,
    required this.colorButton,
  });
}

final menuList = [
  Menu(
    index: 0,
    name: "대시보드",
    routeName: DashboardScreen.routeName,
    child: const DashboardScreen(),
    backButton: false,
    colorButton: null,
  ),
  Menu(
    index: 1,
    name: "회원 관리",
    routeName: UsersScreen.routeName,
    child: const UsersScreen(),
    backButton: false,
    colorButton: null,
  ),
  Menu(
    index: 2,
    name: "회원별 데이터",
    routeName: UsersScreen.routeName,
    child: const UsersScreen(),
    backButton: false,
    colorButton: null,
  ),
  Menu(
    index: 3,
    name: "점수 관리",
    routeName: RankingScreen.routeName,
    child: const RankingScreen(),
    backButton: false,
    colorButton: null,
  ),
  Menu(
    index: 4,
    name: "공지 관리",
    routeName: UsersScreen.routeName,
    child: const UsersScreen(),
    backButton: false,
    colorButton: null,
  ),
  Menu(
    index: 5,
    name: "행사 관리",
    routeName: UsersScreen.routeName,
    child: const UsersScreen(),
    backButton: false,
    colorButton: null,
  ),
  Menu(
    index: 6,
    name: "온라인 치매 검사",
    routeName: UsersScreen.routeName,
    child: const UsersScreen(),
    backButton: false,
    colorButton: const Color(0xff696EFF),
  ),
  Menu(
    index: 7,
    name: "노인 우울척도 검사",
    routeName: UsersScreen.routeName,
    child: const UsersScreen(),
    backButton: false,
    colorButton: const Color(0xffF8ACFF),
  ),
  Menu(
    index: 8,
    name: "영상 관리",
    routeName: UsersScreen.routeName,
    child: const UsersScreen(),
    backButton: false,
    colorButton: const Color(0xffFFBA49),
  ),
  Menu(
    index: 9,
    name: "보호자 지정",
    routeName: UsersScreen.routeName,
    child: const UsersScreen(),
    backButton: false,
    colorButton: const Color(0xff20A39E),
  ),
  Menu(
    index: 10,
    name: "화풀기",
    routeName: UsersScreen.routeName,
    child: const UsersScreen(),
    backButton: false,
    colorButton: const Color(0xffEF5B5B),
  ),
  Menu(
    index: 11,
    name: "친구 초대 관리",
    routeName: UsersScreen.routeName,
    child: const UsersScreen(),
    backButton: false,
    colorButton: null,
  ),
];
