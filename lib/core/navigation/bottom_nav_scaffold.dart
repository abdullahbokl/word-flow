import 'package:flutter/material.dart';
import 'package:wordflow/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:wordflow/features/lexicon/presentation/pages/lexicon_page.dart';
import 'package:wordflow/features/settings/presentation/pages/settings_page.dart';
import 'package:wordflow/features/text_analyzer/presentation/pages/analyzer_page.dart';

class MainAppScaffold extends StatefulWidget {
  const MainAppScaffold({super.key});

  @override
  State<MainAppScaffold> createState() => _MainAppScaffoldState();
}

class _MainAppScaffoldState extends State<MainAppScaffold> {
  int _currentIndex = 0;

  final List<GlobalKey<NavigatorState>> _navigatorKeys = [
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
  ];

  void _onTapped(int index) {
    if (index == _currentIndex) {
      // Pop to first route if already on this tab
      _navigatorKeys[index].currentState?.popUntil((route) => route.isFirst);
    } else {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildTabNavigator(0, const DashboardPage()),
          _buildTabNavigator(1, const AnalyzerPage()),
          _buildTabNavigator(2, const LexiconPage()),
          _buildTabNavigator(3, const SettingsPage()),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: _onTapped,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_rounded),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.analytics_rounded),
            label: 'Analyzer',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_rounded),
            label: 'Lexicon',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_rounded),
            label: 'Settings',
          ),
        ],
      ),
    );
  }

  Widget _buildTabNavigator(int index, Widget rootPage) {
    return Navigator(
      key: _navigatorKeys[index],
      onGenerateRoute: (routeSettings) {
        return MaterialPageRoute(
          builder: (context) => rootPage,
        );
      },
    );
  }
}
