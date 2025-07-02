import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:onldocc_admin/common/view_models/menu_notifier.dart';
import 'package:onldocc_admin/constants/gaps.dart';
import 'package:onldocc_admin/constants/sizes.dart';
import 'package:onldocc_admin/features/login/models/admin_profile_model.dart';
import 'package:onldocc_admin/features/login/view_models/admin_profile_view_model.dart';
import 'package:onldocc_admin/injicare_color.dart';
import 'package:onldocc_admin/palette.dart';

class DefaultScreen extends ConsumerWidget {
  final Menu menu;
  final Widget child;

  const DefaultScreen({
    super.key,
    required this.menu,
    required this.child,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final adminModel = ref.read(adminProfileProvider).value;

    if (adminModel != null) {
      return DefaultTemplate(
        adminModel: adminModel,
        menu: menu,
        child: child,
      );
    } else {
      return FutureBuilder(
          future: ref.read(adminProfileProvider.notifier).getAdminProfile(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final adminModel = snapshot.data!;
              return DefaultTemplate(
                adminModel: adminModel,
                menu: menu,
                child: child,
              );
            }
            return Container();
          });
    }
  }
}

class DefaultTemplate extends StatelessWidget {
  final AdminProfileModel adminModel;
  final Menu menu;
  final Widget child;
  const DefaultTemplate({
    super.key,
    required this.adminModel,
    required this.menu,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Container(
      width: size.width,
      color: Palette().bgLightBlue,
      child: Padding(
        padding: const EdgeInsets.only(
          left: 25,
          right: 25,
          top: 20,
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (menu.backButton)
                        Row(
                          children: [
                            MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.of(context).pop();
                                },
                                child: FaIcon(
                                  FontAwesomeIcons.solidCircleLeft,
                                  color: Palette().darkPurple,
                                  size: 35,
                                ),
                              ),
                            ),
                            Gaps.h20,
                          ],
                        ),
                      if (menu.colorButton != null)
                        Row(
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                color: menu.colorButton,
                              ),
                            ),
                            Gaps.h10,
                          ],
                        ),
                      SelectableText(
                        menu.name,
                        style: TextStyle(
                          color: InjicareColor().gray100,
                          fontWeight: FontWeight.w700,
                          fontSize: 24,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        clipBehavior: Clip.hardEdge,
                        child: CachedNetworkImage(
                          imageUrl: adminModel.image,
                          errorWidget: (context, url, error) {
                            return ColorFiltered(
                              colorFilter: ColorFilter.mode(
                                InjicareColor().secondary20,
                                BlendMode.srcIn,
                              ),
                              child: SvgPicture.asset(
                                "assets/svg/profile-user.svg",
                                fit: BoxFit.cover,
                              ),
                            );
                          },
                        ),
                      ),
                      Gaps.h14,
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SelectableText(
                            adminModel.name,
                            style: TextStyle(
                              fontSize: Sizes.size14,
                              fontWeight: FontWeight.w700,
                              color: Palette().darkGray,
                            ),
                          ),
                          if (adminModel.mail.contains("@"))
                            Column(
                              children: [
                                Gaps.v2,
                                SelectableText(
                                  adminModel.mail,
                                  style: TextStyle(
                                    fontSize: Sizes.size10,
                                    fontWeight: FontWeight.w600,
                                    color: Palette().normalGray,
                                  ),
                                ),
                              ],
                            ),
                        ],
                      )
                    ],
                  )
                ],
              ),
              Gaps.v32,
              // child
              child,
              Gaps.v20,
            ],
          ),
        ),
      ),
    );
  }
}
