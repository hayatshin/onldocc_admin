import 'package:flutter/material.dart';
import 'package:onldocc_admin/constants/gaps.dart';
import 'package:onldocc_admin/constants/sizes.dart';
import 'package:onldocc_admin/features/event/view/event_screen.dart';
import 'package:onldocc_admin/features/event/widgets/field-box/point_field_box.dart';
import 'package:onldocc_admin/palette.dart';

class UploadTargetScoreWidget extends StatefulWidget {
  final Function(int) updateGoalScore;
  final Function(int) updateDiaryPoint;
  final Function(int) updateCommentPoint;
  final Function(int) updateLikePoint;
  final Function(int) updateStepPoint;
  final Function(int) updateInvitationPoint;
  final Function(int) updateQuizPoint;
  final Function(int) updateMaxStepCount;
  final TextEditingController diaryPointController;
  final TextEditingController quizPointController;
  final TextEditingController commentPointController;
  final TextEditingController likePointController;
  final TextEditingController invitationPointController;
  final TextEditingController stepPointController;
  final TextEditingController quizMaxPointController;
  final TextEditingController commentMaxPointController;
  final TextEditingController likeMaxPointController;
  final TextEditingController invitationMaxPointController;
  final TextEditingController stepMaxPointController;

  const UploadTargetScoreWidget({
    super.key,
    required this.updateGoalScore,
    required this.updateDiaryPoint,
    required this.updateCommentPoint,
    required this.updateLikePoint,
    required this.updateStepPoint,
    required this.updateInvitationPoint,
    required this.updateQuizPoint,
    required this.updateMaxStepCount,
    required this.diaryPointController,
    required this.quizPointController,
    required this.commentPointController,
    required this.likePointController,
    required this.invitationPointController,
    required this.stepPointController,
    required this.quizMaxPointController,
    required this.commentMaxPointController,
    required this.likeMaxPointController,
    required this.invitationMaxPointController,
    required this.stepMaxPointController,
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

  final _quizLimitField = ValueNotifier<bool>(false);
  final _commentLimitField = ValueNotifier<bool>(false);
  final _likeLimitField = ValueNotifier<bool>(false);
  final _invitationLimitField = ValueNotifier<bool>(false);

  final _quizLimitValue = ValueNotifier<int>(0);
  final _commentLimitValue = ValueNotifier<int>(0);
  final _likeLimitValue = ValueNotifier<int>(0);
  final _invitationLimitValue = ValueNotifier<int>(0);
  final _stepLimitValue = ValueNotifier<int>(0);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
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
                      textAlignVertical: TextAlignVertical.top,
                      style: contentTextStyle,
                      decoration: InputDecoration(
                        isDense: true,
                        filled: true,
                        fillColor: Palette().lightGreen.withOpacity(0.1),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            Sizes.size20,
                          ),
                        ),
                        errorStyle: TextStyle(
                          color: Theme.of(context).primaryColor,
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            Sizes.size20,
                          ),
                          borderSide: BorderSide(
                            width: 1.5,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            Sizes.size20,
                          ),
                          borderSide: BorderSide(
                            width: 1.5,
                            color: Palette().normalGreen.withOpacity(0.7),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            Sizes.size20,
                          ),
                          borderSide: BorderSide(
                            width: 1.5,
                            color: Palette().darkGreen.withOpacity(0.7),
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: Sizes.size20,
                          vertical: Sizes.size20,
                        ),
                      ),
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
          quizLimitField: _quizLimitField,
          commentLimitField: _commentLimitField,
          likeLimitField: _likeLimitField,
          invitationLimitField: _invitationLimitField,
          diaryPointController: widget.diaryPointController,
          quizPointController: widget.quizPointController,
          commentPointController: widget.commentPointController,
          likePointController: widget.likePointController,
          invitationPointController: widget.invitationPointController,
          stepPointController: widget.stepPointController,
          quizMaxPointController: widget.quizMaxPointController,
          commentMaxPointController: widget.commentMaxPointController,
          likeMaxPointController: widget.likeMaxPointController,
          invitationMaxPointController: widget.invitationMaxPointController,
          stepMaxPointController: widget.stepMaxPointController,
        ),
      ],
    );
  }
}

class PointTextFormField extends StatelessWidget {
  final TextEditingController controller;
  const PointTextFormField({
    super.key,
    required this.controller,
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
        controller: controller,
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
