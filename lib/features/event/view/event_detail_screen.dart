import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:onldocc_admin/common/view/csv.dart';
import 'package:onldocc_admin/common/view/search_below.dart';
import 'package:onldocc_admin/constants/gaps.dart';
import 'package:onldocc_admin/constants/sizes.dart';
import 'package:onldocc_admin/features/event/models/event_user_model.dart';
import 'package:onldocc_admin/features/event/view_models/event_view_model.dart';
import 'package:onldocc_admin/utils.dart';
import 'package:universal_html/html.dart';

class EventDetailScreen extends ConsumerStatefulWidget {
  final String? eventId;
  const EventDetailScreen({
    super.key,
    required this.eventId,
  });

  @override
  ConsumerState<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends ConsumerState<EventDetailScreen>
    with SingleTickerProviderStateMixin {
  final searchHeight = 35;
  List<EventUserModel> _participantsList = [];
  final List<String> _listHeader = [
    "#",
    "이름",
    "나이",
    "성별",
    "핸드폰 번호",
    "거주 지역",
    "참여일",
    "점수",
    "달성 여부"
  ];
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimtaion;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(-1, 0),
      end: Offset.zero,
    ).animate(_animationController);
    _animationController.forward();

    _fadeAnimtaion =
        Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  List<dynamic> exportToList(EventUserModel eventUserModel, int index) {
    return [
      (index + 1).toString(),
      eventUserModel.name,
      eventUserModel.age,
      eventUserModel.gender,
      eventUserModel.phone,
      eventUserModel.fullRegion,
      convertTimettampToString(eventUserModel.participateDate!),
      eventUserModel.userPoint.toString(),
      eventUserModel.goalOrNot! ? "달성" : "미달성",
    ];
  }

  List<List<dynamic>> exportToFullList(List<EventUserModel?> participantsList) {
    List<List<dynamic>> list = [];

    list.add(_listHeader);

    for (int i = 0; i < participantsList.length; i++) {
      final itemList = exportToList(participantsList[i]!, i);
      list.add(itemList);
    }
    return list;
  }

