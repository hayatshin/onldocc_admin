import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:onldocc_admin/common/repo/contract_config_repo.dart';
import 'package:onldocc_admin/common/view/skeleton_loading_screen.dart';
import 'package:onldocc_admin/constants/sizes.dart';
import 'package:onldocc_admin/features/event/models/event_model.dart';
import 'package:onldocc_admin/features/event/models/participant_model.dart';
import 'package:onldocc_admin/features/event/template/event_detail_template.dart';
import 'package:onldocc_admin/features/event/view/event_detail_count_screen.dart';
import 'package:onldocc_admin/features/event/view_models/event_view_model.dart';
import 'package:onldocc_admin/features/users/view/users_screen.dart';
import 'package:onldocc_admin/injicare_color.dart';
import 'package:onldocc_admin/palette.dart';
import 'package:onldocc_admin/utils.dart';

class EventDetailMultipleScoresScreen extends ConsumerStatefulWidget {
  final String? eventId;
  final EventModel? eventModel;
  const EventDetailMultipleScoresScreen({
    super.key,
    required this.eventId,
    required this.eventModel,
  });

  @override
  ConsumerState<EventDetailMultipleScoresScreen> createState() =>
      _EventDetailMultipleScoresScreenState();
}

class _EventDetailMultipleScoresScreenState
    extends ConsumerState<EventDetailMultipleScoresScreen> {
  EventModel? _eventModel;
  final TextStyle _headerTextStyle = TextStyle(
    fontSize: Sizes.size13,
    fontWeight: FontWeight.w600,
    color: Palette().darkGray,
  );

  final TextStyle _contentTextStyle = TextStyle(
    fontSize: Sizes.size12,
    fontWeight: FontWeight.w500,
    color: Palette().darkGray,
  );

  List<ParticipantModel> _participants = [];
  bool _initializeParticipants = false;
  final List<String> _listHeader = [
    "#",
    "이름",
    "연령",
    "성별",
    "핸드폰 번호",
    "참여일",
    "점수",
    "달성 여부",
  ];

  @override
  void initState() {
    super.initState();
    _initializePariticants();
  }

  @override
  void dispose() {
    super.dispose();
  }

  List<String> _exportToList(ParticipantModel participantModel, int index) {
    return [
      (index + 1).toString(),
      participantModel.name.toString(),
      participantModel.userAge.toString(),
      participantModel.gender.toString(),
      participantModel.phone.toString(),
      secondsToStringLine(participantModel.createdAt),
      participantModel.userTotalPoint!.toString(),
      participantModel.userAchieveOrNot! ? "달성" : "미달성",
    ];
  }

  List<List<String>> _exportToFullList(
      List<ParticipantModel?> participantsList) {
    List<List<String>> list = [];

    list.add(_listHeader);

    for (int i = 0; i < participantsList.length; i++) {
      final itemList = _exportToList(participantsList[i]!, i);
      list.add(itemList);
    }
    return list;
  }

  // void generateUserCsv(String eventTitle) {
  //   final csvData = exportToFullList(_participants);

  //   String csvContent = '';
  //   for (var row in csvData) {
  //     for (var i = 0; i < row.length; i++) {
  //       if (row[i].toString().contains(',')) {
  //         csvContent += '"${row[i]}"';
  //       } else {
  //         csvContent += row[i].toString();
  //       }
  //       // csvContent += row[i].toString();

  //       if (i != row.length - 1) {
  //         csvContent += ',';
  //       }
  //     }
  //     csvContent += '\n';
  //   }
  //   final currentDate = DateTime.now();
  //   final formatDate =
  //       "${currentDate.year}-${currentDate.month.toString().padLeft(2, '0')}-${currentDate.day.toString().padLeft(2, '0')}";

  //   String fileName = "인지케어 행사 $eventTitle $formatDate.csv";

  //   final encodedUri = Uri.dataFromString(
  //     csvContent,
  //     encoding: Encoding.getByName("utf-8"),
  //   ).toString();
  //   final anchor = AnchorElement(href: encodedUri)
  //     ..setAttribute('download', fileName)
  //     ..click();
  // }

  void _generateExcel() {
    final csvData = _exportToFullList(_participants);
    String fileName =
        "인지케어 행사 ${_eventModel!.title} ${todayToStringDot()}.xlsx";
    exportExcel(csvData, fileName);
  }

  Future<void> _initializePariticants() async {
    final eventModel = widget.eventModel ??
        await ref.read(eventProvider.notifier).getCertainEvent(widget.eventId!);
    setState(() {
      _eventModel = eventModel;
    });
    final participants =
        await ref.read(eventProvider.notifier).getEventParticipants(eventModel);
    participants.sort((a, b) => b.userTotalPoint!.compareTo(a.userTotalPoint!));
    setState(() {
      _participants = participants;
      _initializeParticipants = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return EventDetailTemplate(
      eventModel: _eventModel ?? EventModel.empty(),
      generateCsv: _generateExcel,
      child: !_initializeParticipants
          ? const SkeletonLoadingScreen()
          : Column(
              children: [
                SizedBox(
                  height: eventTableTabHeight,
                  child: Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: Container(
                          decoration: BoxDecoration(
                              color: const Color(0xFFE9EDF9),
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(16),
                              ),
                              border: Border.all(
                                width: 1,
                                color: const Color(0xFFF3F6FD),
                              )),
                          child: Center(
                            child: Text(
                              "#",
                              style: contentTextStyle,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Container(
                          decoration: BoxDecoration(
                              color: const Color(0xFFE9EDF9),
                              border: Border.all(
                                width: 1,
                                color: const Color(0xFFF3F6FD),
                              )),
                          child: Center(
                            child: Text(
                              "이름",
                              style: contentTextStyle,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Container(
                          decoration: BoxDecoration(
                              color: const Color(0xFFE9EDF9),
                              border: Border.all(
                                width: 1,
                                color: const Color(0xFFF3F6FD),
                              )),
                          child: Center(
                            child: Text(
                              "연령",
                              style: contentTextStyle,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Container(
                          decoration: BoxDecoration(
                              color: const Color(0xFFE9EDF9),
                              border: Border.all(
                                width: 1,
                                color: const Color(0xFFF3F6FD),
                              )),
                          child: Center(
                            child: Text(
                              "성별",
                              style: contentTextStyle,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Container(
                          decoration: BoxDecoration(
                              color: const Color(0xFFE9EDF9),
                              border: Border.all(
                                width: 1,
                                color: const Color(0xFFF3F6FD),
                              )),
                          child: Center(
                            child: Text(
                              "핸드폰 번호",
                              style: contentTextStyle,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                      if (_eventModel != null && _eventModel!.allUsers)
                        Expanded(
                          flex: 1,
                          child: Container(
                            decoration: BoxDecoration(
                                color: const Color(0xFFE9EDF9),
                                border: Border.all(
                                  width: 1,
                                  color: const Color(0xFFF3F6FD),
                                )),
                            child: Center(
                              child: Text(
                                "지역",
                                style: contentTextStyle,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                      Expanded(
                        flex: 1,
                        child: Container(
                          decoration: BoxDecoration(
                              color: const Color(0xFFE9EDF9),
                              border: Border.all(
                                width: 1,
                                color: const Color(0xFFF3F6FD),
                              )),
                          child: Center(
                            child: Text(
                              "참여일",
                              style: contentTextStyle,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Container(
                          decoration: BoxDecoration(
                              color: const Color(0xFFE9EDF9),
                              border: Border.all(
                                width: 1,
                                color: const Color(0xFFF3F6FD),
                              )),
                          child: Center(
                            child: Text(
                              "행사 점수",
                              style: contentTextStyle,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Container(
                          decoration: BoxDecoration(
                              color: const Color(0xFFE9EDF9),
                              borderRadius: const BorderRadius.only(
                                topRight: Radius.circular(16),
                              ),
                              border: Border.all(
                                width: 2,
                                color: const Color(0xFFF3F6FD),
                              )),
                          child: Center(
                            child: Text(
                              "달성 여부",
                              style: contentTextStyle,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                for (int i = 0; i < _participants.length; i++)
                  Column(
                    children: [
                      SizedBox(
                        height: eventTableTabHeight,
                        child: Row(
                          children: [
                            Expanded(
                              flex: 1,
                              child: SelectableText(
                                "${i + 1}",
                                style: contentTextStyle,
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 5),
                                child: Text(
                                  _participants[i].name,
                                  style: contentTextStyle,
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Text(
                                "${_participants[i].userAge}세",
                                style: contentTextStyle,
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Text(
                                _participants[i].gender,
                                style: contentTextStyle,
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                _participants[i].phone,
                                style: contentTextStyle,
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (_eventModel != null && _eventModel!.allUsers)
                              Expanded(
                                flex: 1,
                                child: FutureBuilder(
                                  future: ref
                                      .read(contractRepo)
                                      .convertSubdistrictIdToName(
                                          _participants[i].subdistrictId),
                                  builder: (context, snapshot) {
                                    final subdistrictName = snapshot.data ?? "";

                                    return Text(
                                      subdistrictName,
                                      style: contentTextStyle,
                                      textAlign: TextAlign.center,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    );
                                  },
                                ),
                              ),
                            Expanded(
                              flex: 1,
                              child: Text(
                                secondsToStringLine(_participants[i].createdAt),
                                style: contentTextStyle,
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Text(
                                "${_participants[i].userTotalPoint}점",
                                style: contentTextStyle,
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Text(
                                _participants[i].userAchieveOrNot ?? false
                                    ? "달성"
                                    : "미달성",
                                style: contentTextStyle,
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 1,
                              color: InjicareColor().gray30,
                            ),
                          )
                        ],
                      )
                    ],
                  ),
              ],
            ),
    );
  }
}
