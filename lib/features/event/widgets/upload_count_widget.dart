import 'package:flutter/material.dart';
import 'package:onldocc_admin/constants/gaps.dart';
import 'package:onldocc_admin/features/event/widgets/edit_point_event_widget.dart';

class UploadCountWidget extends StatefulWidget {
  final Function(int) updateDiaryCount;
  final Function(int) updateCommentCount;
  final Function(int) updateLikeCount;
  final Function(int) updateInvitationCount;

  const UploadCountWidget({
    super.key,
    required this.updateDiaryCount,
    required this.updateCommentCount,
    required this.updateLikeCount,
    required this.updateInvitationCount,
  });

  @override
  State<UploadCountWidget> createState() => _UploadCountWidgetState();
}

class _UploadCountWidgetState extends State<UploadCountWidget> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            DefaultCountTile(
              totalWidth: size.width,
              updateEventPoint: widget.updateDiaryCount,
              header: "일기",
              defaultPoint: 0,
              editOrNot: false,
            ),
            DefaultCountTile(
              totalWidth: size.width,
              updateEventPoint: widget.updateCommentCount,
              header: "댓글",
              defaultPoint: 0,
              editOrNot: false,
            ),
            DefaultCountTile(
              totalWidth: size.width,
              updateEventPoint: widget.updateLikeCount,
              header: "좋아요",
              defaultPoint: 0,
              editOrNot: false,
            ),
          ],
        ),
        Gaps.v32,
        DefaultCountTile(
          totalWidth: size.width,
          updateEventPoint: widget.updateInvitationCount,
          header: "친구 초대",
          defaultPoint: 0,
          editOrNot: false,
        ),
      ],
    );
  }
}
