import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:pushup_ledger/core/copy.dart';
import 'package:pushup_ledger/core/theme/app_theme.dart';
import 'package:pushup_ledger/state/ledger_controller.dart';
import 'package:pushup_ledger/ui/app_shell.dart';
import 'package:pushup_ledger/ui/onboarding/onboarding_flow.dart';
import 'package:pushup_ledger/ui/reckoning/reckoning_gate.dart';

class PushupLedgerApp extends StatelessWidget {
  const PushupLedgerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppCopy.appName,
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      home: const _Home(),
    );
  }
}

/// Shows onboarding until the contract is signed, then the main app.
class _Home extends StatelessWidget {
  const _Home();

  @override
  Widget build(BuildContext context) {
    final isOnboardingDone = context.select<LedgerController, bool>(
      (controller) => controller.isOnboardingDone,
    );
    return isOnboardingDone
        ? const ReckoningGate(child: AppShell())
        : const OnboardingFlow();
  }
}
