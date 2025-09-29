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

class EventDetailPhotoScreen extends ConsumerStatefulWidget {
  final String? eventId;
  final EventModel? eventModel;
  const EventDetailPhotoScreen({
    super.key,
    required this.eventId,
    required this.eventModel,
  });

  @override
  ConsumerState<EventDetailPhotoScreen> createState() =>
      _EventDetailPointScreenState();
}

class _EventDetailPointScreenState
    extends ConsumerState<EventDetailPhotoScreen> {
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
    "번호",
    "이름",
    "연령",
    "성별",
    "핸드폰 번호",
    "참여일",
    "작품명",
    "사진",
  ];

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  final GlobalKey<OverlayState> overlayKey = GlobalKey<OverlayState>();
  OverlayEntry? overlayEntry;

  @override
  void initState() {
    super.initState();
    _initializePariticants();
  }

  @override
  void dispose() {
    _removeDeleteOverlay();

    super.dispose();
  }

  void _removeDeleteOverlay() {
    overlayEntry?.remove();
    overlayEntry = null;
  }

  void _showEnlargePhotoImage(BuildContext context, String? photo) async {
    _removeDeleteOverlay();
    if (photo == null) return;
    final size = MediaQuery.of(context).size;

    overlayEntry = OverlayEntry(
      builder: (context) => Positioned.fill(
        child: Material(
          color: Colors.black54,
          child: Stack(
            children: [
              Positioned(
                left: 0,
                right: 0,
                top: 0,
                bottom: 0,
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: size.width * 0.8),
                  child: Image.network(photo),
                ),
              ),
              Positioned(
                left: 50,
                top: 50,
                child: Row(
                  children: [
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: () {
                          _removeDeleteOverlay();
                        },
                        child: const Icon(
                          Icons.close_rounded,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
    Overlay.of(context, debugRequiredFor: widget).insert(overlayEntry!);
  }

  List<String> _exportToList(ParticipantModel participantModel, int index) {
    return [
      (index + 1).toString(),
      participantModel.name.toString(),
      participantModel.userAge.toString(),
      participantModel.gender.toString(),
      participantModel.phone.toString(),
      secondsToStringLine(participantModel.createdAt),
      participantModel.photoTitle ?? "",
      "사진",
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

  void _generateExcel() {
    final csvData = _exportToFullList(_participants);
    String fileName =
        "인지케어 행사 ${_eventModel?.title} ${todayToStringDot()}.xlsx";
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

    setState(() {
      _participants = participants;
      _initializeParticipants = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Overlay(
      initialEntries: [
        OverlayEntry(
          builder: (context) {
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
                                      "번호",
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
                                      "작품명",
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
                                      borderRadius: const BorderRadius.only(
                                        topRight: Radius.circular(16),
                                      ),
                                      border: Border.all(
                                        width: 2,
                                        color: const Color(0xFFF3F6FD),
                                      )),
                                  child: Center(
                                    child: Text(
                                      "사진",
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
                                height: 150,
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
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 5),
                                        child: SelectableText(
                                          _participants[i].name,
                                          style: contentTextStyle,
                                          textAlign: TextAlign.center,
                                          maxLines: 1,
                                          // overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: SelectableText(
                                        "${_participants[i].userAge}세",
                                        style: contentTextStyle,
                                        textAlign: TextAlign.center,
                                        maxLines: 1,
                                        // overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: SelectableText(
                                        _participants[i].gender,
                                        style: contentTextStyle,
                                        textAlign: TextAlign.center,
                                        maxLines: 1,
                                        // overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: SelectableText(
                                        _participants[i].phone,
                                        style: contentTextStyle,
                                        textAlign: TextAlign.center,
                                        maxLines: 1,
                                        // overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    if (_eventModel != null &&
                                        _eventModel!.allUsers)
                                      Expanded(
                                        flex: 1,
                                        child: FutureBuilder(
                                          future: ref
                                              .read(contractRepo)
                                              .convertSubdistrictIdToName(
                                                  _participants[i]
                                                      .subdistrictId),
                                          builder: (context, snapshot) {
                                            final subdistrictName =
                                                snapshot.data ?? "";

                                            return SelectableText(
                                              subdistrictName,
                                              style: contentTextStyle,
                                              textAlign: TextAlign.center,
                                              maxLines: 1,
                                              // overflow: TextOverflow.ellipsis,
                                            );
                                          },
                                        ),
                                      ),
                                    Expanded(
                                      flex: 1,
                                      child: SelectableText(
                                        secondsToStringLine(
                                            _participants[i].createdAt),
                                        style: contentTextStyle,
                                        textAlign: TextAlign.center,
                                        maxLines: 1,
                                        // overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: SelectableText(
                                        _participants[i].photoTitle ?? "",
                                        style: contentTextStyle,
                                        textAlign: TextAlign.center,
                                        maxLines: 1,
                                        // overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: gestureDetectorWithMouseClick(
                                          function: () =>
                                              _showEnlargePhotoImage(context,
                                                  _participants[i].photo),
                                          child: Center(
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                              child: SizedBox(
                                                width: 150,
                                                height: 100,
                                                child: Image.network(
                                                    _participants[i].photo ??
                                                        ""),
                                              ),
                                            ),
                                          )),
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
          },
        )
      ],
    );
  }
}
