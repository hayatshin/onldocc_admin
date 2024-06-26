import 'package:flutter/material.dart';
import 'package:onldocc_admin/constants/gaps.dart';
import 'package:onldocc_admin/constants/sizes.dart';
import 'package:onldocc_admin/features/event/view/event_screen.dart';
import 'package:onldocc_admin/palette.dart';

class UploadMultipleScoresWidget extends StatefulWidget {
  final Function(int) updateGoalScore;
  final Function(int) updateDiaryPoint;
  final Function(int) updateCommentPoint;
  final Function(int) updateLikePoint;
  final Function(int) updateStepPoint;
  final Function(int) updateInvitationPoint;
  final Function(int) updateQuizPoint;
  final Function(int) updateMaxStepCount;
  final Function(int) updateMaxCommentCount;
  final Function(int) updateMaxLikeCount;
  final Function(int) updateInvitationCount;

  const UploadMultipleScoresWidget({
    super.key,
    required this.updateGoalScore,
    required this.updateDiaryPoint,
    required this.updateCommentPoint,
    required this.updateLikePoint,
    required this.updateStepPoint,
    required this.updateInvitationPoint,
    required this.updateQuizPoint,
    required this.updateMaxStepCount,
    required this.updateMaxCommentCount,
    required this.updateMaxLikeCount,
    required this.updateInvitationCount,
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "2. 최소 가이드 점수를 설정해주세요.",
                    style: headerTextStyle,
                    textAlign: TextAlign.start,
                  ),
                  Gaps.v16,
                  Text(
                    "사용자가 대략의 점수 달성을 해야하는지 가이드를 주기 위한 점수입니다.\n설정을 안 하실 경우 ‘0’을 기입해주세요.",
                    style: headerInfoTextStyle,
                    textAlign: TextAlign.start,
                    overflow: TextOverflow.visible,
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 1,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
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
        Gaps.v16,
        Text(
          "고득점 점수 행사의 경우 횟수 제한이 없을 시 무의미한 활동이 많아질 수 있어 횟수 제한 설정을 권장드립니다.",
          style: headerInfoTextStyle,
          textAlign: TextAlign.start,
          overflow: TextOverflow.visible,
        ),
        Gaps.v32,
        // PointFieldBox(
        //   diaryField: _diaryField,
        //   quizField: _quizField,
        //   commentField: _commentField,
        //   likeField: _likeField,
        //   invitationField: _invitationField,
        //   stepField: _stepField,
        //   quizLimitField: _quizLimitField,
        //   commentLimitField: _commentLimitField,
        //   likeLimitField: _likeLimitField,
        //   invitationLimitField: _invitationLimitField,
        // ),
      ],
    );
  }
}
