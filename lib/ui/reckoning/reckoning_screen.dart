import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pushup_ledger/core/constants.dart';
import 'package:pushup_ledger/core/copy.dart';
import 'package:pushup_ledger/core/dates.dart';
import 'package:pushup_ledger/core/theme/app_colors.dart';
import 'package:pushup_ledger/core/theme/app_spacing.dart';
import 'package:pushup_ledger/core/theme/app_typography.dart';
import 'package:pushup_ledger/domain/models/debt.dart';
import 'package:pushup_ledger/domain/reckoning.dart';
import 'package:pushup_ledger/ui/widgets/hold_to_confirm_button.dart';

/// The full-screen demand shown when debt is owed or the day is closing.
class ReckoningScreen extends StatefulWidget {
  const ReckoningScreen({
    required this.reckoning,
    required this.verdict,
    required this.timeUntilWeekCloses,
    required this.timeUntilMidnight,
    required this.onDismissed,
    super.key,
  });

  final Reckoning reckoning;
  final Verdict? verdict;
  final Duration timeUntilWeekCloses;
  final Duration timeUntilMidnight;
  final VoidCallback onDismissed;

  @override
  State<ReckoningScreen> createState() => _ReckoningScreenState();
}

class _ReckoningScreenState extends State<ReckoningScreen> {
  @override
  void initState() {
    super.initState();
    HapticFeedback.mediumImpact();
  }

  @override
  Widget build(BuildContext context) {
    final reckoning = widget.reckoning;
    final verdict = widget.verdict;
    final failedWeek = reckoning.failedWeekStart;
    final isCarried = reckoning.kind == ReckoningKind.carriedDebt;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: AppMotion.entrance,
        curve: Curves.easeOutCubic,
        builder: (context, value, child) => Opacity(
          opacity: value,
          child: Transform.scale(
            scale:
                AppMotion.entranceStartScale +
                (1 - AppMotion.entranceStartScale) * value,
            child: child,
          ),
        ),
        child: Material(
          color: AppColors.ink,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: ListView(
                      children: [
                        if (verdict != null) ...[
                          Text(
                            AppCopy.verdict(
                              verdict.quotaReps,
                              verdict.addedDebt,
                            ),
                            textAlign: TextAlign.center,
                            style: AppTypography.bodyStrong.copyWith(
                              color: AppColors.creamOnInk,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xl),
                        ],
                        Text(
                          _label(reckoning.kind, failedWeek),
                          textAlign: TextAlign.center,
                          style: AppTypography.label.copyWith(
                            color: AppColors.orange,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          '${reckoning.amount}',
                          textAlign: TextAlign.center,
                          style: AppTypography.numeralXL.copyWith(
                            color: isCarried
                                ? AppColors.orange
                                : AppColors.creamOnInk,
                          ),
                        ),
                        Text(
                          AppCopy.pushUpsUnit,
                          textAlign: TextAlign.center,
                          style: AppTypography.heading.copyWith(
                            color: AppColors.mutedOnInk,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        Text(
                          isCarried
                              ? AppCopy.debtCarriedOver
                              : AppCopy.promisedFifty,
                          textAlign: TextAlign.center,
                          style: AppTypography.display.copyWith(
                            color: AppColors.creamOnInk,
                          ),
                        ),
                        if (failedWeek != null) ...[
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            AppCopy.weekFailedRecord(isoWeekNumber(failedWeek)),
                            textAlign: TextAlign.center,
                            style: AppTypography.body.copyWith(
                              color: AppColors.mutedOnInk,
                            ),
                          ),
                        ],
                        const SizedBox(height: AppSpacing.xl),
                        if (reckoning.debts.isNotEmpty) ...[
                          const Divider(color: AppColors.hairlineOnInk),
                          const SizedBox(height: AppSpacing.md),
                          for (final debt in reckoning.debts)
                            _DebtRow(debt: debt),
                          const SizedBox(height: AppSpacing.md),
                        ],
                        if (_countdown(reckoning.kind) case final countdown?)
                          Text(
                            countdown,
                            textAlign: TextAlign.center,
                            style: AppTypography.bodyStrong.copyWith(
                              color: AppColors.orange,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  HoldToConfirmButton(
                    label: AppCopy.holdToPay,
                    labelColor: AppColors.creamOnInk,
                    onConfirmed: widget.onDismissed,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _label(ReckoningKind kind, DateTime? failedWeek) => switch (kind) {
    ReckoningKind.carriedDebt when failedWeek != null =>
      AppCopy.weekFailedLabel(isoWeekNumber(failedWeek)),
    ReckoningKind.carriedDebt ||
    ReckoningKind.openDebt => AppCopy.labelOutstandingDebt,
    ReckoningKind.dayClosing => AppCopy.labelDayClosing,
  };

  String? _countdown(ReckoningKind kind) => switch (kind) {
    ReckoningKind.carriedDebt => null,
    ReckoningKind.openDebt => AppCopy.weekClosesIn(widget.timeUntilWeekCloses),
    ReckoningKind.dayClosing => AppCopy.dayClosesIn(widget.timeUntilMidnight),
  };
}

class _DebtRow extends StatelessWidget {
  const _DebtRow({required this.debt});

  final Debt debt;

  @override
  Widget build(BuildContext context) {
    final style = AppTypography.caption.copyWith(color: AppColors.creamOnInk);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: [
          Expanded(
            child: Text(AppCopy.dayTitle(debt.originDate), style: style),
          ),
          Text(AppCopy.quotaOfTarget(dailyTarget - debt.amount), style: style),
          const SizedBox(width: AppSpacing.lg),
          Text(AppCopy.owes(debt.remaining), style: style),
        ],
      ),
    );
  }
}
