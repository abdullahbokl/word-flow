import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:wordflow/app/di/injection.dart';
import 'package:wordflow/core/constants/app_dimensions.dart';
import 'package:wordflow/core/export/export_result.dart';
import 'package:wordflow/core/export/pdf_export_service.dart';
import 'package:wordflow/core/notifications/notification_service.dart';
import 'package:wordflow/core/theme/theme_cubit.dart';
import 'package:wordflow/core/utils/ui_utils.dart';
import 'package:wordflow/core/widgets/app_text.dart';
import 'package:wordflow/core/widgets/page_header.dart';
import 'package:wordflow/features/excluded_words/presentation/pages/excluded_words_screen.dart';
import 'package:wordflow/features/lexicon/presentation/blocs/lexicon/lexicon_bloc.dart';
import 'package:wordflow/features/settings/presentation/blocs/backup/backup_bloc.dart';
import 'package:wordflow/features/text_analyzer/presentation/blocs/analyzer/analyzer_bloc.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _aiEnabled = true;
  bool _notificationsEnabled = true;

  Future<void> _exportWords() async {
    final words = context.read<LexiconBloc>().state.status.data;
    if (words == null || words.isEmpty) {
      AppUIUtils.showSnackBar(context, message: 'No words to export');
      return;
    }

    try {
      final directory = await getApplicationDocumentsDirectory();
      final filePath =
          '${directory.path}/word_list_${DateTime.now().millisecondsSinceEpoch}.pdf';
      const exportService = PdfExportService();
      final result = await exportService.exportWords(words, filePath);

      if (!mounted) return;
      switch (result) {
        case ExportSuccess(:final path):
          AppUIUtils.showSnackBar(context, message: 'Exported to: $path');
        case ExportFailure(:final message):
          AppUIUtils.showSnackBar(context, message: message);
      }
    } catch (e) {
      if (!mounted) return;
      AppUIUtils.showSnackBar(context, message: 'Export failed: $e');
    }
  }

  Future<void> _exportAnalysis() async {
    final analysis = context.read<AnalyzerBloc>().state.status.data;
    if (analysis == null) {
      AppUIUtils.showSnackBar(context, message: 'No analysis to export');
      return;
    }

    try {
      final directory = await getApplicationDocumentsDirectory();
      final filePath =
          '${directory.path}/analysis_${DateTime.now().millisecondsSinceEpoch}.pdf';
      const exportService = PdfExportService();
      final result = await exportService.exportAnalysis(analysis, filePath);

      if (!mounted) return;
      switch (result) {
        case ExportSuccess(:final path):
          AppUIUtils.showSnackBar(context, message: 'Exported to: $path');
        case ExportFailure(:final message):
          AppUIUtils.showSnackBar(context, message: message);
      }
    } catch (e) {
      if (!mounted) return;
      AppUIUtils.showSnackBar(context, message: 'Export failed: $e');
    }
  }

  Future<void> _sendTestNotification() async {
    try {
      final service = sl<NotificationService>();
      await service.scheduleNotification(
        999,
        'Test Notification',
        'This is a test notification from WordFlow settings.',
        DateTime.now().add(const Duration(seconds: 5)),
      );
      if (!mounted) return;
      AppUIUtils.showSnackBar(context,
          message: 'Test notification scheduled (5s delay)');
    } catch (e) {
      if (!mounted) return;
      AppUIUtils.showSnackBar(context,
          message: 'Failed to schedule notification: $e');
    }
  }

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
                    title: 'AI Configuration',
                    children: [
                      SwitchListTile(
                        secondary: const Icon(Icons.auto_awesome),
                        title: const AppText.body('Enable AI Features'),
                        subtitle: const AppText.body(
                          'Use AI for meanings and examples',
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                        value: _aiEnabled,
                        onChanged: (val) => setState(() => _aiEnabled = val),
                      ),
                      const Divider(height: 1),
                      const ListTile(
                        leading: Icon(Icons.info_outline),
                        title: AppText.body('AI Provider'),
                        trailing:
                            AppText.body('Mock Provider', color: Colors.grey),
                      ),
                      const Divider(height: 1),
                      const ListTile(
                        leading: Icon(Icons.key),
                        title: AppText.body('API Key'),
                        subtitle: AppText.body(
                          'Coming soon',
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                        enabled: false,
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  _Section(
                    title: 'Notifications',
                    children: [
                      SwitchListTile(
                        secondary: const Icon(Icons.notifications_active),
                        title: const AppText.body('Daily Reminders'),
                        subtitle: const AppText.body(
                          'Get reminded to review words',
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                        value: _notificationsEnabled,
                        onChanged: (val) =>
                            setState(() => _notificationsEnabled = val),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.notification_important),
                        title: const AppText.body('Test Notification'),
                        onTap: _sendTestNotification,
                      ),
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
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.label),
                        title: const AppText.body('Manage Tags'),
                        subtitle: const AppText.body(
                          'Organize your words with custom tags',
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          AppUIUtils.showSnackBar(context,
                              message: 'Tag management coming soon');
                        },
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
                  _Section(
                    title: 'Export Data',
                    children: [
                      ListTile(
                        leading: const Icon(Icons.picture_as_pdf),
                        title: const AppText.body('Export Words'),
                        subtitle: const AppText.body(
                          'Save your lexicon as PDF',
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                        onTap: _exportWords,
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.analytics),
                        title: const AppText.body('Export Analysis'),
                        subtitle: const AppText.body(
                          'Save latest analysis as PDF',
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                        onTap: _exportAnalysis,
                      ),
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