  void generateUserCsv(String eventTitle) {
    final csvData = exportToFullList(_participantsList);

    String csvContent = '';
    for (var row in csvData) {
      for (var i = 0; i < row.length; i++) {
        if (row[i].toString().contains(',')) {
          csvContent += '"${row[i]}"';
        } else {
          csvContent += row[i];
        }
        // csvContent += row[i].toString();

        if (i != row.length - 1) {
          csvContent += ',';
        }
      }
      csvContent += '\n';
    }
    final currentDate = DateTime.now();
    final formatDate =
        "${currentDate.year}-${currentDate.month}-${currentDate.day}";

    String fileName = "오늘도청춘 행사 $eventTitle.csv";

    final encodedUri = Uri.dataFromString(
      csvContent,
      encoding: Encoding.getByName("utf-8"),
    ).toString();
    final anchor = AnchorElement(href: encodedUri)
      ..setAttribute('download', fileName)
      ..click();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: ref
          .read(eventProvider.notifier)
          .getCertainEventModel(widget.eventId!),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final eventData = snapshot.data;
          return Scaffold(
            body: Column(
              children: [
                Csv(
                  generateCsv: () => generateUserCsv(eventData.title!),
                  rankingType: "event",
                  userName: eventData!.title!,
                ),
                SearchBelow(
                  child: Column(
                    children: [
                      Gaps.v32,
                      IntrinsicHeight(
                        child: Center(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              FadeTransition(
                                opacity: _fadeAnimtaion,
                                child: SlideTransition(
                                  position: _slideAnimation,
                                  child: SizedBox(
                                    width: 300,
                                    height: 400,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(
                                        Sizes.size10,
                                      ),
                                      child: Image.network(
                                        eventData.missionImage!,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Gaps.h40,
                              SizedBox(
                                width: 400,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Text(
                                      eventData.description!
                                          .replaceAll('\\n', '\n'),
                                      overflow: TextOverflow.visible,
                                      style: const TextStyle(
                                        fontSize: Sizes.size14,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                    Gaps.v32,
                                    Divider(
                                      color: Colors.grey.shade300,
                                      height: 1,
                                    ),
                                    Gaps.v32,
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Icon(
                                          Icons.check_circle_outline_rounded,
                                          color: Colors.grey.shade500,
                                          size: Sizes.size20,
                                        ),
                                        Gaps.h16,
                                        RichText(
                                          textAlign: TextAlign.center,
                                          text: TextSpan(
                                            text: "주최기관:  ",
                                            style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              fontSize: Sizes.size15,
                                              color: Colors.grey.shade800,
                                            ),
                                            children: [
                                              TextSpan(
                                                text: eventData.community,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w400,
                                                  fontSize: Sizes.size15,
                                                  color: Colors.grey.shade800,
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                        Gaps.h20,
                                        CircleAvatar(
                                          radius: 15,
                                          backgroundImage: NetworkImage(
                                            eventData.communityLogo!,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Gaps.v10,
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.check_circle_outline_rounded,
                                          color: Colors.grey.shade500,
                                          size: Sizes.size20,
                                        ),
                                        Gaps.h16,
                                        RichText(
                                          textAlign: TextAlign.center,
                                          text: TextSpan(
                                            text: "시작일:  ",
                                            style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              fontSize: Sizes.size15,
                                              color: Colors.grey.shade800,
                                            ),
                                            children: [
                                              TextSpan(
                                                text: eventData.startPeriod,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w400,
                                                  fontSize: Sizes.size15,
                                                  color: Colors.grey.shade800,
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    Gaps.v10,
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.check_circle_outline_rounded,
                                          color: Colors.grey.shade500,
                                          size: Sizes.size20,
                                        ),
                                        Gaps.h16,
                                        RichText(
                                          textAlign: TextAlign.center,
                                          text: TextSpan(
                                            text: "종료일:  ",
                                            style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              fontSize: Sizes.size15,
                                              color: Colors.grey.shade800,
                                            ),
                                            children: [
                                              TextSpan(
                                                text: eventData.endPeriod,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w400,
                                                  fontSize: Sizes.size15,
                                                  color: Colors.grey.shade800,
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    Gaps.v10,
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.check_circle_outline_rounded,
                                          color: Colors.grey.shade500,
                                          size: Sizes.size20,
                                        ),
                                        Gaps.h16,
                                        RichText(
                                          textAlign: TextAlign.center,
                                          text: TextSpan(
                                            text: "목표 점수:  ",
                                            style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              fontSize: Sizes.size15,
                                              color: Colors.grey.shade800,
                                            ),
                                            children: [
                                              TextSpan(
                                                text: "${eventData.goalScore}점",
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w400,
                                                  fontSize: Sizes.size15,
                                                  color: Colors.grey.shade800,
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    Gaps.v10,
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.check_circle_outline_rounded,
                                          color: Colors.grey.shade500,
                                          size: Sizes.size20,
                                        ),
                                        Gaps.h16,
                                        RichText(
                                          textAlign: TextAlign.center,
                                          text: TextSpan(
                                            text: "달성자 수 제한:  ",
                                            style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              fontSize: Sizes.size15,
                                              color: Colors.grey.shade800,
                                            ),
                                            children: [
                                              TextSpan(
                                                text: eventData.prizeWinners ==
                                                        0
                                                    ? "무제한"
                                                    : "${eventData.prizeWinners}명",
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w400,
                                                  fontSize: Sizes.size15,
                                                  color: Colors.grey.shade800,
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    Gaps.v10,
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.check_circle_outline_rounded,
                                          color: Colors.grey.shade500,
                                          size: Sizes.size20,
                                        ),
                                        Gaps.h16,
                                        RichText(
                                          textAlign: TextAlign.center,
                                          text: TextSpan(
                                            text: "진행 상황:  ",
                                            style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              fontSize: Sizes.size15,
                                              color: Colors.grey.shade800,
                                            ),
                                            children: [
                                              TextSpan(
                                                text: eventData.state,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w400,
                                                  fontSize: Sizes.size15,
                                                  color: Colors.grey.shade800,
                                                ),
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
                        ),
                      ),
                      Gaps.v52,
                      FutureBuilder(
                        future: ref
                            .read(eventProvider.notifier)
                            .getCertainEventParticipants(eventData.documentId!,
                                eventData.goalScore!, eventData.endPeriod!),
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                          } else if (snapshot.hasData) {
                            List<EventUserModel> participants = snapshot.data!;
                            _participantsList = participants;
                            return DataTable(
                              columns: const [
                                DataColumn(
                                  label: Text(
                                    "#",
                                    style: TextStyle(
                                      fontSize: Sizes.size12,
                                    ),
                                  ),
                                ),
                                DataColumn(
                                  label: Text(
                                    "이름",
                                    style: TextStyle(
                                      fontSize: Sizes.size12,
                                    ),
                                  ),
                                ),
                                DataColumn(
                                  label: Text(
                                    "나이",
                                    style: TextStyle(
                                      fontSize: Sizes.size12,
                                    ),
                                  ),
                                ),
                                DataColumn(
                                  label: Text(
                                    "성별",
                                    style: TextStyle(
                                      fontSize: Sizes.size12,
                                    ),
                                  ),
                                ),
                                DataColumn(
                                  label: Text(
                                    "핸드폰 번호",
                                    style: TextStyle(
                                      fontSize: Sizes.size12,
                                    ),
                                  ),
                                ),
                                DataColumn(
                                  label: Text(
                                    "거주 지역",
                                    style: TextStyle(
                                      fontSize: Sizes.size12,
                                    ),
                                  ),
                                ),
                                DataColumn(
                                  label: Text(
                                    "참여일",
                                    style: TextStyle(
                                      fontSize: Sizes.size12,
                                    ),
                                  ),
                                ),
                                DataColumn(
                                  label: Text(
                                    "점수",
                                    style: TextStyle(
                                      fontSize: Sizes.size12,
                                    ),
                                  ),
                                ),
                                DataColumn(
                                  label: Text(
                                    "달성 여부",
                                    style: TextStyle(
                                      fontSize: Sizes.size12,
                                    ),
                                  ),
                                ),
                              ],
                              rows: [
                                for (var i = 0; i < participants.length; i++)
                                  DataRow(
                                    cells: [
                                      DataCell(
                                        Text(
                                          (i + 1).toString(),
                                          style: const TextStyle(
                                            fontSize: Sizes.size12,
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        Text(
                                          participants[i].name!,
                                          style: const TextStyle(
                                            fontSize: Sizes.size12,
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        Text(
                                          participants[i].age!,
                                          style: const TextStyle(
                                            fontSize: Sizes.size12,
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        Text(
                                          participants[i].gender!,
                                          style: const TextStyle(
                                            fontSize: Sizes.size12,
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        Text(
                                          participants[i].phone!,
                                          style: const TextStyle(
                                            fontSize: Sizes.size12,
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        Text(
                                          participants[i].fullRegion!,
                                          style: const TextStyle(
                                            fontSize: Sizes.size12,
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        Text(
                                          convertTimettampToString(
                                              participants[i].participateDate!),
                                          style: const TextStyle(
                                            fontSize: Sizes.size12,
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        Text(
                                          participants[i].userPoint.toString(),
                                          style: const TextStyle(
                                            fontSize: Sizes.size12,
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        Text(
                                          participants[i].goalOrNot!
                                              ? "달성"
                                              : "미달성",
                                          style: const TextStyle(
                                            fontSize: Sizes.size12,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                              ],
                            );
                          }
                          return Center(
                            child: CircularProgressIndicator.adaptive(
                              backgroundColor: Theme.of(context).primaryColor,
                            ),
                          );
                        },
                      )
                    ],
                  ),
                ),
              ],
            ),
          );
        }
        return CircularProgressIndicator.adaptive(
          backgroundColor: Theme.of(context).primaryColor,
        );
      },
    );
  }
}
