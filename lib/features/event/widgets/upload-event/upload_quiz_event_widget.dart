import 'package:flutter/material.dart';
import 'package:onldocc_admin/constants/gaps.dart';
import 'package:onldocc_admin/constants/sizes.dart';
import 'package:onldocc_admin/features/event/models/event_model.dart';
import 'package:onldocc_admin/features/event/view/event_screen.dart';
import 'package:onldocc_admin/injicare_color.dart';
import 'package:onldocc_admin/palette.dart';

class UploadQuizEventWidget extends StatefulWidget {
  final Function(String) updateQuiz;
  final Function(String) updateAnswer;
  final bool edit;
  final EventModel? eventModel;

  const UploadQuizEventWidget({
    super.key,
    required this.updateQuiz,
    required this.updateAnswer,
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
  @override
  void initState() {
    super.initState();
    if (widget.edit && widget.eventModel != null) {}
  }

  @override
  void dispose() {
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
                          ? widget.eventModel?.quizOne.toString()
                          : null,
                      onChanged: (value) {
                        if (value.isNotEmpty) {
                          widget.updateQuiz(value);
                        }
                      },
                      textAlignVertical: TextAlignVertical.top,
                      style: contentTextStyle,
                      decoration: InputDecoration(
                        isDense: true,
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.3),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            Sizes.size20,
                          ),
                        ),
                        hintText: "이탈리아의 수도는?",
                        hintStyle: contentTextStyle.copyWith(
                          color: InjicareColor().gray50,
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
                            color: Palette().darkBlue.withOpacity(0.5),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            Sizes.size20,
                          ),
                          borderSide: BorderSide(
                            width: 1.5,
                            color: Palette().darkBlue.withOpacity(0.5),
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: Sizes.size20,
                          vertical: Sizes.size20,
                        ),
                      ),
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
              child: Text(
                "3. 정답을 작성해주세요.",
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
                    width: 200,
                    child: TextFormField(
                      // expands: true,
                      maxLines: 1,
                      // minLines: null,
                      // controller: _descriptionControllder,
                      initialValue: widget.edit
                          ? widget.eventModel?.answerOne.toString()
                          : null,
                      onChanged: (value) {
                        if (value.isNotEmpty) {
                          widget.updateAnswer(value);
                        }
                      },

                      textAlignVertical: TextAlignVertical.top,
                      style: contentTextStyle,
                      decoration: InputDecoration(
                        isDense: true,
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.3),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            Sizes.size20,
                          ),
                        ),
                        hintText: "로마",
                        hintStyle: contentTextStyle.copyWith(
                          color: InjicareColor().gray50,
                        ),
                        errorStyle: headerTextStyle.copyWith(color: Colors.red),
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
                            color: Palette().darkBlue.withOpacity(0.5),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            Sizes.size20,
                          ),
                          borderSide: BorderSide(
                            width: 1.5,
                            color: Palette().darkBlue.withOpacity(0.5),
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: Sizes.size20,
                          vertical: Sizes.size20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        Gaps.v52,
      ],
    );
  }
}
