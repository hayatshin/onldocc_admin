import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:onldocc_admin/common/view/skeleton_loading_screen.dart';
import 'package:onldocc_admin/constants/gaps.dart';
import 'package:onldocc_admin/constants/sizes.dart';
import 'package:onldocc_admin/features/event/models/event_model.dart';
import 'package:onldocc_admin/features/event/models/participant_model.dart';
import 'package:onldocc_admin/features/event/template/event_detail_template.dart';
import 'package:onldocc_admin/features/event/view_models/event_view_model.dart';
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
    "#",
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
              child: _initializeParticipants
                  ? Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(
                          Sizes.size20,
                        ),
                      ),
                      child: SizedBox(
                        width: size.width,
                        height: size.height,
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: Sizes.size20,
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 1,
                                    child: Align(
                                      alignment: Alignment.center,
                                      child: SelectableText(
                                        "#",
                                        style: _headerTextStyle,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Align(
                                      alignment: Alignment.center,
                                      child: SelectableText(
                                        "이름",
                                        style: _headerTextStyle,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Align(
                                      alignment: Alignment.center,
                                      child: SelectableText(
                                        "연령",
                                        style: _headerTextStyle,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Align(
                                      alignment: Alignment.center,
                                      child: SelectableText(
                                        "성별",
                                        style: _headerTextStyle,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Align(
                                      alignment: Alignment.center,
                                      child: SelectableText(
                                        "핸드폰 번호",
                                        style: _headerTextStyle,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Align(
                                      alignment: Alignment.center,
                                      child: SelectableText(
                                        "참여일",
                                        style: _headerTextStyle,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 3,
                                    child: Align(
                                      alignment: Alignment.center,
                                      child: SelectableText(
                                        "작품명",
                                        style: _headerTextStyle,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Align(
                                      alignment: Alignment.center,
                                      child: SelectableText(
                                        "사진",
                                        style: _headerTextStyle,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Divider(
                              color: Colors.grey.shade200,
                            ),
                            Gaps.v16,
                            Expanded(
                              child: ListView.builder(
                                shrinkWrap: true,
                                itemCount: _participants.length,
                                itemBuilder: (context, index) {
                                  return Row(
                                    children: [
                                      Expanded(
                                        flex: 1,
                                        child: Padding(
                                          padding: const EdgeInsets.all(
                                            Sizes.size3,
                                          ),
                                          child: Align(
                                            alignment: Alignment.center,
                                            child: SelectableText(
                                              (index + 1).toString(),
                                              // softWrap: true,
                                              // overflow: TextOverflow.ellipsis,
                                              style: _contentTextStyle,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Padding(
                                          padding: const EdgeInsets.all(
                                            Sizes.size3,
                                          ),
                                          child: Align(
                                            alignment: Alignment.center,
                                            child: SelectableText(
                                              _participants[index].name,
                                              // softWrap: true,
                                              // overflow: TextOverflow.ellipsis,
                                              style: _contentTextStyle,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 1,
                                        child: Padding(
                                          padding: const EdgeInsets.all(
                                            Sizes.size3,
                                          ),
                                          child: Align(
                                            alignment: Alignment.center,
                                            child: SelectableText(
                                              _participants[index].userAge,
                                              // softWrap: true,
                                              // overflow: TextOverflow.ellipsis,
                                              style: _contentTextStyle,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 1,
                                        child: Padding(
                                          padding: const EdgeInsets.all(
                                            Sizes.size3,
                                          ),
                                          child: Align(
                                            alignment: Alignment.center,
                                            child: SelectableText(
                                              _participants[index].gender,
                                              // softWrap: true,
                                              // overflow: TextOverflow.ellipsis,
                                              style: _contentTextStyle,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Padding(
                                          padding: const EdgeInsets.all(
                                            Sizes.size3,
                                          ),
                                          child: Align(
                                            alignment: Alignment.center,
                                            child: SelectableText(
                                              _participants[index].phone,
                                              // softWrap: true,
                                              // overflow: TextOverflow.ellipsis,
                                              style: _contentTextStyle,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Padding(
                                          padding: const EdgeInsets.all(
                                            Sizes.size3,
                                          ),
                                          child: Align(
                                            alignment: Alignment.center,
                                            child: SelectableText(
                                              secondsToStringDiaryTimeLine(
                                                  _participants[index]
                                                      .createdAt),
                                              // softWrap: true,
                                              // overflow: TextOverflow.ellipsis,
                                              style: _contentTextStyle,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 3,
                                        child: Padding(
                                          padding: const EdgeInsets.all(
                                            Sizes.size3,
                                          ),
                                          child: Align(
                                            alignment: Alignment.center,
                                            child: SelectableText(
                                              _participants[index].photoTitle ??
                                                  "",
                                              // softWrap: true,
                                              // overflow: TextOverflow.ellipsis,
                                              style: _contentTextStyle,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Padding(
                                          padding: const EdgeInsets.all(
                                            Sizes.size3,
                                          ),
                                          child: MouseRegion(
                                            cursor: SystemMouseCursors.click,
                                            child: GestureDetector(
                                              onTap: () =>
                                                  _showEnlargePhotoImage(
                                                      context,
                                                      _participants[index]
                                                          .photo),
                                              child: Align(
                                                alignment: Alignment.center,
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                    Sizes.size5,
                                                  ),
                                                  child: SizedBox(
                                                    width: 150,
                                                    height: 100,
                                                    child: Image.network(
                                                      _participants[index]
                                                              .photo ??
                                                          "",
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),
                            Gaps.v16,
                          ],
                        ),
                      ),
                    )
                  : const SkeletonLoadingScreen(),
            );
          },
        )
      ],
    );
  }
}
