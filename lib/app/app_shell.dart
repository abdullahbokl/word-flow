import 'package:flutter/material.dart';
import 'package:lexitrack/app/exit_dialog.dart';
import 'package:lexitrack/features/history/presentation/pages/history_page.dart';
import 'package:lexitrack/features/lexicon/presentation/pages/lexicon_page.dart';
import 'package:lexitrack/features/settings/presentation/pages/settings_page.dart';
import 'package:lexitrack/features/text_analyzer/presentation/pages/analyzer_page.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;
  late final PageController _pageController;

  final List<Widget> _pages = const [
    AnalyzerPage(),
    LexiconPage(),
    HistoryPage(),
    SettingsPage(),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTapped(int index) {
    if (index == _currentIndex) return;
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
  }

  void _onPageChanged(int index) {
    if (index == _currentIndex) return;
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) async {
          if (didPop) return;

          if (_currentIndex != 0) {
            _onTapped(0);
            return;
          }

          final exit = await showExitDialog(context);
          if (exit == true) {
            if (context.mounted) {
              Navigator.of(context).pop();
            }
          }
        },
        child: Scaffold(
          body: PageView(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            children: _pages,
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _currentIndex,
            onDestinationSelected: _onTapped,
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.analytics_outlined),
                label: 'Analyzer',
              ),
              NavigationDestination(
                icon: Icon(Icons.menu_book_outlined),
                label: 'Lexicon',
              ),
              NavigationDestination(
                icon: Icon(Icons.history_outlined),
                label: 'History',
              ),
              NavigationDestination(
                icon: Icon(Icons.settings_outlined),
                label: 'Settings',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
