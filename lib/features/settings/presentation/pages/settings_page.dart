import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:lexitrack/core/constants/app_dimensions.dart';
import 'package:lexitrack/core/theme/theme_cubit.dart';
import 'package:lexitrack/core/widgets/app_text.dart';
import 'package:lexitrack/core/widgets/page_header.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding:
                EdgeInsets.symmetric(horizontal: AppDimensions.pagePadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PageHeader(title: 'Settings'),
                SizedBox(height: 32),
                _Section(
                  title: 'Appearance',
                  children: [
                    _ThemeSelector(),
                  ],
                ),
                SizedBox(height: 32),
                _Section(
                  title: 'About',
                  children: [
                    ListTile(
                      leading: Icon(Icons.info_outline),
                      title: AppText.body('Version'),
                      trailing: AppText.body('1.0.0', color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText.label(
          title.toUpperCase(),
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
        const SizedBox(height: 8),
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: Theme.of(context).dividerColor.withAlpha(50),
            ),
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }
}

class _ThemeSelector extends StatelessWidget {
  const _ThemeSelector();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeMode>(
      builder: (context, mode) {
        return Column(
          children: [
            _ThemeOption(
              title: 'System Default',
              isSelected: mode == ThemeMode.system,
              icon: Icons.brightness_auto,
              onTap: () => context.read<ThemeCubit>().setSystem(),
            ),
            const Divider(height: 1),
            _ThemeOption(
              title: 'Light Mode',
              isSelected: mode == ThemeMode.light,
              icon: Icons.light_mode,
              onTap: () => context.read<ThemeCubit>().setLight(),
            ),
            const Divider(height: 1),
            _ThemeOption(
              title: 'Dark Mode',
              isSelected: mode == ThemeMode.dark,
              icon: Icons.dark_mode,
              onTap: () => context.read<ThemeCubit>().setDark(),
            ),
          ],
        );
      },
    );
  }
}

class _ThemeOption extends StatelessWidget {
  const _ThemeOption({
    required this.title,
    required this.isSelected,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final bool isSelected;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      leading: Icon(icon, color: isSelected ? theme.colorScheme.primary : null),
      title: AppText.body(
        title,
        fontWeight: isSelected ? FontWeight.bold : null,
      ),
      trailing: isSelected
          ? Icon(Icons.check_circle, color: theme.colorScheme.primary)
          : null,
      onTap: onTap,
    );
  }
}
