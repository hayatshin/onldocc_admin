import 'package:flutter/material.dart';

import '../../../constants/gaps.dart';
import '../../../constants/sizes.dart';

class NoUserPage extends StatelessWidget {
  const NoUserPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.mood_bad,
                size: Sizes.size44,
                color: Colors.grey.shade800,
              ),
            ],
          ),
          Gaps.v40,
          SelectableText(
            "일치하는 회원이 없습니다.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: Sizes.size16,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade800,
            ),
          ),
        ],
      ),
    );
  }
}
