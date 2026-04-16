import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wordflow/core/theme/design_tokens.dart';
import 'package:wordflow/features/dashboard/presentation/widgets/analytics_section.dart';
import 'package:wordflow/features/dashboard/presentation/widgets/progress_section.dart';
import 'package:wordflow/features/review/presentation/blocs/review_bloc.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  void initState() {
    super.initState();
    // Trigger loading due reviews for the progress section
    context.read<ReviewBloc>().add(const LoadDueReviews());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppTokens.space24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Dashboard',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(height: AppTokens.space32),
              const ProgressSection(),
              const SizedBox(height: AppTokens.space48),
              const AnalyticsSection(),
            ],
          ),
        ),
      ),
    );
  }
}
