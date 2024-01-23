import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/_internal/file_picker_web.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:go_router/go_router.dart';
import 'package:onldocc_admin/common/view/error_screen.dart';
import 'package:onldocc_admin/common/view/search_below.dart';
import 'package:onldocc_admin/common/view_models/contract_config_view_model.dart';
import 'package:onldocc_admin/features/event/models/event_model.dart';
import 'package:onldocc_admin/features/event/repo/event_repo.dart';
import 'package:onldocc_admin/features/event/view_models/event_view_model.dart';
import 'package:onldocc_admin/features/login/models/admin_profile_model.dart';
import 'package:onldocc_admin/utils.dart';

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
  final double searchHeight = 35;
  final bool _feedHover = false;
  final bool _addEventHover = false;
  final bool _initialSetting = false;
  // final List<EventModel?> _eventDataList = [];
  final TextEditingController _titleControllder = TextEditingController();
  final TextEditingController _descriptionControllder = TextEditingController();
  final TextEditingController _goalScoreController = TextEditingController();
  final TextEditingController _prizewinnersControllder =
      TextEditingController();

  // 행사 추가하기
  final String _eventTitle = "";
  final String _eventDescription = "";

  PlatformFile? _eventImageFile;
  Uint8List? _eventImageBytes;

  DateTime? _eventStartDate;
  DateTime? _eventEndDate;

  final String _eventPrizeWinners = "";
  final String _eventGoalScore = "";

  Map<String, dynamic> addedEventData = {};
  final bool _enabledEventButton = false;

