import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:onldocc_admin/constants/sizes.dart';

Widget loadingWidget() {
  return Center(
    child: LoadingAnimationWidget.inkDrop(
      color: Colors.grey.shade600,
      size: Sizes.size32,
    ),
  );
}
