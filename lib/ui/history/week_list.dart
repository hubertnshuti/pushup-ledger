import 'package:material_ui/material_ui.dart';
import 'package:pushup_ledger/core/copy.dart';
import 'package:pushup_ledger/core/dates.dart';
import 'package:pushup_ledger/core/theme/app_colors.dart';
import 'package:pushup_ledger/core/theme/app_spacing.dart';
import 'package:pushup_ledger/core/theme/app_typography.dart';
import 'package:pushup_ledger/domain/models/week_status.dart';
import 'package:pushup_ledger/domain/models/week_summary.dart';

/// Every tracked week, newest first.
class WeekList extends StatelessWidget {
  const WeekList({required this.weeks, super.key});

  final List<WeekSummary> weeks;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final week in weeks.reversed)
          ConstrainedBox(
            constraints: const BoxConstraints(
              minHeight: AppSizes.minTouchTarget,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppCopy.weekRange(
                          week.weekStart,
                          sundayOf(week.weekStart),
                        ),
                        style: AppTypography.bodyStrong,
                      ),
                      Text(
                        AppCopy.reps(week.totalReps),
                        style: AppTypography.caption.copyWith(
                          color: AppColors.inkMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                _StatusBadge(status: week.status),
              ],
            ),
          ),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final WeekStatus status;

  @override
  Widget build(BuildContext context) {
    final (text, fill, textColor, outline) = switch (status) {
      WeekStatus.clean => (
        AppCopy.weekClean,
        AppColors.ink,
        AppColors.creamOnInk,
        AppColors.ink,
      ),
      WeekStatus.recovered => (
        AppCopy.weekRecovered,
        AppColors.transparent,
        AppColors.ink,
        AppColors.ink,
      ),
      WeekStatus.failed => (
        AppCopy.weekFailed,
        AppColors.orange,
        AppColors.ink,
        AppColors.orange,
      ),
      WeekStatus.inProgress => (
        AppCopy.weekInProgress,
        AppColors.transparent,
        AppColors.inkMuted,
        AppColors.hairline,
      ),
    };
    return DecoratedBox(
      decoration: ShapeDecoration(
        color: fill,
        shape: StadiumBorder(
          side: BorderSide(color: outline, width: AppSizes.border),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        child: Text(
          text,
          style: AppTypography.caption.copyWith(color: textColor),
        ),
      ),
    );
  }
}
