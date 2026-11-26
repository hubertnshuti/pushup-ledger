import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:pushup_ledger/core/constants.dart';
import 'package:pushup_ledger/core/copy.dart';
import 'package:pushup_ledger/core/theme/app_colors.dart';
import 'package:pushup_ledger/core/theme/app_spacing.dart';
import 'package:pushup_ledger/core/theme/app_typography.dart';
import 'package:pushup_ledger/state/ledger_controller.dart';

/// Opens the two-step sheet for logging a set.
Future<void> showLogSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    sheetAnimationStyle: const AnimationStyle(
      duration: AppMotion.sheet,
      reverseDuration: AppMotion.sheet,
    ),
    builder: (_) => const LogSheet(),
  );
}

class LogSheet extends StatefulWidget {
  const LogSheet({super.key});

  @override
  State<LogSheet> createState() => _LogSheetState();
}

class _LogSheetState extends State<LogSheet> {
  int _count = defaultSetCount;
  bool _isConfirming = false;
  bool _isSaving = false;

  void _setCount(int value) {
    setState(() => _count = value.clamp(minSetCount, maxSetCount));
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);
    final navigator = Navigator.of(context);
    try {
      await context.read<LedgerController>().logSet(_count);
      navigator.pop();
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: _isConfirming
            ? _ConfirmStep(
                count: _count,
                isSaving: _isSaving,
                onConfirm: _save,
                onBack: () => setState(() => _isConfirming = false),
              )
            : _PickStep(
                count: _count,
                onChanged: _setCount,
                onContinue: () => setState(() => _isConfirming = true),
              ),
      ),
    );
  }
}

class _PickStep extends StatelessWidget {
  const _PickStep({
    required this.count,
    required this.onChanged,
    required this.onContinue,
  });

  final int count;
  final ValueChanged<int> onChanged;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(AppCopy.logTitle, style: AppTypography.title),
        const SizedBox(height: AppSpacing.lg),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              tooltip: AppCopy.decreaseCount,
              onPressed: count > minSetCount
                  ? () => onChanged(count - 1)
                  : null,
              icon: const Icon(Icons.remove_outlined),
            ),
            Text('$count', style: AppTypography.numeralL),
            IconButton(
              tooltip: AppCopy.increaseCount,
              onPressed: count < maxSetCount
                  ? () => onChanged(count + 1)
                  : null,
              icon: const Icon(Icons.add_outlined),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            for (final quick in quickSetCounts)
              _QuickCount(
                value: quick,
                isSelected: quick == count,
                onTap: () => onChanged(quick),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),
        FilledButton(
          onPressed: onContinue,
          child: Text(AppCopy.logCount(count)),
        ),
      ],
    );
  }
}

class _QuickCount extends StatelessWidget {
  const _QuickCount({
    required this.value,
    required this.isSelected,
    required this.onTap,
  });

  final int value;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? AppColors.ink : AppColors.transparent,
      shape: const StadiumBorder(
        side: BorderSide(color: AppColors.hairline, width: AppSizes.border),
      ),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onTap,
        child: SizedBox(
          width: AppSizes.minTouchTarget + AppSpacing.lg,
          height: AppSizes.minTouchTarget,
          child: Center(
            child: Text(
              '$value',
              style: AppTypography.bodyStrong.copyWith(
                color: isSelected ? AppColors.creamOnInk : AppColors.ink,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ConfirmStep extends StatelessWidget {
  const _ConfirmStep({
    required this.count,
    required this.isSaving,
    required this.onConfirm,
    required this.onBack,
  });

  final int count;
  final bool isSaving;
  final VoidCallback onConfirm;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(AppCopy.confirmSet(count), style: AppTypography.title),
        const SizedBox(height: AppSpacing.xl),
        FilledButton(
          onPressed: isSaving ? null : onConfirm,
          child: const Text(AppCopy.confirm),
        ),
        const SizedBox(height: AppSpacing.sm),
        TextButton(
          onPressed: isSaving ? null : onBack,
          child: const Text(AppCopy.back),
        ),
      ],
    );
  }
}
