import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:onldocc_admin/constants/sizes.dart';

class BottomModalButton extends StatelessWidget {
  final String text;
  final Function() submitFunction;
  final bool hoverBottomButton;
  final bool loading;

  const BottomModalButton({
    super.key,
    required this.text,
    required this.submitFunction,
    required this.hoverBottomButton,
    required this.loading,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      height: 40,
      child: ElevatedButton(
        onPressed: submitFunction,
        style: ButtonStyle(
          side: MaterialStateProperty.resolveWith<BorderSide>(
            (states) {
              return BorderSide(
                color: hoverBottomButton && !text.contains("삭제하기")
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
            hoverBottomButton && !text.contains("삭제하기")
                ? Theme.of(context).primaryColor
                : Colors.grey.shade800,
          ),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                Sizes.size10,
              ),
            ),
          ),
        ),
        child: loading
            ? LoadingAnimationWidget.threeArchedCircle(
                color: Colors.grey.shade700,
                size: 12,
              )
            : Text(
                text,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: hoverBottomButton && !text.contains("삭제하기")
                      ? Theme.of(context).primaryColor
                      : Colors.grey.shade800,
                ),
              ),
      ),
    );
  }
}

final enabledSubmitButton = ValueNotifier<bool>(false);
