import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:onldocc_admin/constants/gaps.dart';
import 'package:onldocc_admin/constants/sizes.dart';
import 'package:onldocc_admin/features/event/widgets/edit_target_score_event_widget.dart';

class UploadTargetScoreWidget extends StatefulWidget {
  final Function(int) updateGoalScore;
  final Function(int) updateDiaryPoint;
  final Function(int) updateCommentPoint;
  final Function(int) updateLikePoint;
  final Function(int) updateStepPoint;
  final Function(int) updateInvitationPoint;
  final Function(int) updateQuizPoint;
  final Function(int) updateMaxStepCount;

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
  });

  @override
  State<UploadTargetScoreWidget> createState() =>
      _UploadTargetScoreWidgetState();
}

class _UploadTargetScoreWidgetState extends State<UploadTargetScoreWidget> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: size.width * 0.12,
              child: const Text(
                "목표 점수 설정",
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.start,
              ),
            ),
            Gaps.h32,
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                SizedBox(
                  width: 150,
                  child: TextFormField(
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    minLines: 1,
                    onChanged: (value) {
                      final goalScore = int.parse(value);
                      widget.updateGoalScore(goalScore);
                    },
                    // controller: _goalScoreController,
                    textAlignVertical: TextAlignVertical.top,
                    style: const TextStyle(
                      fontSize: Sizes.size14,
                      color: Colors.black87,
                      fontWeight: FontWeight.w600,
                    ),
                    decoration: InputDecoration(
                      isDense: true,
                      hintText: "",
                      hintStyle: TextStyle(
                        fontSize: Sizes.size14,
                        color: Colors.grey.shade400,
                        fontWeight: FontWeight.w300,
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          Sizes.size3,
                        ),
                      ),
                      errorStyle: TextStyle(
                        color: Theme.of(context).primaryColor,
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          Sizes.size3,
                        ),
                        borderSide: BorderSide(
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          Sizes.size3,
                        ),
                        borderSide: BorderSide(
                          color: Colors.grey.shade300,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          Sizes.size3,
                        ),
                        borderSide: BorderSide(
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: Sizes.size10,
                        vertical: Sizes.size10,
                      ),
                    ),
                  ),
                ),
                Gaps.h10,
                Text(
                  "점",
                  style: TextStyle(
                    fontSize: Sizes.size14,
                    color: Colors.grey.shade800,
                    fontWeight: FontWeight.w300,
                  ),
                )
              ],
            ),
          ],
        ),
        Gaps.v52,
        Row(
          // mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              flex: 2,
              child: DefaultPointTile(
                totalWidth: size.width,
                updateEventPoint: widget.updateDiaryPoint,
                header: "일기",
                defaultPoint: 0,
                editOrNot: false,
              ),
            ),
            const Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MaxPointTextWidget(
                    text: "( 일일 최대:     1회 )",
                  ),
                ],
              ),
            ),
          ],
        ),
        Gaps.v32,
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              flex: 2,
              child: DefaultPointTile(
                totalWidth: size.width,
                updateEventPoint: widget.updateQuizPoint,
                header: "문제 풀기",
                defaultPoint: 0,
                editOrNot: false,
              ),
            ),
            const Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MaxPointTextWidget(
                    text: "( 일일 최대:     1회 )",
                  ),
                ],
              ),
            ),
          ],
        ),
        Gaps.v32,
        Row(
          children: [
            Expanded(
              flex: 1,
              child: DefaultPointTile(
                totalWidth: size.width,
                updateEventPoint: widget.updateCommentPoint,
                header: "댓글",
                defaultPoint: 0,
                editOrNot: false,
              ),
            ),
          ],
        ),
        Gaps.v32,
        Row(
          children: [
            Expanded(
              flex: 1,
              child: DefaultPointTile(
                totalWidth: size.width,
                updateEventPoint: widget.updateLikePoint,
                header: "좋아요",
                defaultPoint: 0,
                editOrNot: false,
              ),
            ),
          ],
        ),
        Gaps.v32,
        Row(
          children: [
            Expanded(
              flex: 1,
              child: DefaultPointTile(
                totalWidth: size.width,
                updateEventPoint: widget.updateInvitationPoint,
                header: "친구 초대",
                defaultPoint: 0,
                editOrNot: false,
              ),
            ),
          ],
        ),
        Gaps.v32,
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  flex: 2,
                  child: DefaultPointTile(
                    totalWidth: size.width,
                    updateEventPoint: widget.updateStepPoint,
                    header: "걸음수",
                    defaultPoint: 0,
                    editOrNot: false,
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: MaxStepPointTile(
                    totalWidth: size.width,
                    updateEventPoint: widget.updateMaxStepCount,
                    header: "일일 최대: ",
                    defaultPoint: 10000,
                    editOrNot: false,
                  ),
                ),
              ],
            ),
            Gaps.v20,
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Container(),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    "※ 걸음수는 신체 활동 권한 설정을 허용하지 않은 사용자들이 많아 사용을 권장하지 않습니다.",
                    style: TextStyle(
                      fontSize: Sizes.size12,
                      fontWeight: FontWeight.w300,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
