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
    _timer = Timer.periodic(const Duration(milliseconds: 1000), (_) {
      final minLength = (_random.nextInt(1) + 3);
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
            padding: const EdgeInsets.symmetric(
              horizontal: 0,
            ),
            lines: _minLength,
            spacing: 10,
            lineStyle: SkeletonLineStyle(
              randomLength: true,
              height: 18,
              borderRadius: BorderRadius.circular(5),
              minLength: MediaQuery.of(context).size.width / _minLength,
              maxLength: MediaQuery.of(context).size.width,
            ),
          ),
        ),
      ],
    );
  }
}
