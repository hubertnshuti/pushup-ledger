import 'package:material_ui/material_ui.dart';
import 'package:pushup_ledger/core/copy.dart';
import 'package:pushup_ledger/core/dates.dart';
import 'package:pushup_ledger/core/theme/app_colors.dart';
import 'package:pushup_ledger/core/theme/app_spacing.dart';
import 'package:pushup_ledger/core/theme/app_typography.dart';
import 'package:pushup_ledger/domain/history_grid.dart';
import 'package:pushup_ledger/domain/models/day_record.dart';

/// Weeks as columns, Monday at the top, with the newest week on the right.
class ContributionGrid extends StatelessWidget {
  const ContributionGrid({
    required this.weeks,
    required this.onDayTap,
    super.key,
  });

  final List<List<GridCell>> weeks;
  final ValueChanged<DayRecord> onDayTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          reverse: true,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final week in weeks)
                Padding(
                  padding: const EdgeInsets.only(right: AppSizes.gridGap),
                  child: Column(
                    children: [
                      for (final cell in week)
                        Padding(
                          padding: const EdgeInsets.only(
                            bottom: AppSizes.gridGap,
                          ),
                          child: _Cell(cell: cell, onDayTap: onDayTap),
                        ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        const _Legend(),
      ],
    );
  }
}

Color _fillFor(GridLevel level) => switch (level) {
  GridLevel.none => AppColors.transparent,
  GridLevel.empty => AppColors.gridEmpty,
  GridLevel.low => AppColors.gridLow,
  GridLevel.mid => AppColors.gridMid,
  GridLevel.full => AppColors.orange,
};

class _Cell extends StatelessWidget {
  const _Cell({required this.cell, required this.onDayTap});

  final GridCell cell;
  final ValueChanged<DayRecord> onDayTap;

  @override
  Widget build(BuildContext context) {
    final day = cell.day;
    return Semantics(
      button: day != null,
      label: AppCopy.dayTitle(cell.date),
      child: GestureDetector(
        key: ValueKey('grid-${formatIsoDate(cell.date)}'),
        behavior: HitTestBehavior.opaque,
        onTap: day == null ? null : () => onDayTap(day),
        child: _Swatch(
          level: cell.level,
          hasDot: cell.hasMissedDot,
          isToday: cell.isToday,
        ),
      ),
    );
  }
}

class _Swatch extends StatelessWidget {
  const _Swatch({
    required this.level,
    this.hasDot = false,
    this.isToday = false,
  });

  final GridLevel level;
  final bool hasDot;
  final bool isToday;

  @override
  Widget build(BuildContext context) {
    final Border? border = isToday
        ? Border.all(color: AppColors.ink, width: AppSizes.ringStroke)
        : level == GridLevel.none
        ? Border.all(color: AppColors.hairline, width: AppSizes.border)
        : null;
    return Container(
      width: AppSizes.gridCell,
      height: AppSizes.gridCell,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: _fillFor(level),
        borderRadius: BorderRadius.circular(AppRadii.gridCell),
        border: border,
      ),
      child: hasDot
          ? const SizedBox.square(
              dimension: AppSizes.gridDot,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.ink,
                  shape: BoxShape.circle,
                ),
              ),
            )
          : null,
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend();

  @override
  Widget build(BuildContext context) {
    final style = AppTypography.caption.copyWith(color: AppColors.inkMuted);
    return Row(
      children: [
        Text(AppCopy.gridLess, style: style),
        const SizedBox(width: AppSpacing.xs),
        for (final level in const [
          GridLevel.empty,
          GridLevel.low,
          GridLevel.mid,
          GridLevel.full,
        ])
          Padding(
            padding: const EdgeInsets.only(right: AppSizes.gridGap),
            child: _Swatch(level: level),
          ),
        const SizedBox(width: AppSpacing.xs),
        Text(AppCopy.gridMore, style: style),
      ],
    );
  }
}
