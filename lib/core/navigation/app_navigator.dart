import 'package:flutter/material.dart';

import 'package:lexitrack/features/history/presentation/pages/history_detail_page.dart';

class AppNavigator {
  static final key = GlobalKey<NavigatorState>();

  static NavigatorState get navigator => key.currentState!;

  static void push(Widget page) {
    navigator.push(_CustomPageRoute(builder: (_) => page));
  }

  static void pushReplacement(Widget page) {
    navigator.pushReplacement(_CustomPageRoute(builder: (_) => page));
  }

  static void pop<T>([T? result]) {
    navigator.pop(result);
  }

  static bool canPop() => navigator.canPop();

  static void toHistoryDetail(int id) {
    push(HistoryDetailPage(id: id));
  }
}

class _CustomPageRoute<T> extends PageRouteBuilder<T> {
  _CustomPageRoute({required WidgetBuilder builder})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) =>
              builder(context),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0);
            const end = Offset.zero;
            const curve = Curves.easeInOutCubic;

            final tween = Tween(begin: begin, end: end).chain(
              CurveTween(curve: curve),
            );
            final fadeTween = Tween(begin: 0.0, end: 1.0);

            return SlideTransition(
              position: animation.drive(tween),
              child: FadeTransition(
                opacity: animation.drive(fadeTween),
                child: child,
              ),
            );
          },
          transitionDuration: const Duration(milliseconds: 300),
          reverseTransitionDuration: const Duration(milliseconds: 250),
        );
}
