import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:pushup_ledger/core/copy.dart';
import 'package:pushup_ledger/core/theme/app_colors.dart';
import 'package:pushup_ledger/core/theme/app_spacing.dart';
import 'package:pushup_ledger/core/theme/app_typography.dart';
import 'package:pushup_ledger/domain/models/ledger_snapshot.dart';
import 'package:pushup_ledger/state/ledger_controller.dart';
import 'package:pushup_ledger/ui/history/contribution_grid.dart';
import 'package:pushup_ledger/ui/history/day_detail_sheet.dart';
import 'package:pushup_ledger/ui/history/week_list.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<LedgerController>();
    final snapshot = controller.snapshot;
    final startDate = controller.startDate;
    final hasDays = snapshot != null && snapshot.days.isNotEmpty;

    return Scaffold(
      appBar: AppBar(title: const Text(AppCopy.navHistory)),
      body: SafeArea(
        child: !hasDays
            ? Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenHorizontal,
                ),
                child: Text(
                  startDate == null
                      ? AppCopy.noStartDate
                      : AppCopy.startsOn(startDate),
                ),
              )
            : ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenHorizontal,
                  vertical: AppSpacing.lg,
                ),
                children: [
                  _Totals(snapshot: snapshot),
                  const SizedBox(height: AppSpacing.cardGap),
                  _Section(
                    label: AppCopy.labelDays,
                    child: ContributionGrid(
                      weeks: controller.gridWeeks,
                      onDayTap: (day) => showDayDetailSheet(
                        context,
                        day: day,
                        debt: snapshot.debtFrom(day.date),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.cardGap),
                  _Section(
                    label: AppCopy.labelWeeks,
                    child: WeekList(weeks: snapshot.weeks),
                  ),
                ],
              ),
      ),
    );
  }
}

class _Totals extends StatelessWidget {
  const _Totals({required this.snapshot});

  final LedgerSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    return _Section(
      label: AppCopy.labelTotals,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${snapshot.allTimeReps}', style: AppTypography.numeralL),
          const Text(AppCopy.allTimePushups, style: AppTypography.body),
          const SizedBox(height: AppSpacing.xs),
          Text(
            AppCopy.daysCompleted(snapshot.completedDays, snapshot.trackedDays),
            style: AppTypography.caption.copyWith(color: AppColors.inkMuted),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTypography.label.copyWith(color: AppColors.inkMuted),
              ),
              const SizedBox(height: AppSpacing.md),
              child,
            ],
          ),
        ),
      ),
    );
  }
}
