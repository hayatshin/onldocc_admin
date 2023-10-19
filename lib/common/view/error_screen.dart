import 'package:flutter/material.dart';
import 'package:onldocc_admin/constants/gaps.dart';
import 'package:onldocc_admin/constants/sizes.dart';

class ErrorScreen extends StatelessWidget {
  const ErrorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: Sizes.size40,
            color: Theme.of(context).primaryColor,
          ),
          Gaps.v40,
          const Text(
            "문제가 발생했습니다.\n인지케어팀에 문의해주세요.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: Sizes.size16,
            ),
          ),
          Gaps.v32,
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.mail_outline,
                size: Sizes.size20,
                color: Colors.grey.shade600,
              ),
              Gaps.h10,
              Text(
                "help@hayat.kr",
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w600,
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}
