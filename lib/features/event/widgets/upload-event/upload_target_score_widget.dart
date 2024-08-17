import 'package:flutter/material.dart';
import 'package:onldocc_admin/constants/gaps.dart';
import 'package:onldocc_admin/constants/sizes.dart';
import 'package:onldocc_admin/features/event/models/event_model.dart';
import 'package:onldocc_admin/features/event/view/event_screen.dart';
import 'package:onldocc_admin/features/event/widgets/field-box/point_field_box.dart';
import 'package:onldocc_admin/palette.dart';
import 'package:onldocc_admin/utils.dart';

class UploadTargetScoreWidget extends StatefulWidget {
  final Function(int) updateGoalScore;
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
  final bool edit;
  final EventModel? eventModel;
  // final TextEditingController diaryPointController;
  // final TextEditingController quizPointController;
  // final TextEditingController commentPointController;
  // final TextEditingController likePointController;
  // final TextEditingController invitationPointController;
  // final TextEditingController stepPointController;
  // final TextEditingController commentMaxPointController;
  // final TextEditingController likeMaxPointController;
  // final TextEditingController invitationMaxPointController;
  // final TextEditingController stepMaxPointController;

  const UploadTargetScoreWidget({
    super.key,
    required this.updateGoalScore,
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
    required this.edit,
    this.eventModel,
    // required this.diaryPointController,
    // required this.quizPointController,
    // required this.commentPointController,
    // required this.likePointController,
    // required this.invitationPointController,
    // required this.stepPointController,
    // required this.commentMaxPointController,
    // required this.likeMaxPointController,
    // required this.invitationMaxPointController,
    // required this.stepMaxPointController,
  });

  @override
  State<UploadTargetScoreWidget> createState() =>
      _UploadTargetScoreWidgetState();
}

class _UploadTargetScoreWidgetState extends State<UploadTargetScoreWidget> {
  final _diaryField = ValueNotifier<bool>(false);
  final _quizField = ValueNotifier<bool>(false);
  final _commentField = ValueNotifier<bool>(false);
  final _likeField = ValueNotifier<bool>(false);
  final _invitationField = ValueNotifier<bool>(false);
  final _stepField = ValueNotifier<bool>(false);

  final _commentLimitField = ValueNotifier<bool>(false);
  final _likeLimitField = ValueNotifier<bool>(false);
  final _invitationLimitField = ValueNotifier<bool>(false);

  // final _quizLimitValue = ValueNotifier<int>(0);
  // final _commentLimitValue = ValueNotifier<int>(0);
  // final _likeLimitValue = ValueNotifier<int>(0);
  // final _invitationLimitValue = ValueNotifier<int>(0);
  // final _stepLimitValue = ValueNotifier<int>(0);

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
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 1,
              child: Text(
                "2. 목표 점수를 설정해주세요.",
                style: headerTextStyle,
                textAlign: TextAlign.start,
              ),
            ),
            Expanded(
              flex: 4,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  SizedBox(
                    width: 100,
                    height: 40,
                    child: TextFormField(
                      // expands: true,
                      maxLines: 1,
                      // minLines: null,
                      // controller: _descriptionControllder,
                      initialValue: widget.eventModel?.targetScore.toString(),
                      onChanged: (value) {
                        if (value.isNotEmpty) {
                          widget.updateGoalScore(int.parse(value));
                        }
                      },
                      textAlignVertical: TextAlignVertical.top,
                      style: contentTextStyle,
                      decoration: eventSettingInputDecorationStyle(),
                    ),
                  ),
                  Gaps.h10,
                  Text(
                    "점",
                    style: contentTextStyle,
                  ),
                ],
              ),
            ),
          ],
        ),
        Gaps.v52,
        Text(
          "3. 점수 산출 방식을 설정해주세요.",
          style: headerTextStyle,
          textAlign: TextAlign.start,
        ),
        Gaps.v20,
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
          updateMaxStepPoint: widget.updateMaxCommentPoint,
          edit: widget.edit,
          eventModel: widget.eventModel,
          // diaryPointController: widget.diaryPointController,
          // quizPointController: widget.quizPointController,
          // commentPointController: widget.commentPointController,
          // likePointController: widget.likePointController,
          // invitationPointController: widget.invitationPointController,
          // stepPointController: widget.stepPointController,
          // commentMaxPointController: widget.commentMaxPointController,
          // likeMaxPointController: widget.likeMaxPointController,
          // invitationMaxPointController: widget.invitationMaxPointController,
          // stepMaxPointController: widget.stepMaxPointController,
        ),
      ],
    );
  }
}

class PointTextFormField extends StatelessWidget {
  final Function(int) updateState;
  final bool step;
  final bool edit;
  final int? point;
  const PointTextFormField({
    super.key,
    required this.updateState,
    this.step = false,
    required this.edit,
    this.point,
  });

  @override
  Widget build(BuildContext context) {
    final TextStyle contentTextStyle = TextStyle(
      fontSize: Sizes.size14,
      fontWeight: FontWeight.w500,
      color: Palette().darkGray,
    );

    return SizedBox(
      width: 80,
      child: TextFormField(
        maxLines: 1,
        onChanged: (String value) {
          updateState(int.parse(value));
        },
        initialValue: edit
            ? "$point"
            : step
                ? "7000"
                : null,
        textAlignVertical: TextAlignVertical.top,
        style: contentTextStyle,
        decoration: InputDecoration(
          isDense: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(
              Sizes.size10,
            ),
          ),
          errorStyle: TextStyle(
            color: Theme.of(context).primaryColor,
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(
              Sizes.size10,
            ),
            borderSide: BorderSide(
              width: 1.5,
              color: Theme.of(context).primaryColor,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(
              Sizes.size10,
            ),
            borderSide: BorderSide(
              width: 1.5,
              color: Palette().normalGray.withOpacity(0.7),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(
              Sizes.size10,
            ),
            borderSide: BorderSide(
              width: 1.5,
              color: Palette().darkGray.withOpacity(0.7),
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: Sizes.size15,
            vertical: Sizes.size10,
          ),
        ),
      ),
    );
  }
}
