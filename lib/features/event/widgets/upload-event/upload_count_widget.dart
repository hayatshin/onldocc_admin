import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:onldocc_admin/constants/gaps.dart';
import 'package:onldocc_admin/constants/sizes.dart';
import 'package:onldocc_admin/features/event/models/event_model.dart';
import 'package:onldocc_admin/features/event/widgets/field-box/count_field_box.dart';
import 'package:onldocc_admin/palette.dart';

class UploadCountWidget extends StatefulWidget {
  final Function(int) updateDiaryCount;
  final Function(int) updateCommentCount;
  final Function(int) updateLikeCount;
  final Function(int) updateInvitationCount;
  final Function(int) updateQuizCount;
  final Function(int) updateMaxCommentCount;
  final Function(int) updateMaxLikeCount;
  final Function(int) updateMaxInvitationCount;
  final bool edit;
  final EventModel? eventModel;
  const UploadCountWidget({
    super.key,
    required this.updateDiaryCount,
    required this.updateCommentCount,
    required this.updateLikeCount,
    required this.updateInvitationCount,
    required this.updateQuizCount,
    required this.updateMaxCommentCount,
    required this.updateMaxLikeCount,
    required this.updateMaxInvitationCount,
    required this.edit,
    this.eventModel,
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
  final _diaryField = ValueNotifier<bool>(false);
  final _quizField = ValueNotifier<bool>(false);
  final _commentField = ValueNotifier<bool>(false);
  final _likeField = ValueNotifier<bool>(false);
  final _invitationField = ValueNotifier<bool>(false);

  final _commentLimitField = ValueNotifier<bool>(false);
  final _likeLimitField = ValueNotifier<bool>(false);
  final _invitationLimitField = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    if (widget.edit && widget.eventModel != null) {
      _diaryField.value = widget.eventModel!.diaryCount != 0;
      _quizField.value = widget.eventModel!.quizCount != 0;
      _commentField.value = widget.eventModel!.commentCount != 0;
      _likeField.value = widget.eventModel!.likeCount != 0;
      _invitationField.value = widget.eventModel!.invitationCount != 0;
      _commentLimitField.value = widget.eventModel!.maxCommentCount != 0;
      _likeLimitField.value = widget.eventModel!.maxLikeCount != 0;
      _invitationLimitField.value = widget.eventModel!.maxInvitationCount != 0;
    }
  }

  @override
  void dispose() {
    _diaryField.dispose();
    _quizField.dispose();
    _commentField.dispose();
    _likeField.dispose();
    _invitationField.dispose();

    _commentLimitField.dispose();
    _likeLimitField.dispose();
    _invitationLimitField.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
          commentLimitField: _commentLimitField,
          likeLimitField: _likeLimitField,
          invitationLimitField: _invitationLimitField,
          updateDiaryCount: widget.updateDiaryCount,
          updateCommentCount: widget.updateCommentCount,
          updateLikeCount: widget.updateLikeCount,
          updateInvitationCount: widget.updateInvitationCount,
          updateQuizCount: widget.updateQuizCount,
          updateMaxCommentCount: widget.updateMaxCommentCount,
          updateMaxLikeCount: widget.updateMaxLikeCount,
          updateMaxInvitationCount: widget.updateMaxInvitationCount,
          edit: widget.edit,
          eventModel: widget.eventModel,
        ),
      ],
    );
  }
}
