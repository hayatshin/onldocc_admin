import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_skeleton_ui/flutter_skeleton_ui.dart';

class SkeletonLoadingScreen extends StatefulWidget {
  const SkeletonLoadingScreen({super.key});

  @override
  State<SkeletonLoadingScreen> createState() => _SkeletonLoadingScreenState();
}

class _SkeletonLoadingScreenState extends State<SkeletonLoadingScreen> {
  int _minLength = 3;
  late Timer _timer;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(milliseconds: 500), (_) {
      final minLength = (_random.nextInt(5) + 3);
      setState(() {
        _minLength = minLength;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SkeletonParagraph(
          style: SkeletonParagraphStyle(
            lines: _minLength,
            spacing: 15,
            lineStyle: SkeletonLineStyle(
              randomLength: true,
              height: 20,
              borderRadius: BorderRadius.circular(4),
              minLength: MediaQuery.of(context).size.width / _minLength,
              maxLength: MediaQuery.of(context).size.width,
            ),
          ),
        ),
      ],
    );
  }
}
