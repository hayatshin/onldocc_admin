import 'package:flutter/material.dart';
import 'package:onldocc_admin/constants/gaps.dart';
import 'package:onldocc_admin/constants/sizes.dart';
import 'package:onldocc_admin/palette.dart';

class CountFieldBox extends StatelessWidget {
  final ValueNotifier<bool> diaryField;
  final ValueNotifier<bool> quizField;
  final ValueNotifier<bool> commentField;
  final ValueNotifier<bool> likeField;
  final ValueNotifier<bool> invitationField;
  final ValueNotifier<bool> quizLimitField;
  final ValueNotifier<bool> commentLimitField;
  final ValueNotifier<bool> likeLimitField;
  final ValueNotifier<bool> invitationLimitField;

  const CountFieldBox({
    super.key,
    required this.diaryField,
    required this.quizField,
    required this.commentField,
    required this.likeField,
    required this.invitationField,
    required this.quizLimitField,
    required this.commentLimitField,
    required this.likeLimitField,
    required this.invitationLimitField,
  });

  @override
  Widget build(BuildContext context) {
    const double fieldHeight = 45;

    final TextStyle fieldHeaderTextStyle = TextStyle(
      fontSize: Sizes.size13,
      fontWeight: FontWeight.w700,
      color: Palette().normalGreen,
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
          color: Palette().normalGreen.withOpacity(0.7),
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
                    FieldPointUsageTile(
                      fieldHeight: fieldHeight,
                      fieldHeaderTextStyle: fieldHeaderTextStyle,
                      fieldName: "친구 초대",
                      field: invitationField,
                    ),
                  ],
                ),
              ),
            ),
            Container(
              width: 0.5,
              color: Palette().normalGreen.withOpacity(0.7),
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
                                    children: [
                                      Expanded(
                                        child: Row(
                                          children: [
                                            // const PointTextFormField(),
                                            Gaps.h10,
                                            Text(
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
                                            Text(
                                              "1일 최대:",
                                              style: fieldContentTextStyle,
                                            ),
                                            Gaps.h20,
                                            Text(
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
                    FieldPointSetterTile(
                      fieldHeight: fieldHeight,
                      fieldContentTextStyle: fieldContentTextStyle,
                      field: quizField,
                      fieldLimit: quizLimitField,
                    ),
                    FieldPointSetterTile(
                      fieldHeight: fieldHeight,
                      fieldContentTextStyle: fieldContentTextStyle,
                      field: commentField,
                      fieldLimit: commentLimitField,
                    ),
                    FieldPointSetterTile(
                      fieldHeight: fieldHeight,
                      fieldContentTextStyle: fieldContentTextStyle,
                      field: likeField,
                      fieldLimit: likeLimitField,
                    ),
                    FieldPointSetterTile(
                      fieldHeight: fieldHeight,
                      fieldContentTextStyle: fieldContentTextStyle,
                      field: invitationField,
                      fieldLimit: invitationLimitField,
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

class FieldPointUsageTile extends StatelessWidget {
  final double? fieldHeight;
  final TextStyle fieldHeaderTextStyle;
  final String fieldName;
  final ValueNotifier<bool> field;

  const FieldPointUsageTile({
    super.key,
    required this.fieldHeight,
    required this.fieldHeaderTextStyle,
    required this.fieldName,
    required this.field,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: fieldHeight,
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Row(
              children: [
                ValueListenableBuilder(
                  valueListenable: field,
                  builder: (context, fieldValue, child) => Transform.scale(
                    scale: 0.8,
                    child: Checkbox(
                      value: fieldValue,
                      activeColor: Palette().normalGreen,
                      splashRadius: 0,
                      onChanged: (value) {
                        if (value != null) {
                          field.value = value;
                        }
                      },
                    ),
                  ),
                ),
                Gaps.h10,
                Text(
                  fieldName,
                  style: fieldHeaderTextStyle,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class FieldPointSetterTile extends StatelessWidget {
  final double? fieldHeight;
  final TextStyle fieldContentTextStyle;
  final ValueNotifier<bool> field;
  final ValueNotifier<bool> fieldLimit;

  const FieldPointSetterTile({
    super.key,
    required this.fieldHeight,
    required this.fieldContentTextStyle,
    required this.field,
    required this.fieldLimit,
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
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        // const PointTextFormField(),
                        Gaps.h10,
                        Text(
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
                              activeColor: Palette().normalGreen,
                              groupValue: fieldLimitValue,
                              onChanged: (bool? value) {
                                fieldLimit.value = !fieldLimit.value;
                              },
                            ),
                            Gaps.h14,
                            Text(
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
                                    Text(
                                      "1일 최대:",
                                      style: fieldContentTextStyle,
                                    ),
                                    Gaps.h16,
                                    // const PointTextFormField(),
                                    Gaps.h10,
                                    Text(
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
