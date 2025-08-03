import 'package:flutter/material.dart';
import 'package:tilikjalan/core/core.dart';
import 'package:tilikjalan/features/map/map.dart';
import 'package:tilikjalan/features/notification/notification.dart';
import 'package:tilikjalan/features/profile/profile.dart';
import 'package:tilikjalan/features/report/report.dart';
import 'package:tilikjalan/features/sensing/sensing.dart';
import 'package:tilikjalan/gen/assets.gen.dart';
import 'package:tilikjalan/utils/utils.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    MapPage(),
    ReportPage(),
    SizedBox(),
    NotificationPage(),
    ProfilePage(),
  ];

  void _onItemTapped(int index) {
    if (index == 2) {
      context.push(const SensingPage());
      return;
    }
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = context.textTheme;

    BottomNavigationBarItem buildItem({
      required Widget icon,
      required Widget activeIcon,
      required String label,
      required bool isActive,
    }) {
      return BottomNavigationBarItem(
        icon: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isActive) activeIcon else icon,
            const SizedBox(height: 4),
            Text(
              label,
              style: textTheme.caption.copyWith(
                color: isActive ? colors.primary[500] : colors.grey[500],
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
        label: '',
      );
    }

    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: colors.primary[500],
        unselectedItemColor: colors.grey[500],
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: [
          buildItem(
            icon: Assets.icons.map.svg(
              width: 24,
              height: 24,
              colorFilter: ColorFilter.mode(
                colors.grey[500]!,
                BlendMode.srcIn,
              ),
            ),
            activeIcon: Assets.icons.mapActive.svg(
              width: 24,
              height: 24,
              colorFilter: ColorFilter.mode(
                colors.primary[500]!,
                BlendMode.srcIn,
              ),
            ),
            label: 'Peta',
            isActive: _selectedIndex == 0,
          ),
          buildItem(
            icon: Assets.icons.report.svg(
              width: 24,
              height: 24,
              colorFilter: ColorFilter.mode(
                colors.grey[500]!,
                BlendMode.srcIn,
              ),
            ),
            activeIcon: Assets.icons.reportActive.svg(
              width: 24,
              height: 24,
              colorFilter: ColorFilter.mode(
                colors.primary[500]!,
                BlendMode.srcIn,
              ),
            ),
            label: 'Lapor',
            isActive: _selectedIndex == 1,
          ),
          const BottomNavigationBarItem(
            icon: SizedBox.shrink(),
            label: 'Sensing',
          ),
          buildItem(
            icon: Assets.icons.notification.svg(
              width: 24,
              height: 24,
              colorFilter: ColorFilter.mode(
                colors.grey[500]!,
                BlendMode.srcIn,
              ),
            ),
            activeIcon: Assets.icons.notificationActive.svg(
              width: 24,
              height: 24,
              colorFilter: ColorFilter.mode(
                colors.primary[500]!,
                BlendMode.srcIn,
              ),
            ),
            label: 'Notifikasi',
            isActive: _selectedIndex == 3,
          ),
          buildItem(
            icon: Assets.icons.profile.svg(
              width: 24,
              height: 24,
              colorFilter: ColorFilter.mode(
                colors.grey[500]!,
                BlendMode.srcIn,
              ),
            ),
            activeIcon: Assets.icons.profileActive.svg(
              width: 24,
              height: 24,
              colorFilter: ColorFilter.mode(
                colors.primary[500]!,
                BlendMode.srcIn,
              ),
            ),
            label: 'Profil',
            isActive: _selectedIndex == 4,
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(top: 8),
        child: SizedBox(
          width: 60,
          height: 60,
          child: FloatingActionButton(
            onPressed: () {
              context.push(const SensingPage());
            },
            elevation: 0,
            shape: const CircleBorder(),
            backgroundColor: colors.primary[500],
            child: Semantics(
              label: 'Sensing',
              child: Assets.icons.sensing.svg(),
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
