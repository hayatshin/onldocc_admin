import 'package:flutter/material.dart';
import 'package:onldocc_admin/palette.dart';

Widget loadingWidget(BuildContext context) {
  return Center(
    child: CircularProgressIndicator.adaptive(
      backgroundColor: Palette().darkGray,
    ),
  );
}
