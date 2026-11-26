import 'dart:math';

import 'package:material_ui/material_ui.dart';
import 'package:pushup_ledger/core/constants.dart';
import 'package:pushup_ledger/core/copy.dart';
import 'package:pushup_ledger/core/theme/app_colors.dart';
import 'package:pushup_ledger/core/theme/app_spacing.dart';
import 'package:pushup_ledger/core/theme/app_typography.dart';
import 'package:pushup_ledger/domain/week_strip.dart';

/// The current week from Monday to Sunday, with the streak below it.
class WeekStripView extends StatelessWidget {
  const WeekStripView({
    required this.days,
    required this.currentStreak,
    required this.bestStreak,
    super.key,
  });

  final List<WeekDay> days;
  final int currentStreak;
  final int bestStreak;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppCopy.labelWeek,
              style: AppTypography.label.copyWith(color: AppColors.inkMuted),
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                for (final (index, day) in days.indexed)
                  Column(
                    children: [
                      Text(
                        AppCopy.weekdayLetters[index],
                        style: AppTypography.caption.copyWith(
                          color: AppColors.inkMuted,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      _DayCircle(day: day),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              AppCopy.streak(currentStreak, bestStreak),
              style: AppTypography.caption.copyWith(color: AppColors.inkMuted),
            ),
          ],
        ),
      ),
    );
  }
}

class _DayCircle extends StatelessWidget {
  const _DayCircle({required this.day});

  final WeekDay day;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: AppSizes.weekCircle,
      child: switch (day.state) {
        WeekDayState.complete => const DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.ink,
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.check_outlined, color: AppColors.creamOnInk),
        ),
        WeekDayState.partial => CustomPaint(
          painter: _ArcPainter(day.quotaReps / dailyTarget),
        ),
        WeekDayState.missed => DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.orange,
              width: AppSizes.ringStroke,
            ),
          ),
          child: const Center(
            child: SizedBox.square(
              dimension: AppSizes.dot,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.ink,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        ),
        WeekDayState.upcoming => DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.hairline,
              width: AppSizes.border,
            ),
          ),
        ),
      },
    );
  }
}

class _ArcPainter extends CustomPainter {
  const _ArcPainter(this.fraction);

  final double fraction;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = (Offset.zero & size).deflate(AppSizes.ringStroke / 2);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = AppSizes.ringStroke
      ..color = AppColors.hairline;
    canvas.drawOval(rect, paint);
    paint.color = AppColors.ink;
    canvas.drawArc(rect, -pi / 2, 2 * pi * fraction, false, paint);
  }

  @override
  bool shouldRepaint(_ArcPainter oldDelegate) =>
      oldDelegate.fraction != fraction;
}
