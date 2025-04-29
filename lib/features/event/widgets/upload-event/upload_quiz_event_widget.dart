import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_multi_formatter/formatters/masked_input_formatter.dart';
import 'package:onldocc_admin/constants/gaps.dart';
import 'package:onldocc_admin/features/event/models/event_model.dart';
import 'package:onldocc_admin/features/event/template/event_detail_template.dart';
import 'package:onldocc_admin/features/event/view/event_screen.dart';
import 'package:onldocc_admin/utils.dart';

class UploadQuizEventWidget extends StatefulWidget {
  final Function(String) updateQuiz;
  final Function(String) updateFirstChoice;
  final Function(String) updateSecondChoice;
  final Function(String) updateThirdChoice;
  final Function(String) updateFourthChoice;
  final Function(int) updateQuizAnswer;

  final bool submit;
  final bool edit;
  final EventModel? eventModel;

  const UploadQuizEventWidget({
    super.key,
    required this.updateQuiz,
    required this.updateFirstChoice,
    required this.updateSecondChoice,
    required this.updateThirdChoice,
    required this.updateFourthChoice,
    required this.updateQuizAnswer,
    required this.submit,
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
  State<UploadQuizEventWidget> createState() =>
      _UploadQuizEventWidgetStateState();
}

class _UploadQuizEventWidgetStateState extends State<UploadQuizEventWidget> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    if (_formKey.currentState != null && widget.submit) {
      _formKey.currentState!.validate();
    }
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 1,
                child: SelectableText(
                  "2. 질문을 작성해주세요.",
                  style: headerTextStyle,
                  textAlign: TextAlign.start,
                ),
              ),
              Expanded(
                flex: 4,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: TextFormField(
                        // expands: true,
                        maxLines: 1,
                        // minLines: null,
                        // controller: _descriptionControllder,
                        initialValue: widget.edit
                            ? widget.eventModel?.quiz.toString()
                            : null,
                        validator: (value) {
                          if (value != null && value.isEmpty) {
                            return "";
                          }
                          return null;
                        },
                        onChanged: (value) {
                          if (value.isNotEmpty) {
                            widget.updateQuiz(value);
                          }
                        },
                        textAlignVertical: TextAlignVertical.top,
                        style: contentTextStyle,
                        decoration: eventSettingInputDecorationStyle()
                            .copyWith(hintText: "이탈리아의 수도는?"),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Gaps.v40,
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 1,
                child: SelectableText(
                  "3. 사지선다 보기를 작성해주세요.",
                  style: headerTextStyle,
                  textAlign: TextAlign.start,
                ),
              ),
              Expanded(
                flex: 4,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MultipleChoiceWidget(
                      index: 1,
                      initialValue: widget.edit
                          ? widget.eventModel?.firstChoice.toString()
                          : null,
                      updateValue: (value) => widget.updateFirstChoice(value),
                    ),
                    MultipleChoiceWidget(
                      index: 2,
                      initialValue: widget.edit
                          ? widget.eventModel?.secondChoice.toString()
                          : null,
                      updateValue: (value) => widget.updateSecondChoice(value),
                    ),
                    MultipleChoiceWidget(
                      index: 3,
                      initialValue: widget.edit
                          ? widget.eventModel?.thirdChoice.toString()
                          : null,
                      updateValue: (value) => widget.updateThirdChoice(value),
                    ),
                    MultipleChoiceWidget(
                      index: 4,
                      initialValue: widget.edit
                          ? widget.eventModel?.fourthChoice.toString()
                          : null,
                      updateValue: (value) => widget.updateFourthChoice(value),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Gaps.v40,
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 1,
                child: SelectableText(
                  "4. 정답을 작성해주세요.",
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
                      width: 80,
                      child: TextFormField(
                        // expands: true,
                        // minLines: null,
                        // controller: _descriptionControllder,
                        initialValue: widget.edit
                            ? widget.eventModel?.quizAnswer.toString()
                            : null,
                        validator: (value) {
                          if (value != null && value.isEmpty) {
                            return "";
                          }
                          return null;
                        },
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          if (value.isNotEmpty) {
                            widget.updateQuizAnswer(int.parse(value));
                          }
                        },
                        textAlignVertical: TextAlignVertical.top,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          MaskedInputFormatter("#"),
                        ],
                        style: contentTextStyle,
                        decoration: eventSettingInputDecorationStyle(),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Gaps.v52,
        ],
      ),
    );
  }
}

class MultipleChoiceWidget extends StatelessWidget {
  final int? index;
  final String? initialValue;
  final Function(String) updateValue;
  const MultipleChoiceWidget({
    super.key,
    required this.index,
    required this.initialValue,
    required this.updateValue,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        EventHeader(headerText: "${index ?? ""}"),
        Gaps.h10,
        SizedBox(
          width: 150,
          child: TextFormField(
            // expands: true,
            maxLines: 1,
            // minLines: null,
            // controller: _descriptionControllder,
            initialValue: initialValue,
            onChanged: (value) {
              if (value.isNotEmpty) {
                updateValue(value);
              }
            },
            validator: (value) {
              if (value != null && value.isEmpty) {
                return "";
              }
              return null;
            },
            textAlignVertical: TextAlignVertical.top,
            style: contentTextStyle,
            decoration: eventSettingInputDecorationStyle(),
          ),
        )
      ],
    );
  }
}
