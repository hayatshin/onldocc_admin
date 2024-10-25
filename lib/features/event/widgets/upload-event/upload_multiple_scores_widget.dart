import 'package:flutter/material.dart';
import 'package:onldocc_admin/constants/gaps.dart';
import 'package:onldocc_admin/features/event/models/event_model.dart';
import 'package:onldocc_admin/features/event/view/event_screen.dart';
import 'package:onldocc_admin/features/event/widgets/field-box/point_field_box.dart';

class UploadMultipleScoresWidget extends StatefulWidget {
  // final Function(int) updateGoalScore;
  final Function(int) updateDiaryPoint;
  final Function(int) updateCommentPoint;
  final Function(int) updateLikePoint;
  final Function(int) updateStepPoint;
  final Function(int) updateInvitationPoint;
  final Function(int) updateQuizPoint;
  final Function(int) updateMaxStepPoint;
  final Function(int) updateMaxCommentPoint;
  final Function(int) updateMaxLikePoint;
  final Function(int) updateMaxInvitationPoint;
  final Function(String) updateInvitationType;
  final bool edit;
  final EventModel? eventModel;

  const UploadMultipleScoresWidget({
    super.key,
    // required this.updateGoalScore,
    required this.updateDiaryPoint,
    required this.updateCommentPoint,
    required this.updateLikePoint,
    required this.updateStepPoint,
    required this.updateInvitationPoint,
    required this.updateQuizPoint,
    required this.updateMaxStepPoint,
    required this.updateMaxCommentPoint,
    required this.updateMaxLikePoint,
    required this.updateMaxInvitationPoint,
    required this.updateInvitationType,
    required this.edit,
    this.eventModel,
  });

  @override
  State<UploadMultipleScoresWidget> createState() =>
      _UploadMultipleScoresWidgetState();
}

