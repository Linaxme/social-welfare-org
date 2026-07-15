import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:somiti_app/features/auth/presentation/login_screen.dart';
import 'package:somiti_app/features/collections/presentation/add_donation_screen.dart';
import 'package:somiti_app/features/collections/presentation/collection_history_screen.dart';
import 'package:somiti_app/features/dashboard/presentation/dashboard_screen.dart';
import 'package:somiti_app/features/help/presentation/add_help_screen.dart';
import 'package:somiti_app/features/help/presentation/help_detail_screen.dart';
import 'package:somiti_app/features/help/presentation/help_list_screen.dart';
import 'package:somiti_app/features/members/presentation/add_member_screen.dart';
import 'package:somiti_app/features/members/presentation/edit_member_screen.dart';
import 'package:somiti_app/features/members/presentation/member_list_screen.dart';
import 'package:somiti_app/features/members/presentation/member_profile_screen.dart';
import 'package:somiti_app/features/profile/presentation/profile_screen.dart';
import 'package:somiti_app/features/reports/presentation/reports_screen.dart';
import 'package:somiti_app/features/settings/presentation/settings_screen.dart';
import 'package:somiti_app/features/shell/home_shell.dart';
import 'package:somiti_app/shared/data/app_session.dart';

final GlobalKey<NavigatorState> _rootKey = GlobalKey<NavigatorState>();

GoRouter createRouter() {
  return GoRouter(
    navigatorKey: _rootKey,
    initialLocation: '/login',
    refreshListenable: AppSession.instance,
    redirect: (context, state) {
      final session = AppSession.instance;
      if (!session.isReady) return null;
      final loggingIn = state.matchedLocation == '/login';
      if (!session.isLoggedIn && !loggingIn) return '/login';
      if (session.isLoggedIn && loggingIn) return '/home';
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return HomeShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) => const DashboardScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home/members',
                builder: (context, state) => const MemberListScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home/help',
                builder: (context, state) => const HelpListScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home/settings',
                builder: (context, state) => const SettingsScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/settings',
        parentNavigatorKey: _rootKey,
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/reports',
        parentNavigatorKey: _rootKey,
        builder: (context, state) => const ReportsScreen(),
      ),
      GoRoute(
        path: '/profile',
        parentNavigatorKey: _rootKey,
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/help',
        parentNavigatorKey: _rootKey,
        builder: (context, state) => const HelpListScreen(),
      ),
      GoRoute(
        path: '/collections',
        parentNavigatorKey: _rootKey,
        builder: (context, state) => const CollectionHistoryScreen(),
      ),
      GoRoute(
        path: '/members/new',
        parentNavigatorKey: _rootKey,
        builder: (context, state) => const AddMemberScreen(),
      ),
      GoRoute(
        path: '/members/:id/edit',
        parentNavigatorKey: _rootKey,
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return EditMemberScreen(memberId: id);
        },
      ),
      GoRoute(
        path: '/members/:id',
        parentNavigatorKey: _rootKey,
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return MemberProfileScreen(memberId: id);
        },
      ),
      GoRoute(
        path: '/donation/new',
        parentNavigatorKey: _rootKey,
        builder: (context, state) {
          final donorId = state.uri.queryParameters['donorId'];
          return AddDonationScreen(preselectedDonorId: donorId);
        },
      ),
      GoRoute(
        path: '/help/new',
        parentNavigatorKey: _rootKey,
        builder: (context, state) => const AddHelpScreen(),
      ),
      GoRoute(
        path: '/help/:id',
        parentNavigatorKey: _rootKey,
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return HelpDetailScreen(helpId: id);
        },
      ),
    ],
  );
}
