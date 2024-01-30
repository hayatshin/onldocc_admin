import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/_internal/file_picker_web.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:onldocc_admin/common/view/search_below.dart';
import 'package:onldocc_admin/features/event/models/event_model.dart';
import 'package:onldocc_admin/features/event/view_models/event_view_model.dart';
import 'package:onldocc_admin/features/notice/view_models/notice_view_model.dart';
import 'package:onldocc_admin/features/notice/widgets/edit_notification_widget.dart';
import 'package:onldocc_admin/features/notice/widgets/upload_notification_widget.dart';
import 'package:onldocc_admin/features/ranking/models/diary_model.dart';
import 'package:onldocc_admin/utils.dart';

import '../../../constants/gaps.dart';
import '../../../constants/sizes.dart';

class NoticeScreen extends ConsumerStatefulWidget {
  static const routeURL = "/notice";
  static const routeName = "notice";
  const NoticeScreen({super.key});

  @override
  ConsumerState<NoticeScreen> createState() => _NoticeScreenState();
}

class _NoticeScreenState extends ConsumerState<NoticeScreen> {
  double searchHeight = 35;
  bool _feedHover = false;

  GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  GlobalKey<OverlayState> overlayKey = GlobalKey<OverlayState>();
  OverlayEntry? overlayEntry;

  List<DiaryModel> _noticeList = [];

  void uploadNotification(
      BuildContext context, double totalWidth, double totalHeight) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      constraints: BoxConstraints(
        minWidth: totalWidth,
      ),
      builder: (context) {
        return UploadNotificationWidget(
          context: context,
          totalWidth: totalWidth,
          totalHeight: totalHeight,
          refreshScreen: refreshScreen,
        );
      },
    );
  }

  void editNotification(
    BuildContext context,
    double totalWidth,
    double totalHeight,
    DiaryModel diaryModel,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      constraints: BoxConstraints(
        minWidth: totalWidth,
      ),
      builder: (context) {
        return EditNotificationWidget(
          context: context,
          totalWidth: totalWidth,
          totalHeight: totalHeight,
          diaryModel: diaryModel,
          refreshScreen: refreshScreen,
        );
      },
    );
  }

  void refreshScreen() {
    fetchAllNoticies();
  }

  @override
  void initState() {
    super.initState();
    fetchAllNoticies();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> fetchAllNoticies() async {
    final noticeList =
        await ref.read(noticeProvider.notifier).fetchAllNotices();
    setState(() {
      _noticeList = noticeList;
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Column(
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
                  Visibility(
                    visible: size.width > 700,
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      onHover: (event) {
                        setState(() {
                          _feedHover = true;
                        });
                      },
                      onExit: (event) {
                        setState(() {
                          _feedHover = false;
                        });
                      },
                      child: GestureDetector(
                        onTap: () => uploadNotification(
                            context, size.width, size.height),
                        child: Container(
                          width: 150,
                          height: searchHeight,
                          decoration: BoxDecoration(
                            color: _feedHover
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
                              "피드 공지 올리기",
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
                              flex: 5,
                              child: Align(
                                alignment: Alignment.center,
                                child: Text(
                                  "공지",
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
                                  "이미지",
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
                                  "작성일",
                                  style: TextStyle(
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
                          itemCount: _noticeList.length,
                          itemBuilder: (context, index) {
                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
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
                                  flex: 5,
                                  child: Padding(
                                    padding: const EdgeInsets.all(
                                      Sizes.size10,
                                    ),
                                    child: Align(
                                      alignment: Alignment.topLeft,
                                      child: Text(
                                        _noticeList[index].todayDiary,
                                        softWrap: true,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: Sizes.size12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Padding(
                                    padding: const EdgeInsets.all(
                                      Sizes.size10,
                                    ),
                                    child: Align(
                                      alignment: Alignment.center,
                                      child: _noticeList[index].images!.isEmpty
                                          ? const Text(
                                              "-",
                                              softWrap: true,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                // color: Colors.white,
                                                fontSize: Sizes.size12,
                                              ),
                                            )
                                          : SizedBox(
                                              width: 100,
                                              height: 100,
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                  Sizes.size5,
                                                ),
                                                clipBehavior: Clip.hardEdge,
                                                child: Image.network(
                                                  _noticeList[index].images![0],
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                    ),
                                  ),
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
                                        secondsToStringLine(
                                            _noticeList[index].createdAt),
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
                                  flex: 1,
                                  child: MouseRegion(
                                    cursor: SystemMouseCursors.click,
                                    child: GestureDetector(
                                      onTap: () => editNotification(
                                          context,
                                          size.width,
                                          size.height,
                                          _noticeList[index]),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: Sizes.size10,
                                        ),
                                        child: CircleAvatar(
                                          backgroundColor: Colors.grey.shade200,
                                          child: Icon(
                                            Icons.chevron_right,
                                            size: Sizes.size16,
                                            color:
                                                Theme.of(context).primaryColor,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                )
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
    );
  }
}
