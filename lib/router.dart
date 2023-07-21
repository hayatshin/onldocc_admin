import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:onldocc_admin/common/view/sidebar_template.dart';
import 'package:onldocc_admin/features/event/view/event_detail_screen.dart';
import 'package:onldocc_admin/features/event/view/event_screen.dart';
import 'package:onldocc_admin/features/login/repo/authentication_repo.dart';
import 'package:onldocc_admin/features/login/view/login_screen.dart';
import 'package:onldocc_admin/features/ca/view/ca_screen.dart';
import 'package:onldocc_admin/features/ranking/view/ranking_diary_screen.dart';
import 'package:onldocc_admin/features/ranking/view/ranking_screen.dart';
import 'package:onldocc_admin/features/ranking/view/ranking_step_screen.dart';
import 'package:onldocc_admin/features/ranking/view/ranking_users_screen.dart';
import 'package:onldocc_admin/features/users/view/users_screen.dart';

final routerProvider = Provider(
  (ref) {
    return GoRouter(
      initialLocation: "/",
      redirect: (context, state) {
        final isLoggedIn = ref.read(authRepo).isLoggedIn;
        if (!isLoggedIn) {
          if (state.location != LoginScreen.routeURL) return "/";
        }
        return null;
      },
      routes: [
        ShellRoute(
          builder: (context, state, child) {
            switch (state.fullPath) {
              case "/":
                return child;
              case UsersScreen.routeURL:
                return SidebarTemplate(selectedMenuURL: 0, child: child);
              case RankingScreen.routeURL:
                return SidebarTemplate(selectedMenuURL: 1, child: child);
              case "${RankingScreen.routeURL}/${RankingUsersScreen.stepRouteURL}":
                return SidebarTemplate(selectedMenuURL: 2, child: child);
              case "${RankingScreen.routeURL}/${RankingUsersScreen.stepRouteURL}/:userId":
                return SidebarTemplate(selectedMenuURL: 2, child: child);
              case "${RankingScreen.routeURL}/${RankingUsersScreen.diaryRouteURL}":
                return SidebarTemplate(selectedMenuURL: 3, child: child);
              case "${RankingScreen.routeURL}/${RankingUsersScreen.diaryRouteURL}/:userId":
                return SidebarTemplate(selectedMenuURL: 3, child: child);
              case CaScreen.routeURL:
                return SidebarTemplate(selectedMenuURL: 4, child: child);
              case "${CaScreen.routeURL}/:userId":
                return SidebarTemplate(selectedMenuURL: 4, child: child);
              case EventScreen.routeURL:
                return SidebarTemplate(selectedMenuURL: 5, child: child);
            }
            return child;
          },
          routes: [
            GoRoute(
              name: LoginScreen.routeName,
              path: LoginScreen.routeURL,
              pageBuilder: (context, state) => NoTransitionPage(
                key: state.pageKey,
                child: const LoginScreen(),
              ),
            ),
            GoRoute(
              name: UsersScreen.routeName,
              path: UsersScreen.routeURL,
              pageBuilder: (context, state) => NoTransitionPage(
                key: state.pageKey,
                child: const UsersScreen(),
              ),
            ),
            // ranking
            GoRoute(
              name: RankingScreen.routeName,
              path: RankingScreen.routeURL,
              pageBuilder: (context, state) => NoTransitionPage(
                key: state.pageKey,
                child: const RankingScreen(),
              ),
              routes: [
                // ranking/step
                GoRoute(
                  name: RankingUsersScreen.stepRouteName,
                  path: RankingUsersScreen.stepRouteURL,
                  pageBuilder: (context, state) => NoTransitionPage(
                    key: state.pageKey,
                    child: const RankingUsersScreen(
                      rankingType: "step",
                    ),
                  ),
                  routes: [
                    // ranking/step/:index
                    GoRoute(
                      path: ":userId",
                      pageBuilder: (context, state) => MaterialPage(
                        key: state.pageKey,
                        child: RankingStepScreen(
                          // index: state.pathParameters["index"],
                          userId: state.pathParameters["userId"],
                          // userName: (state.extra as RankingExtra).userName,
                          rankingType: "걸음수",
                        ),
                      ),
                    )
                  ],
                ),
                // ranking/diary
                GoRoute(
                  name: RankingUsersScreen.diaryRouteName,
                  path: RankingUsersScreen.diaryRouteURL,
                  pageBuilder: (context, state) => NoTransitionPage(
                    key: state.pageKey,
                    child: const RankingUsersScreen(
                      rankingType: "diary",
                    ),
                  ),
                  routes: [
                    GoRoute(
                      path: ":userId",
                      pageBuilder: (context, state) => MaterialPage(
                        key: state.pageKey,
                        child: RankingDiaryScreen(
                          // index: state.pathParameters["index"],
                          userId: state.pathParameters["userId"],
                          // userName: (state.extra as RankingExtra).userName,
                          rankingType: "일기",
                        ),
                      ),
                    )
                  ],
                ),
              ],
            ),
            GoRoute(
                name: CaScreen.routeName,
                path: CaScreen.routeURL,
                pageBuilder: (context, state) => NoTransitionPage(
                      key: state.pageKey,
                      child: const RankingUsersScreen(
                        rankingType: "ca",
                      ),
                    ),
                routes: [
                  GoRoute(
                    path: ":userId",
                    pageBuilder: (context, state) => MaterialPage(
                      key: state.pageKey,
                      child: CaScreen(
                        // index: state.pathParameters["index"],
                        userId: state.pathParameters["userId"],
                        // userName: (state.extra as RankingExtra).userName,
                        rankingType: "인지",
                      ),
                    ),
                  )
                ]),
            GoRoute(
              name: EventScreen.routeName,
              path: EventScreen.routeURL,
              pageBuilder: (context, state) => NoTransitionPage(
                key: state.pageKey,
                child: const EventScreen(),
              ),
              routes: [
                GoRoute(
                  path: ":eventId",
                  pageBuilder: (context, state) => NoTransitionPage(
                    key: state.pageKey,
                    child: EventDetailScreen(
                        eventId: state.pathParameters['eventId']),
                  ),
                ),
              ],
            ),
          ],
        )
      ],
    );
  },
);
