import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:onldocc_admin/common/models/path_extra.dart';
import 'package:onldocc_admin/common/view/sidebar_template.dart';
import 'package:onldocc_admin/common/view_models/menu_notifier.dart';
import 'package:onldocc_admin/features/ca/models/cognition_test_model.dart';
import 'package:onldocc_admin/features/ca/view/alzheimer_test_screen.dart';
import 'package:onldocc_admin/features/ca/view/cognition_test_detail_screen.dart';
import 'package:onldocc_admin/features/ca/view/depression_test_screen.dart';
import 'package:onldocc_admin/features/ca/view/diary_cognition_quiz_screen.dart';
import 'package:onldocc_admin/features/ca/view/diary_cognition_quiz_user_screen.dart';
import 'package:onldocc_admin/features/care/view/care_screen.dart';
import 'package:onldocc_admin/features/dashboard/view/dashboard_screen.dart';
import 'package:onldocc_admin/features/decibel/view/decibel_screen.dart';
import 'package:onldocc_admin/features/event/models/event_model.dart';
import 'package:onldocc_admin/features/event/view/event_detail_count_screen.dart';
import 'package:onldocc_admin/features/event/view/event_detail_multiple_scores_screen.dart';
import 'package:onldocc_admin/features/event/view/event_detail_photo_screen.dart';
import 'package:onldocc_admin/features/event/view/event_detail_quiz_screen.dart';
import 'package:onldocc_admin/features/event/view/event_detail_target_score_screen.dart';
import 'package:onldocc_admin/features/event/view/event_screen.dart';
import 'package:onldocc_admin/features/invitation/%08view/invitation_detail_screen.dart';
import 'package:onldocc_admin/features/invitation/%08view/invitation_screen.dart';
import 'package:onldocc_admin/features/login/repo/authentication_repo.dart';
import 'package:onldocc_admin/features/login/view/login_screen.dart';
import 'package:onldocc_admin/features/notice/views/notice_screen.dart';
import 'package:onldocc_admin/features/ranking/view/ranking_screen.dart';
import 'package:onldocc_admin/features/ranking/view/ranking_user_dashboard_screen.dart';
import 'package:onldocc_admin/features/tv/view/tv_screen.dart';
import 'package:onldocc_admin/features/user-dashboard/view/user_dashboard_screen.dart';
import 'package:onldocc_admin/features/users/view/users_screen.dart';
import 'package:onldocc_admin/utils.dart';

