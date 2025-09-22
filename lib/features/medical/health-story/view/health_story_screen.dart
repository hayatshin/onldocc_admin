import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:onldocc_admin/common/view_a/default_screen.dart';
import 'package:onldocc_admin/common/view_models/menu_notifier.dart';
import 'package:onldocc_admin/constants/gaps.dart';
import 'package:onldocc_admin/features/medical/health-story/models/health_story_model.dart';
import 'package:onldocc_admin/features/medical/health-story/repo/health_story_repo.dart';
import 'package:onldocc_admin/features/medical/health-story/view_models/health_story_view_model.dart';
import 'package:onldocc_admin/features/medical/health-story/widgets/upload_health_story.dart';
import 'package:onldocc_admin/features/notice/views/notice_screen.dart';
import 'package:onldocc_admin/features/users/view/users_screen.dart';
import 'package:onldocc_admin/injicare_color.dart';
import 'package:onldocc_admin/injicare_font.dart';
import 'package:onldocc_admin/utils.dart';

class HealthStoryScreen extends ConsumerStatefulWidget {
  static const routeURL = "/health-story";
  static const routeName = "healthstory";
  const HealthStoryScreen({super.key});

  @override
  ConsumerState<HealthStoryScreen> createState() => _HealthStoryScreenState();
}

class _HealthStoryScreenState extends ConsumerState<HealthStoryScreen> {
  final double _tabHeight = 110;
  GlobalKey<OverlayState> overlayKey = GlobalKey<OverlayState>();
  OverlayEntry? overlayEntry;

  static const int _itemsPerPage = 5;
  int _currentPage = 0;
  int _pageIndication = 0;
  int _totalListLength = 0;
  int _endPage = 0;

  final List _initialList = [];
  List _stories = [];

  @override
  void initState() {
    super.initState();
    _initializeStories();
  }

  Future<void> _initializeStories() async {
    final stories =
        await ref.read(healthStoryProvider.notifier).fetchAllHealthStories();
    int endPage = stories.length ~/ _itemsPerPage + 1;

    setState(() {
      _stories = stories;
      _totalListLength = stories.length;
      _endPage = endPage;
    });
  }

  void _editHealthStory(HealthStoryModel model) {
    showRightModal(
      context,
      UploadHealthStory(
        model: model,
        updateHealthStories: _initializeStories,
      ),
    );
  }

  void _uploadHealthStory() {
    showRightModal(
      context,
      UploadHealthStory(
        updateHealthStories: _initializeStories,
      ),
    );
  }

  void removeDeleteOverlay() {
    overlayEntry?.remove();
    overlayEntry = null;
  }

  void _showDeleteOverlay(HealthStoryModel model) async {
    removeDeleteOverlay();

    overlayEntry = OverlayEntry(builder: (context) {
      return deleteTitleOverlay(model.title, removeDeleteOverlay,
          () => _deleteHealthStory(model.healthStoryId));
    });
    Overlay.of(context, debugRequiredFor: widget, rootOverlay: true)
        .insert(overlayEntry!);
  }

  Future<void> _deleteHealthStory(String healthStoryId) async {
    await ref.read(healthStoryRepo).deleteHealthStory(healthStoryId);
    if (!mounted) return;
    removeDeleteOverlay();
    showTopCompletingSnackBar(context, "성공적으로 콘텐츠를 삭제하였습니다.");
    setState(() {
      _stories.removeWhere((user) => user.healthStoryId == healthStoryId);
    });
  }

  void _updateUserlistPerPage() {
    int startPage = _currentPage * _itemsPerPage;
    int endPage = startPage + _itemsPerPage > _initialList.length
        ? _initialList.length
        : startPage + _itemsPerPage;

    setState(() {
      _stories = _initialList.sublist(startPage, endPage);
    });
  }

  void _previousPage() {
    if (_pageIndication == 0) return;

    setState(() {
      _pageIndication--;
      _currentPage = _pageIndication * 5;
    });
    _updateUserlistPerPage();
  }

  void _nextPage() {
    int endIndication = _endPage ~/ 5;
    if (_pageIndication >= endIndication) return;
    setState(() {
      _pageIndication++;
      _currentPage = _pageIndication * 5;
    });
    _updateUserlistPerPage();
  }

