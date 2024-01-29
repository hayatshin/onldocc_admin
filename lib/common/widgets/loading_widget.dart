import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:onldocc_admin/constants/sizes.dart';

Widget loadingWidget(BuildContext context) {
  return Center(
    child: CircularProgressIndicator.adaptive(
      backgroundColor: Theme.of(context).primaryColor,
    ),
  );
}
