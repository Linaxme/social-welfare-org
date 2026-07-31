import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/app_strings.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/data/app_session.dart';
import '../../shared/data/locale_provider.dart';
import '../../shared/data/org_settings.dart';
import '../../shared/widgets/widgets.dart';

class HomeShell extends StatelessWidget {
  const HomeShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  void _onTap(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isWide = width >= 800;
    return isWide
        ? _WebShell(navigationShell: navigationShell, onTap: _onTap)
        : _MobileShell(navigationShell: navigationShell, onTap: _onTap);
  }
}

// ─── Mobile Shell (unchanged) ─────────────────────────────────────────────────

class _MobileShell extends StatelessWidget {
  const _MobileShell({required this.navigationShell, required this.onTap});

  final StatefulNavigationShell navigationShell;
  final void Function(int) onTap;

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.current;
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.primary,
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.35),
              blurRadius: 16,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: BottomNavigationBar(
            currentIndex: navigationShell.currentIndex,
            onTap: onTap,
            backgroundColor: AppColors.primary,
            selectedItemColor: AppColors.secondary,
            unselectedItemColor: Colors.white70,
            selectedFontSize: 11,
            unselectedFontSize: 10,
            type: BottomNavigationBarType.fixed,
            elevation: 0,
            items: [
              BottomNavigationBarItem(
                icon: const Icon(Icons.dashboard_outlined),
                activeIcon: const Icon(Icons.dashboard_rounded),
                label: s.navDashboard,
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.people_outline),
                activeIcon: const Icon(Icons.people_rounded),
                label: s.navMembers,
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.volunteer_activism_outlined),
                activeIcon: const Icon(Icons.volunteer_activism),
                label: s.navHelp,
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.settings_outlined),
                activeIcon: const Icon(Icons.settings),
                label: s.navSettings,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Web Shell ────────────────────────────────────────────────────────────────

class _WebShell extends StatelessWidget {
  const _WebShell({required this.navigationShell, required this.onTap});

