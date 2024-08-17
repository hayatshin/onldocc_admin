import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:onldocc_admin/common/view_a/default_screen.dart';
import 'package:onldocc_admin/common/view_models/menu_notifier.dart';
import 'package:onldocc_admin/common/widgets/report_button.dart';
import 'package:onldocc_admin/features/login/view_models/admin_profile_view_model.dart';
import 'package:onldocc_admin/features/tv/models/tv_model.dart';
import 'package:onldocc_admin/features/tv/view_models/tv_view_model.dart';
import 'package:onldocc_admin/features/tv/widgets/upload_tv_widget.dart';
import 'package:onldocc_admin/palette.dart';

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
          pcontext: context,
          edit: false,
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
        return UploadTvWidget(
          pcontext: context,
          edit: true,
          tvModel: tvModel,
          refreshScreen: getUserTvs,
        );
        // return EditTvWidget(
        //   context: context,
        //   totalWidth: totalWidth,
        //   totalHeight: totalHeight,
        //   tvModel: tvModel,
        //   refreshScreen: getUserTvs,
        // );
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
    return Overlay(
      initialEntries: [
        OverlayEntry(
          builder: (context) => DefaultScreen(
            menu: menuList[7],
            child: SizedBox(
              width: size.width,
              height: size.height,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ReportButton(
                        iconExists: false,
                        buttonText: "영상 올리기",
                        buttonColor: Palette().darkPurple,
                        action: () => uploadVideoTap(
                          context,
                          size.width,
                          size.height,
                        ),
                      ),
                    ],
                  ),
                  Gaps.v40,
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(
                          Sizes.size20,
                        ),
                      ),
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
                                    child: Text(
                                      "#",
                                      style: _headerTextStyle,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Align(
                                    alignment: Alignment.center,
                                    child: Text(
                                      "썸네일",
                                      style: _headerTextStyle,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 3,
                                  child: Align(
                                    alignment: Alignment.center,
                                    child: Text(
                                      "제목",
                                      style: _headerTextStyle,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Align(
                                    alignment: Alignment.center,
                                    child: Text(
                                      "수정",
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
                              itemCount: _tvList.length,
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
                                          child: Text(
                                            (index + 1).toString(),
                                            softWrap: true,
                                            overflow: TextOverflow.ellipsis,
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
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              Sizes.size5,
                                            ),
                                            child: SizedBox(
                                              width: 150,
                                              height: 100,
                                              child: Image.network(
                                                _tvList[index].thumbnail,
                                                fit: BoxFit.cover,
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
                                            style: _contentTextStyle,
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
                                            onTap: () => editVideoTap(
                                              context,
                                              size.width,
                                              size.height,
                                              _tvList[index],
                                            ),
                                            child: FaIcon(
                                              FontAwesomeIcons.pen,
                                              size: 14,
                                              color: Palette().darkGray,
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
                  ),
                ],
              ),
            ),
          ),
        )
      ],
    );
  }
}
