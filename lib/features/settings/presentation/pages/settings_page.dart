import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wordflow/core/constants/app_dimensions.dart';
import 'package:wordflow/core/theme/theme_cubit.dart';
import 'package:wordflow/core/utils/ui_utils.dart';
import 'package:wordflow/core/widgets/app_text.dart';
import 'package:wordflow/core/widgets/page_header.dart';
import 'package:wordflow/features/excluded_words/presentation/pages/excluded_words_screen.dart';
import 'package:wordflow/features/settings/presentation/blocs/backup/backup_bloc.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.pagePadding),
            child: BlocListener<BackupBloc, BackupState>(
              listenWhen: (previous, current) =>
                  previous.message != current.message &&
                  current.message != null,
              listener: (context, state) {
                AppUIUtils.showSnackBar(
                  context,
                  message: state.message!,
                );
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const PageHeader(title: 'Settings'),
                  const SizedBox(height: 32),
                  const _Section(
                    title: 'Appearance',
                    children: [
                      _ThemeSelector(),
                    ],
                  ),
                  const SizedBox(height: 32),
                  _Section(
                    title: 'Analysis Settings',
                    children: [
                      ListTile(
                        leading: const Icon(Icons.block),
                        title: const AppText.body('Excluded Words'),
                        subtitle: const AppText.body(
                          "Words that won't be counted in analysis",
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const ExcludedWordsScreen(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  const _Section(
                    title: 'Data & Sync',
                    children: [
                      _BackupSettings(),
                    ],
                  ),
                  const SizedBox(height: 32),
                  const _Section(
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

class _BackupSettings extends StatelessWidget {
  const _BackupSettings();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BackupBloc, BackupState>(
      builder: (context, state) {
        if (!state.isAuthenticated) {
          return ListTile(
            leading: const Icon(Icons.cloud_off),
            title: const AppText.body('Backup to Google Drive'),
            subtitle: const AppText.body(
              'Sign in to enable cloud backup',
              color: Colors.grey,
              fontSize: 12,
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.read<BackupBloc>().add(ConnectDrive()),
          );
        }

        return Column(
          children: [
            ListTile(
              leading: const Icon(Icons.cloud_done, color: Colors.green),
              title: const AppText.body('Google Drive Connected'),
              subtitle: AppText.body(
                state.userEmail ?? 'Authenticated',
                color: Colors.grey,
                fontSize: 12,
              ),
              trailing: TextButton(
                onPressed: () =>
                    context.read<BackupBloc>().add(SignOutBackup()),
                child: const AppText.body('Sign Out', color: Colors.red),
              ),
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.backup),
              title: const AppText.body('Backup Now'),
              subtitle: const AppText.body(
                'Upload your local database to Drive',
                color: Colors.grey,
                fontSize: 12,
              ),
              onTap: state.status == BackupStatus.loading
                  ? null
                  : () => context.read<BackupBloc>().add(PerformBackup()),
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.restore),
              title: const AppText.body('Restore from Drive'),
              subtitle: const AppText.body(
                'Replace local data with cloud backup',
                color: Colors.grey,
                fontSize: 12,
              ),
              onTap: state.status == BackupStatus.loading
                  ? null
                  : () => _showRestoreDialog(context),
            ),
            const Divider(height: 1),
            if (state.lastBackup != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                color: Theme.of(context).colorScheme.primary.withAlpha(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const AppText.label('CLOUD BACKUP STATUS', fontSize: 10),
                    const SizedBox(height: 4),
                    AppText.body(
                      'Last synced: ${state.lastBackup!.modifiedTime.toString().split('.')[0]}',
                      fontSize: 12,
                    ),
                    AppText.body(
                      'File size: ${(state.lastBackup!.size / 1024).toStringAsFixed(1)} KB',
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ],
                ),
              ),
            if (state.status == BackupStatus.loading)
              const LinearProgressIndicator(),
          ],
        );
      },
    );
  }

  void _showRestoreDialog(BuildContext context) {
    unawaited(showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const AppText.label('Restore Data?'),
        content: const AppText.body(
          'This will overwrite your current local data with the backup from Google Drive. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const AppText.body('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<BackupBloc>().add(PerformRestore());
            },
            child: const AppText.body('Restore', color: Colors.red),
          ),
        ],
      ),
    ));
  }
}
