import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wordflow/core/domain/entities/word_entity.dart';
import 'package:wordflow/core/theme/app_colors.dart';
import 'package:wordflow/features/review/presentation/blocs/review_bloc.dart';

class ReviewSessionPage extends StatefulWidget {
  const ReviewSessionPage({super.key});

  @override
  State<ReviewSessionPage> createState() => _ReviewSessionPageState();
}

class _ReviewSessionPageState extends State<ReviewSessionPage> {
  bool _isRevealed = false;
  int _initialTotal = 0;
  int _reviewedCount = 0;
  int _goodCount = 0;
  int? _currentWordId;

  @override
  void initState() {
    super.initState();
    context.read<ReviewBloc>().add(const LoadDueReviews());
  }

  void _onReveal() {
    setState(() {
      _isRevealed = true;
    });
  }

  void _onSubmit(WordEntity word, int quality) {
    context
        .read<ReviewBloc>()
        .add(SubmitReview(wordId: word.id, quality: quality));
    setState(() {
      _isRevealed = false;
      _reviewedCount++;
      if (quality >= 4) _goodCount++;
    });
  }

  void _onSkip(WordEntity word) {
    context.read<ReviewBloc>().add(SkipReview(word.id));
    setState(() {
      _isRevealed = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ReviewBloc, ReviewState>(
      listener: (context, state) {
        if (state is ReviewLoaded) {
          if (_initialTotal == 0) {
            _initialTotal = state.dueWords.length;
          }
          if (state.dueWords.isNotEmpty &&
              state.dueWords.first.id != _currentWordId) {
            _currentWordId = state.dueWords.first.id;
            _isRevealed = false;
          }
        }
      },
      builder: (context, state) {
        final showSkip = state is ReviewLoaded && state.dueWords.isNotEmpty;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Review Session'),
            actions: [
              if (showSkip)
                IconButton(
                  icon: const Icon(Icons.skip_next),
                  tooltip: 'Skip Word',
                  onPressed: () => _onSkip(state.dueWords.first),
                ),
            ],
          ),
          body: SafeArea(
            child: _buildBody(state),
          ),
        );
      },
    );
  }

  Widget _buildBody(ReviewState state) {
    return switch (state) {
      ReviewInitial() ||
      ReviewLoading() =>
        const Center(child: CircularProgressIndicator()),
      ReviewError(:final message) => Center(child: Text(message)),
      ReviewCompleted() => _buildSummary(),
      ReviewLoaded(:final dueWords) => dueWords.isEmpty
          ? _buildEmptyState()
          : _buildReviewContent(dueWords.first),
    };
  }

  Widget _buildReviewContent(WordEntity word) {
    final progress = _initialTotal > 0 ? _reviewedCount / _initialTotal : 0.0;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${_reviewedCount + 1} of $_initialTotal',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  Text(
                    '${(progress * 100).round()}%',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: progress,
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                valueColor:
                    const AlwaysStoppedAnimation<Color>(AppColors.primary),
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          ),
        ),
        Expanded(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    word.text,
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),
                  if (!_isRevealed)
                    ElevatedButton(
                      onPressed: _onReveal,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                      ),
                      child: const Text('Reveal Meaning'),
                    )
                  else
                    _buildRevealedContent(word),
                ],
              ),
            ),
          ),
        ),
        if (_isRevealed) _buildActionButtons(word),
      ],
    );
  }

  Widget _buildRevealedContent(WordEntity word) {
    return Column(
      children: [
        if (word.meaning != null)
          Text(
            word.meaning!,
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.1, end: 0),
        const SizedBox(height: 16),
        if (word.definitions != null && word.definitions!.isNotEmpty)
          ...word.definitions!.take(2).map(
                (def) => Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    def,
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
        if (word.examples != null && word.examples!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: Text(
              '"${word.examples!.first}"',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontStyle: FontStyle.italic,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
          ),
      ],
    ).animate().fadeIn(duration: 500.ms);
  }

  Widget _buildActionButtons(WordEntity word) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _ActionButton(
              label: 'Hard',
              color: AppColors.error,
              onPressed: () => _onSubmit(word, 2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _ActionButton(
              label: 'Good',
              color: AppColors.primary,
              onPressed: () => _onSubmit(word, 4),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _ActionButton(
              label: 'Easy',
              color: AppColors.accent,
              onPressed: () => _onSubmit(word, 5),
            ),
          ),
        ],
      ),
    ).animate().slideY(begin: 1, end: 0, duration: 300.ms);
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.check_circle_outline,
              size: 80,
              color: AppColors.accent,
            ),
            const SizedBox(height: 24),
            Text(
              'No words due for review',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              "Great job! You've caught up with all your scheduled reviews. Add more words to your lexicon to keep learning.",
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Back to Dashboard'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummary() {
    final accuracy =
        _reviewedCount > 0 ? (_goodCount / _reviewedCount * 100).round() : 0;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Session Complete!',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
            ),
            const SizedBox(height: 40),
            _SummaryItem(
              label: 'Words Reviewed',
              value: '$_reviewedCount',
              icon: Icons.menu_book,
            ),
            const SizedBox(height: 16),
            _SummaryItem(
              label: 'Accuracy',
              value: '$accuracy%',
              icon: Icons.insights,
            ),
            const SizedBox(height: 16),
            const _SummaryItem(
              label: 'Next Session',
              value: 'Tomorrow', // Simplified for now
              icon: Icons.event,
            ),
            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Finish'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.color,
    required this.onPressed,
  });

  final String label;
  final Color color;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  const _SummaryItem({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary),
          const SizedBox(width: 16),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const Spacer(),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
          ),
        ],
      ),
    );
  }
}
