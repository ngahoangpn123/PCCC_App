import 'package:flutter/material.dart';

import '../../core/di/locator.dart';
import '../calendar/screens/calendar_screen.dart';
import '../home/screens/home_screen.dart';
import '../management/screens/management_screen.dart';
import '../notifications/screens/notifications_screen.dart';
import '../profile/screens/profile_screen.dart';

/// Khung chính với 5 tab ở thanh điều hướng dưới.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;
  int _unread = 0;

  @override
  void initState() {
    super.initState();
    _refreshUnread();
  }

  Future<void> _refreshUnread() async {
    final count = await Locator.notifications.unreadCount();
    if (mounted) setState(() => _unread = count);
  }

  void _goTo(int index) {
    setState(() => _index = index);
    _refreshUnread();
  }

  Widget _page() {
    switch (_index) {
      case 0:
        return HomeScreen(onOpenTab: _goTo);
      case 1:
        return const ManagementScreen();
      case 2:
        return const CalendarScreen();
      case 3:
        return NotificationsScreen(onChanged: _refreshUnread);
      default:
        return const ProfileScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Mỗi lần đổi tab sẽ tải lại dữ liệu của tab đó.
      body: KeyedSubtree(key: ValueKey(_index), child: _page()),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: _goTo,
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Trang chủ',
          ),
          const NavigationDestination(
            icon: Icon(Icons.grid_view_outlined),
            selectedIcon: Icon(Icons.grid_view_rounded),
            label: 'Quản lý',
          ),
          const NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month),
            label: 'Lịch',
          ),
          NavigationDestination(
            icon: Badge(
              isLabelVisible: _unread > 0,
              label: Text('$_unread'),
              child: const Icon(Icons.notifications_outlined),
            ),
            selectedIcon: Badge(
              isLabelVisible: _unread > 0,
              label: Text('$_unread'),
              child: const Icon(Icons.notifications),
            ),
            label: 'Thông báo',
          ),
          const NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Cá nhân',
          ),
        ],
      ),
    );
  }
}