class _UploadMultipleScoresWidgetState
    extends State<UploadMultipleScoresWidget> {
  final _diaryField = ValueNotifier<bool>(false);
  final _quizField = ValueNotifier<bool>(false);
  final _commentField = ValueNotifier<bool>(false);
  final _likeField = ValueNotifier<bool>(false);
  final _invitationField = ValueNotifier<bool>(false);
  final _stepField = ValueNotifier<bool>(false);

  final _quizLimitField = ValueNotifier<bool>(false);
  final _commentLimitField = ValueNotifier<bool>(false);
  final _likeLimitField = ValueNotifier<bool>(false);
  final _invitationLimitField = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();

    if (widget.edit && widget.eventModel != null) {
      _diaryField.value = widget.eventModel!.diaryPoint != 0;
      _quizField.value = widget.eventModel!.quizPoint != 0;
      _commentField.value = widget.eventModel!.commentPoint != 0;
      _likeField.value = widget.eventModel!.likePoint != 0;
      _stepField.value = widget.eventModel!.stepPoint != 0;
      _invitationField.value = widget.eventModel!.invitationPoint != 0;
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
    _stepField.dispose();

    _quizLimitField.dispose();
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
        // Column(
        //   children: [
        //     Row(
        //       mainAxisAlignment: MainAxisAlignment.start,
        //       crossAxisAlignment: CrossAxisAlignment.start,
        //       children: [
        //         Expanded(
        //           flex: 1,
        //           child: Column(
        //             crossAxisAlignment: CrossAxisAlignment.start,
        //             children: [
        //               Text(
        //                 "2. 최소 가이드 점수를 설정해주세요.",
        //                 style: headerTextStyle,
        //                 textAlign: TextAlign.start,
        //               ),
        //               Gaps.v16,
        //               Text(
        //                 "사용자가 대략의 점수 달성을 해야하는지 가이드를 주기 위한 점수입니다.\n설정을 안 하실 경우 ‘0’을 기입해주세요.",
        //                 style: headerInfoTextStyle,
        //                 textAlign: TextAlign.start,
        //                 overflow: TextOverflow.visible,
        //               ),
        //             ],
        //           ),
        //         ),
        //         Expanded(
        //           flex: 1,
        //           child: Row(
        //             mainAxisAlignment: MainAxisAlignment.start,
        //             crossAxisAlignment: CrossAxisAlignment.end,
        //             children: [
        //               SizedBox(
        //                 width: 100,
        //                 height: 40,
        //                 child: TextFormField(
        //                   // expands: true,
        //                   maxLines: 1,
        //                   // minLines: null,
        //                   // controller: _descriptionControllder,
        //                   textAlignVertical: TextAlignVertical.top,
        //                   style: contentTextStyle,
        //                   decoration: InputDecoration(
        //                     isDense: true,
        //                     filled: true,
        //                     fillColor: Colors.white.withOpacity(0.3),
        //                     border: OutlineInputBorder(
        //                       borderRadius: BorderRadius.circular(
        //                         Sizes.size20,
        //                       ),
        //                     ),
        //                     errorStyle: TextStyle(
        //                       color: Theme.of(context).primaryColor,
        //                     ),
        //                     errorBorder: OutlineInputBorder(
        //                       borderRadius: BorderRadius.circular(
        //                         Sizes.size20,
        //                       ),
        //                       borderSide: BorderSide(
        //                         width: 1.5,
        //                         color: Theme.of(context).primaryColor,
        //                       ),
        //                     ),
        //                     enabledBorder: OutlineInputBorder(
        //                       borderRadius: BorderRadius.circular(
        //                         Sizes.size20,
        //                       ),
        //                       borderSide: BorderSide(
        //                         width: 1.5,
        //                         color: Palette().darkBlue.withOpacity(0.7),
        //                       ),
        //                     ),
        //                     focusedBorder: OutlineInputBorder(
        //                       borderRadius: BorderRadius.circular(
        //                         Sizes.size20,
        //                       ),
        //                       borderSide: BorderSide(
        //                         width: 1.5,
        //                         color: Palette().darkBlue.withOpacity(0.7),
        //                       ),
        //                     ),
        //                     contentPadding: const EdgeInsets.symmetric(
        //                       horizontal: Sizes.size20,
        //                       vertical: Sizes.size20,
        //                     ),
        //                   ),
        //                 ),
        //               ),
        //               Gaps.h10,
        //               Text(
        //                 "점",
        //                 style: contentTextStyle,
        //               ),
        //             ],
        //           ),
        //         ),
        //       ],
        //     ),
        //     Gaps.v52,
        //   ],
        // ),
        Text(
          "2. 점수 산출 방식을 설정해주세요.",
          style: headerTextStyle,
          textAlign: TextAlign.start,
        ),
        Gaps.v16,
        Text(
          "고득점 점수 행사의 경우 횟수 제한이 없을 시 무의미한 활동이 많아질 수 있어 횟수 제한 설정을 권장드립니다.",
          style: headerInfoTextStyle,
          textAlign: TextAlign.start,
          overflow: TextOverflow.visible,
        ),
        Gaps.v32,
        PointFieldBox(
          diaryField: _diaryField,
          quizField: _quizField,
          commentField: _commentField,
          likeField: _likeField,
          invitationField: _invitationField,
          stepField: _stepField,
          commentLimitField: _commentLimitField,
          likeLimitField: _likeLimitField,
          invitationLimitField: _invitationLimitField,
          updateDiaryPoint: widget.updateDiaryPoint,
          updateCommentPoint: widget.updateCommentPoint,
          updateLikePoint: widget.updateLikePoint,
          updateStepPoint: widget.updateStepPoint,
          updateInvitationPoint: widget.updateInvitationPoint,
          updateQuizPoint: widget.updateQuizPoint,
          updateMaxCommentPoint: widget.updateMaxCommentPoint,
          updateMaxLikePoint: widget.updateMaxLikePoint,
          updateMaxInvitationPoint: widget.updateMaxInvitationPoint,
          updateMaxStepPoint: widget.updateMaxStepPoint,
          updateInvitationType: widget.updateInvitationType,
          edit: widget.edit,
          eventModel: widget.eventModel,
        ),
      ],
    );
  }
}
