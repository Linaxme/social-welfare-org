import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../data/app_session.dart';
import '../data/org_settings.dart';
import 'widgets.dart';

/// Shared green curved header matching the home dashboard design.
class AppPageHeader extends StatelessWidget {
  const AppPageHeader({
    super.key,
    required this.title,
    this.subtitle = 'সেবা ও কল্যাণমূলক সংগঠন',
    this.showBack = false,
    this.actions,
    this.compact = true,
  }) : welcomeName = null,
       welcomeRole = null,
       isHome = false;

  /// Home dashboard variant with welcome row.
  const AppPageHeader.home({
    super.key,
    required this.title,
    required this.welcomeName,
    required this.welcomeRole,
    this.subtitle = 'সেবা ও কল্যাণমূলক সংগঠন',
  })  : showBack = false,
        actions = null,
        compact = false,
        isHome = true;

  final String title;
  final String subtitle;
  final bool showBack;
  final List<Widget>? actions;
  final bool compact;
  final bool isHome;
  final String? welcomeName;
  final String? welcomeRole;

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    final canPop = showBack && (GoRouter.of(context).canPop());

    return ClipPath(
      clipper: const AppHeaderCurveClipper(),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.fromLTRB(
          16,
          top + (compact ? 4 : 6),
          12,
          compact ? 20 : 22,
        ),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.primaryDark, AppColors.primary],
          ),
        ),
        child: Stack(
          children: [
            const Positioned.fill(
              child: CustomPaint(painter: AppHeaderPatternPainter()),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (canPop || (actions != null && actions!.isNotEmpty))
                  Row(
                    children: [
                      if (canPop)
                        IconButton(
                          visualDensity: VisualDensity.compact,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 36,
                            minHeight: 36,
                          ),
                          onPressed: () => context.pop(),
                          icon: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      const Spacer(),
                      if (actions != null)
                        ...actions!.map(
                          (w) => IconTheme(
                            data: const IconThemeData(color: Colors.white),
                            child: w,
                          ),
                        ),
                    ],
                  ),
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isHome ? 17 : 18,
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFFD4C08A),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    height: 1.2,
                  ),
                ),
                if (isHome && welcomeName != null) ...[
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      AvatarCircle(
                        name: welcomeName!,
                        size: 34,
                        backgroundColor: Colors.white.withValues(alpha: 0.2),
                        foregroundColor: Colors.white,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'স্বাগতম, $welcomeRole',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Convenience scaffold: green header + body (no Material AppBar).
class AppPageScaffold extends StatelessWidget {
  const AppPageScaffold({
    super.key,
    required this.title,
    required this.body,
    this.subtitle = 'সেবা ও কল্যাণমূলক সংগঠন',
    this.showBack = true,
    this.actions,
    this.floatingActionButton,
  });

  final String title;
  final String subtitle;
  final Widget body;
  final bool showBack;
  final List<Widget>? actions;
  final Widget? floatingActionButton;

  @override
  Widget build(BuildContext context) {
    // Auto showBack only when route can pop, unless forced false for tabs.
    final effectiveBack = showBack;

    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: floatingActionButton,
      body: Column(
        children: [
          AppPageHeader(
            title: title,
            subtitle: subtitle,
            showBack: effectiveBack,
            actions: actions,
          ),
          Expanded(child: body),
        ],
      ),
    );
  }
}

/// Shell tab pages — no back button.
class AppTabScaffold extends StatelessWidget {
  const AppTabScaffold({
    super.key,
    required this.title,
    required this.body,
    this.subtitle,
    this.actions,
    this.floatingActionButton,
  });

  final String title;
  final String? subtitle;
  final Widget body;
  final List<Widget>? actions;
  final Widget? floatingActionButton;

  @override
  Widget build(BuildContext context) {
    final org = OrgSettings.instance.orgName;
    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: floatingActionButton,
      body: Column(
        children: [
          AppPageHeader(
            title: title,
            subtitle: subtitle ?? org,
            showBack: false,
            actions: actions,
          ),
          Expanded(child: body),
        ],
      ),
    );
  }
}

String appWelcomeRoleLabel() {
  final s = AppSession.instance;
  if (s.isAdmin) return 'অ্যাডমিন';
  if (s.isCollector) return 'কালেক্টর';
  return 'মেম্বার';
}

class AppHeaderCurveClipper extends CustomClipper<Path> {
  const AppHeaderCurveClipper();

  @override
  Path getClip(Size size) {
    final path = Path()
      ..lineTo(0, size.height - 20)
      ..quadraticBezierTo(
        size.width / 2,
        size.height + 2,
        size.width,
        size.height - 20,
      )
      ..lineTo(size.width, 0)
      ..close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class AppHeaderPatternPainter extends CustomPainter {
  const AppHeaderPatternPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.07)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    const step = 36.0;
    for (var x = -step; x < size.width + step; x += step) {
      for (var y = -step; y < size.height + step; y += step) {
        final c = Offset(x, y);
        const r = 14.0;
        for (var i = 0; i < 8; i++) {
          final a = i * math.pi / 4;
          final a2 = a + math.pi / 4;
          canvas.drawLine(
            c + Offset(math.cos(a) * r, math.sin(a) * r),
            c + Offset(math.cos(a2) * r * 0.55, math.sin(a2) * r * 0.55),
            paint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
