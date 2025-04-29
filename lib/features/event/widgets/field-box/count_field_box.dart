import 'package:flutter/material.dart';
import 'package:onldocc_admin/constants/gaps.dart';
import 'package:onldocc_admin/constants/sizes.dart';
import 'package:onldocc_admin/features/event/models/event_model.dart';
import 'package:onldocc_admin/features/event/widgets/field-box/point_field_box.dart';
import 'package:onldocc_admin/features/event/widgets/upload-event/upload_target_score_widget.dart';
import 'package:onldocc_admin/palette.dart';

class CountFieldBox extends StatelessWidget {
  final ValueNotifier<bool> diaryField;
  final ValueNotifier<bool> quizField;
  final ValueNotifier<bool> commentField;
  final ValueNotifier<bool> likeField;
  final ValueNotifier<bool> invitationField;
  final ValueNotifier<bool> commentLimitField;
  final ValueNotifier<bool> likeLimitField;
  final ValueNotifier<bool> invitationLimitField;
  // final TextEditingController diaryCountController;
  // final TextEditingController quizCountController;
  // final TextEditingController commentCountController;
  // final TextEditingController likeCountController;
  // final TextEditingController invitationCountController;
  // final TextEditingController commentMaxCountController;
  // final TextEditingController likeMaxCountController;
  // final TextEditingController invitationMaxCountController;
  final Function(int) updateDiaryCount;
  final Function(int) updateCommentCount;
  final Function(int) updateLikeCount;
  final Function(int) updateInvitationCount;
  final Function(int) updateQuizCount;
  final Function(int) updateMaxCommentCount;
  final Function(int) updateMaxLikeCount;
  final Function(int) updateMaxInvitationCount;
  final Function(String) updateInvitationType;
  final bool edit;
  final EventModel? eventModel;

  const CountFieldBox({
    super.key,
    required this.diaryField,
    required this.quizField,
    required this.commentField,
    required this.likeField,
    required this.invitationField,
    required this.commentLimitField,
    required this.likeLimitField,
    required this.invitationLimitField,
    // required this.diaryCountController,
    // required this.quizCountController,
    // required this.commentCountController,
    // required this.likeCountController,
    // required this.invitationCountController,
    // required this.commentMaxCountController,
    // required this.likeMaxCountController,
    // required this.invitationMaxCountController,
    required this.updateDiaryCount,
    required this.updateCommentCount,
    required this.updateLikeCount,
    required this.updateInvitationCount,
    required this.updateQuizCount,
    required this.updateMaxCommentCount,
    required this.updateMaxLikeCount,
    required this.updateMaxInvitationCount,
    required this.updateInvitationType,
    required this.edit,
    this.eventModel,
  });

