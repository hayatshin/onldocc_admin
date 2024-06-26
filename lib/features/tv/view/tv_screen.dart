import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:onldocc_admin/common/widgets/top_button.dart';
import 'package:onldocc_admin/constants/const.dart';
import 'package:onldocc_admin/features/login/view_models/admin_profile_view_model.dart';
import 'package:onldocc_admin/features/tv/models/tv_model.dart';
import 'package:onldocc_admin/features/tv/view_models/tv_view_model.dart';
import 'package:onldocc_admin/features/tv/widgets/edit_tv_widget.dart';
import 'package:onldocc_admin/features/tv/widgets/upload_tv_widget.dart';

import '../../../common/view/search_below.dart';
import '../../../constants/gaps.dart';
import '../../../constants/sizes.dart';

class TvScreen extends ConsumerStatefulWidget {
  static const routeURL = "/tv";
  static const routeName = "tv";

  const TvScreen({
    super.key,
  });

  @override
  ConsumerState<TvScreen> createState() => _TvScreenState();
}

class _TvScreenState extends ConsumerState<TvScreen> {
  List<TvModel> _tvList = [];

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  final GlobalKey<OverlayState> overlayKey = GlobalKey<OverlayState>();
  OverlayEntry? overlayEntry;
  bool loadingFinished = false;

  void uploadVideoTap(
      BuildContext context, double totalWidth, double totalHeight) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      constraints: BoxConstraints(
        minWidth: totalWidth,
      ),
      builder: (context) {
        return UploadTvWidget(
          context: context,
          totalWidth: totalWidth,
          totalHeight: totalHeight,
          refreshScreen: getUserTvs,
        );
      },
    );
  }

  void editVideoTap(BuildContext context, double totalWidth, double totalHeight,
      TvModel tvModel) {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      constraints: BoxConstraints(
        minWidth: totalWidth,
      ),
      builder: (context) {
        return EditTvWidget(
          context: context,
          totalWidth: totalWidth,
          totalHeight: totalHeight,
          tvModel: tvModel,
          refreshScreen: getUserTvs,
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    if (selectContractRegion.value != null) {
      getUserTvs();
    }

    selectContractRegion.addListener(() async {
      if (mounted) {
        setState(() {
          loadingFinished = false;
        });

        await getUserTvs();
      }
    });
  }

  Future<void> getUserTvs() async {
    final tvList = await ref.read(tvProvider.notifier).getUserTvs();

    if (selectContractRegion.value!.subdistrictId == "") {
      if (mounted) {
        setState(() {
          loadingFinished = true;
          _tvList = tvList;
        });
      }
    } else {
      if (selectContractRegion.value!.contractCommunityId != "" &&
          selectContractRegion.value!.contractCommunityId != null) {
        final filterDataList = tvList
            .where((e) =>
                e.contractCommunityId ==
                selectContractRegion.value!.contractCommunityId)
            .toList();
        if (mounted) {
          setState(() {
            loadingFinished = true;
            _tvList = filterDataList;
          });
        }
      } else {
        final filterDataList = tvList
            .where((e) =>
                e.contractCommunityId == null || e.contractCommunityId == "")
            .toList();

        if (mounted) {
          setState(() {
            loadingFinished = true;
            _tvList = filterDataList;
          });
        }
      }
    }
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
                  TopButton(
                    text: "영상 올리기",
                    actionFunction: () => uploadVideoTap(
                      context,
                      size.width,
                      size.height,
                    ),
                  )
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
                      const Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: Sizes.size16,
                        ),
                        child: Row(
                          children: [
                            Expanded(
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
                            Expanded(
                              flex: 3,
                              child: Align(
                                alignment: Alignment.center,
                                child: Text(
                                  "썸네일",
                                  style: TextStyle(
                                    fontSize: Sizes.size12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: Align(
                                alignment: Alignment.center,
                                child: Text(
                                  "제목",
                                  style: TextStyle(
                                    fontSize: Sizes.size12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Align(
                                alignment: Alignment.center,
                                child: Text(
                                  "수정",
                                  style: TextStyle(
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
                      Expanded(
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: _tvList.length,
                          itemBuilder: (context, index) {
                            // final uri = UriData.fromString(_tvList[index].link);
                            // print("uri -> $uri");
                            // VideoPlayerController videoPlayercontrollder =
                            //     VideoPlayerController.networkUrl(uri.uri)
                            //       ..initialize();

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
                                      child: Text(
                                        (index + 1).toString(),
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
                                  flex: 3,
                                  child: Padding(
                                    padding: const EdgeInsets.all(
                                      Sizes.size3,
                                    ),
                                    child: Align(
                                      alignment: Alignment.center,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(
                                          Sizes.size5,
                                        ),
                                        child: _tvList[index].videoType ==
                                                "youtube"
                                            ? SizedBox(
                                                width: 150,
                                                height: 100,
                                                child: Image.network(
                                                  _tvList[index].thumbnail,
                                                  fit: BoxFit.cover,
                                                ),
                                              )
                                            : Container(
                                                width: 150,
                                                height: 100,
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                    border: Border.all(
                                                      color:
                                                          Colors.grey.shade200,
                                                    )),
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(3),
                                                  child: Center(
                                                    child: Flexible(
                                                      child: Text(
                                                        "파일 형식은 썸네일이 제공되지 않습니다.",
                                                        textAlign:
                                                            TextAlign.center,
                                                        overflow: TextOverflow
                                                            .visible,
                                                        style: TextStyle(
                                                          color: Colors
                                                              .grey.shade500,
                                                          fontSize:
                                                              Sizes.size12,
                                                        ),
                                                        maxLines: null,
                                                        softWrap: true,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
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
                                      child: Text(
                                        _tvList[index].title,
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
                                    child: MouseRegion(
                                      cursor: SystemMouseCursors.click,
                                      child: GestureDetector(
                                        onTap: () => editVideoTap(
                                          context,
                                          size.width,
                                          size.height,
                                          _tvList[index],
                                        ),
                                        child: const Icon(
                                          Icons.edit,
                                          size: Sizes.size16,
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
    );
  }
}
