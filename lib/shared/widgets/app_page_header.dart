import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/app_strings.dart';
import '../../core/theme/app_theme.dart';
import '../data/app_session.dart';
import '../data/locale_provider.dart';
import '../data/org_settings.dart';
import 'widgets.dart';

// ─── Helpers ──────────────────────────────────────────────────────────────────

bool _isWebLayout(BuildContext context) =>
    MediaQuery.sizeOf(context).width >= 800;

class LanguageToggleButton extends StatelessWidget {
  const LanguageToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: LocaleProvider.instance,
      builder: (context, _) {
        final isBn = LocaleProvider.instance.isBn;
        return GestureDetector(
          onTap: () => LocaleProvider.instance.toggleLocale(),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              isBn ? 'EN' : 'বাং',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        );
      },
    );
  }
}

// ─── AppPageHeader (mobile curved / web flat) ─────────────────────────────────

class AppPageHeader extends StatelessWidget {
  const AppPageHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.showBack = false,
    this.actions,
    this.compact = true,
  })  : welcomeName = null,
        welcomeRole = null,
        isHome = false;

  const AppPageHeader.home({
    super.key,
    required this.title,
    required this.welcomeName,
    required this.welcomeRole,
    this.subtitle,
  })  : showBack = false,
        actions = null,
        compact = false,
        isHome = true;

  final String title;
  final String? subtitle;
  final bool showBack;
  final List<Widget>? actions;
  final bool compact;
  final bool isHome;
  final String? welcomeName;
  final String? welcomeRole;

  @override
  Widget build(BuildContext context) {
    if (_isWebLayout(context)) {
      return _WebPageHeader(
        title: title,
        subtitle: subtitle,
        showBack: showBack,
        actions: actions,
        isHome: isHome,
        welcomeName: welcomeName,
        welcomeRole: welcomeRole,
      );
    }
    return _MobilePageHeader(
      title: title,
      subtitle: subtitle,
      showBack: showBack,
      actions: actions,
      compact: compact,
      isHome: isHome,
      welcomeName: welcomeName,
      welcomeRole: welcomeRole,
    );
  }
}

// ─── Mobile Header (original curved) ─────────────────────────────────────────

class _MobilePageHeader extends StatelessWidget {
  const _MobilePageHeader({
    required this.title,
    this.subtitle,
    required this.showBack,
    this.actions,
    required this.compact,
    required this.isHome,
    this.welcomeName,
    this.welcomeRole,
  });

  final String title;
  final String? subtitle;
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
    final s = AppStrings.current;
    final effectiveSubtitle = subtitle ?? s.socialWelfareOrg;

    return ClipPath(
      clipper: const AppHeaderCurveClipper(),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.fromLTRB(
          16,
          top + (compact ? 18 : 24),
          12,
          compact ? 54 : 68,
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
                if (canPop || (actions != null && actions!.isNotEmpty) || isHome)
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
                      const LanguageToggleButton(),
                      if (actions != null) ...[
                        const SizedBox(width: 4),
                        ...actions!.map(
                          (w) => IconTheme(
                            data: const IconThemeData(color: Colors.white),
                            child: w,
                          ),
                        ),
                      ],
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
                  effectiveSubtitle,
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
                          '${s.welcome}, $welcomeName',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          welcomeRole ?? '',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
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

// ─── Web Header (flat top bar) ────────────────────────────────────────────────

class _WebPageHeader extends StatelessWidget {
  const _WebPageHeader({
    required this.title,
    this.subtitle,
    required this.showBack,
    this.actions,
    required this.isHome,
    this.welcomeName,
    this.welcomeRole,
  });

  final String title;
  final String? subtitle;
  final bool showBack;
  final List<Widget>? actions;
  final bool isHome;
  final String? welcomeName;
  final String? welcomeRole;

  @override
  Widget build(BuildContext context) {
    final canPop = showBack && GoRouter.of(context).canPop();
    final s = AppStrings.current;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: AppColors.divider, width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (canPop) ...[
            InkWell(
              onTap: () => context.pop(),
              borderRadius: BorderRadius.circular(8),
              child: const Padding(
                padding: EdgeInsets.all(6),
                child: Icon(Icons.arrow_back_ios_new_rounded,
                    size: 18, color: AppColors.primary),
              ),
            ),
            const SizedBox(width: 10),
          ],
          // Title section
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    height: 1.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (subtitle != null || isHome) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle ?? s.socialWelfareOrg,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          // Welcome name on home
          if (isHome && welcomeName != null) ...[
            const SizedBox(width: 16),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AvatarCircle(
                    name: welcomeName!,
                    size: 24,
                    backgroundColor:
                        AppColors.primary.withValues(alpha: 0.15),
                    foregroundColor: AppColors.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${s.welcome}, $welcomeName',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      welcomeRole ?? '',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          // Action buttons
          if (actions != null) ...[
            const SizedBox(width: 8),
            ...actions!.map(
              (w) => IconTheme(
                data: const IconThemeData(color: AppColors.primary),
                child: w,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── AppPageScaffold ──────────────────────────────────────────────────────────

class AppPageScaffold extends StatelessWidget {
  const AppPageScaffold({
    super.key,
    required this.title,
    required this.body,
    this.subtitle,
    this.showBack = true,
    this.actions,
    this.floatingActionButton,
  });

  final String title;
  final String? subtitle;
  final Widget body;
  final bool showBack;
  final List<Widget>? actions;
  final Widget? floatingActionButton;

  @override
  Widget build(BuildContext context) {
    final isWeb = _isWebLayout(context);
    return Scaffold(
      backgroundColor: isWeb ? const Color(0xFFF4F6F8) : AppColors.background,
      floatingActionButton: floatingActionButton,
      body: Column(
        children: [
          AppPageHeader(
            title: title,
            subtitle: subtitle,
            showBack: showBack,
            actions: actions,
          ),
          Expanded(
            child: isWeb
                ? Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 960),
                      child: body,
                    ),
                  )
                : body,
          ),
        ],
      ),
    );
  }
}

// ─── AppTabScaffold ───────────────────────────────────────────────────────────

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
    final isWeb = _isWebLayout(context);
    return Scaffold(
      backgroundColor: isWeb ? const Color(0xFFF4F6F8) : AppColors.background,
      floatingActionButton: floatingActionButton,
      body: Column(
        children: [
          AppPageHeader(
            title: title,
            subtitle: subtitle ?? org,
            showBack: false,
            actions: actions,
          ),
          Expanded(
            child: isWeb
                ? Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 960),
                      child: body,
                    ),
                  )
                : body,
          ),
        ],
      ),
    );
  }
}

// ─── Role label helper ────────────────────────────────────────────────────────

String appWelcomeRoleLabel() {
  final s = AppSession.instance;
  final strings = AppStrings.current;
  if (s.isAdmin) return strings.admin;
  if (s.isCollector) return strings.collector;
  return strings.memberRole;
}

// ─── Clippers & Painters (mobile) ────────────────────────────────────────────

class AppHeaderCurveClipper extends CustomClipper<Path> {
  const AppHeaderCurveClipper();

  @override
  Path getClip(Size size) {
    final path = Path()
      ..lineTo(0, size.height - 54)
      ..quadraticBezierTo(
        size.width / 2,
        size.height + 8,
        size.width,
        size.height - 54,
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
