import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:onldocc_admin/common/view/csv.dart';
import 'package:onldocc_admin/common/view_models/menu_notifier.dart';
import 'package:onldocc_admin/constants/gaps.dart';
import 'package:onldocc_admin/constants/sizes.dart';
import 'package:onldocc_admin/features/event/models/event_model.dart';
import 'package:onldocc_admin/features/users/view/users_screen.dart';
import 'package:onldocc_admin/injicare_color.dart';
import 'package:onldocc_admin/palette.dart';

class EventDetailTemplate extends ConsumerWidget {
  final EventModel eventModel;
  final Function() generateCsv;
  final Widget child;
  const EventDetailTemplate({
    super.key,
    required this.eventModel,
    required this.generateCsv,
    required this.child,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TextStyle headerTextStyle = TextStyle(
      fontSize: Sizes.size13,
      fontWeight: FontWeight.w600,
      color: Palette().darkGray,
    );

    final TextStyle contentTextStyle = TextStyle(
      fontSize: Sizes.size12,
      fontWeight: FontWeight.w500,
      color: Palette().darkGray,
    );
    final size = MediaQuery.of(context).size;

    return Container(
      width: size.width,
      height: size.height,
      decoration: BoxDecoration(
        color: Palette().bgLightBlue,
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 30,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Gaps.v20,
              Csv(
                generateCsv: generateCsv,
                rankingType: "event",
                userName: eventModel.title,
                menu: menuList[4],
              ),
              Gaps.v40,
              SizedBox(
                height: 250,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      width: 250,
                      height: 250,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        clipBehavior: Clip.hardEdge,
                        child: eventModel.eventImage != ""
                            ? Image.network(
                                eventModel.eventImage,
                                fit: BoxFit.fill,
                              )
                            : Container(),
                      ),
                    ),
                    Gaps.h40,
                    SizedBox(
                      width: 180,
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const EventHeader(headerText: "행사 개요"),
                            Row(
                              children: [
                                SelectableText(
                                  "주최기관: ",
                                  style: headerTextStyle,
                                ),
                                SelectableText(
                                  eventModel.orgName!.split(' ').last,
                                  style: headerTextStyle.copyWith(
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                            Gaps.v10,
                            Row(
                              children: [
                                SelectableText(
                                  "시작일:  ",
                                  style: headerTextStyle,
                                ),
                                SelectableText(
                                  eventModel.startDate,
                                  style: headerTextStyle.copyWith(
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                            Gaps.v10,
                            Row(
                              children: [
                                SelectableText(
                                  "종료일:  ",
                                  style: headerTextStyle,
                                ),
                                SelectableText(
                                  eventModel.endDate,
                                  style: headerTextStyle.copyWith(
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                            Gaps.v10,
                            if (eventModel.eventType == "targetScore")
                              Column(
                                children: [
                                  Row(
                                    children: [
                                      SelectableText(
                                        "목표 점수:  ",
                                        style: headerTextStyle,
                                      ),
                                      SelectableText(
                                        "${eventModel.targetScore}점",
                                        style: headerTextStyle.copyWith(
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Gaps.v10,
                                ],
                              ),
                            if (eventModel.achieversNumber != 0)
                              Column(
                                children: [
                                  Row(
                                    children: [
                                      SelectableText(
                                        "달성자 수 제한:  ",
                                        style: headerTextStyle,
                                      ),
                                      SelectableText(
                                        "${eventModel.achieversNumber}명",
                                        style: headerTextStyle.copyWith(
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Gaps.v10,
                                ],
                              ),
                            Row(
                              children: [
                                Row(
                                  children: [
                                    SelectableText(
                                      "진행 상황:  ",
                                      style: headerTextStyle,
                                    ),
                                    SelectableText(
                                      "${eventModel.state}",
                                      style: headerTextStyle.copyWith(
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    Column(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 30,
                            ),
                            child: Container(
                              width: 1,
                              color: InjicareColor().secondary20,
                            ),
                          ),
                        )
                      ],
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const EventHeader(headerText: "설명"),
                          Expanded(
                            child: SingleChildScrollView(
                              child: SelectableText(
                                eventModel.description.replaceAll('\\n', '\n'),
                                // softWrap: true,
                                style: headerTextStyle.copyWith(
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Gaps.v40,
              child,
              Gaps.v40,
            ],
          ),
        ),
      ),
    );
  }
}

class EventHeader extends StatelessWidget {
  final String headerText;
  const EventHeader({
    super.key,
    required this.headerText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: InjicareColor().secondary20.withOpacity(0.5),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 3,
                ),
                child: SelectableText(
                  headerText,
                  style: contentTextStyle.copyWith(
                    color: InjicareColor().gray80,
                  ),
                ),
              ),
            ),
          ],
        ),
        Gaps.v20,
      ],
    );
  }
}
