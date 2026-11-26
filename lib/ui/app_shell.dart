import 'package:material_ui/material_ui.dart';
import 'package:pushup_ledger/core/copy.dart';
import 'package:pushup_ledger/core/theme/app_colors.dart';
import 'package:pushup_ledger/core/theme/app_spacing.dart';
import 'package:pushup_ledger/ui/history/history_screen.dart';
import 'package:pushup_ledger/ui/home/today_screen.dart';

/// The main layout: one screen at a time above the bottom navigation.
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: const [TodayScreen(), HistoryScreen()],
      ),
      bottomNavigationBar: DecoratedBox(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: AppColors.hairline, width: AppSizes.border),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) => setState(() => _selectedIndex = index),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.today_outlined),
              label: AppCopy.navToday,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.grid_view_outlined),
              label: AppCopy.navHistory,
            ),
          ],
        ),
      ),
    );
  }
}
