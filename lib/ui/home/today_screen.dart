import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:pushup_ledger/core/constants.dart';
import 'package:pushup_ledger/core/copy.dart';
import 'package:pushup_ledger/core/theme/app_spacing.dart';
import 'package:pushup_ledger/state/ledger_controller.dart';
import 'package:pushup_ledger/ui/home/debt_card.dart';
import 'package:pushup_ledger/ui/home/entries_section.dart';
import 'package:pushup_ledger/ui/home/today_progress.dart';
import 'package:pushup_ledger/ui/home/week_strip_view.dart';
import 'package:pushup_ledger/ui/log/log_sheet.dart';
import 'package:pushup_ledger/ui/settings/settings_screen.dart';

class TodayScreen extends StatefulWidget {
  const TodayScreen({super.key});

  @override
  State<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends State<TodayScreen> with WidgetsBindingObserver {
  late final Timer _refreshTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _refreshTimer = Timer.periodic(uiRefreshInterval, (_) => _refresh());
  }

  @override
  void dispose() {
    _refreshTimer.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refresh();
    }
  }

  void _refresh() => context.read<LedgerController>().refresh();

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<LedgerController>();
    final snapshot = controller.snapshot;
    final today = controller.today;
    final startDate = controller.startDate;

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppCopy.navToday),
        actions: [
          IconButton(
            tooltip: AppCopy.settingsTitle,
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const SettingsScreen()),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenHorizontal,
          ),
          child: today == null || snapshot == null
              ? Text(
                  startDate == null
                      ? AppCopy.noStartDate
                      : AppCopy.startsOn(startDate),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: ListView(
                        children: [
                          if (snapshot.totalOwed > 0) ...[
                            DebtCard(
                              totalOwed: snapshot.totalOwed,
                              isCarried: snapshot.carriedOwed > 0,
                              timeUntilDue: controller.timeUntilWeekCloses,
                            ),
                            const SizedBox(height: AppSpacing.cardGap),
                          ],
                          TodayProgress(
                            day: today,
                            status: controller.windowStatus,
                          ),
                          const SizedBox(height: AppSpacing.cardGap),
                          WeekStripView(
                            days: controller.weekStrip,
                            currentStreak: snapshot.currentStreak,
                            bestStreak: snapshot.bestStreak,
                          ),
                          const SizedBox(height: AppSpacing.cardGap),
                          const EntriesSection(),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.lg,
                      ),
                      child: FilledButton(
                        onPressed: () => showLogSheet(context),
                        child: const Text(AppCopy.logPushups),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