  final StatefulNavigationShell navigationShell;
  final void Function(int) onTap;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      body: Row(
        children: [
          _WebSidebar(
            currentIndex: navigationShell.currentIndex,
            onTap: onTap,
          ),
          const VerticalDivider(
              width: 1, thickness: 1, color: AppColors.divider),
          Expanded(
            child: MediaQuery(
              data: MediaQuery.of(context).copyWith(
                padding: EdgeInsets.zero,
              ),
              child: navigationShell,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Sidebar ──────────────────────────────────────────────────────────────────

class _WebSidebar extends StatelessWidget {
  const _WebSidebar({required this.currentIndex, required this.onTap});

  final int currentIndex;
  final void Function(int) onTap;

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.current;
    final navItems = [
      _NavItem(
        icon: Icons.dashboard_outlined,
        activeIcon: Icons.dashboard_rounded,
        label: s.navDashboard,
      ),
      _NavItem(
        icon: Icons.people_outline,
        activeIcon: Icons.people_rounded,
        label: s.navMembers,
      ),
      _NavItem(
        icon: Icons.volunteer_activism_outlined,
        activeIcon: Icons.volunteer_activism,
        label: s.navHelp,
      ),
      _NavItem(
        icon: Icons.settings_outlined,
        activeIcon: Icons.settings,
        label: s.navSettings,
      ),
    ];

    return SizedBox(
      width: 240,
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.primaryDark, AppColors.primary],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _SidebarHeader(),
            const Divider(
                color: Colors.white12, height: 1, indent: 16, endIndent: 16),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                itemCount: navItems.length,
                itemBuilder: (context, i) {
                  final item = navItems[i];
                  final isActive = currentIndex == i;
                  return _SidebarNavTile(
                    icon: item.icon,
                    activeIcon: item.activeIcon,
                    label: item.label,
                    isActive: isActive,
                    onTap: () => onTap(i),
                  );
                },
              ),
            ),
            const Divider(
                color: Colors.white12, height: 1, indent: 16, endIndent: 16),
            _SidebarFooter(),
          ],
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const _NavItem(
      {required this.icon, required this.activeIcon, required this.label});
}

// ─── Sidebar Header ───────────────────────────────────────────────────────────

class _SidebarHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    return ListenableBuilder(
      listenable: OrgSettings.instance,
      builder: (context, _) {
        final orgName = OrgSettings.instance.orgName;
        return Padding(
          padding: EdgeInsets.fromLTRB(16, top + 20, 16, 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.secondary.withValues(alpha: 0.55),
                    width: 1.5,
                  ),
                ),
                child: const Icon(Icons.mosque_rounded,
                    color: AppColors.secondary, size: 24),
              ),
              const SizedBox(height: 11),
              Text(
                orgName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  height: 1.35,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 3),
              Text(
                AppStrings.current.socialWelfareOrg,
                style: TextStyle(
                  color: AppColors.secondary.withValues(alpha: 0.8),
                  fontSize: 10.5,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─── Sidebar Nav Tile ─────────────────────────────────────────────────────────

class _SidebarNavTile extends StatelessWidget {
  const _SidebarNavTile({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          hoverColor: Colors.white.withValues(alpha: 0.08),
          splashColor: Colors.white.withValues(alpha: 0.12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
            decoration: BoxDecoration(
              color: isActive
                  ? Colors.white.withValues(alpha: 0.14)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
              border: isActive
                  ? Border.all(
                      color: AppColors.secondary.withValues(alpha: 0.35),
                      width: 1,
                    )
                  : null,
            ),
            child: Row(
              children: [
                Icon(
                  isActive ? activeIcon : icon,
                  color: isActive ? AppColors.secondary : Colors.white60,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: isActive ? Colors.white : Colors.white70,
                      fontSize: 13,
                      fontWeight:
                          isActive ? FontWeight.w700 : FontWeight.w400,
                    ),
                  ),
                ),
                if (isActive)
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: AppColors.secondary,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Sidebar Footer ───────────────────────────────────────────────────────────

class _SidebarFooter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppSession.instance,
      builder: (context, _) {
        final session = AppSession.instance;
        final user = session.user;
        final s = AppStrings.current;
        final roleLabel = session.isAdmin
            ? s.admin
            : session.isCollector
                ? s.collector
                : s.memberRole;

        return Padding(
          padding: const EdgeInsets.fromLTRB(10, 10, 10, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Language toggle
              ListenableBuilder(
                listenable: LocaleProvider.instance,
                builder: (context, _) {
                  final isBn = LocaleProvider.instance.isBn;
                  return Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => LocaleProvider.instance.toggleLocale(),
                      borderRadius: BorderRadius.circular(8),
                      hoverColor: Colors.white.withValues(alpha: 0.07),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 9),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.07),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.translate_rounded,
                                color: Colors.white54, size: 16),
                            const SizedBox(width: 10),
                            Text(
                              isBn ? 'Switch to English' : 'বাংলায় দেখুন',
                              style: const TextStyle(
                                  color: Colors.white60, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 6),
              // User info + logout
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.07),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    AvatarCircle(
                      name: user.name,
                      size: 32,
                      backgroundColor:
                          AppColors.secondary.withValues(alpha: 0.3),
                      foregroundColor: Colors.white,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            roleLabel,
                            style: TextStyle(
                              color: AppColors.secondary.withValues(alpha: 0.85),
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Tooltip(
                      message: s.logout,
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(6),
                          onTap: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: Text(s.logout),
                                content: const Text(
                                    'আপনি কি সত্যিই লগআউট করতে চান?'),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(ctx, false),
                                    child: Text(s.cancel),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(ctx, true),
                                    child: Text(
                                      s.logout,
                                      style: const TextStyle(
                                          color: AppColors.error),
                                    ),
                                  ),
                                ],
                              ),
                            );
                            if (confirm == true) {
                              await AppSession.instance.logout();
                            }
                          },
                          child: const Padding(
                            padding: EdgeInsets.all(4),
                            child: Icon(Icons.logout_rounded,
                                color: Colors.white54, size: 18),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
