import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:onldocc_admin/common/repo/contract_config_repo.dart';
import 'package:onldocc_admin/common/view/csv.dart';
import 'package:onldocc_admin/common/view_models/menu_notifier.dart';
import 'package:onldocc_admin/constants/const.dart';
import 'package:onldocc_admin/constants/gaps.dart';
import 'package:onldocc_admin/constants/sizes.dart';
import 'package:onldocc_admin/features/event/models/event_model.dart';
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
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Gaps.v20,
              Csv(
                generateCsv: generateCsv,
                rankingType: "event",
                userName: eventModel.title,
                menu: menuList[4],
              ),
              Gaps.v40,
              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 200,
                    height: 250,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        width: 2,
                        color: Palette().lightGray,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      clipBehavior: Clip.hardEdge,
                      child: Image.network(
                        eventModel.eventImage,
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                  Gaps.h80,
                  SizedBox(
                    width: size.width * 0.3,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          eventModel.description.replaceAll('\\n', '\n'),
                          overflow: TextOverflow.visible,
                          style: headerTextStyle,
                        ),
                        Gaps.v32,
                        Divider(
                          color: InjicareColor().gray30,
                          thickness: 0.5,
                          endIndent: 10,
                        ),
                        Gaps.v32,
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            FutureBuilder(
                              future: ref
                                  .read(contractRepo)
                                  .convertSubdistrictIdToName(
                                      eventModel.orgSubdistrictId),
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  return RichText(
                                    textAlign: TextAlign.center,
                                    text: TextSpan(
                                      text: "주최기관:  ",
                                      style: headerTextStyle,
                                      children: [
                                        TextSpan(
                                          text: snapshot.data!,
                                          style: contentTextStyle,
                                        )
                                      ],
                                    ),
                                  );
                                }
                                return RichText(
                                  textAlign: TextAlign.center,
                                  text: TextSpan(
                                    text: "주최기관:  ",
                                    style: headerTextStyle,
                                    children: [
                                      TextSpan(
                                        text: "인지케어",
                                        style: contentTextStyle,
                                      )
                                    ],
                                  ),
                                );
                              },
                            ),
                            Gaps.h20,
                            CircleAvatar(
                              radius: 15,
                              backgroundImage: NetworkImage(
                                eventModel.orgImage != "" &&
                                        eventModel.orgImage != null
                                    ? eventModel.orgImage!
                                    : injicareAvatar,
                              ),
                            ),
                          ],
                        ),
                        Gaps.v10,
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(
                                text: "시작일:  ",
                                style: headerTextStyle,
                                children: [
                                  TextSpan(
                                    text: eventModel.startDate,
                                    style: contentTextStyle,
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                        Gaps.v10,
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(
                                text: "종료일:  ",
                                style: headerTextStyle,
                                children: [
                                  TextSpan(
                                    text: eventModel.endDate,
                                    style: contentTextStyle,
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                        Gaps.v10,
                        if (eventModel.eventType == "targetScore")
                          Column(
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  RichText(
                                    textAlign: TextAlign.center,
                                    text: TextSpan(
                                      text: "목표 점수:  ",
                                      style: headerTextStyle,
                                      children: [
                                        TextSpan(
                                          text: "${eventModel.targetScore}점",
                                          style: contentTextStyle,
                                        )
                                      ],
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
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  RichText(
                                    textAlign: TextAlign.center,
                                    text: TextSpan(
                                      text: "달성자 수 제한:  ",
                                      style: headerTextStyle,
                                      children: [
                                        TextSpan(
                                          text:
                                              "${eventModel.achieversNumber}명",
                                          style: contentTextStyle,
                                        )
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              Gaps.v10,
                            ],
                          ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(
                                text: "진행 상황:  ",
                                style: headerTextStyle,
                                children: [
                                  TextSpan(
                                    text: eventModel.state,
                                    style: contentTextStyle,
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  )
                ],
              ),
              Gaps.v96,
              child
            ],
          ),
        ),
      ),
    );
  }
}
