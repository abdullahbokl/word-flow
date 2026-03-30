import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:word_flow/core/di/injection.dart';
import 'package:word_flow/features/vocabulary/presentation/blocs/analysis_settings_cubit.dart';
import 'package:word_flow/features/vocabulary/presentation/blocs/analysis_settings_state.dart';

class AnalysisSettingsPage extends StatelessWidget {
  const AnalysisSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<AnalysisSettingsCubit>()..load(),
      child: const _AnalysisSettingsView(),
    );
  }
}

class _AnalysisSettingsView extends StatelessWidget {
  const _AnalysisSettingsView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Analysis Settings',
          style: GoogleFonts.outfit(fontWeight: FontWeight.w600),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: true,
      ),
      body: BlocConsumer<AnalysisSettingsCubit, AnalysisSettingsState>(
        listener: (context, state) {
          state.maybeWhen(
            loaded: (config, isSaving, error) {
              if (error != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(error),
                    backgroundColor: colorScheme.error,
                  ),
                );
              }
            },
            error: (msg) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(msg),
                  backgroundColor: colorScheme.error,
                ),
              );
            },
            orElse: () {},
          );
        },
        builder: (context, state) {
          return state.when(
            initial: () => const Center(child: CircularProgressIndicator()),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (msg) => Center(child: Text(msg)),
            loaded: (config, isSaving, error) => ListView(
              padding: const EdgeInsets.all(24),
              children: [
                _buildSectionHeader(context, 'Core Configuration', Icons.settings_rounded),
                const SizedBox(height: 16),
                _buildCard(
                  context,
                  child: Column(
                    children: [
                      ListTile(
                        leading: Icon(Icons.language_rounded, color: colorScheme.primary),
                        title: Text('Primary Language', style: GoogleFonts.outfit(fontWeight: FontWeight.w500)),
                        subtitle: Text(config.language.toUpperCase(), style: GoogleFonts.outfit(fontSize: 12)),
                        trailing: DropdownButton<String>(
                          value: config.language,
                          underline: const SizedBox(),
                          items: const [
                            DropdownMenuItem(value: 'english', child: Text('English')),
                            DropdownMenuItem(value: 'spanish', child: Text('Spanish')),
                          ],
                          onChanged: (val) {
                            if (val != null) context.read<AnalysisSettingsCubit>().updateLanguage(val);
                          },
                        ),
                      ),
                      const Divider(height: 1, indent: 64),
                      ListTile(
                        leading: Icon(Icons.short_text_rounded, color: colorScheme.primary),
                        title: Text('Minimum Word Length', style: GoogleFonts.outfit(fontWeight: FontWeight.w500)),
                        subtitle: Text('${config.minWordLength} characters', style: GoogleFonts.outfit(fontSize: 12)),
                        trailing: SizedBox(
                          width: 120,
                          child: Slider(
                            value: config.minWordLength.toDouble(),
                            min: 1,
                            max: 5,
                            divisions: 4,
                            label: config.minWordLength.toString(),
                            onChanged: (val) {
                              context.read<AnalysisSettingsCubit>().updateMinWordLength(val.toInt());
                            },
                          ),
                        ),
                      ),
                      const Divider(height: 1, indent: 64),
                      SwitchListTile(
                        secondary: Icon(Icons.merge_type_rounded, color: colorScheme.primary),
                        title: Text('Merge Contractions', style: GoogleFonts.outfit(fontWeight: FontWeight.w500)),
                        subtitle: Text("Treat \"don't\" as one word", style: GoogleFonts.outfit(fontSize: 12)),
                        value: config.includeContractionsAsOne,
                        onChanged: (val) {
                          context.read<AnalysisSettingsCubit>().toggleContractions(val);
                        },
                      ),
                      const Divider(height: 1, indent: 64),
                      SwitchListTile(
                        secondary: Icon(Icons.account_tree_rounded, color: colorScheme.primary),
                        title: Text('Group Word Variants', style: GoogleFonts.outfit(fontWeight: FontWeight.w500)),
                        subtitle: Text("Count \"runs\" and \"running\" as \"run\" (Stemming)", style: GoogleFonts.outfit(fontSize: 12)),
                        value: config.useStemming,
                        onChanged: (val) {
                          context.read<AnalysisSettingsCubit>().toggleStemming(val);
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                _buildSectionHeader(context, 'Stopwords Manager', Icons.block_rounded),
                const SizedBox(height: 16),
                _buildCard(
                  context,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Words listed here will be ignored during text analysis. Language-specific defaults are included by default.',
                          style: theme.textTheme.bodySmall?.copyWith(height: 1.5),
                        ),
                        const SizedBox(height: 20),
                        TextField(
                          decoration: InputDecoration(
                            hintText: 'Add custom stopword...',
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.add_circle_outline_rounded),
                              onPressed: () {}, // Handled by onSubmitted or similar
                            ),
                            prefixIcon: const Icon(Icons.search_rounded),
                            filled: true,
                            fillColor: colorScheme.surfaceVariant.withOpacity(0.3),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          onSubmitted: (val) {
                            if (val.isNotEmpty) {
                              context.read<AnalysisSettingsCubit>().addStopword(val);
                            }
                          },
                        ),
                        const SizedBox(height: 20),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: config.stopWords.take(50).map((word) {
                            // Highlight custom ones (fake it for now since we don't distinguish in domain model yet)
                            return Chip(
                              label: Text(word, style: GoogleFonts.outfit(fontSize: 12)),
                              onDeleted: () => context.read<AnalysisSettingsCubit>().removeStopword(word),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              backgroundColor: colorScheme.primaryContainer.withOpacity(0.4),
                              deleteIconColor: colorScheme.primary,
                            );
                          }).toList(),
                        ),
                        if (config.stopWords.length > 50)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              '+ ${config.stopWords.length - 50} more stopwords',
                              style: theme.textTheme.labelSmall,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, IconData icon) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(icon, size: 20, color: colorScheme.primary.withOpacity(0.7)),
        const SizedBox(width: 12),
        Text(
          title,
          style: GoogleFonts.outfit(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
            color: colorScheme.onSurface.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildCard(BuildContext context, {required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: child,
      ),
    );
  }
}
