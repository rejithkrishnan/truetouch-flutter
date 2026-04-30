import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/splash/splash_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/board_book/board_book_screen.dart';
import '../../features/sound_match/sound_match_screen.dart';
import '../../features/parent_menu/parent_menu_screen.dart';
import '../../features/bubble_pop/bubble_pop_screen.dart';
import '../../shared/widgets/parental_gate.dart';

// ---------- Route names -------------------------------------------------------
abstract final class AppRoutes {
  static const splash = '/';
  static const home = '/home';
  static const boardBook = '/board-book';
  static const soundMatch = '/sound-match';
  static const bubblePop = '/bubble-pop';
  // Parent menu is shown as a dialog/overlay, not a route
}

// ---------- Custom fade transition page ---------------------------------------
class _FadePage<T> extends CustomTransitionPage<T> {
  _FadePage({required super.child, super.key})
      : super(
          transitionsBuilder: (_, animation, __, child) => FadeTransition(
            opacity: CurveTween(curve: Curves.easeInOut).animate(animation),
            child: child,
          ),
          transitionDuration: const Duration(milliseconds: 300),
          reverseTransitionDuration: const Duration(milliseconds: 300),
        );
}

// ---------- Router provider ---------------------------------------------------
final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    routes: [
      ShellRoute(
        builder: (context, state, child) {
          return ParentalGate(
            onUnlocked: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  fullscreenDialog: true,
                  builder: (_) => const ParentMenuDialog(),
                ),
              );
            },
            child: child,
          );
        },
        routes: [
          GoRoute(
            path: AppRoutes.splash,
            pageBuilder: (context, state) => _FadePage(
              key: state.pageKey,
              child: const SplashScreen(),
            ),
          ),
          GoRoute(
            path: AppRoutes.home,
            pageBuilder: (context, state) => _FadePage(
              key: state.pageKey,
              child: const HomeScreen(),
            ),
          ),
          GoRoute(
            path: AppRoutes.boardBook,
            pageBuilder: (context, state) => _FadePage(
              key: state.pageKey,
              child: const BoardBookScreen(),
            ),
          ),
          GoRoute(
            path: AppRoutes.soundMatch,
            pageBuilder: (context, state) => _FadePage(
              key: state.pageKey,
              child: const SoundMatchScreen(),
            ),
          ),
          GoRoute(
            path: AppRoutes.bubblePop,
            pageBuilder: (context, state) => _FadePage(
              key: state.pageKey,
              child: const BubblePopScreen(),
            ),
          ),
        ],
      ),
    ],
  );
});
