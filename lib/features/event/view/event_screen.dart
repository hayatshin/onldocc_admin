import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:onldocc_admin/common/repo/contract_config_repo.dart';
import 'package:onldocc_admin/common/view/search_below.dart';
import 'package:onldocc_admin/common/widgets/loading_widget.dart';
import 'package:onldocc_admin/constants/const.dart';
import 'package:onldocc_admin/features/event/models/event_model.dart';
import 'package:onldocc_admin/features/event/repo/event_repo.dart';
import 'package:onldocc_admin/features/event/view_models/event_view_model.dart';
import 'package:onldocc_admin/features/event/widgets/edit_count_event_widget.dart';
import 'package:onldocc_admin/features/event/widgets/edit_multiple_scores_event_widget.dart';
import 'package:onldocc_admin/features/event/widgets/edit_target_score_event_widget.dart';
import 'package:onldocc_admin/features/event/widgets/upload_event_widget.dart';
import 'package:onldocc_admin/features/login/view_models/admin_profile_view_model.dart';

import '../../../constants/gaps.dart';
import '../../../constants/sizes.dart';

class EventScreen extends ConsumerStatefulWidget {
  static const routeURL = "/event";
  static const routeName = "event";
  const EventScreen({super.key});

  @override
  ConsumerState<EventScreen> createState() => _EventScreenState();
}

class _EventScreenState extends ConsumerState<EventScreen> {
  bool _addEventHover = false;

  List<EventModel> eventList = [];
  bool loadingFinished = false;

  Map<String, dynamic> addedEventData = {};

  GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  void refreshScreen() {
    getUserEvents();
  }

