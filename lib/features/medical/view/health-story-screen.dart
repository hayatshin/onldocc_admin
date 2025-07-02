import 'package:flutter/material.dart';
import 'package:onldocc_admin/common/view_a/default_screen.dart';
import 'package:onldocc_admin/common/view_models/menu_notifier.dart';

class HealthStoryScreen extends StatefulWidget {
  static const routeURL = "/health-story";
  static const routeName = "healthstory";
  const HealthStoryScreen({super.key});

  @override
  State<HealthStoryScreen> createState() => _HealthStoryScreenState();
}

class _HealthStoryScreenState extends State<HealthStoryScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultScreen(
        menu: menuList[12],
        child: const Column(
          children: [],
        ));
  }
}
