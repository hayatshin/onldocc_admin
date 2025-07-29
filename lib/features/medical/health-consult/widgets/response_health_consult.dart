import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:onldocc_admin/common/view_a/modal_screen.dart';
import 'package:onldocc_admin/constants/gaps.dart';
import 'package:onldocc_admin/features/login/view_models/admin_profile_view_model.dart';
import 'package:onldocc_admin/features/medical/health-consult/models/health_consult_inquiry_model.dart';
import 'package:onldocc_admin/features/medical/health-consult/models/health_consult_response_model.dart';
import 'package:onldocc_admin/features/medical/health-consult/view_models/health_consult_view_model.dart';
import 'package:onldocc_admin/features/medical/health-story/view/health_story_screen.dart';
import 'package:onldocc_admin/injicare_color.dart';
import 'package:onldocc_admin/injicare_font.dart';
import 'package:onldocc_admin/utils.dart';
import 'package:uuid/uuid.dart';

class ResponseHealthConsult extends ConsumerStatefulWidget {
  final HealthConsultInquiryModel model;
  final Function() updateHealthConsults;
  final HealthConsultResponseModel? response;
  const ResponseHealthConsult({
    super.key,
    required this.model,
    required this.updateHealthConsults,
    this.response,
  });

  @override
  ConsumerState<ResponseHealthConsult> createState() =>
      _ResponseHealthConsultState();
}

class _ResponseHealthConsultState extends ConsumerState<ResponseHealthConsult> {
  final TextEditingController _responseControllder = TextEditingController();
  bool _enableButton = false;

  @override
  void initState() {
    super.initState();

    if (widget.response != null) {
      _responseControllder.text = widget.response!.response;
    }

    _responseControllder.addListener(() {
      if (_responseControllder.text.isEmpty) {
        setState(() {
          _enableButton = false;
        });
      } else {
        setState(() {
          _enableButton = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _responseControllder.dispose();
    super.dispose();
  }

  Future<void> insertHealthConsultResponse() async {
    final adminProfile = ref.read(adminProfileProvider).value;
    if (adminProfile == null) return;
    if (adminProfile.doctor == null ||
        adminProfile.doctor?.role != "counseling") {
      showTopWarningSnackBar(context, "작성 권한을 가진 의사가 아닙니다");
      return;
    }

    if (_responseControllder.text.isEmpty) {
      showTopWarningSnackBar(context, "답변 내용을을 적어주세요");
      return;
    }

    final healthConsultResponseId = widget.model.response == null
        ? Uuid().v4()
        : widget.model.response!.healthConsultResponseId;

    final model = HealthConsultResponseModel(
      healthConsultResponseId: healthConsultResponseId,
      doctorId: adminProfile.doctor!.doctorId,
      response: _responseControllder.text,
      createdAt: getCurrentSeconds(),
      healthConsultInquiryId: widget.model.healthConsultInquiryId,
    );

    await ref
        .read(healthConsultProvider.notifier)
        .insertHealthConsultResponse(model);
    widget.updateHealthConsults();

    if (!mounted) return;
    final snackBarText =
        widget.response == null ? "답변이 성공적으로 등록되었어요" : "답변이 성공적으로 수정되었어요";
    showTopCompletingSnackBar(context, snackBarText);

    if (!mounted) return;
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return ModalScreen(
      widthPercentage: 0.5,
      modalTitle: widget.response == null ? "답변하기" : "수정하기",
      modalButtonOneText: widget.response == null ? "답변 완료" : "수정 완료",
      modalButtonOneFunction: insertHealthConsultResponse,
      enableModelButton: _enableButton,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            widget.model.response == null
                ? WaitedResponse()
                : CompletedResponse(),
            Gaps.v10,
            SelectableText(
              widget.model.title,
              style: InjicareFont().body01.copyWith(
                    color: InjicareColor().gray100,
                  ),
            ),
            Gaps.v10,
            SelectableText(
              widget.model.inquiry,
              style: InjicareFont().body05.copyWith(
                    color: InjicareColor().gray80,
                  ),
            ),
            Gaps.v20,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                      ),
                      clipBehavior: Clip.hardEdge,
                      child: CachedNetworkImage(
                        imageUrl: widget.model.userAvatar!,
                        fit: BoxFit.cover,
                        fadeInDuration: Duration.zero,
                        fadeOutDuration: Duration.zero,
                        errorWidget: (context, url, error) => ColorFiltered(
                          colorFilter: ColorFilter.mode(
                            InjicareColor().secondary50.withValues(alpha: 0.2),
                            BlendMode.srcIn,
                          ),
                          child: SvgPicture.asset(
                            "assets/svg/profile-user.svg",
                          ),
                        ),
                      ),
                    ),
                    Gaps.h10,
                    Text(
                      "${widget.model.userName} (${widget.model.userAge}/${widget.model.userGender})",
                      style: InjicareFont().body07.copyWith(
                            color: InjicareColor().gray70,
                          ),
                    ),
                  ],
                ),
                Text(
                  createdAtToDateDot(widget.model.createdAt),
                  style: InjicareFont().body08.copyWith(
                        color: InjicareColor().gray60,
                      ),
                ),
              ],
            ),
            Gaps.v32,
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 1,
                    color: InjicareColor().gray30,
                  ),
                ),
              ],
            ),
            Gaps.v32,
            Text(
              "답변 내용",
              style: InjicareFont().body04.copyWith(
                    color: InjicareColor().gray80,
                  ),
            ),
            Gaps.v10,
            Container(
              height: 250,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: BoxBorder.all(
                  width: 1,
                  color: InjicareColor().gray20,
                ),
              ),
              child: Padding(
                padding:
                    EdgeInsetsGeometry.symmetric(horizontal: 16, vertical: 10),
                child: TextFormField(
                  controller: _responseControllder,
                  expands: true,
                  maxLines: null,
                  minLines: null,
                  style: InjicareFont().body05.copyWith(
                        color: InjicareColor().gray100,
                      ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: "답변 내용을 자세히 적어주세요",
                    hintStyle: InjicareFont().body08.copyWith(
                          color: InjicareColor().gray40,
                        ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class CompletedResponse extends StatelessWidget {
  const CompletedResponse({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 54,
      height: 22,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        color: InjicareColor().primary20,
      ),
      child: Center(
        child: Text(
          "답변완료",
          style: InjicareFont().label03.copyWith(
                color: InjicareColor().primary50,
              ),
        ),
      ),
    );
  }
}

class WaitedResponse extends StatelessWidget {
  const WaitedResponse({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 54,
      height: 22,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        color: InjicareColor().secondary20,
      ),
      child: Center(
        child: Text(
          "답변대기",
          style: InjicareFont().label03.copyWith(
                color: InjicareColor().secondary50,
              ),
        ),
      ),
    );
  }
}
