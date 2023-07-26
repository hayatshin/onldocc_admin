import 'package:flutter/material.dart';

class TvScreen extends StatefulWidget {
  static const routeURL = "/tv";
  static const routeName = "tv";

  const TvScreen({
    super.key,
  });

  @override
  State<TvScreen> createState() => _TvScreenState();
}

class _TvScreenState extends State<TvScreen> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Text("tv screen"),
    );
  }
}
