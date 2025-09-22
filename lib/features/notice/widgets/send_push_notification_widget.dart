import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:onldocc_admin/common/view_a/modal_screen.dart';
import 'package:onldocc_admin/constants/gaps.dart';
import 'package:onldocc_admin/constants/sizes.dart';
import 'package:onldocc_admin/features/event/view/event_screen.dart';
import 'package:onldocc_admin/features/login/models/admin_profile_model.dart';
import 'package:onldocc_admin/features/login/view_models/admin_profile_view_model.dart';
import 'package:onldocc_admin/palette.dart';
import 'package:onldocc_admin/utils.dart';

class SendPushNotificationWidget extends ConsumerStatefulWidget {
  final BuildContext pcontext;
  const SendPushNotificationWidget({
    super.key,
    required this.pcontext,
  });

  @override
  ConsumerState<SendPushNotificationWidget> createState() =>
      _UploadFeedWidgetState();
}

class _UploadFeedWidgetState extends ConsumerState<SendPushNotificationWidget> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _titleControllder = TextEditingController();
  final TextEditingController _descriptionControllder = TextEditingController();

  final TextStyle _headerTextStyle = TextStyle(
    fontSize: Sizes.size12,
    fontWeight: FontWeight.w600,
    color: Palette().darkGray,
  );

  final TextStyle _contentTextStyle = TextStyle(
    fontSize: Sizes.size14,
    fontWeight: FontWeight.w500,
    color: Palette().darkGray,
  );

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _titleControllder.dispose();
    _descriptionControllder.dispose();
    super.dispose();
  }

  Future<void> _submitFeedNotification() async {
    if (_formKey.currentState != null) {
      if (_formKey.currentState!.validate()) {
        AdminProfileModel? adminProfileModel =
            ref.read(adminProfileProvider).value;
        if (adminProfileModel == null) {
          showTopWarningSnackBar(context, "오류가 발생했습니다");
          return;
        }
        if (adminProfileModel.master) {
          showTopWarningSnackBar(context, "전체 발송은 콘솔을 이용해주세요");
          return;
        } else {
          // master 계정이 아닌 경우
          if (selectContractRegion.value?.contractCommunityId != "" &&
              selectContractRegion.value?.contractCommunityId != null) {
            // 기관 발송
            pushTopicFcmNotification(
                selectContractRegion.value!.contractCommunityId!,
                _titleControllder.text,
                _descriptionControllder.text);
          } else {
            // 지역 발송
            pushTopicFcmNotification(adminProfileModel.subdistrictId,
                _titleControllder.text, _descriptionControllder.text);
          }
          showTopCompletingSnackBar(context, "푸쉬 알림 전송이 완료되었습니다");
          context.pop();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return StatefulBuilder(
      builder: (context, setState) {
        return ModalScreen(
          widthPercentage: 0.5,
          modalTitle: "푸쉬 알림 전송하기",
          modalButtonOneText: "전송하기",
          modalButtonOneFunction: _submitFeedNotification,
          // modalButtonTwoText: !widget.edit ? null : "수정하기",
          // modalButtonTwoFunction: _editFeedNotification,
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: size.width * 0.12,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SelectableText(
                            "푸쉬 타이틀",
                            style: _headerTextStyle,
                            textAlign: TextAlign.start,
                          ),
                        ],
                      ),
                    ),
                    Gaps.h32,
                    Expanded(
                      child: TextFormField(
                        minLines: 1,
                        validator: (value) {
                          if (value != null && value.isEmpty) {
                            return "푸쉬 타이틀을 입력해주세요";
                          }
                          return null;
                        },
                        controller: _titleControllder,
                        textAlignVertical: TextAlignVertical.top,
                        style: _contentTextStyle,
                        decoration: inputDecorationStyle(),
                      ),
                    ),
                  ],
                ),
                Gaps.v32,
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: size.width * 0.12,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SelectableText(
                            "푸쉬 디스크립션",
                            style: _headerTextStyle,
                            textAlign: TextAlign.start,
                          ),
                        ],
                      ),
                    ),
                    Gaps.h32,
                    Expanded(
                      child: TextFormField(
                        minLines: 1,
                        validator: (value) {
                          if (value != null && value.isEmpty) {
                            return "푸쉬 디스크립션을 입력해주세요";
                          }
                          return null;
                        },
                        controller: _descriptionControllder,
                        textAlignVertical: TextAlignVertical.top,
                        style: _contentTextStyle,
                        decoration: inputDecorationStyle(),
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Gaps.v32,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: size.width * 0.12,
                        ),
                        Gaps.h32,
                        ClipRRect(
                          borderRadius: BorderRadius.circular(5),
                          child: Image.asset(
                            "assets/notice/push-noti.png",
                            width: 250,
                          ),
                        ),
                      ],
                    ),
                    Gaps.v16,
                    Row(
                      children: [
                        Container(
                          width: size.width * 0.12,
                        ),
                        Gaps.h32,
                        Text(
                          "앱에 오랫동안 접속하지 않은 사용자에게도 푸쉬 알림을 전달할 수 있습니다",
                          style: headerInfoTextStyle,
                        ),
                      ],
                    )
                  ],
                )
                    .animate()
                    .slideY(
                      begin: -0.1,
                      end: 0,
                      duration: Duration(milliseconds: 200),
                    )
                    .fadeIn(duration: Duration(milliseconds: 200)),
              ],
            ),
          ),
        );
      },
    );
  }
}
