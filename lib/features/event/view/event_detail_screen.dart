import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:onldocc_admin/common/repo/contract_config_repo.dart';
import 'package:onldocc_admin/common/view/csv.dart';
import 'package:onldocc_admin/common/view/search_below.dart';
import 'package:onldocc_admin/common/view/skeleton_loading_screen.dart';
import 'package:onldocc_admin/constants/const.dart';
import 'package:onldocc_admin/constants/gaps.dart';
import 'package:onldocc_admin/constants/sizes.dart';
import 'package:onldocc_admin/features/event/models/event_model.dart';
import 'package:onldocc_admin/features/event/models/participant_model.dart';
import 'package:onldocc_admin/features/event/view_models/event_view_model.dart';
import 'package:onldocc_admin/utils.dart';
import 'package:universal_html/html.dart';

class EventDetailScreen extends ConsumerStatefulWidget {
  final EventModel? eventModel;
  const EventDetailScreen({
    super.key,
    required this.eventModel,
  });

  @override
  ConsumerState<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends ConsumerState<EventDetailScreen> {
  List<ParticipantModel> _participants = [];
  bool _initializeParticipants = false;
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

  @override
  void initState() {
    super.initState();
    initializePariticants();
  }

  @override
  void dispose() {
    super.dispose();
  }

  List<dynamic> exportToList(ParticipantModel participantModel, int index) {
    return [
      (index + 1).toString(),
      participantModel.name,
      participantModel.userAge,
      participantModel.gender,
      participantModel.phone,
      participantModel.smallRegion,
      secondsToStringLine(participantModel.createdAt),
      participantModel.totalPoint.toString(),
      participantModel.totalPoint >= widget.eventModel!.targetScore
          ? "달성"
          : "미달성",
    ];
  }

  List<List<dynamic>> exportToFullList(
      List<ParticipantModel?> participantsList) {
    List<List<dynamic>> list = [];

    list.add(_listHeader);

    for (int i = 0; i < participantsList.length; i++) {
      final itemList = exportToList(participantsList[i]!, i);
      list.add(itemList);
    }
    return list;
  }

  void generateUserCsv(String eventTitle) {
    final csvData = exportToFullList(_participants);

    String csvContent = '';
    for (var row in csvData) {
      for (var i = 0; i < row.length; i++) {
        if (row[i].toString().contains(',')) {
          csvContent += '"${row[i]}"';
        } else {
          csvContent += row[i].toString();
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
        "${currentDate.year}-${currentDate.month.toString().padLeft(2, '0')}-${currentDate.day.toString().padLeft(2, '0')}";

    String fileName = "인지케어 행사 $eventTitle $formatDate.csv";

    final encodedUri = Uri.dataFromString(
      csvContent,
      encoding: Encoding.getByName("utf-8"),
    ).toString();
    final anchor = AnchorElement(href: encodedUri)
      ..setAttribute('download', fileName)
      ..click();
  }

  Future<void> initializePariticants() async {
    final participants = await ref
        .read(eventProvider.notifier)
        .getEventParticipants(widget.eventModel!);
    participants.sort((a, b) => b.totalPoint.compareTo(a.totalPoint));

    setState(() {
      _participants = participants;
      _initializeParticipants = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: Column(
        children: [
          Csv(
            generateCsv: () => generateUserCsv(widget.eventModel!.title),
            rankingType: "event",
            userName: widget.eventModel!.title,
          ),
          SearchBelow(
            size: size,
            child: Container(
              color: Colors.grey.shade50,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Gaps.v32,
                  IntrinsicHeight(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: Sizes.size20,
                        horizontal: 200,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Container(
                            width: 250,
                            height: 300,
                            decoration: BoxDecoration(
                                border: Border.all(
                              width: 2,
                            )),
                            child: Image.network(
                              widget.eventModel!.eventImage,
                              fit: BoxFit.fill,
                            ),
                          ),
                          Gaps.h80,
                          SizedBox(
                            width: 400,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  widget.eventModel!.description
                                      .replaceAll('\\n', '\n'),
                                  overflow: TextOverflow.visible,
                                  style: const TextStyle(
                                    fontSize: Sizes.size14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Gaps.v32,
                                const Divider(
                                  color: Colors.black,
                                  thickness: 1.5,
                                  endIndent: 10,
                                ),
                                Gaps.v32,
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Icon(
                                      Icons.check_circle_outline_rounded,
                                      color: Theme.of(context).primaryColor,
                                      size: Sizes.size20,
                                    ),
                                    Gaps.h16,
                                    FutureBuilder(
                                      future: ref
                                          .read(contractRepo)
                                          .convertSubdistrictIdToName(widget
                                              .eventModel!.orgSubdistrictId),
                                      builder: (context, snapshot) {
                                        if (snapshot.hasData) {
                                          return RichText(
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
                                                  text: snapshot.data!,
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w400,
                                                    fontSize: Sizes.size15,
                                                    color: Colors.grey.shade800,
                                                  ),
                                                )
                                              ],
                                            ),
                                          );
                                        }
                                        return RichText(
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
                                                text: "인지케어",
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w400,
                                                  fontSize: Sizes.size15,
                                                  color: Colors.grey.shade800,
                                                ),
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
                                        widget.eventModel!.orgImage != "" &&
                                                widget.eventModel!.orgImage !=
                                                    null
                                            ? widget.eventModel!.orgImage!
                                            : injicareAvatar,
                                      ),
                                    ),
                                  ],
                                ),
                                Gaps.v10,
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.check_circle_outline_rounded,
                                      color: Theme.of(context).primaryColor,
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
                                            text: widget.eventModel!.startDate,
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
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.check_circle_outline_rounded,
                                      color: Theme.of(context).primaryColor,
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
                                            text: widget.eventModel!.endDate,
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
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.check_circle_outline_rounded,
                                      color: Theme.of(context).primaryColor,
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
                                            text:
                                                "${widget.eventModel!.targetScore}점",
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
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.check_circle_outline_rounded,
                                      color: Theme.of(context).primaryColor,
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
                                            text: widget.eventModel!
                                                        .achieversNumber ==
                                                    0
                                                ? "무제한"
                                                : "${widget.eventModel!.achieversNumber}명",
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
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.check_circle_outline_rounded,
                                      color: Colors.blue,
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
                                            text: widget.eventModel!.state,
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
                  _initializeParticipants
                      ? Center(
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                width: 1.0,
                                color: Colors.black,
                              ),
                              borderRadius: BorderRadius.circular(
                                Sizes.size5,
                              ),
                              color: Colors.white,
                            ),
                            child: DataTable(
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
                                for (var i = 0; i < _participants.length; i++)
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
                                          _participants[i].name,
                                          style: const TextStyle(
                                            fontSize: Sizes.size12,
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        Text(
                                          _participants[i].userAge,
                                          style: const TextStyle(
                                            fontSize: Sizes.size12,
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        Text(
                                          _participants[i].gender,
                                          style: const TextStyle(
                                            fontSize: Sizes.size12,
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        Text(
                                          _participants[i].phone,
                                          style: const TextStyle(
                                            fontSize: Sizes.size12,
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        Text(
                                          _participants[i].smallRegion,
                                          style: const TextStyle(
                                            fontSize: Sizes.size12,
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        Text(
                                          secondsToStringLine(
                                              _participants[i].createdAt),
                                          style: const TextStyle(
                                            fontSize: Sizes.size12,
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        Text(
                                          _participants[i]
                                              .totalPoint
                                              .toString(),
                                          style: const TextStyle(
                                            fontSize: Sizes.size12,
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        Text(
                                          _participants[i].totalPoint >=
                                                  widget.eventModel!.targetScore
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
                            ),
                          ),
                        )
                      : const SkeletonLoadingScreen()
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
