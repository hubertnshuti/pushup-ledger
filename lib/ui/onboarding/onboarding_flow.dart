import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:pushup_ledger/core/copy.dart';
import 'package:pushup_ledger/core/theme/app_colors.dart';
import 'package:pushup_ledger/core/theme/app_spacing.dart';
import 'package:pushup_ledger/core/theme/app_typography.dart';
import 'package:pushup_ledger/services/permission_service.dart';
import 'package:pushup_ledger/state/ledger_controller.dart';
import 'package:pushup_ledger/ui/widgets/hold_to_confirm_button.dart';

/// First-launch steps: contract, start date, then each permission.
class OnboardingFlow extends StatefulWidget {
  const OnboardingFlow({super.key});

  @override
  State<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends State<OnboardingFlow> {
  int _step = 0;
  bool _startTomorrow = false;

  static const int _permissionsStart = 2;

  void _next() {
    final finalStep = _permissionsStart + AppPermission.values.length;
    if (_step + 1 < finalStep) {
      setState(() => _step++);
    } else {
      context.read<LedgerController>().finishOnboarding(
        startTomorrow: _startTomorrow,
      );
    }
  }

  void _chooseStart({required bool tomorrow}) {
    _startTomorrow = tomorrow;
    _next();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: switch (_step) {
            0 => _ContractStep(onSigned: _next),
            1 => _StartStep(onChosen: _chooseStart),
            _ => _PermissionStep(
              key: ValueKey(_step),
              permission: AppPermission.values[_step - _permissionsStart],
              onDone: _next,
            ),
          },
        ),
      ),
    );
  }
}

class _ContractStep extends StatelessWidget {
  const _ContractStep({required this.onSigned});

  final VoidCallback onSigned;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(AppCopy.contractTitle, style: AppTypography.display),
        const SizedBox(height: AppSpacing.xl),
        for (final line in AppCopy.contractLines)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: Text(line, style: AppTypography.heading),
          ),
        const Spacer(),
        HoldToConfirmButton(
          label: AppCopy.holdToSign,
          labelColor: AppColors.ink,
          onConfirmed: onSigned,
        ),
      ],
    );
  }
}

class _StartStep extends StatelessWidget {
  const _StartStep({required this.onChosen});

  final void Function({required bool tomorrow}) onChosen;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(AppCopy.startTitle, style: AppTypography.title),
        const Spacer(),
        FilledButton(
          onPressed: () => onChosen(tomorrow: false),
          child: const Text(AppCopy.startToday),
        ),
        const SizedBox(height: AppSpacing.md),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.ink,
            foregroundColor: AppColors.creamOnInk,
            minimumSize: const Size.fromHeight(AppSizes.secondaryButton),
          ),
          onPressed: () => onChosen(tomorrow: true),
          child: const Text(AppCopy.startTomorrow),
        ),
      ],
    );
  }
}

class _PermissionStep extends StatelessWidget {
  const _PermissionStep({
    required this.permission,
    required this.onDone,
    super.key,
  });

  final AppPermission permission;
  final VoidCallback onDone;

  Future<void> _allow(BuildContext context) async {
    await context.read<PermissionService>().request(permission);
    onDone();
  }

  @override
  Widget build(BuildContext context) {
    final (title, body) = switch (permission) {
      AppPermission.notifications => (
        AppCopy.permissionNotificationsTitle,
        AppCopy.permissionNotificationsBody,
      ),
      AppPermission.exactAlarms => (
        AppCopy.permissionAlarmsTitle,
        AppCopy.permissionAlarmsBody,
      ),
      AppPermission.batteryOptimization => (
        AppCopy.permissionBatteryTitle,
        AppCopy.permissionBatteryBody,
      ),
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(title, style: AppTypography.title),
        const SizedBox(height: AppSpacing.md),
        Text(
          body,
          style: AppTypography.body.copyWith(color: AppColors.inkMuted),
        ),
        const Spacer(),
        FilledButton(
          onPressed: () => _allow(context),
          child: const Text(AppCopy.allow),
        ),
        const SizedBox(height: AppSpacing.sm),
        TextButton(onPressed: onDone, child: const Text(AppCopy.notNow)),
      ],
    );
  }
}