  void addEventTap(
      BuildContext context, double totalWidth, double totalHeight) {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      constraints: BoxConstraints(
        minWidth: totalWidth,
      ),
      builder: (context) {
        return UploadEventWidget(
          context: context,
          totalWidth: totalWidth,
          totalHeight: totalHeight,
          refreshScreen: refreshScreen,
        );
      },
    );
  }

  void editEventTap(BuildContext context, double totalWidth, double totalHeight,
      EventModel eventModel) {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      constraints: BoxConstraints(
        minWidth: totalWidth,
      ),
      builder: (context) {
        if (eventModel.eventType == EventType.targetScore.name) {
          return EditTargetScoreEventWidget(
            context: context,
            totalWidth: totalWidth,
            totalHeight: totalHeight,
            eventModel: eventModel,
            refreshScreen: refreshScreen,
          );
        } else if (eventModel.eventType == EventType.multipleScores.name) {
          return EditMultipleScoresEventWidget(
            context: context,
            totalWidth: totalWidth,
            totalHeight: totalHeight,
            eventModel: eventModel,
            refreshScreen: refreshScreen,
          );
        } else {
          return EditCountEventWidget(
            context: context,
            totalWidth: totalWidth,
            totalHeight: totalHeight,
            eventModel: eventModel,
            refreshScreen: refreshScreen,
          );
        }
      },
    );
  }

  Future<void> getUserEvents() async {
    List<EventModel> dbeventList =
        await ref.read(eventProvider.notifier).getUserEvents();

    if (selectContractRegion.value!.subdistrictId == "") {
      if (mounted) {
        setState(() {
          loadingFinished = true;
          eventList = dbeventList;
        });
      }
    } else {
      if (selectContractRegion.value!.contractCommunityId != "" &&
          selectContractRegion.value!.contractCommunityId != null) {
        final filterDataList = dbeventList
            .where((e) =>
                e.contractCommunityId ==
                selectContractRegion.value!.contractCommunityId)
            .toList();
        if (mounted) {
          setState(() {
            loadingFinished = true;
            eventList = filterDataList;
          });
        }
      } else {
        final filterDataList = dbeventList
            .where((e) =>
                e.contractCommunityId == null || e.contractCommunityId == "")
            .toList();
        if (mounted) {
          setState(() {
            loadingFinished = true;
            eventList = filterDataList;
          });
        }
      }
    }
  }

  void goDetailEvent(EventModel eventModel) {
    context.go("/event/${eventModel.eventId}", extra: eventModel);
  }

  @override
  void initState() {
    super.initState();
    if (selectContractRegion.value != null) {
      getUserEvents();
    }

    selectContractRegion.addListener(() async {
      if (mounted) {
        await getUserEvents();
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return loadingFinished
        ? Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.grey.shade200,
                    ),
                  ),
                ),
                child: SizedBox(
                  height: searchHeight + Sizes.size40,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: Sizes.size10,
                      horizontal: Sizes.size32,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Gaps.h20,
                        Visibility(
                          visible: size.width > 550,
                          child: MouseRegion(
                            cursor: SystemMouseCursors.click,
                            onHover: (event) {
                              setState(() {
                                _addEventHover = true;
                              });
                            },
                            onExit: (event) {
                              setState(() {
                                _addEventHover = false;
                              });
                            },
                            child: GestureDetector(
                              onTap: () =>
                                  addEventTap(context, size.width, size.height),
                              child: Container(
                                width: 150,
                                height: searchHeight,
                                decoration: BoxDecoration(
                                  color: _addEventHover
                                      ? Colors.grey.shade200
                                      : Colors.white,
                                  border: Border.all(
                                    color: Colors.grey.shade800,
                                  ),
                                  borderRadius: BorderRadius.circular(
                                    Sizes.size10,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    "행사 추가하기",
                                    style: TextStyle(
                                      color: Colors.grey.shade800,
                                      fontSize: Sizes.size14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SearchBelow(
                size: size,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: Sizes.size40,
                        horizontal: Sizes.size20,
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(
                            Sizes.size10,
                          ),
                        ),
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: Sizes.size16,
                              ),
                              child: Row(
                                children: [
                                  const Expanded(
                                    flex: 1,
                                    child: Align(
                                      alignment: Alignment.center,
                                      child: Text(
                                        "#",
                                        style: TextStyle(
                                          // color: Colors.white,
                                          fontSize: Sizes.size12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const Expanded(
                                    flex: 3,
                                    child: Align(
                                      alignment: Alignment.center,
                                      child: Text(
                                        "행사",
                                        style: TextStyle(
                                          fontSize: Sizes.size12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const Expanded(
                                    flex: 5,
                                    child: Align(
                                      alignment: Alignment.center,
                                      child: Text(
                                        "설명",
                                        style: TextStyle(
                                          fontSize: Sizes.size12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const Expanded(
                                    flex: 2,
                                    child: Align(
                                      alignment: Alignment.center,
                                      child: Text(
                                        "주최 기관",
                                        style: TextStyle(
                                          fontSize: Sizes.size12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const Expanded(
                                    flex: 2,
                                    child: Align(
                                      alignment: Alignment.center,
                                      child: Text(
                                        "시작일",
                                        style: TextStyle(
                                          fontSize: Sizes.size12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const Expanded(
                                    flex: 2,
                                    child: Align(
                                      alignment: Alignment.center,
                                      child: Text(
                                        "종료일",
                                        style: TextStyle(
                                          fontSize: Sizes.size12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const Expanded(
                                    flex: 1,
                                    child: Align(
                                      alignment: Alignment.center,
                                      child: Text(
                                        "진행\n상황",
                                        style: TextStyle(
                                          // color: Colors.white,
                                          fontSize: Sizes.size12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const Expanded(
                                    flex: 1,
                                    child: Align(
                                      alignment: Alignment.center,
                                      child: Text(
                                        "공개\n여부",
                                        style: TextStyle(
                                          // color: Colors.white,
                                          fontSize: Sizes.size12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Align(
                                      alignment: Alignment.center,
                                      child: Text(
                                        "수정",
                                        style: TextStyle(
                                          color: Theme.of(context).primaryColor,
                                          fontSize: Sizes.size12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Align(
                                      alignment: Alignment.center,
                                      child: Text(
                                        "선택",
                                        style: TextStyle(
                                          color: Theme.of(context).primaryColor,
                                          fontSize: Sizes.size12,
                                          fontWeight: FontWeight.w500,
                                        ),
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
                            SingleChildScrollView(
                              child: ListView.builder(
                                shrinkWrap: true,
                                itemCount: eventList.length,
                                itemBuilder: (context, index) {
                                  return Row(
                                    children: [
                                      Expanded(
                                        flex: 1,
                                        child: Padding(
                                          padding: const EdgeInsets.all(
                                            Sizes.size10,
                                          ),
                                          child: Align(
                                            alignment: Alignment.center,
                                            child: Text(
                                              (index + 1).toString(),
                                              style: const TextStyle(
                                                // color: Colors.white,
                                                fontSize: Sizes.size12,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 3,
                                        child: Padding(
                                          padding: const EdgeInsets.all(
                                            Sizes.size10,
                                          ),
                                          child: Align(
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              eventList[index].title,
                                              softWrap: true,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                // color: Colors.white,
                                                fontSize: Sizes.size12,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 5,
                                        child: Padding(
                                          padding: const EdgeInsets.all(
                                            Sizes.size10,
                                          ),
                                          child: Align(
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              eventList[index]
                                                  .description
                                                  .replaceAll('\\n', '\n'),
                                              softWrap: true,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                // color: Colors.white,
                                                fontSize: Sizes.size12,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      FutureBuilder(
                                        future: ref
                                            .read(contractRepo)
                                            .convertSubdistrictIdToName(
                                                eventList[index]
                                                    .orgSubdistrictId),
                                        builder: (context, snapshot) {
                                          if (snapshot.hasData) {
                                            return Expanded(
                                              flex: 2,
                                              child: Padding(
                                                padding: const EdgeInsets.all(
                                                  Sizes.size10,
                                                ),
                                                child: Align(
                                                  alignment:
                                                      Alignment.centerLeft,
                                                  child: Text(
                                                    snapshot.data!,
                                                    softWrap: true,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: const TextStyle(
                                                      // color: Colors.white,
                                                      fontSize: Sizes.size12,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            );
                                          }
                                          return const Expanded(
                                            flex: 2,
                                            child: Text(
                                              "-",
                                              style: TextStyle(
                                                fontSize: Sizes.size12,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          );
                                        },
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Padding(
                                          padding: const EdgeInsets.all(
                                            Sizes.size10,
                                          ),
                                          child: Align(
                                            alignment: Alignment.center,
                                            child: Text(
                                              eventList[index].startDate,
                                              softWrap: true,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                // color: Colors.white,
                                                fontSize: Sizes.size12,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Align(
                                          alignment: Alignment.center,
                                          child: Text(
                                            eventList[index].endDate,
                                            softWrap: true,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              // color: Colors.white,
                                              fontSize: Sizes.size12,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 1,
                                        child: Align(
                                          alignment: Alignment.center,
                                          child: Text(
                                            eventList[index].state!,
                                            style: const TextStyle(
                                              // color: Colors.white,
                                              fontSize: Sizes.size12,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 1,
                                        child: MouseRegion(
                                          cursor: SystemMouseCursors.click,
                                          child: GestureDetector(
                                            onTap: () async {
                                              await ref
                                                  .read(eventRepo)
                                                  .editEventAdminSecret(
                                                      eventList[index].eventId,
                                                      eventList[index]
                                                          .adminSecret);
                                              await getUserEvents();
                                            },
                                            child: Align(
                                              alignment: Alignment.center,
                                              child: Text(
                                                eventList[index].adminSecret
                                                    ? "비공개"
                                                    : "공개",
                                                style: const TextStyle(
                                                  // color: Colors.white,
                                                  fontSize: Sizes.size12,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 1,
                                        child: MouseRegion(
                                          cursor: SystemMouseCursors.click,
                                          child: GestureDetector(
                                            onTap: () => editEventTap(
                                              context,
                                              size.width,
                                              size.height,
                                              eventList[index],
                                            ),
                                            child: const Icon(
                                              Icons.edit,
                                              size: Sizes.size16,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 1,
                                        child: Align(
                                          alignment: Alignment.center,
                                          child: MouseRegion(
                                            cursor: SystemMouseCursors.click,
                                            child: GestureDetector(
                                              onTap: () => goDetailEvent(
                                                  eventList[index]),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  vertical: Sizes.size10,
                                                ),
                                                child: CircleAvatar(
                                                  backgroundColor:
                                                      Colors.grey.shade200,
                                                  child: Icon(
                                                    Icons.chevron_right,
                                                    size: Sizes.size16,
                                                    color: Theme.of(context)
                                                        .primaryColor,
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
                    );
                  },
                ),
              ),
            ],
          )
        : loadingWidget(context);
  }
}
