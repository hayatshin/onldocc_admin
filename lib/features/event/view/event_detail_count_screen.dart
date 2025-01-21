import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:onldocc_admin/common/repo/contract_config_repo.dart';
import 'package:onldocc_admin/common/view/skeleton_loading_screen.dart';
import 'package:onldocc_admin/constants/sizes.dart';
import 'package:onldocc_admin/features/event/models/event_model.dart';
import 'package:onldocc_admin/features/event/models/participant_model.dart';
import 'package:onldocc_admin/features/event/template/event_detail_template.dart';
import 'package:onldocc_admin/features/event/view_models/event_view_model.dart';
import 'package:onldocc_admin/palette.dart';
import 'package:onldocc_admin/utils.dart';

class EventDetailCountScreen extends ConsumerStatefulWidget {
  final String? eventId;
  final EventModel? eventModel;
  const EventDetailCountScreen({
    super.key,
    required this.eventId,
    required this.eventModel,
  });

  @override
  ConsumerState<EventDetailCountScreen> createState() =>
      _EventDetailCountScreenState();
}

class _EventDetailCountScreenState
    extends ConsumerState<EventDetailCountScreen> {
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
    "나이",
    "성별",
    "핸드폰 번호",
    "참여일",
    "달성 여부"
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
      child: _initializeParticipants
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
                  dividerThickness: 0.1,
                  border: TableBorder(
                    borderRadius: BorderRadius.circular(20),
                    top: BorderSide(
                      color: Palette().darkPurple,
                      width: 1.5,
                    ),
                    bottom: BorderSide(
                      color: Palette().darkPurple,
                      width: 1.5,
                    ),
                    horizontalInside: BorderSide(
                      color: Palette().lightGray,
                      width: 0.1,
                    ),
                  ),
                  columns: [
                    DataColumn(
                      label: Text(
                        "#",
                        style: _headerTextStyle,
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        "이름",
                        style: _headerTextStyle,
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        "나이",
                        style: _headerTextStyle,
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        "성별",
                        style: _headerTextStyle,
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        "핸드폰 번호",
                        style: _headerTextStyle,
                      ),
                    ),
                    if (_eventModel != null && _eventModel!.allUsers)
                      DataColumn(
                        label: Text(
                          "지역",
                          style: _headerTextStyle,
                        ),
                      ),
                    DataColumn(
                      label: Text(
                        "참여일",
                        style: _headerTextStyle,
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        "달성 여부",
                        style: _headerTextStyle,
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        "선물 신청",
                        style: _headerTextStyle,
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
                              style: _contentTextStyle,
                            ),
                          ),
                          DataCell(
                            Text(
                              _participants[i].name,
                              style: _contentTextStyle,
                            ),
                          ),
                          DataCell(
                            Text(
                              _participants[i].userAge,
                              style: _contentTextStyle,
                            ),
                          ),
                          DataCell(
                            Text(
                              _participants[i].gender,
                              style: _contentTextStyle,
                            ),
                          ),
                          DataCell(
                            Text(
                              _participants[i].phone,
                              style: _contentTextStyle,
                            ),
                          ),
                          if (_eventModel != null && _eventModel!.allUsers)
                            DataCell(
                              FutureBuilder(
                                future: ref
                                    .read(contractRepo)
                                    .convertSubdistrictIdToName(
                                        _participants[i].subdistrictId),
                                builder: (context, snapshot) {
                                  final subdistrictName = snapshot.data ?? "";
                                  return Text(
                                    subdistrictName,
                                    style: _contentTextStyle,
                                  );
                                },
                              ),
                            ),
                          DataCell(
                            Text(
                              secondsToStringLine(_participants[i].createdAt),
                              style: _contentTextStyle,
                            ),
                          ),
                          DataCell(
                            Text(
                              _participants[i].userAchieveOrNot! ? "달성" : "미달성",
                              style: _contentTextStyle,
                            ),
                          ),
                          DataCell(
                            Text(
                              _participants[i].gift ? "○" : "",
                              style: _contentTextStyle,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            )
          : const SkeletonLoadingScreen(),
    );
  }
}
