import 'package:flutter/material.dart';
import 'package:onldocc_admin/common/view/search_csv.dart';
import 'package:onldocc_admin/common/view_a/default_screen.dart';
import 'package:onldocc_admin/common/view_models/menu_notifier.dart';

class HealthConsultScreen extends StatefulWidget {
  static const routeURL = "/health-consult";
  static const routeName = "healthConsult";
  const HealthConsultScreen({super.key});

  @override
  State<HealthConsultScreen> createState() => _HealthConsultScreenState();
}

class _HealthConsultScreenState extends State<HealthConsultScreen> {
  Future<void> _filterUserDataList(
      String? searchBy, String searchKeyword) async {}

  Future<void> _getUserModelList() async {}

  Future<void> _generateExcel() async {}

  @override
  Widget build(BuildContext context) {
    return DefaultScreen(
        menu: menuList[11],
        child: Column(
          children: [
            SearchCsv(
              filterUserList: _filterUserDataList,
              resetInitialList: _getUserModelList,
              generateCsv: _generateExcel,
            ),
          ],
        ));
  }
}
