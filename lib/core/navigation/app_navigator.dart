import 'package:flutter/material.dart';

import '../../../features/history/presentation/pages/history_detail_page.dart';

class AppNavigator {
  static final key = GlobalKey<NavigatorState>();

  static NavigatorState get navigator => key.currentState!;

  static void push(Widget page) {
    navigator.push(MaterialPageRoute(builder: (_) => page));
  }

  static void pushReplacement(Widget page) {
    navigator.pushReplacement(MaterialPageRoute(builder: (_) => page));
  }

  static void pop<T>([T? result]) {
    navigator.pop(result);
  }

  static bool canPop() => navigator.canPop();

  // Route-specific helpers
  static void toHistoryDetail(int id) {
    push(HistoryDetailPage(id: id));
  }
}
