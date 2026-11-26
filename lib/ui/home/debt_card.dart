import 'package:material_ui/material_ui.dart';
import 'package:pushup_ledger/core/copy.dart';
import 'package:pushup_ledger/core/theme/app_colors.dart';
import 'package:pushup_ledger/core/theme/app_spacing.dart';
import 'package:pushup_ledger/core/theme/app_typography.dart';

/// Pinned summary of what is owed. Carried debt uses the severe treatment.
class DebtCard extends StatelessWidget {
  const DebtCard({
    required this.totalOwed,
    required this.isCarried,
    required this.timeUntilDue,
    super.key,
  });

  final int totalOwed;
  final bool isCarried;
  final Duration timeUntilDue;

  @override
  Widget build(BuildContext context) {
    final textColor = isCarried ? AppColors.creamOnInk : AppColors.ink;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: isCarried ? AppColors.ink : AppColors.orangeTint,
        borderRadius: BorderRadius.circular(AppRadii.card),
        border: Border.all(color: AppColors.orange, width: AppSizes.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isCarried ? AppCopy.labelCarriedDebt : AppCopy.labelDebt,
              style: AppTypography.label.copyWith(
                color: isCarried ? AppColors.orange : AppColors.orangeText,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              '$totalOwed',
              style: AppTypography.numeralL.copyWith(color: AppColors.orange),
            ),
            Text(
              AppCopy.pushUpsOwed,
              style: AppTypography.body.copyWith(color: textColor),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              isCarried ? AppCopy.debtOverdue : AppCopy.debtDue(timeUntilDue),
              style: AppTypography.caption.copyWith(color: textColor),
            ),
          ],
        ),
      ),
    );
  }
}
