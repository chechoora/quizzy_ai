import 'package:flutter/material.dart';
import 'package:poc_ai_quiz/di/di.dart';
import 'package:poc_ai_quiz/domain/sync/deck_card_sync_service.dart';
import 'package:poc_ai_quiz/domain/sync/sync_scheduler.dart';
import 'package:quizzy_design/quizzy_design.dart';

/// Thin indeterminate progress bar shown while background sync is running.
/// Stays collapsed (renders nothing) when idle, and for the `quizzy` flavor
/// where [SyncScheduler] is disabled and `isSyncing` never flips to true.
class SyncProgressBar extends StatelessWidget {
  const SyncProgressBar({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: getIt<DeckCardSyncService>().isSyncing,
      builder: (context, isSyncing, _) {
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: isSyncing
              ? const SizedBox(
                  key: ValueKey('syncing'),
                  height: 1,
                  child: LinearProgressIndicator(
                    backgroundColor: AppColors.grayscale200,
                    color: AppColors.primary500,
                  ),
                )
              : const SizedBox(height: 1, key: ValueKey('idle')),
        );
      },
    );
  }
}
