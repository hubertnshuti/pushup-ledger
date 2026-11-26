import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:pushup_ledger/core/copy.dart';
import 'package:pushup_ledger/core/theme/app_colors.dart';
import 'package:pushup_ledger/core/theme/app_spacing.dart';
import 'package:pushup_ledger/core/theme/app_typography.dart';
import 'package:pushup_ledger/domain/models/log_entry.dart';
import 'package:pushup_ledger/state/ledger_controller.dart';

/// Today's logged sets, with undo while it is still allowed.
class EntriesSection extends StatelessWidget {
  const EntriesSection({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<LedgerController>();
    final entries = controller.todayEntries;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppCopy.labelEntries,
          style: AppTypography.label.copyWith(color: AppColors.inkMuted),
        ),
        const SizedBox(height: AppSpacing.sm),
        if (entries.isEmpty)
          Text(
            AppCopy.noEntries,
            style: AppTypography.body.copyWith(color: AppColors.inkMuted),
          ),
        for (final entry in entries)
          _EntryRow(
            entry: entry,
            canUndo: controller.canUndoEntry(entry),
            onUndo: () => controller.undo(entry.id),
          ),
      ],
    );
  }
}

class _EntryRow extends StatelessWidget {
  const _EntryRow({
    required this.entry,
    required this.canUndo,
    required this.onUndo,
  });

  final LogEntry entry;
  final bool canUndo;
  final VoidCallback onUndo;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: AppSizes.minTouchTarget),
      child: Row(
        children: [
          Text(
            AppCopy.entryTime(entry.createdAt),
            style: AppTypography.caption.copyWith(color: AppColors.inkMuted),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Text(
              AppCopy.reps(entry.count),
              style: AppTypography.bodyStrong,
            ),
          ),
          if (canUndo)
            TextButton(onPressed: onUndo, child: const Text(AppCopy.undo)),
        ],
      ),
    );
  }
}