  @override
  Widget build(BuildContext context) {
    const double fieldHeight = 45;

    final TextStyle fieldHeaderTextStyle = TextStyle(
      fontSize: Sizes.size13,
      fontWeight: FontWeight.w700,
      color: Palette().darkBlue,
    );
    final TextStyle fieldContentTextStyle = TextStyle(
      fontSize: Sizes.size12,
      fontWeight: FontWeight.w400,
      color: Palette().darkGray,
    );

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          width: 0.5,
          color: Palette().darkBlue.withOpacity(0.7),
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: IntrinsicHeight(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                  children: [
                    FieldPointUsageTile(
                      fieldHeight: fieldHeight,
                      fieldHeaderTextStyle: fieldHeaderTextStyle,
                      fieldName: "일기",
                      field: diaryField,
                    ),
                    FieldPointUsageTile(
                      fieldHeight: fieldHeight,
                      fieldHeaderTextStyle: fieldHeaderTextStyle,
                      fieldName: "문제 풀기",
                      field: quizField,
                    ),
                    FieldPointUsageTile(
                      fieldHeight: fieldHeight,
                      fieldHeaderTextStyle: fieldHeaderTextStyle,
                      fieldName: "댓글",
                      field: commentField,
                    ),
                    FieldPointUsageTile(
                      fieldHeight: fieldHeight,
                      fieldHeaderTextStyle: fieldHeaderTextStyle,
                      fieldName: "좋아요",
                      field: likeField,
                    ),
                    InvitationFieldPointUsageTile(
                      fieldHeight: fieldHeight,
                      fieldHeaderTextStyle: fieldHeaderTextStyle,
                      fieldName: "친구 초대",
                      field: invitationField,
                      invitationType: eventModel?.invitationType ?? "send",
                      updateInvitationType: updateInvitationType,
                    ),
                  ],
                ),
              ),
            ),
            Container(
              width: 0.5,
              color: Palette().darkBlue.withOpacity(0.7),
            ),
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                  children: [
                    // 일기
                    SizedBox(
                      height: fieldHeight,
                      child: ValueListenableBuilder(
                        valueListenable: diaryField,
                        builder: (context, diaryFieldValue, child) =>
                            !diaryFieldValue
                                ? Container()
                                : Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Expanded(
                                        child: Row(
                                          children: [
                                            PointTextFormField(
                                              edit: edit,
                                              point: eventModel?.diaryCount,
                                              updateState: updateDiaryCount,
                                            ),
                                            Gaps.h10,
                                            SelectableText(
                                              "회",
                                              style: fieldContentTextStyle,
                                            ),
                                          ],
                                        ),
                                      ),
                                      Expanded(child: Container()),
                                      Expanded(
                                        child: Row(
                                          children: [
                                            SelectableText(
                                              "1일 최대:",
                                              style: fieldContentTextStyle,
                                            ),
                                            Gaps.h20,
                                            SelectableText(
                                              "1 회",
                                              style: fieldContentTextStyle,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                      ),
                    ),
                    // 문제 풀기
                    SizedBox(
                      height: fieldHeight,
                      child: ValueListenableBuilder(
                        valueListenable: quizField,
                        builder: (context, quizFieldValue, child) =>
                            !quizFieldValue
                                ? Container()
                                : Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Expanded(
                                        child: Row(
                                          children: [
                                            PointTextFormField(
                                              edit: edit,
                                              point: eventModel?.quizCount,
                                              updateState: updateQuizCount,
                                            ),
                                            Gaps.h10,
                                            SelectableText(
                                              "회",
                                              style: fieldContentTextStyle,
                                            ),
                                          ],
                                        ),
                                      ),
                                      Expanded(child: Container()),
                                      Expanded(
                                        child: Row(
                                          children: [
                                            SelectableText(
                                              "1일 최대:",
                                              style: fieldContentTextStyle,
                                            ),
                                            Gaps.h20,
                                            SelectableText(
                                              "1 회",
                                              style: fieldContentTextStyle,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                      ),
                    ),
                    FieldCountSetterTile(
                      fieldHeight: fieldHeight,
                      fieldContentTextStyle: fieldContentTextStyle,
                      field: commentField,
                      fieldLimit: commentLimitField,
                      updateState: updateCommentCount,
                      updateMaxState: updateMaxCommentCount,
                      edit: edit,
                      count: eventModel?.commentCount,
                      maxCount: eventModel?.maxCommentCount,
                    ),
                    FieldCountSetterTile(
                      fieldHeight: fieldHeight,
                      fieldContentTextStyle: fieldContentTextStyle,
                      field: likeField,
                      fieldLimit: likeLimitField,
                      updateState: updateLikeCount,
                      updateMaxState: updateMaxLikeCount,
                      edit: edit,
                      count: eventModel?.likeCount,
                      maxCount: eventModel?.maxLikeCount,
                    ),
                    FieldCountSetterTile(
                      fieldHeight: fieldHeight,
                      fieldContentTextStyle: fieldContentTextStyle,
                      field: invitationField,
                      fieldLimit: invitationLimitField,
                      updateState: updateInvitationCount,
                      updateMaxState: updateMaxInvitationCount,
                      edit: edit,
                      count: eventModel?.invitationCount,
                      maxCount: eventModel?.maxInvitationCount,
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class FieldCountSetterTile extends StatelessWidget {
  final double? fieldHeight;
  final TextStyle fieldContentTextStyle;
  final ValueNotifier<bool> field;
  final ValueNotifier<bool> fieldLimit;
  final Function(int) updateState;
  final Function(int) updateMaxState;
  final bool edit;
  final int? count;
  final int? maxCount;

  const FieldCountSetterTile({
    super.key,
    required this.fieldHeight,
    required this.fieldContentTextStyle,
    required this.field,
    required this.fieldLimit,
    required this.updateState,
    required this.updateMaxState,
    required this.edit,
    this.count,
    this.maxCount,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: fieldHeight,
      child: ValueListenableBuilder(
        valueListenable: field,
        builder: (context, fieldValue, child) => !fieldValue
            ? Container()
            : Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        PointTextFormField(
                          updateState: updateState,
                          edit: edit,
                          point: count,
                        ),
                        Gaps.h10,
                        SelectableText(
                          "회",
                          style: fieldContentTextStyle,
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ValueListenableBuilder(
                      valueListenable: fieldLimit,
                      builder: (context, fieldLimitValue, child) {
                        return Row(
                          children: [
                            Radio(
                              toggleable: true,
                              value: false,
                              splashRadius: 0,
                              activeColor: Palette().darkBlue,
                              groupValue: fieldLimitValue,
                              onChanged: (bool? value) {
                                fieldLimit.value = !fieldLimit.value;
                              },
                            ),
                            Gaps.h14,
                            SelectableText(
                              "1일 횟수 제한 없음",
                              style: fieldContentTextStyle,
                            )
                          ],
                        );
                      },
                    ),
                  ),
                  Expanded(
                    child: ValueListenableBuilder(
                      valueListenable: fieldLimit,
                      builder: (context, fieldLimitValue, child) =>
                          !fieldLimitValue
                              ? Container()
                              : Row(
                                  children: [
                                    SelectableText(
                                      "1일 최대:",
                                      style: fieldContentTextStyle,
                                    ),
                                    Gaps.h16,
                                    PointTextFormField(
                                      edit: edit,
                                      point: maxCount,
                                      updateState: updateMaxState,
                                    ),
                                    Gaps.h10,
                                    SelectableText(
                                      "회",
                                      style: fieldContentTextStyle,
                                    ),
                                  ],
                                ),
                    ),
                  )
                ],
              ),
      ),
    );
  }
}
