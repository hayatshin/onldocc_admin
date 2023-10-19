import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:onldocc_admin/common/models/contract_notifier.dart';
import 'package:onldocc_admin/constants/gaps.dart';
import 'package:onldocc_admin/constants/sizes.dart';
import 'package:onldocc_admin/features/login/models/admin_profile_model.dart';
import 'package:onldocc_admin/features/login/view_models/admin_profile_view_model.dart';

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
  final double? formWidth = 400;
  bool _buttonDisabled = true;
  bool emailTap = false;
  bool passwordTap = false;
  final ContractNotifier _contractNotifier = ContractNotifier();

  Map<String, String> formData = {};
  bool forwardAnimation = true;

  @override
  void initState() {
    super.initState();
    // _animationController = AnimationController(
    //   vsync: this,
    //   duration: const Duration(seconds: 3),
    // );
    // _slideAnimation = Tween<Offset>(
    //   begin: const Offset(0, 1),
    //   end: Offset.zero,
    // ).animate(_animationController);
    // _animationController.forward();

    // _fadeAnimtaion =
    //     Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);
    // _animateSlider();
  }

  // Future<void> _animateSlider() async {
  //   Future.delayed(const Duration(seconds: 2)).then((_) {
  //     int nextPage = 0;
  //     if (forwardAnimation) {
  //       nextPage = _pageController.page!.round() + 1;
  //     } else {
  //       nextPage = _pageController.page!.round() - 1;
  //     }

  //     if (nextPage == 4) {
  //       nextPage = nextPage - 1;
  //       setState(() {
  //         forwardAnimation = false;
  //       });
  //     }
  //     if (nextPage == 0) {
  //       setState(() {
  //         forwardAnimation = true;
  //       });
  //     }
  //     _pageController
  //         .animateToPage(
  //           nextPage,
  //           duration: const Duration(
  //             seconds: 1,
  //           ),
  //           curve: Curves.linear,
  //         )
  //         .then((value) => _animateSlider());
  //   });
  // }

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
          AdminProfileModel adminProfile = await ref
              .read(adminProfileProvider.notifier)
              .login(formData["email"]!, formData["password"]!, context);
          _contractNotifier.changeContractModel(
              contractType: adminProfile.contractType,
              contractName: adminProfile.contractName);
        } catch (e) {
          print("e -> $e");
        }
      }
    }
  }

  void _onChangeValidate() {
    if (emailTap && passwordTap) {
      setState(() {
        _buttonDisabled = !_formKey.currentState!.validate();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Row(
        children: [
          SizedBox(
            width: size.width * 0.5,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: Sizes.size96,
                horizontal: 130,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "인지케어 관리자페이지",
                      style: TextStyle(
                        fontSize: Sizes.size32,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    Gaps.v40,
                    const Text(
                      "회원 관리, 활동 관리, 행사 관리를 한번에!\n오늘도 시니어분들의 건강을 위해 한걸음 더 나아갑니다.",
                      style: TextStyle(
                        fontSize: Sizes.size20,
                        fontWeight: FontWeight.w200,
                        height: 1.7,
                      ),
                    ),
                    Gaps.v80,
                    SizedBox(
                      width: formWidth,
                      child: TextFormField(
                        onFieldSubmitted: (value) => _onSubmitTap(),
                        textAlignVertical: TextAlignVertical.center,
                        style: const TextStyle(
                          fontSize: Sizes.size14,
                          color: Colors.black87,
                        ),
                        decoration: InputDecoration(
                          hintText: "이메일",
                          hintStyle: TextStyle(
                            fontSize: Sizes.size14,
                            color: Colors.grey.shade500,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              Sizes.size5,
                            ),
                          ),
                          errorStyle: TextStyle(
                            color: Theme.of(context).primaryColor,
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              Sizes.size5,
                            ),
                            borderSide: BorderSide(
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              Sizes.size5,
                            ),
                            borderSide: BorderSide(
                              color: Colors.grey.shade300,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              Sizes.size5,
                            ),
                            borderSide: BorderSide(
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: Sizes.size20,
                          ),
                        ),
                        validator: (value) {
                          if (value != null && value.isEmpty) {
                            return "이메일을 입력해주세요.";
                          }
                          return null;
                        },
                        onChanged: (value) {
                          emailTap = true;
                          _onChangeValidate();
                        },
                        onSaved: (newValue) {
                          if (newValue != null) {
                            formData['email'] = newValue;
                          }
                        },
                      ),
                    ),
                    Gaps.v24,
                    SizedBox(
                      width: formWidth,
                      child: TextFormField(
                        onFieldSubmitted: (value) => _onSubmitTap(),
                        textAlignVertical: TextAlignVertical.center,
                        style: const TextStyle(
                          fontSize: Sizes.size14,
                          color: Colors.black87,
                        ),
                        obscureText: _isPasswordInvisible,
                        decoration: InputDecoration(
                          hintText: "비밀번호",
                          hintStyle: TextStyle(
                            fontSize: Sizes.size14,
                            color: Colors.grey.shade500,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              Sizes.size5,
                            ),
                          ),
                          errorStyle: TextStyle(
                            color: Theme.of(context).primaryColor,
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              Sizes.size5,
                            ),
                            borderSide: BorderSide(
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              Sizes.size5,
                            ),
                            borderSide: BorderSide(
                              color: Colors.grey.shade300,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              Sizes.size5,
                            ),
                            borderSide: BorderSide(
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: Sizes.size20,
                          ),
                          suffixIcon: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
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
                                    size: Sizes.size20,
                                    color: Colors.grey.shade500,
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
                        onChanged: (value) {
                          passwordTap = true;
                          _onChangeValidate();
                        },
                        onSaved: (newValue) {
                          if (newValue != null) {
                            formData['password'] = newValue;
                          }
                        },
                      ),
                    ),
                    Gaps.v60,
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: _onSubmitTap,
                        child: SizedBox(
                          width: formWidth,
                          height: Sizes.size44,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 500),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.pink.shade200,
                                )
                              ],
                              color: _buttonDisabled
                                  ? const Color.fromARGB(255, 252, 204, 220)
                                  : Theme.of(context).primaryColor,
                              borderRadius: BorderRadius.circular(
                                Sizes.size5,
                              ),
                            ),
                            child: const AnimatedDefaultTextStyle(
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: Sizes.size16,
                                color: Colors.white,
                              ),
                              duration: Duration(milliseconds: 500),
                              child: Text("로그인"),
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
          Container(
            width: size.width * 0.5,
            height: size.height,
            decoration: BoxDecoration(
              color: const Color(0xff081B35).withOpacity(0.9),
              borderRadius: BorderRadius.circular(
                Sizes.size5,
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                  top: size.height * 0.1,
                  left: size.width * 0.15,
                  child: Image.asset(
                    "assets/app_screen/today_diary.png",
                    width: size.width * 0.15,
                  ),
                ).animate().fadeIn(
                      begin: 0,
                      duration: const Duration(
                        seconds: 1,
                      ),
                    ),
                Positioned(
                  top: size.height * 0.3,
                  left: size.width * 0.2,
                  child: Image.asset(
                    "assets/app_screen/ai_chat.png",
                    width: size.width * 0.15,
                  ),
                )
                    .animate(
                        delay: const Duration(
                      milliseconds: 500,
                    ))
                    .fadeIn(
                      begin: 0,
                      duration: const Duration(
                        seconds: 1,
                      ),
                    )
              ],
            ),
          ),
          // Expanded(
          //   child: Container(
          //     decoration: const BoxDecoration(
          //       color: Color.fromARGB(255, 252, 204, 220),
          //     ),
          //     child: Column(
          //       mainAxisAlignment: MainAxisAlignment.center,
          //       children: [
          //         const Text(
          //           "세상에서 가장 쉬운\n치매 예방 플랫폼",
          //           textAlign: TextAlign.center,
          //           style: TextStyle(
          //             fontSize: Sizes.size24,
          //             fontFamily: "SamlipBasic",
          //           ),
          //         ),
          //         Gaps.v20,
          //         Text(
          //           "오늘도청춘",
          //           textAlign: TextAlign.center,
          //           style: TextStyle(
          //             color: Theme.of(context).primaryColor,
          //             fontSize: Sizes.size40,
          //             fontFamily: "SamlipOutline",
          //           ),
          //         ),
          //         Gaps.v20,
          //         FadeTransition(
          //           opacity: _fadeAnimtaion,
          //           child: SlideTransition(
          //             position: _slideAnimation,
          //             child: Image.asset(
          //               'assets/images/main_phone.png',
          //               width: 430,
          //             ),
          //           ),
          //         ),
          //       ],
          //     ),
          //   ),
          // )
        ],
      ),
    );
  }
}