  void _changePage(int s) {
    setState(() {
      _currentPage = s - 1;
    });
    _updateUserlistPerPage();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultScreen(
        menu: menuList[12],
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HeaderWithButton(
                buttonAction: _uploadHealthStory,
                buttonText: "콘텐츠 등록하기",
                listCount: _totalListLength,
                svgName: "video",
              ),
              SizedBox(
                height: 50,
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
                      flex: 10,
                      child: Container(
                        decoration: BoxDecoration(
                            color: const Color(0xFFE9EDF9),
                            border: Border.all(
                              width: 1,
                              color: const Color(0xFFF3F6FD),
                            )),
                        child: Center(
                          child: Text(
                            "제목",
                            style: contentTextStyle,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Container(
                        decoration: BoxDecoration(
                            color: const Color(0xFFE9EDF9),
                            border: Border.all(
                              width: 1,
                              color: const Color(0xFFF3F6FD),
                            )),
                        child: Center(
                          child: Text(
                            "이미지",
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
                            "작성일자",
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
                          ),
                          borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(16),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            "",
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
              if (_stories.isNotEmpty)
                for (int i = 0; i < _stories.length; i++)
                  Column(
                    children: [
                      SizedBox(
                        height: _tabHeight,
                        child: Row(
                          children: [
                            Expanded(
                              flex: 1,
                              child: Text(
                                "${_currentPage * _itemsPerPage + 1 + i}",
                                style: contentTextStyle,
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Expanded(
                              flex: 10,
                              child: SelectableText(
                                _stories[i].title,
                                style: contentTextStyle,
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: Center(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: SizedBox(
                                    width: 140,
                                    height: 90,
                                    child: Image.network(
                                      _stories[i].thumbnail,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: SelectableText(
                                createdAtToDateDot(_stories[i].createdAt),
                                style: contentTextStyle,
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      MouseRegion(
                                        cursor: SystemMouseCursors.click,
                                        child: GestureDetector(
                                          onTap: () =>
                                              _editHealthStory(_stories[i]),
                                          child: const EditButton(),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Gaps.v3,
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      MouseRegion(
                                        cursor: SystemMouseCursors.click,
                                        child: GestureDetector(
                                          onTap: () =>
                                              _showDeleteOverlay(_stories[i]),
                                          child: const DeleteButton(),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
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
              Gaps.v40,
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: _previousPage,
                      child: ColorFiltered(
                        colorFilter: ColorFilter.mode(
                            _pageIndication == 0
                                ? InjicareColor().gray50
                                : InjicareColor().gray100,
                            BlendMode.srcIn),
                        child: SvgPicture.asset(
                          "assets/svg/chevron-left.svg",
                        ),
                      ),
                    ),
                  ),
                  Gaps.h10,
                  for (int s = (_pageIndication * 5 + 1);
                      s <
                          (s >= _endPage + 1
                              ? _endPage + 1
                              : (_pageIndication * 5 + 1) + 5);
                      s++)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Gaps.h10,
                        MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: GestureDetector(
                            onTap: () => _changePage(s),
                            child: Text(
                              "$s",
                              style: InjicareFont().body07.copyWith(
                                  color: _currentPage + 1 == s
                                      ? InjicareColor().gray100
                                      : InjicareColor().gray60,
                                  fontWeight: _currentPage + 1 == s
                                      ? FontWeight.w900
                                      : FontWeight.w400),
                            ),
                          ),
                        ),
                        Gaps.h10,
                      ],
                    ),
                  Gaps.h10,
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: _nextPage,
                      child: ColorFiltered(
                        colorFilter: ColorFilter.mode(
                            _pageIndication + 5 > _endPage
                                ? InjicareColor().gray50
                                : InjicareColor().gray100,
                            BlendMode.srcIn),
                        child: SvgPicture.asset(
                          "assets/svg/chevron-right.svg",
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ));
  }
}

String createdAtToDateDot(int seconds) {
  final milliseconds = seconds * 1000;
  DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(milliseconds);
  final f = DateFormat('yy.MM.dd');
  return f.format(dateTime);
}
