import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:pushup_ledger/state/ledger_controller.dart';
import 'package:pushup_ledger/ui/reckoning/reckoning_screen.dart';

/// Places the blocking screen above the app whenever one is active.
class ReckoningGate extends StatefulWidget {
  const ReckoningGate({required this.child, super.key});

  final Widget child;

  @override
  State<ReckoningGate> createState() => _ReckoningGateState();
}

class _ReckoningGateState extends State<ReckoningGate>
    with WidgetsBindingObserver {
  bool _wasBlocking = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(context.read<LedgerController>().handleResume());
    }
  }

  /// Closes any open sheet so it cannot sit on top of the blocking screen.
  void _closeOpenSheets() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<LedgerController>();
    final reckoning = controller.activeReckoning;
    final isBlocking = reckoning != null;
    if (isBlocking && !_wasBlocking) {
      _closeOpenSheets();
    }
    _wasBlocking = isBlocking;

    return PopScope(
      canPop: !isBlocking,
      child: Stack(
        fit: StackFit.expand,
        children: [
          IgnorePointer(
            ignoring: isBlocking,
            child: ExcludeSemantics(excluding: isBlocking, child: widget.child),
          ),
          if (reckoning != null)
            ReckoningScreen(
              reckoning: reckoning,
              verdict: controller.activeVerdict,
              timeUntilWeekCloses: controller.timeUntilWeekCloses,
              timeUntilMidnight: controller.timeUntilMidnight,
              onDismissed: controller.dismissReckoning,
            ),
        ],
      ),
    );
  }
}