// 피드 공지 올리기
  final String _feedDescription = "";

  final List<PlatformFile> _feedImageFile = [];
  Uint8List? _feedImageBytes;
  final List<Uint8List> _feedImageArray = [];

  final bool _enabledFeedButton = false;

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  final GlobalKey<OverlayState> overlayKey = GlobalKey<OverlayState>();
  OverlayEntry? overlayEntry;

  Future<void> deleteEventFirebase(String documentId) async {
    AdminProfileModel data =
        await ref.read(contractConfigProvider.notifier).getMyAdminProfile();
    // final contractType = data.contractType;
    // final contractName = data.contractName;
    // late Map<String, dynamic> eventJson;

    // await ref.read(eventRepo).deleteEvent(documentId);
    // await ref
    //     .read(eventProvider.notifier)
    //     .getEventModels(contractType, contractName);
    removeDeleteOverlay();
  }

  Future<void> addEventFirebase() async {
    String? eventImgURL = await ref
        .read(eventRepo)
        .uploadEventImage(_eventImageBytes!, _eventTitle);

    if (eventImgURL != null) {
      // AdminProfileModel data =
      //     await ref.read(contractConfigProvider.notifier).getMyAdminProfile();
      // final contractType = data.contractType;
      // final contractName = data.contractName;
      // late Map<String, dynamic> eventJson;

      // if (contractType == "지역") {
      //   String? image = await ref.read(eventRepo).getRegionImage(contractName);
      //   eventJson = {
      //     "allUser": false,
      //     "description": _eventDescription,
      //     "documentId": DateTime.now().millisecondsSinceEpoch.toString(),
      //     "startPeriod": convertTimettampToStringDot(_eventStartDate!),
      //     "endPeriod": convertTimettampToStringDot(_eventEndDate!),
      //     "goalScore": int.parse(_eventGoalScore),
      //     "missionImage": eventImgURL,
      //     "prizeWinners": int.parse(_eventPrizeWinners),
      //     "state": "진행",
      //     "title": _eventTitle,
      //     "contractType": "region",
      //     "contractName": contractName,
      //     "contractLogo": image,
      //     "autoProgress": false,
      //   };
      // } else if (contractType == "기관") {
      //   String? image =
      //       await ref.read(eventRepo).getCommunityImage(contractName);

      //   eventJson = {
      //     "allUser": false,
      //     "description": _eventDescription,
      //     "documentId": DateTime.now().millisecondsSinceEpoch.toString(),
      //     "startPeriod": convertTimettampToStringDot(_eventStartDate!),
      //     "endPeriod": convertTimettampToStringDot(_eventEndDate!),
      //     "goalScore": int.parse(_eventGoalScore),
      //     "missionImage": eventImgURL,
      //     "prizeWinners": int.parse(_eventPrizeWinners),
      //     "state": "진행",
      //     "title": _eventTitle,
      //     "contractType": "community",
      //     "contractName": contractName,
      //     "contractLogo": image,
      //     "autoProgress": false,
      //   };
    } else {
      // 마스터
      // String? image =
      //     "https://firebasestorage.googleapis.com/v0/b/chungchunon-android-dd695.appspot.com/o/missions%2F%E1%84%8B%E1%85%A1%E1%84%8B%E1%85%B5%E1%84%8F%E1%85%A9%E1%86%AB_%E1%84%8B%E1%85%B5%E1%84%86%E1%85%B5%E1%84%8C%E1%85%B5_%E1%84%91%E1%85%B5%E1%86%BC%E1%84%8F%E1%85%B32.png?alt=media&token=0ffe5480-4d88-42c0-be29-f7d366bb62d5";
      // eventJson = {
      //   "allUser": true,
      //   "description": _eventDescription,
      //   "documentId": DateTime.now().millisecondsSinceEpoch.toString(),
      //   "startPeriod": convertTimettampToStringDot(_eventStartDate!),
      //   "endPeriod": convertTimettampToStringDot(_eventEndDate!),
      //   "goalScore": int.parse(_eventGoalScore),
      //   "missionImage": eventImgURL,
      //   "prizeWinners": int.parse(_eventPrizeWinners),
      //   "state": "진행",
      //   "title": _eventTitle,
      //   "contractType": "master",
      //   "contractName": contractName,
      //   "contractLogo": image,
      //   "autoProgress": false,
      // };
    }

    // await ref.read(eventRepo).saveEvent(eventJson);
    // await ref
    //     .read(eventProvider.notifier)
    //     .getEventModels(contractType, contractName);

    context.pop();
    showSnackBar(context, "행사가 추가되었습니다.");
  }

  Future<void> addFeedFirebase() async {
    // AdminProfileModel data =
    //     await ref.read(contractConfigProvider.notifier).getMyAdminProfile();
    // final contractType = data.contractType;
    // final contractName = data.contractName;

    // final contractTypeEng = contractType == "지역"
    //     ? "region"
    //     : contractType == "기관"
    //         ? "community"
    //         : "";

    // String userId = contractType == "마스터"
    //     ? "kakao:2358828971"
    //     : "notice:${contractTypeEng}_$contractName";
    // DateTime now = DateTime.now();
    // String nowString =
    //     "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
    // String diaryId = "${userId}_$nowString";

    // Map<String, dynamic> todayMood = {
    //   "description": "기뻐요",
    //   "image": 2131230971,
    //   "position": 0,
    // };

    // List<String> images =
    //     await ref.read(eventRepo).uploadFeedImage(_feedImageArray);

    // Map<String, dynamic> diaryModel = {
    //   "userId": userId,
    //   "diaryId": diaryId,
    //   "monthDate": "${now.year}-${now.month.toString().padLeft(2, '0')}",
    //   "timestamp": FieldValue.serverTimestamp(),
    //   "secret": false,
    //   "images": images,
    //   "todayMood": todayMood,
    //   "numLikes": 0,
    //   "numComments": 0,
    //   "todayDiary": _feedDescription,
    //   "blockedBy": [],
    //   "contractType": contractType,
    //   "contractName": contractName,
    // };
    // await ref.read(eventRepo).addNotification(userId, diaryId, diaryModel);

    // context.pop();
    // showSnackBar(context, "피드 공지가 올라갔습니다.");
  }

  Future<void> pickImageFromGallery(
      void Function(void Function()) setState) async {
    try {
      FilePickerResult? result = await FilePickerWeb.platform.pickFiles(
        type: FileType.image,
      );
      if (result == null) return;
      // setState(() {
      //   _eventImageFile = result.files.first;
      //   _eventImageBytes = _eventImageFile!.bytes!;

      //   _enabledEventButton = _eventTitle.isNotEmpty &&
      //       _eventDescription.isNotEmpty &&
      //       _eventImageBytes != null &&
      //       _eventPrizeWinners.isNotEmpty &&
      //       _eventGoalScore.isNotEmpty &&
      //       _eventStartDate != null &&
      //       _eventEndDate != null;
      // });
    } catch (e) {
      // ScaffoldMessenger.of(context).showSnackBar(
      //   const SnackBar(
      //     content: Text("오류가 발생했습니다."),
      //   ),
      // );
    }
  }

  Future<void> pickMultipleImagesFromGallery(
      void Function(void Function()) setState) async {
    try {
      FilePickerResult? result = await FilePickerWeb.platform.pickFiles(
        type: FileType.image,
      );
      if (result == null) return;
      // _feedImageFile = result.files;
      for (PlatformFile file in _feedImageFile) {
        _feedImageArray.add(file.bytes!);
      }
      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
    }
  }

  void selectStartPeriod(void Function(void Function()) setState) async {
    DateTime now = DateTime.now();
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year),
      lastDate: now,
    );

    if (picked != null) {
      setState(() {
        _eventStartDate = picked;

        // _enabledEventButton = _eventTitle.isNotEmpty &&
        //     _eventDescription.isNotEmpty &&
        //     _eventImageBytes != null &&
        //     _eventPrizeWinners.isNotEmpty &&
        //     _eventGoalScore.isNotEmpty &&
        //     _eventStartDate != null &&
        //     _eventEndDate != null;
      });
    }
  }

  void selectEndPeriod(void Function(void Function()) setState) async {
    DateTime now = DateTime.now();
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year),
      lastDate: now,
    );
    if (picked != null) {
      setState(() {
        _eventEndDate = picked;

        // _enabledEventButton = _eventTitle.isNotEmpty &&
        //     _eventDescription.isNotEmpty &&
        //     _eventImageBytes != null &&
        //     _eventPrizeWinners.isNotEmpty &&
        //     _eventGoalScore.isNotEmpty &&
        //     _eventStartDate != null &&
        //     _eventEndDate != null;
      });
    }
  }

  void feedUploadTap(
      BuildContext context, double totalWidth, double totalHeight) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      constraints: BoxConstraints(
        minWidth: totalWidth,
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              height: totalHeight * 0.8,
              width: totalWidth,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(Sizes.size10),
                  topRight: Radius.circular(Sizes.size10),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(
                  Sizes.size40,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        SizedBox(
                          width: 200,
                          height: 40,
                          child: ElevatedButton(
                            onPressed:
                                _enabledFeedButton ? addFeedFirebase : null,
                            style: ButtonStyle(
                              side:
                                  MaterialStateProperty.resolveWith<BorderSide>(
                                (states) {
                                  return BorderSide(
                                    color: _enabledFeedButton
                                        ? Theme.of(context).primaryColor
                                        : Colors.grey.shade800,
                                    width: 1,
                                  );
                                },
                              ),
                              backgroundColor: MaterialStateProperty.all(
                                Colors.white,
                              ),
                              surfaceTintColor: MaterialStateProperty.all(
                                _enabledFeedButton
                                    ? Theme.of(context).primaryColor
                                    : Colors.grey.shade800,
                              ),
                              shape: MaterialStateProperty.all<
                                  RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    Sizes.size10,
                                  ),
                                ),
                              ),
                            ),
                            child: Text(
                              "피드 공지 올리기",
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: _enabledFeedButton
                                    ? Theme.of(context).primaryColor
                                    : Colors.grey.shade800,
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                    Gaps.v52,
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                SizedBox(
                                  width: totalWidth * 0.1,
                                  height: 200,
                                  child: const Text(
                                    "공지 내용",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                    textAlign: TextAlign.start,
                                  ),
                                ),
                                Gaps.h32,
                                SizedBox(
                                  width: totalWidth * 0.7,
                                  height: 200,
                                  child: TextFormField(
                                    expands: true,
                                    maxLines: null,
                                    minLines: null,
                                    onFieldSubmitted: (value) {},
                                    onChanged: (value) {
                                      setState(() {
                                        // _feedDescription = value;

                                        // _enabledFeedButton =
                                        //     _feedDescription.isNotEmpty;
                                      });
                                    },
                                    controller: _descriptionControllder,
                                    textAlignVertical: TextAlignVertical.top,
                                    style: const TextStyle(
                                      fontSize: Sizes.size12,
                                      color: Colors.black87,
                                    ),
                                    decoration: InputDecoration(
                                      isDense: true,
                                      hintText: "",
                                      hintStyle: TextStyle(
                                        fontSize: Sizes.size12,
                                        color: Colors.grey.shade400,
                                        fontWeight: FontWeight.w300,
                                      ),
                                      filled: true,
                                      fillColor: Colors.grey.shade50,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(
                                          Sizes.size3,
                                        ),
                                      ),
                                      errorStyle: TextStyle(
                                        color: Theme.of(context).primaryColor,
                                      ),
                                      errorBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(
                                          Sizes.size3,
                                        ),
                                        borderSide: BorderSide(
                                          color: Theme.of(context).primaryColor,
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(
                                          Sizes.size3,
                                        ),
                                        borderSide: BorderSide(
                                          color: Colors.grey.shade300,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(
                                          Sizes.size3,
                                        ),
                                        borderSide: BorderSide(
                                          color: Theme.of(context).primaryColor,
                                        ),
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                        horizontal: Sizes.size20,
                                        vertical: Sizes.size20,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Gaps.v52,
                            SizedBox(
                              height: 200,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width: totalWidth * 0.1,
                                    child: const Text(
                                      "이미지 (선택)",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                      ),
                                      textAlign: TextAlign.start,
                                    ),
                                  ),
                                  Gaps.h32,
                                  SizedBox(
                                    child: ElevatedButton(
                                      onPressed: () =>
                                          pickMultipleImagesFromGallery(
                                              setState),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.grey.shade200,
                                        surfaceTintColor: Colors.pink.shade200,
                                      ),
                                      child: Text(
                                        '이미지 올리기',
                                        style: TextStyle(
                                          color: Colors.grey.shade800,
                                          fontSize: Sizes.size12,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Gaps.h32,
                                  Expanded(
                                    child: ListView.separated(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: _feedImageArray.length,
                                      itemBuilder: (context, index) {
                                        return Stack(
                                          children: [
                                            SizedBox(
                                              width: 200,
                                              height: 200,
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                  Sizes.size5,
                                                ),
                                                child: Image.memory(
                                                  _feedImageArray[index],
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                            Positioned(
                                              top: 10,
                                              right: 10,
                                              child: MouseRegion(
                                                cursor:
                                                    SystemMouseCursors.click,
                                                child: GestureDetector(
                                                  onTap: () {
                                                    setState(() {
                                                      _feedImageArray
                                                          .removeAt(index);
                                                    });
                                                  },
                                                  child: CircleAvatar(
                                                    backgroundColor:
                                                        Colors.grey.shade100,
                                                    child: const Icon(
                                                      Icons.close_rounded,
                                                      color: Colors.black87,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            )
                                          ],
                                        );
                                      },
                                      separatorBuilder: (context, index) {
                                        return Gaps.h10;
                                      },
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
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
        return StatefulBuilder(builder: (context, setState) {
          return Container(
            width: totalWidth,
            height: totalHeight * 0.8,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(Sizes.size10),
                topRight: Radius.circular(Sizes.size10),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(
                Sizes.size40,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      SizedBox(
                        width: 200,
                        height: 40,
                        child: ElevatedButton(
                          onPressed:
                              _enabledEventButton ? addEventFirebase : null,
                          style: ButtonStyle(
                            side: MaterialStateProperty.resolveWith<BorderSide>(
                              (states) {
                                return BorderSide(
                                  color: _enabledEventButton
                                      ? Theme.of(context).primaryColor
                                      : Colors.grey.shade800,
                                  width: 1,
                                );
                              },
                            ),
                            backgroundColor: MaterialStateProperty.all(
                              Colors.white,
                            ),
                            surfaceTintColor: MaterialStateProperty.all(
                              _enabledEventButton
                                  ? Theme.of(context).primaryColor
                                  : Colors.grey.shade800,
                            ),
                            shape: MaterialStateProperty.all<
                                RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  Sizes.size10,
                                ),
                              ),
                            ),
                          ),
                          child: Text(
                            "행사 추가하기",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: _enabledEventButton
                                  ? Theme.of(context).primaryColor
                                  : Colors.grey.shade800,
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                  Gaps.v52,
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          Gaps.v52,
                          IntrinsicHeight(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Align(
                                  alignment: Alignment.topLeft,
                                  child: SizedBox(
                                    width: totalWidth * 0.1,
                                    child: const Text(
                                      "행사 타이틀",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                                Gaps.h32,
                                SizedBox(
                                  width: totalWidth * 0.6,
                                  child: TextFormField(
                                    maxLength: 50,
                                    onFieldSubmitted: (value) {},
                                    onChanged: (value) {
                                      setState(() {
                                        // _eventTitle = value;

                                        // _enabledEventButton =
                                        //     _eventTitle.isNotEmpty &&
                                        //         _eventDescription.isNotEmpty &&
                                        //         _eventImageBytes != null &&
                                        //         _eventPrizeWinners.isNotEmpty &&
                                        //         _eventGoalScore.isNotEmpty &&
                                        //         _eventStartDate != null &&
                                        //         _eventEndDate != null;
                                      });
                                    },
                                    controller: _titleControllder,
                                    textAlignVertical: TextAlignVertical.center,
                                    style: const TextStyle(
                                      fontSize: Sizes.size12,
                                      color: Colors.black87,
                                    ),
                                    decoration: InputDecoration(
                                      hintText: "",
                                      hintStyle: TextStyle(
                                        fontSize: Sizes.size12,
                                        color: Colors.grey.shade400,
                                        fontWeight: FontWeight.w300,
                                      ),
                                      filled: true,
                                      fillColor: Colors.grey.shade50,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(
                                          Sizes.size3,
                                        ),
                                      ),
                                      errorStyle: TextStyle(
                                        color: Theme.of(context).primaryColor,
                                      ),
                                      errorBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(
                                          Sizes.size3,
                                        ),
                                        borderSide: BorderSide(
                                          color: Theme.of(context).primaryColor,
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(
                                          Sizes.size3,
                                        ),
                                        borderSide: BorderSide(
                                          color: Colors.grey.shade300,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(
                                          Sizes.size3,
                                        ),
                                        borderSide: BorderSide(
                                          color: Theme.of(context).primaryColor,
                                        ),
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                        horizontal: Sizes.size20,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: totalWidth * 0.1,
                                child: const Text(
                                  "행사 이미지",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                  textAlign: TextAlign.start,
                                ),
                              ),
                              Gaps.h32,
                              Container(
                                width: 200,
                                height: 200,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(
                                      Sizes.size5,
                                    ),
                                    border: Border.all(
                                      color: Colors.grey.shade200,
                                    )),
                                child: _eventImageFile == null
                                    ? Icon(
                                        Icons.image,
                                        size: Sizes.size80,
                                        color: Colors.grey.shade200,
                                      )
                                    : Image.memory(
                                        _eventImageBytes!,
                                        fit: BoxFit.cover,
                                      ),
                              ),
                              Gaps.h52,
                              SizedBox(
                                height: 200,
                                child: Align(
                                  alignment: Alignment.bottomLeft,
                                  child: ElevatedButton(
                                    onPressed: () =>
                                        pickImageFromGallery(setState),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.grey.shade200,
                                      surfaceTintColor: Colors.pink.shade200,
                                    ),
                                    child: Text(
                                      '이미지 올리기',
                                      style: TextStyle(
                                        color: Colors.grey.shade800,
                                        fontSize: Sizes.size12,
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                          Gaps.v52,
                          IntrinsicHeight(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                SizedBox(
                                  width: totalWidth * 0.1,
                                  child: const Text(
                                    "행사 설명",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                    textAlign: TextAlign.start,
                                  ),
                                ),
                                Gaps.h32,
                                SizedBox(
                                  width: totalWidth * 0.6,
                                  height: 200,
                                  child: TextFormField(
                                    maxLength: 200,
                                    expands: true,
                                    maxLines: null,
                                    minLines: null,
                                    onFieldSubmitted: (value) {},
                                    onChanged: (value) {
                                      setState(() {
                                        // _eventDescription = value;

                                        // _enabledEventButton =
                                        //     _eventTitle.isNotEmpty &&
                                        //         _eventDescription.isNotEmpty &&
                                        //         _eventImageBytes != null &&
                                        //         _eventPrizeWinners.isNotEmpty &&
                                        //         _eventGoalScore.isNotEmpty &&
                                        //         _eventStartDate != null &&
                                        //         _eventEndDate != null;
                                      });
                                    },
                                    controller: _descriptionControllder,
                                    textAlignVertical: TextAlignVertical.top,
                                    style: const TextStyle(
                                      fontSize: Sizes.size12,
                                      color: Colors.black87,
                                    ),
                                    decoration: InputDecoration(
                                      isDense: true,
                                      hintText: "",
                                      hintStyle: TextStyle(
                                        fontSize: Sizes.size12,
                                        color: Colors.grey.shade400,
                                        fontWeight: FontWeight.w300,
                                      ),
                                      filled: true,
                                      fillColor: Colors.grey.shade50,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(
                                          Sizes.size3,
                                        ),
                                      ),
                                      errorStyle: TextStyle(
                                        color: Theme.of(context).primaryColor,
                                      ),
                                      errorBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(
                                          Sizes.size3,
                                        ),
                                        borderSide: BorderSide(
                                          color: Theme.of(context).primaryColor,
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(
                                          Sizes.size3,
                                        ),
                                        borderSide: BorderSide(
                                          color: Colors.grey.shade300,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(
                                          Sizes.size3,
                                        ),
                                        borderSide: BorderSide(
                                          color: Theme.of(context).primaryColor,
                                        ),
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                        horizontal: Sizes.size20,
                                        vertical: Sizes.size20,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Gaps.v52,
                          Row(
                            children: [
                              Expanded(
                                flex: 1,
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: totalWidth * 0.1,
                                      child: const Text(
                                        "시작일",
                                        style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                        ),
                                        textAlign: TextAlign.start,
                                      ),
                                    ),
                                    Gaps.h32,
                                    Align(
                                      alignment: Alignment.bottomLeft,
                                      child: ElevatedButton(
                                        onPressed: () =>
                                            selectStartPeriod(setState),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.grey.shade200,
                                          surfaceTintColor:
                                              Colors.pink.shade200,
                                        ),
                                        child: Text(
                                          '날짜 선택하기',
                                          style: TextStyle(
                                            color: Colors.grey.shade800,
                                            fontSize: Sizes.size12,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Gaps.h20,
                                    if (_eventStartDate != null)
                                      Text(
                                        "${_eventStartDate?.year}.${_eventStartDate?.month.toString().padLeft(2, '0')}.${_eventStartDate?.day.toString().padLeft(2, '0')}",
                                        style: TextStyle(
                                          color: Colors.grey.shade800,
                                          fontSize: Sizes.size12,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: totalWidth * 0.1,
                                      child: const Text(
                                        "종료일",
                                        style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                        ),
                                        textAlign: TextAlign.start,
                                      ),
                                    ),
                                    Gaps.h32,
                                    Align(
                                      alignment: Alignment.bottomLeft,
                                      child: ElevatedButton(
                                        onPressed: () =>
                                            selectEndPeriod(setState),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.grey.shade200,
                                          surfaceTintColor:
                                              Colors.pink.shade200,
                                        ),
                                        child: Text(
                                          '날짜 선택하기',
                                          style: TextStyle(
                                            color: Colors.grey.shade800,
                                            fontSize: Sizes.size12,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Gaps.h20,
                                    if (_eventEndDate != null)
                                      Text(
                                        "${_eventEndDate?.year}.${_eventEndDate?.month.toString().padLeft(2, '0')}.${_eventEndDate?.day.toString().padLeft(2, '0')}",
                                        style: TextStyle(
                                          color: Colors.grey.shade800,
                                          fontSize: Sizes.size12,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          Gaps.v52,
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              SizedBox(
                                width: totalWidth * 0.1,
                                child: const Text(
                                  "목표 점수 설정",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                  textAlign: TextAlign.start,
                                ),
                              ),
                              Gaps.h32,
                              SizedBox(
                                width: 60,
                                child: TextFormField(
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly
                                  ],
                                  minLines: 1,
                                  onFieldSubmitted: (value) {},
                                  onChanged: (value) {
                                    setState(() {
                                      // _eventGoalScore = value;

                                      // _enabledEventButton =
                                      //     _eventTitle.isNotEmpty &&
                                      //         _eventDescription.isNotEmpty &&
                                      //         _eventImageBytes != null &&
                                      //         _eventPrizeWinners.isNotEmpty &&
                                      //         _eventGoalScore.isNotEmpty &&
                                      //         _eventStartDate != null &&
                                      //         _eventEndDate != null;
                                    });
                                  },
                                  controller: _goalScoreController,
                                  textAlignVertical: TextAlignVertical.top,
                                  style: const TextStyle(
                                    fontSize: Sizes.size12,
                                    color: Colors.black87,
                                  ),
                                  decoration: InputDecoration(
                                    isDense: true,
                                    hintText: "",
                                    hintStyle: TextStyle(
                                      fontSize: Sizes.size12,
                                      color: Colors.grey.shade400,
                                      fontWeight: FontWeight.w300,
                                    ),
                                    filled: true,
                                    fillColor: Colors.grey.shade50,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(
                                        Sizes.size3,
                                      ),
                                    ),
                                    errorStyle: TextStyle(
                                      color: Theme.of(context).primaryColor,
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(
                                        Sizes.size3,
                                      ),
                                      borderSide: BorderSide(
                                        color: Theme.of(context).primaryColor,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(
                                        Sizes.size3,
                                      ),
                                      borderSide: BorderSide(
                                        color: Colors.grey.shade300,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(
                                        Sizes.size3,
                                      ),
                                      borderSide: BorderSide(
                                        color: Theme.of(context).primaryColor,
                                      ),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: Sizes.size10,
                                      vertical: Sizes.size10,
                                    ),
                                  ),
                                ),
                              ),
                              Gaps.h10,
                              Text(
                                "점",
                                style: TextStyle(
                                  fontSize: Sizes.size14,
                                  color: Colors.grey.shade800,
                                  fontWeight: FontWeight.w300,
                                ),
                              )
                            ],
                          ),
                          Gaps.v52,
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              SizedBox(
                                width: totalWidth * 0.1,
                                child: const Text(
                                  "당첨자 수 제한",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                  textAlign: TextAlign.start,
                                ),
                              ),
                              Gaps.h32,
                              SizedBox(
                                width: 60,
                                child: TextFormField(
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly
                                  ],
                                  minLines: 1,
                                  onFieldSubmitted: (value) {},
                                  onChanged: (value) {
                                    setState(() {
                                      // _eventPrizeWinners = value;

                                      // _enabledEventButton =
                                      //     _eventTitle.isNotEmpty &&
                                      //         _eventDescription.isNotEmpty &&
                                      //         _eventImageBytes != null &&
                                      //         _eventPrizeWinners.isNotEmpty &&
                                      //         _eventGoalScore.isNotEmpty &&
                                      //         _eventStartDate != null &&
                                      //         _eventEndDate != null;
                                    });
                                  },
                                  controller: _prizewinnersControllder,
                                  textAlignVertical: TextAlignVertical.top,
                                  style: const TextStyle(
                                    fontSize: Sizes.size12,
                                    color: Colors.black87,
                                  ),
                                  decoration: InputDecoration(
                                    isDense: true,
                                    hintText: "",
                                    hintStyle: TextStyle(
                                      fontSize: Sizes.size12,
                                      color: Colors.grey.shade400,
                                      fontWeight: FontWeight.w300,
                                    ),
                                    filled: true,
                                    fillColor: Colors.grey.shade50,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(
                                        Sizes.size3,
                                      ),
                                    ),
                                    errorStyle: TextStyle(
                                      color: Theme.of(context).primaryColor,
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(
                                        Sizes.size3,
                                      ),
                                      borderSide: BorderSide(
                                        color: Theme.of(context).primaryColor,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(
                                        Sizes.size3,
                                      ),
                                      borderSide: BorderSide(
                                        color: Colors.grey.shade300,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(
                                        Sizes.size3,
                                      ),
                                      borderSide: BorderSide(
                                        color: Theme.of(context).primaryColor,
                                      ),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: Sizes.size10,
                                      vertical: Sizes.size10,
                                    ),
                                  ),
                                ),
                              ),
                              Gaps.h10,
                              Text(
                                "명",
                                style: TextStyle(
                                  fontSize: Sizes.size14,
                                  color: Colors.grey.shade800,
                                  fontWeight: FontWeight.w300,
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        });
      },
    );
  }

  Future<List<EventModel>> getEvents(
      String contractType, String contractName) async {
    List<EventModel> eventList = await ref
        .read(eventProvider.notifier)
        .getEventModels(contractType, contractName);
    setState(() {
      // _initialSetting = true;
    });
    return eventList;
  }

  void removeDeleteOverlay() {
    overlayEntry?.remove();
    overlayEntry = null;
  }

  void showDeleteOverlay(
      BuildContext context, String eventId, String eventName) async {
    removeDeleteOverlay();

    // assert(overlayEntry == null);

    overlayEntry = OverlayEntry(
      builder: (context) => Positioned.fill(
        child: Material(
          color: Colors.black54,
          child: Center(
            child: AlertDialog(
              title: Text(
                eventName.length > 10
                    ? "${eventName.substring(0, 11)}.."
                    : eventName,
                style: const TextStyle(
                  fontSize: Sizes.size20,
                  fontWeight: FontWeight.w500,
                ),
              ),
              backgroundColor: Colors.white,
              content: const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "정말로 삭제하시겠습니까?",
                    style: TextStyle(
                      fontSize: Sizes.size13,
                    ),
                  ),
                  Text(
                    "삭제하면 다시 되돌릴 수 없습니다.",
                    style: TextStyle(
                      fontSize: Sizes.size13,
                    ),
                  ),
                ],
              ),
              actions: [
                ElevatedButton(
                  onPressed: removeDeleteOverlay,
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all(Colors.pink.shade100),
                  ),
                  child: Text(
                    "취소",
                    style: TextStyle(
                      fontSize: Sizes.size13,
                      color: Colors.grey.shade800,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => deleteEventFirebase(eventId),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(
                        Theme.of(context).primaryColor),
                  ),
                  child: const Text(
                    "삭제",
                    style: TextStyle(
                      fontSize: Sizes.size13,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    Overlay.of(context, debugRequiredFor: widget).insert(overlayEntry!);
  }

  void goDetailEvent(String eventId) {
    context.go("/event/$eventId");
  }

  @override
  void dispose() {
    _titleControllder.dispose();
    _descriptionControllder.dispose();
    _prizewinnersControllder.dispose();
    _goalScoreController.dispose();

    removeDeleteOverlay();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return ref.watch(eventProvider).when(
        loading: () => CircularProgressIndicator.adaptive(
              backgroundColor: Theme.of(context).primaryColor,
            ),
        error: (error, stackTrace) => const ErrorScreen(),
        data: (data) {
          final eventList = data;
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
                            // onHover: (event) {
                            //   setState(() {
                            //     _feedHover = true;
                            //   });
                            // },
                            // onExit: (event) {
                            //   setState(() {
                            //     _feedHover = false;
                            //   });
                            // },
                            child: GestureDetector(
                              onTap: () => feedUploadTap(
                                  context, size.width - 270, size.height),
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
                        Gaps.h20,
                        Visibility(
                          visible: size.width > 550,
                          child: MouseRegion(
                            cursor: SystemMouseCursors.click,
                            // onHover: (event) {
                            //   setState(() {
                            //     _addEventHover = true;
                            //   });
                            // },
                            // onExit: (event) {
                            //   setState(() {
                            //     _addEventHover = false;
                            //   });
                            // },
                            child: GestureDetector(
                              onTap: () => addEventTap(
                                  context, size.width - 270, size.height),
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
                                        "진행 상황",
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
                                        "삭제",
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
                                            alignment: Alignment.center,
                                            child: Text(
                                              eventList[index].title!,
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
                                            alignment: Alignment.center,
                                            child: Text(
                                              eventList[index]
                                                  .description!
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
                                      Expanded(
                                        flex: 2,
                                        child: Padding(
                                          padding: const EdgeInsets.all(
                                            Sizes.size10,
                                          ),
                                          child: Align(
                                            alignment: Alignment.center,
                                            child: Text(
                                              eventList[index].contractName!,
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
                                        child: Padding(
                                          padding: const EdgeInsets.all(
                                            Sizes.size10,
                                          ),
                                          child: Align(
                                            alignment: Alignment.center,
                                            child: Text(
                                              eventList[index].startPeriod!,
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
                                            eventList[index].endPeriod!,
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
                                      eventList[index].allUser != true
                                          ? Expanded(
                                              flex: 1,
                                              child: MouseRegion(
                                                cursor:
                                                    SystemMouseCursors.click,
                                                child: GestureDetector(
                                                  onTap: () =>
                                                      showDeleteOverlay(
                                                          context,
                                                          eventList[index]
                                                              .documentId!,
                                                          eventList[index]
                                                              .title!),
                                                  child: const Icon(
                                                    Icons.delete,
                                                    size: Sizes.size16,
                                                  ),
                                                ),
                                              ),
                                            )
                                          : Expanded(
                                              flex: 1,
                                              child: Container(),
                                            ),
                                      Expanded(
                                        flex: 1,
                                        child: Align(
                                          alignment: Alignment.center,
                                          child: MouseRegion(
                                            cursor: SystemMouseCursors.click,
                                            child: GestureDetector(
                                              onTap: () => goDetailEvent(
                                                  eventList[index].documentId!),
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
          );
        });
  }
}
