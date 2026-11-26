import 'package:material_ui/material_ui.dart';
import 'package:pushup_ledger/core/copy.dart';
import 'package:pushup_ledger/core/theme/app_colors.dart';
import 'package:pushup_ledger/core/theme/app_spacing.dart';
import 'package:pushup_ledger/core/theme/app_typography.dart';
import 'package:pushup_ledger/domain/models/day_record.dart';
import 'package:pushup_ledger/domain/models/debt.dart';

/// Opens the details of one tracked day.
Future<void> showDayDetailSheet(
  BuildContext context, {
  required DayRecord day,
  required Debt? debt,
}) {
  return showModalBottomSheet<void>(
    context: context,
    sheetAnimationStyle: const AnimationStyle(
      duration: AppMotion.sheet,
      reverseDuration: AppMotion.sheet,
    ),
    builder: (_) => DayDetailSheet(day: day, debt: debt),
  );
}

class DayDetailSheet extends StatelessWidget {
  const DayDetailSheet({required this.day, required this.debt, super.key});

  final DayRecord day;
  final Debt? debt;

  @override
  Widget build(BuildContext context) {
    final debt = this.debt;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(AppCopy.dayTitle(day.date), style: AppTypography.title),
            const SizedBox(height: AppSpacing.lg),
            _DetailRow(
              label: AppCopy.detailCounted,
              value: AppCopy.quotaOfTarget(day.quotaReps),
            ),
            _DetailRow(label: AppCopy.detailExtra, value: '${day.extraReps}'),
            _DetailRow(
              label: AppCopy.detailDebtPaid,
              value: '${day.debtPaidReps}',
            ),
            if (debt != null) ...[
              const SizedBox(height: AppSpacing.md),
              const Divider(),
              const SizedBox(height: AppSpacing.md),
              for (final payment in debt.payments)
                Text(
                  AppCopy.paidBack(payment.amount, payment.date),
                  style: AppTypography.body,
                ),
              if (!debt.isPaid)
                Text(
                  AppCopy.stillOwed(debt.remaining),
                  style: AppTypography.bodyStrong.copyWith(
                    color: AppColors.orangeText,
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: AppTypography.body.copyWith(color: AppColors.inkMuted),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Text(value, style: AppTypography.bodyStrong),
        ],
      ),
    );
  }
}
