import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:onldocc_admin/constants/gaps.dart';
import 'package:onldocc_admin/constants/sizes.dart';
import 'package:onldocc_admin/features/event/models/event_model.dart';
import 'package:onldocc_admin/features/event/widgets/upload-event/upload_target_score_widget.dart';
import 'package:onldocc_admin/palette.dart';

class PointFieldBox extends StatelessWidget {
  final ValueNotifier<bool> diaryField;
  final ValueNotifier<bool> quizField;
  final ValueNotifier<bool> commentField;
  final ValueNotifier<bool> likeField;
  final ValueNotifier<bool> invitationField;
  final ValueNotifier<bool> stepField;
  final ValueNotifier<bool> commentLimitField;
  final ValueNotifier<bool> likeLimitField;
  final ValueNotifier<bool> invitationLimitField;
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

  const PointFieldBox({
    super.key,
    required this.diaryField,
    required this.quizField,
    required this.commentField,
    required this.likeField,
    required this.invitationField,
    required this.stepField,
    required this.commentLimitField,
    required this.likeLimitField,
    required this.invitationLimitField,
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
                    FieldPointUsageTile(
                      fieldHeight: fieldHeight,
                      fieldHeaderTextStyle: fieldHeaderTextStyle,
                      fieldName: "걸음수",
                      field: stepField,
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
                                            Text(
                                              "1회당 점수:",
                                              style: fieldContentTextStyle,
                                            ),
                                            Gaps.h16,
                                            PointTextFormField(
                                              edit: edit,
                                              point: eventModel?.diaryPoint,
                                              updateState: updateDiaryPoint,
                                            ),
                                            Gaps.h10,
                                            Text(
                                              "점",
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
                                            Text(
                                              "1회당 점수:",
                                              style: fieldContentTextStyle,
                                            ),
                                            Gaps.h16,
                                            PointTextFormField(
                                              edit: edit,
                                              point: eventModel?.quizPoint,
                                              updateState: updateQuizPoint,
                                            ),
                                            Gaps.h10,
                                            Text(
                                              "점",
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
                    FieldPointSetterTile(
                      fieldHeight: fieldHeight,
                      fieldContentTextStyle: fieldContentTextStyle,
                      field: commentField,
                      fieldLimit: commentLimitField,
                      updateState: updateCommentPoint,
                      updateMaxState: updateMaxCommentPoint,
                      edit: edit,
                      point: eventModel?.commentPoint,
                      maxPoint: eventModel?.maxCommentCount,
                    ),
                    FieldPointSetterTile(
                      fieldHeight: fieldHeight,
                      fieldContentTextStyle: fieldContentTextStyle,
                      field: likeField,
                      fieldLimit: likeLimitField,
                      updateState: updateLikePoint,
                      updateMaxState: updateMaxLikePoint,
                      edit: edit,
                      point: eventModel?.likePoint,
                      maxPoint: eventModel?.maxLikeCount,
                    ),
                    FieldPointSetterTile(
                      fieldHeight: fieldHeight,
                      fieldContentTextStyle: fieldContentTextStyle,
                      field: invitationField,
                      fieldLimit: invitationLimitField,
                      updateState: updateInvitationPoint,
                      updateMaxState: updateMaxInvitationPoint,
                      edit: edit,
                      point: eventModel?.invitationPoint,
                      maxPoint: eventModel?.maxInvitationCount,
                    ),
                    SizedBox(
                      height: fieldHeight,
                      child: ValueListenableBuilder(
                        valueListenable: stepField,
                        builder: (context, stepFieldValue, child) =>
                            !stepFieldValue
                                ? Container()
                                : Row(
                                    children: [
                                      Expanded(
                                        child: Row(
                                          children: [
                                            Text(
                                              "1회당 점수:",
                                              style: fieldContentTextStyle,
                                            ),
                                            Gaps.h16,
                                            PointTextFormField(
                                              edit: edit,
                                              point: eventModel?.stepPoint,
                                              updateState: updateStepPoint,
                                            ),
                                            Gaps.h10,
                                            Text(
                                              "점",
                                              style: fieldContentTextStyle,
                                            ),
                                          ],
                                        ),
                                      ),
                                      Expanded(
                                        child: Container(),
                                      ),
                                      Expanded(
                                        child: Row(
                                          children: [
                                            Text(
                                              "1일 최대:",
                                              style: fieldContentTextStyle,
                                            ),
                                            Gaps.h16,
                                            PointTextFormField(
                                              edit: edit,
                                              point: eventModel?.maxStepCount,
                                              updateState: updateMaxStepPoint,
                                              step: true,
                                            ),
                                            Gaps.h10,
                                            Text(
                                              "보",
                                              style: fieldContentTextStyle,
                                            ),
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                      ),
                    )
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

class InvitationFieldPointUsageTile extends StatefulWidget {
  final double? fieldHeight;
  final TextStyle fieldHeaderTextStyle;
  final String fieldName;
  final ValueNotifier<bool> field;
  final String invitationType;
  final Function(String) updateInvitationType;

  const InvitationFieldPointUsageTile({
    super.key,
    required this.fieldHeight,
    required this.fieldHeaderTextStyle,
    required this.fieldName,
    required this.field,
    required this.invitationType,
    required this.updateInvitationType,
  });

  @override
  State<InvitationFieldPointUsageTile> createState() =>
      _InvitationFieldPointUsageTileState();
}

class _InvitationFieldPointUsageTileState
    extends State<InvitationFieldPointUsageTile> {
  final double menuHeight = 30;
  final List<String> _invitationTypes = ["친구 초대 기준", "초대 친구 가입 기준"];
  String _selectedInvitationType = "친구 초대 기준";

  @override
  void initState() {
    super.initState();
    _selectedInvitationType = widget.invitationType == "send"
        ? _invitationTypes[0]
        : _invitationTypes[1];
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.fieldHeight,
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Row(
              children: [
                ValueListenableBuilder(
                  valueListenable: widget.field,
                  builder: (context, fieldValue, child) => Transform.scale(
                    scale: 0.8,
                    child: Checkbox(
                      value: fieldValue,
                      activeColor: Palette().darkBlue,
                      splashRadius: 0,
                      onChanged: (value) {
                        if (value != null) {
                          widget.field.value = value;
                        }
                      },
                    ),
                  ),
                ),
                Gaps.h10,
                Text(
                  widget.fieldName,
                  style: widget.fieldHeaderTextStyle,
                ),
                Gaps.h10,
                Expanded(
                  child: SizedBox(
                    height: menuHeight,
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton2<String>(
                        isExpanded: true,
                        items: _invitationTypes.map((String item) {
                          return DropdownMenuItem<String>(
                            value: item,
                            child: Text(
                              item,
                              style: TextStyle(
                                fontSize: 12,
                                color: Palette().normalGray,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                        value: _selectedInvitationType,
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _selectedInvitationType = value;
                            });

                            final invitationType = value == _invitationTypes[0]
                                ? "send"
                                : "receive";
                            widget.updateInvitationType(invitationType);
                          }
                        },
                        buttonStyleData: ButtonStyleData(
                          padding: const EdgeInsets.only(left: 14, right: 14),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.white,
                            border: Border.all(
                              color: Palette().lightGray,
                              width: 0.5,
                            ),
                          ),
                        ),
                        iconStyleData: IconStyleData(
                          icon: const Icon(
                            Icons.expand_more_rounded,
                          ),
                          iconSize: 14,
                          iconEnabledColor: Palette().normalGray,
                          iconDisabledColor: Palette().normalGray,
                        ),
                        dropdownStyleData: DropdownStyleData(
                          elevation: 2,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.white,
                          ),
                          scrollbarTheme: ScrollbarThemeData(
                            radius: const Radius.circular(10),
                            thumbVisibility: WidgetStateProperty.all(true),
                          ),
                        ),
                        menuItemStyleData: MenuItemStyleData(
                          height: menuHeight,
                          padding: const EdgeInsets.only(
                            left: 15,
                            right: 15,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
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
                      activeColor: Palette().darkBlue,
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
  final Function(int) updateState;
  final Function(int) updateMaxState;
  final bool edit;
  final int? point;
  final int? maxPoint;

  const FieldPointSetterTile({
    super.key,
    required this.fieldHeight,
    required this.fieldContentTextStyle,
    required this.field,
    required this.fieldLimit,
    required this.updateState,
    required this.updateMaxState,
    required this.edit,
    this.point,
    this.maxPoint,
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
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          "1회당 점수:",
                          style: fieldContentTextStyle,
                        ),
                        Gaps.h16,
                        PointTextFormField(
                          edit: edit,
                          point: point,
                          updateState: updateState,
                        ),
                        Gaps.h10,
                        Text(
                          "점",
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
                                    PointTextFormField(
                                      updateState: updateMaxState,
                                      edit: edit,
                                      point: maxPoint,
                                    ),
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
