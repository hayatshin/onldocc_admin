import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:onldocc_admin/constants/gaps.dart';
import 'package:onldocc_admin/constants/sizes.dart';
import 'package:onldocc_admin/features/event/widgets/field-box/count_field_box.dart';
import 'package:onldocc_admin/palette.dart';

class UploadCountWidget extends StatefulWidget {
  final Function(int) updateDiaryCount;
  final Function(int) updateCommentCount;
  final Function(int) updateLikeCount;
  final Function(int) updateInvitationCount;
  final Function(int) updateQuizCount;

  const UploadCountWidget({
    super.key,
    required this.updateDiaryCount,
    required this.updateCommentCount,
    required this.updateLikeCount,
    required this.updateInvitationCount,
    required this.updateQuizCount,
  });

  @override
  State<UploadCountWidget> createState() => _UploadCountWidgetState();
}

class _UploadCountWidgetState extends State<UploadCountWidget> {
  final double fieldHeight = 45;

  final TextStyle _headerTextStyle = TextStyle(
    fontSize: Sizes.size12,
    fontWeight: FontWeight.w600,
    color: Palette().darkGray,
  );

  final TextStyle _headerInfoTextStyle = TextStyle(
    fontSize: Sizes.size11,
    fontWeight: FontWeight.w300,
    color: Palette().normalGray,
  );

  final TextStyle _contentTextStyle = TextStyle(
    fontSize: Sizes.size14,
    fontWeight: FontWeight.w500,
    color: Palette().darkGray,
  );

  final TextStyle _fieldHeaderTextStyle = TextStyle(
    fontSize: Sizes.size13,
    fontWeight: FontWeight.w700,
    color: Palette().normalGreen,
  );

  final TextStyle _fieldLimitTextStyle = TextStyle(
    fontSize: Sizes.size12,
    fontWeight: FontWeight.w600,
    color: Palette().normalGray,
  );
  final TextStyle _fieldLimitChangeTextStyle = const TextStyle(
    fontSize: Sizes.size12,
    fontWeight: FontWeight.w600,
    color: Color(0xFFFF2D78),
  );
  final TextStyle _fieldContentTextStyle = TextStyle(
    fontSize: Sizes.size12,
    fontWeight: FontWeight.w400,
    color: Palette().darkGray,
  );

  final _diaryField = ValueNotifier<bool>(false);
  final _quizField = ValueNotifier<bool>(false);
  final _commentField = ValueNotifier<bool>(false);
  final _likeField = ValueNotifier<bool>(false);
  final _invitationField = ValueNotifier<bool>(false);

  final _quizLimitField = ValueNotifier<bool>(false);
  final _commentLimitField = ValueNotifier<bool>(false);
  final _likeLimitField = ValueNotifier<bool>(false);
  final _invitationLimitField = ValueNotifier<bool>(false);

  final _quizLimitValue = ValueNotifier<int>(0);
  final _commentLimitValue = ValueNotifier<int>(0);
  final _likeLimitValue = ValueNotifier<int>(0);
  final _invitationLimitValue = ValueNotifier<int>(0);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "2. 점수 산출 방식을 설정해주세요.",
          style: _headerTextStyle,
          textAlign: TextAlign.start,
        ),
        Gaps.v32,
        CountFieldBox(
          diaryField: _diaryField,
          quizField: _quizField,
          commentField: _commentField,
          likeField: _likeField,
          invitationField: _invitationField,
          quizLimitField: _quizLimitField,
          commentLimitField: _commentLimitField,
          likeLimitField: _likeLimitField,
          invitationLimitField: _invitationLimitField,
        ),
      ],
    );
  }
}
