import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:onldocc_admin/common/view/sidebar_template.dart';
import 'package:onldocc_admin/features/event/view/event_detail_screen.dart';
import 'package:onldocc_admin/features/event/view/event_screen.dart';
import 'package:onldocc_admin/features/login/repo/authentication_repo.dart';
import 'package:onldocc_admin/features/login/view/login_screen.dart';
import 'package:onldocc_admin/features/mood/view/mood_screen.dart';
import 'package:onldocc_admin/features/ranking/models/ranking_step_extra.dart';
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
              case "${RankingScreen.routeURL}/${RankingUsersScreen.stepRouteURL}/:index":
                return SidebarTemplate(selectedMenuURL: 2, child: child);
              case "${RankingScreen.routeURL}/${RankingDiaryScreen.routeURL}":
                return SidebarTemplate(selectedMenuURL: 3, child: child);
              case MoodScreen.routeURL:
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
            GoRoute(
              name: RankingScreen.routeName,
              path: RankingScreen.routeURL,
              pageBuilder: (context, state) => NoTransitionPage(
                key: state.pageKey,
                child: const RankingScreen(),
              ),
              routes: [
                GoRoute(
                    name: RankingUsersScreen.stepRouteName,
                    path: RankingUsersScreen.stepRouteURL,
                    pageBuilder: (context, state) => NoTransitionPage(
                          key: state.pageKey,
                          child: const RankingUsersScreen(),
                        ),
                    routes: [
                      GoRoute(
                        path: ":index",
                        pageBuilder: (context, state) => MaterialPage(
                          key: state.pageKey,
                          child: RankingStepScreen(
                            index: state.pathParameters["index"],
                            userId: (state.extra as RankingStepExtra).userId,
                            userName:
                                (state.extra as RankingStepExtra).userName,
                          ),
                        ),
                      )
                    ]),
                GoRoute(
                  name: RankingDiaryScreen.routeName,
                  path: RankingDiaryScreen.routeURL,
                  pageBuilder: (context, state) => NoTransitionPage(
                    key: state.pageKey,
                    child: const RankingDiaryScreen(),
                  ),
                ),
              ],
            ),
            GoRoute(
              name: MoodScreen.routeName,
              path: MoodScreen.routeURL,
              pageBuilder: (context, state) => NoTransitionPage(
                key: state.pageKey,
                child: const MoodScreen(),
              ),
            ),
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