final routerProvider = Provider(
  (ref) {
    return GoRouter(
      initialLocation: "/",
      redirect: (context, state) {
        final isLoggedIn = ref.watch(authRepo).isLoggedIn;
        if (!isLoggedIn) {
          if (state.matchedLocation != LoginScreen.routeURL) return "/";
        }
        return null;
      },
      routes: [
        ShellRoute(
          builder: (context, state, child) {
            switch (state.fullPath) {
              case "/":
                return child;

              case DashboardScreen.routeURL:
                menuNotifier.setSelectedMenu(0, context);
                return SidebarTemplate(selectedMenuURL: 0, child: child);

              case UsersScreen.routeURL:
                menuNotifier.setSelectedMenu(1, context);
                return SidebarTemplate(selectedMenuURL: 1, child: child);

              case "${UsersScreen.routeURL}/:userId":
                menuNotifier.setSelectedMenu(1, context);
                return SidebarTemplate(selectedMenuURL: 1, child: child);

              case RankingScreen.routeURL:
                menuNotifier.setSelectedMenu(2, context);
                return SidebarTemplate(selectedMenuURL: 2, child: child);

              case "${RankingScreen.routeURL}/:userId":
                menuNotifier.setSelectedMenu(2, context);
                return SidebarTemplate(selectedMenuURL: 2, child: child);

              case NoticeScreen.routeURL:
                menuNotifier.setSelectedMenu(3, context);
                return SidebarTemplate(selectedMenuURL: 3, child: child);

              case EventScreen.routeURL:
                menuNotifier.setSelectedMenu(4, context);
                return SidebarTemplate(selectedMenuURL: 4, child: child);

              case "${EventScreen.routeURL}/:eventType/:eventId":
                menuNotifier.setSelectedMenu(4, context);
                return SidebarTemplate(selectedMenuURL: 4, child: child);

              // case QuizScreen.routeURL:
              //   menuNotifier.setSelectedMenu(4, context);
              //   return SidebarTemplate(selectedMenuURL: 4, child: child);

              // case "${QuizScreen.routeURL}/:userId":
              //   menuNotifier.setSelectedMenu(4, context);
              //   return SidebarTemplate(selectedMenuURL: 4, child: child);

              case DiaryCognitionQuizScreen.routeURL:
                menuNotifier.setSelectedMenu(5, context);
                return SidebarTemplate(selectedMenuURL: 5, child: child);

              case "${DiaryCognitionQuizScreen.routeURL}/:userId":
                menuNotifier.setSelectedMenu(5, context);
                return SidebarTemplate(selectedMenuURL: 5, child: child);

              case AlzheimerTestScreen.routeURL:
                menuNotifier.setSelectedMenu(6, context);
                return SidebarTemplate(selectedMenuURL: 6, child: child);

              case "${AlzheimerTestScreen.routeURL}/:testId":
                menuNotifier.setSelectedMenu(6, context);
                return SidebarTemplate(selectedMenuURL: 6, child: child);

              case DepressionTestScreen.routeURL:
                menuNotifier.setSelectedMenu(7, context);
                return SidebarTemplate(selectedMenuURL: 7, child: child);

              case "${DepressionTestScreen.routeURL}/:testId":
                menuNotifier.setSelectedMenu(7, context);
                return SidebarTemplate(selectedMenuURL: 7, child: child);

              case TvScreen.routeURL:
                menuNotifier.setSelectedMenu(8, context);
                return SidebarTemplate(selectedMenuURL: 8, child: child);

              case CareScreen.routeURL:
                menuNotifier.setSelectedMenu(9, context);
                return SidebarTemplate(selectedMenuURL: 9, child: child);

              case DecibelScreen.routeURL:
                menuNotifier.setSelectedMenu(10, context);
                return SidebarTemplate(selectedMenuURL: 10, child: child);

              case InvitationScreen.routeURL:
                menuNotifier.setSelectedMenu(11, context);
                return SidebarTemplate(selectedMenuURL: 11, child: child);

              case "${InvitationScreen.routeURL}/:userId":
                menuNotifier.setSelectedMenu(11, context);
                return SidebarTemplate(selectedMenuURL: 11, child: child);
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
              name: DashboardScreen.routeName,
              path: DashboardScreen.routeURL,
              pageBuilder: (context, state) => NoTransitionPage(
                key: state.pageKey,
                child: const DashboardScreen(),
              ),
            ),
            GoRoute(
                name: UsersScreen.routeName,
                path: UsersScreen.routeURL,
                pageBuilder: (context, state) => NoTransitionPage(
                      key: state.pageKey,
                      child: const UsersScreen(),
                    ),
                routes: [
                  GoRoute(
                    path: ":userId",
                    pageBuilder: (context, state) => MaterialPage(
                      key: state.pageKey,
                      child: UserDashboardScreen(
                        userId: state.pathParameters["userId"],
                        userName: state.extra != null
                            ? (state.extra as PathExtra).userName
                            : "",
                      ),
                    ),
                  )
                ]),
            GoRoute(
                name: RankingScreen.routeName,
                path: RankingScreen.routeURL,
                pageBuilder: (context, state) => NoTransitionPage(
                      key: state.pageKey,
                      child: const RankingScreen(),
                    ),
                routes: [
                  GoRoute(
                    path: ":userId",
                    pageBuilder: (context, state) {
                      final startSeconds = state.uri.queryParameters["start"];
                      final endSeconds = state.uri.queryParameters["end"];
                      return MaterialPage(
                        key: state.pageKey,
                        child: RankingUserDashboardScreen(
                          userId: state.pathParameters["userId"],
                          userName: state.extra != null
                              ? (state.extra as DatePathExtra).userName
                              : null,
                          dateRange: state.extra != null
                              ? (state.extra as DatePathExtra).dateRange
                              : encodeSeconds(startSeconds!, endSeconds!),
                        ),
                      );
                    },
                  )
                ]),
            GoRoute(
              name: NoticeScreen.routeName,
              path: NoticeScreen.routeURL,
              pageBuilder: (context, state) => NoTransitionPage(
                key: state.pageKey,
                child: const NoticeScreen(),
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
                  path: ":eventType/:eventId",
                  pageBuilder: (context, state) {
                    final eventType = state.pathParameters["eventType"];
                    final eventId = state.pathParameters["eventId"];

                    final eventModel = state.extra as EventModel?;

                    return MaterialPage(
                      key: state.pageKey,
                      child: eventType == EventType.targetScore.name
                          ? EventDetailTargetScoreScreen(
                              eventId: eventId,
                              eventModel: eventModel,
                            )
                          : eventType == EventType.multipleScores.name
                              ? EventDetailMultipleScoresScreen(
                                  eventId: eventId,
                                  eventModel: eventModel,
                                )
                              : eventType == EventType.count.name
                                  ? EventDetailCountScreen(
                                      eventId: eventId, eventModel: eventModel)
                                  : eventType == EventType.quiz.name
                                      ? EventDetailQuizScreen(
                                          eventId: eventId,
                                          eventModel: eventModel)
                                      : eventType == EventType.photo.name
                                          ? EventDetailPhotoScreen(
                                              eventId: eventId,
                                              eventModel: eventModel)
                                          : Container(),
                    );
                  },
                ),
              ],
            ),
            GoRoute(
              name: DiaryCognitionQuizScreen.routeName,
              path: DiaryCognitionQuizScreen.routeURL,
              pageBuilder: (context, state) => NoTransitionPage(
                key: state.pageKey,
                child: const DiaryCognitionQuizScreen(),
              ),
              routes: [
                GoRoute(
                  path: ":userId",
                  pageBuilder: (context, state) {
                    return MaterialPage(
                      key: state.pageKey,
                      child: DiaryCognitionQuizUserScreen(
                        userId: state.pathParameters["userId"],
                        userName: state.extra != null
                            ? (state.extra as PathExtra).userName
                            : "",
                      ),
                    );
                  },
                )
              ],
            ),
            GoRoute(
              name: AlzheimerTestScreen.routeName,
              path: AlzheimerTestScreen.routeURL,
              pageBuilder: (context, state) => NoTransitionPage(
                key: state.pageKey,
                child: const AlzheimerTestScreen(),
              ),
              routes: [
                GoRoute(
                  path: ":testId",
                  pageBuilder: (context, state) => MaterialPage(
                    key: state.pageKey,
                    child: CognitionTestDetailScreen(
                      model: state.extra as CognitionTestModel,
                    ),
                  ),
                )
              ],
            ),
            GoRoute(
              name: DepressionTestScreen.routeName,
              path: DepressionTestScreen.routeURL,
              pageBuilder: (context, state) => NoTransitionPage(
                key: state.pageKey,
                child: const DepressionTestScreen(),
              ),
              routes: [
                GoRoute(
                  path: ":testId",
                  pageBuilder: (context, state) => MaterialPage(
                    key: state.pageKey,
                    child: CognitionTestDetailScreen(
                      model: state.extra as CognitionTestModel,
                    ),
                  ),
                )
              ],
            ),
            GoRoute(
              name: TvScreen.routeName,
              path: TvScreen.routeURL,
              pageBuilder: (context, state) => NoTransitionPage(
                key: state.pageKey,
                child: const TvScreen(),
              ),
            ),
            GoRoute(
              name: CareScreen.routeName,
              path: CareScreen.routeURL,
              pageBuilder: (context, state) => NoTransitionPage(
                key: state.pageKey,
                child: const CareScreen(),
              ),
            ),
            GoRoute(
              name: DecibelScreen.routeName,
              path: DecibelScreen.routeURL,
              pageBuilder: (context, state) => NoTransitionPage(
                key: state.pageKey,
                child: const DecibelScreen(),
              ),
            ),
            GoRoute(
                name: InvitationScreen.routeName,
                path: InvitationScreen.routeURL,
                pageBuilder: (context, state) => NoTransitionPage(
                      key: state.pageKey,
                      child: const InvitationScreen(),
                    ),
                routes: [
                  GoRoute(
                    path: ":userId",
                    pageBuilder: (context, state) {
                      // final startSeconds = state.uri.queryParameters["start"];
                      // final endSeconds = state.uri.queryParameters["end"];
                      return MaterialPage(
                        key: state.pageKey,
                        child: InvitationDetailScreen(
                          userId: state.pathParameters["userId"],
                          userName: state.extra != null
                              ? (state.extra as PathExtra).userName
                              : null,
                          // dateRange: state.extra != null
                          //     ? (state.extra as DatePathExtra).dateRange
                          //     : encodeSeconds(startSeconds!, endSeconds!),
                        ),
                      );
                    },
                  )
                ]),
          ],
        ),
      ],
    );
  },
);
