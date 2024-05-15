import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:onldocc_admin/constants/gaps.dart';
import 'package:onldocc_admin/constants/sizes.dart';
import 'package:onldocc_admin/features/login/view_models/admin_profile_view_model.dart';
import 'package:onldocc_admin/palette.dart';

class LoginScreen extends ConsumerStatefulWidget {
  static const routeURL = "/";
  static const routeName = "login";
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isPasswordInvisible = true;
  final double? formWidth = 280;
  final double? formHeight = 42;

  Map<String, String> formData = {};
  bool forwardAnimation = true;

  @override
  void initState() {
    super.initState();
  }

  void _onPasswordVisibleTap() {
    setState(() {
      _isPasswordInvisible = !_isPasswordInvisible;
    });
  }

  Future<void> _onSubmitTap() async {
    if (_formKey.currentState != null) {
      if (_formKey.currentState!.validate()) {
        try {
          _formKey.currentState!.save();
          await ref
              .read(adminProfileProvider.notifier)
              .login(formData["email"]!, formData["password"]!, context);
        } catch (e) {
          // ignore: avoid_print
          print("_onSubmitTap -> $e");
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: Sizes.size96,
          ),
          child: SizedBox(
            width: 800,
            height: size.height,
            child: Stack(
              children: [
                Positioned(
                  left: 0,
                  right: 0,
                  top: 0,
                  bottom: 0,
                  child: Opacity(
                    opacity: 0.2,
                    child: Image.asset(
                      "assets/images/gradient-back.png",
                    ),
                  ),
                ),
                Positioned(
                  left: 0,
                  top: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Gaps.v20,
                                  Text(
                                    "시니어들의 빅데이터",
                                    style: TextStyle(
                                      fontSize: Sizes.size28,
                                      fontWeight: FontWeight.w800,
                                      color: Palette().darkGray,
                                    ),
                                  ),
                                  Text(
                                    "인지케어 관리자페이지",
                                    style: TextStyle(
                                      fontSize: Sizes.size28,
                                      fontWeight: FontWeight.w800,
                                      color: Palette().darkGray,
                                    ),
                                  ),
                                ],
                              ),
                              Gaps.h20,
                              Image.asset(
                                "assets/images/icon_line.png",
                                width: 65,
                              ),
                            ],
                          ),
                          Gaps.v40,
                          RichText(
                            text: TextSpan(
                                text: "인지 검사, AI 대화, 일기, 걸음수 등 시니어들의 활동 ",
                                style: TextStyle(
                                  fontSize: Sizes.size16,
                                  fontWeight: FontWeight.w300,
                                  color: Palette().normalGray,
                                  height: 1.7,
                                ),
                                children: const [
                                  TextSpan(
                                    text: "빅데이터 ",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  TextSpan(
                                    text: "제공부터\n지자체의 ",
                                  ),
                                  TextSpan(
                                    text: "월별 리포트 발행",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  TextSpan(
                                    text: "과 다양한 ",
                                  ),
                                  TextSpan(
                                    text: "행사 주관",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  TextSpan(
                                    text: "까지!\n인지케어에서 한번에 관리하세요.",
                                  ),
                                ]),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Form(
                  key: _formKey,
                  child: Positioned(
                    right: 0,
                    bottom: 0,
                    child: SizedBox(
                      width: 360,
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Text(
                                "이메일",
                                style: TextStyle(
                                  color: Palette().darkPurple,
                                  fontWeight: FontWeight.w700,
                                  fontSize: Sizes.size16,
                                ),
                              ),
                              const Spacer(),
                              SizedBox(
                                width: formWidth,
                                child: TextFormField(
                                  cursorColor: Palette().darkPurple,
                                  onFieldSubmitted: (value) => _onSubmitTap(),
                                  textAlignVertical: TextAlignVertical.center,
                                  style: TextStyle(
                                    fontSize: Sizes.size14,
                                    color: Palette().darkPurple,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(
                                        Sizes.size5,
                                      ),
                                      borderSide: BorderSide(
                                        color: Palette().darkPurple,
                                        width: 2,
                                      ),
                                    ),
                                    focusedErrorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(
                                        Sizes.size5,
                                      ),
                                      borderSide: BorderSide(
                                        color: Palette().darkPurple,
                                        width: 2,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(
                                        Sizes.size5,
                                      ),
                                      borderSide: BorderSide(
                                        color: Palette().darkPurple,
                                        width: 2,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(
                                        Sizes.size5,
                                      ),
                                      borderSide: BorderSide(
                                        color: Palette().darkPurple,
                                        width: 2,
                                      ),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(
                                        Sizes.size5,
                                      ),
                                      borderSide: BorderSide(
                                        color: Palette().darkPurple,
                                        width: 2,
                                      ),
                                    ),
                                    errorStyle: const TextStyle(
                                      color: Colors.red,
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: Sizes.size15,
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value != null && value.isEmpty) {
                                      return "이메일을 입력해주세요.";
                                    }
                                    return null;
                                  },
                                  onSaved: (newValue) {
                                    if (newValue != null) {
                                      formData['email'] = newValue;
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                          Gaps.v20,
                          Row(
                            children: [
                              Text(
                                "비밀번호",
                                style: TextStyle(
                                  color: Palette().darkPurple,
                                  fontWeight: FontWeight.w700,
                                  fontSize: Sizes.size16,
                                ),
                              ),
                              const Spacer(),
                              SizedBox(
                                width: formWidth,
                                child: TextFormField(
                                  cursorColor: Palette().darkPurple,
                                  onFieldSubmitted: (value) => _onSubmitTap(),
                                  textAlignVertical: TextAlignVertical.center,
                                  style: TextStyle(
                                    fontSize: Sizes.size14,
                                    color: Palette().darkPurple,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  obscureText: _isPasswordInvisible,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(
                                        Sizes.size5,
                                      ),
                                      borderSide: BorderSide(
                                        color: Palette().darkPurple,
                                        width: 2,
                                      ),
                                    ),
                                    focusedErrorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(
                                        Sizes.size5,
                                      ),
                                      borderSide: BorderSide(
                                        color: Palette().darkPurple,
                                        width: 2,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(
                                        Sizes.size5,
                                      ),
                                      borderSide: BorderSide(
                                        color: Palette().darkPurple,
                                        width: 2,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(
                                        Sizes.size5,
                                      ),
                                      borderSide: BorderSide(
                                        color: Palette().darkPurple,
                                        width: 2,
                                      ),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(
                                        Sizes.size5,
                                      ),
                                      borderSide: BorderSide(
                                        color: Palette().darkPurple,
                                        width: 2,
                                      ),
                                    ),
                                    errorStyle: const TextStyle(
                                      color: Colors.red,
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: Sizes.size15,
                                    ),
                                    suffixIcon: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            right: Sizes.size24,
                                          ),
                                          child: GestureDetector(
                                            onTap: _onPasswordVisibleTap,
                                            child: FaIcon(
                                              _isPasswordInvisible
                                                  ? FontAwesomeIcons.eye
                                                  : FontAwesomeIcons.eyeSlash,
                                              size: Sizes.size16,
                                              color: Palette().darkPurple,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value != null && value.isEmpty) {
                                      return "비밀번호를 입력해주세요.";
                                    }
                                    return null;
                                  },
                                  onSaved: (newValue) {
                                    if (newValue != null) {
                                      formData['password'] = newValue;
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                          Gaps.v36,
                          Row(
                            children: [
                              Expanded(
                                child: MouseRegion(
                                  cursor: SystemMouseCursors.click,
                                  child: GestureDetector(
                                    onTap: _onSubmitTap,
                                    child: SizedBox(
                                      height: Sizes.size44,
                                      child: AnimatedContainer(
                                        duration:
                                            const Duration(milliseconds: 500),
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          color: Palette().darkPurple,
                                          borderRadius: BorderRadius.circular(
                                            Sizes.size5,
                                          ),
                                        ),
                                        child: const Text(
                                          "로그인",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w700,
                                            fontSize: Sizes.size16,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
