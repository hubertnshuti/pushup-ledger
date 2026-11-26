import 'package:material_ui/material_ui.dart';
import 'package:pushup_ledger/core/constants.dart';
import 'package:pushup_ledger/core/copy.dart';
import 'package:pushup_ledger/core/theme/app_colors.dart';
import 'package:pushup_ledger/core/theme/app_spacing.dart';
import 'package:pushup_ledger/core/theme/app_typography.dart';
import 'package:pushup_ledger/domain/models/day_record.dart';
import 'package:pushup_ledger/domain/models/window_status.dart';

/// Today's count, progress bar, and window status.
class TodayProgress extends StatelessWidget {
  const TodayProgress({required this.day, required this.status, super.key});

  final DayRecord day;
  final WindowStatus status;

  @override
  Widget build(BuildContext context) {
    final isClosing = status.phase == WindowPhase.dayClosing;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppCopy.labelToday,
              style: AppTypography.label.copyWith(color: AppColors.inkMuted),
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                TweenAnimationBuilder<int>(
                  tween: IntTween(end: day.quotaReps),
                  duration: AppMotion.standard,
                  curve: Curves.easeOutCubic,
                  builder: (context, value, _) =>
                      Text('$value', style: AppTypography.numeralL),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  AppCopy.outOfTarget(),
                  style: AppTypography.heading.copyWith(
                    color: AppColors.inkMuted,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            _ProgressBar(
              fraction: day.quotaReps / dailyTarget,
              color: isClosing ? AppColors.orange : AppColors.ink,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              day.isComplete
                  ? AppCopy.dayDone
                  : AppCopy.left(day.remainingReps),
              style: AppTypography.bodyStrong,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              _statusText(status, day.remainingReps),
              style: AppTypography.caption.copyWith(
                color: isClosing ? AppColors.orangeText : AppColors.inkMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _statusText(WindowStatus status, int remaining) {
    final left = status.timeLeft ?? Duration.zero;
    return switch (status.phase) {
      WindowPhase.dayComplete => AppCopy.dayComplete,
      WindowPhase.beforeMorning => AppCopy.beforeMorning,
      WindowPhase.morningOpen => AppCopy.morningCloses(left),
      WindowPhase.betweenWindows => AppCopy.betweenWindows,
      WindowPhase.eveningOpen => AppCopy.eveningCloses(left),
      WindowPhase.dayClosing => AppCopy.dayClosing(remaining),
    };
  }
}

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.fraction, required this.color});

  final double fraction;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSizes.progressBar),
      child: Container(
        height: AppSizes.progressBar,
        color: AppColors.hairline,
        alignment: Alignment.centerLeft,
        child: AnimatedFractionallySizedBox(
          duration: AppMotion.standard,
          curve: Curves.easeOutCubic,
          widthFactor: fraction,
          heightFactor: 1,
          child: ColoredBox(color: color),
        ),
      ),
    );
  }
}
