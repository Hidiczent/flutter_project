
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:laoepic_thesis_app/features/package/pages/package_detail_page.dart';
import 'package:laoepic_thesis_app/features/notifications/pages/notification_page.dart';
import 'package:laoepic_thesis_app/shared/utils/open_filtered_packages.dart';
import 'package:laoepic_thesis_app/data/models/package_list_filters.dart';
import 'package:laoepic_thesis_app/features/home/widgets/home_best_top_section.dart';
import 'package:laoepic_thesis_app/features/home/widgets/home_hero_section.dart';
import 'package:laoepic_thesis_app/features/home/widgets/home_about_highlights_section.dart';
import 'package:laoepic_thesis_app/features/home/widgets/home_package_types_section.dart';
import 'package:laoepic_thesis_app/features/home/widgets/home_our_services_section.dart';
import 'package:laoepic_thesis_app/features/home/widgets/home_reviews_section.dart';
import 'package:laoepic_thesis_app/features/home/widgets/home_top_experiences_section.dart';
import 'package:laoepic_thesis_app/data/services/pending_payment.dart';
import 'package:laoepic_thesis_app/features/payment/pages/payment_return_page.dart';
import 'package:laoepic_thesis_app/features/package/widgets/package_card.dart';
import 'package:provider/provider.dart';
import 'package:laoepic_thesis_app/core/api/api_locale_prefs.dart';
import 'package:laoepic_thesis_app/config/app_config.dart';
import 'package:laoepic_thesis_app/data/models/package_model.dart';
import 'package:laoepic_thesis_app/providers/package_provider.dart';
import 'package:laoepic_thesis_app/providers/price_display_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:laoepic_thesis_app/i18n/i18n_keys.dart';
import 'package:laoepic_thesis_app/i18n/ui_i18n.dart';
import 'package:laoepic_thesis_app/theme/app_colors.dart';

/// Main landing screen aggregating hero, featured packages, reviews, and quick actions.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  String searchQuery = '';
  int unreadNotificationsCount = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    checkToken();
    fetchUnreadNotificationsCount();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      fetchUnreadNotificationsCount();
      _resumePendingPayment();
    }
  }

  Future<void> _resumePendingPayment() async {
    final pending = await PendingPayment.load();
    if (pending == null || !mounted) return;
    await Navigator.push<void>(
      context,
      MaterialPageRoute<void>(
        builder: (_) => PaymentReturnPage(
          bookingId: pending.bookingId,
          invoiceNo: pending.invoiceNo,
        ),
      ),
    );
  }

  String _badgeLabel(int count) {
    if (count > 99) return '99+';
    return '$count';
  }

  void checkToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');
    if (token != null) {
      print("🔐 Token: $token");
    } else {
      print("❌ No token found");
    }
  }

  Future<void> fetchUnreadNotificationsCount() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (!mounted) return;

      final token = prefs.getString('jwt_token');
      if (token == null) return;

      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}/notifications/unread-count'),
        headers: await buildAuthApiHeaders(token),
      );
      if (!mounted) return;

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        if (body['success'] == true && body['data'] is Map<String, dynamic>) {
          final c = body['data']['count'];
          if (!mounted) return;
          setState(() {
            unreadNotificationsCount = c is int ? c : int.tryParse('$c') ?? 0;
          });
        }
      }
    } catch (e, st) {
      debugPrint('fetchUnreadNotificationsCount failed: $e\n$st');
    }
  }

  @override
  Widget build(BuildContext context) {
    final packageProvider = Provider.of<PackageProvider>(context);
    final i18n = context.watch<UiI18n>();
    final packages = packageProvider.packages;
    final featured = packages.take(8).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(i18n),
      body:
          packageProvider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  HomeHeroSection(packages: packages),
                  const SizedBox(height: 16),
                  const HomeBestTopSection(),
                  const SizedBox(height: 16),
                  const HomeOurServicesSection(),
                  const SizedBox(height: 16),
                  const HomeAboutHighlightsSection(),
                  const SizedBox(height: 16),
                  const HomePackageTypesSection(),
                  const SizedBox(height: 16),
                  HomeTopExperiencesSection(packages: packages),
                  const SizedBox(height: 16),
                  HomeReviewsSection(
                    packageIds: packages.take(12).map((p) => p.id).toList(),
                    packageTitles: {
                      for (final p in packages.take(12)) p.id: p.title,
                    },
                  ),
                  const SizedBox(height: 8),
                  sectionTitle(
                    i18n,
                    i18n.tr(I18nKey.homeFeaturedPackages),
                    onSeeAll: () {
                      openFilteredPackagesPage(
                        context,
                        initialFilters: PackageListFilters(
                          search: searchQuery.trim().isEmpty
                              ? null
                              : searchQuery.trim(),
                        ),
                        title: i18n.tr(I18nKey.packageAllPackages),
                      );
                    },
                  ),
                  if (featured.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Center(
                        child: Text(i18n.tr(I18nKey.packageNoPackagesFound)),
                      ),
                    )
                  else
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: featured.map((pkg) => PackageCard(pkg: pkg)).toList(),
                      ),
                    ),
                ],
              ),
    );
  }

  PreferredSizeWidget _buildAppBar(UiI18n i18n) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(100),
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 50, 16, 16),
        decoration: const BoxDecoration(color: AppColors.primary),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Container(
                height: 45,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search, color: Colors.grey),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        onChanged: (val) => setState(() => searchQuery = val),
                        onSubmitted: (val) {
                          if (val.trim().isEmpty) return;
                          openFilteredPackagesPage(
                            context,
                            initialFilters: PackageListFilters(search: val.trim()),
                            title: i18n.tr(I18nKey.packageAllPackages),
                          );
                        },
                        decoration: InputDecoration(
                          hintText: i18n.tr(I18nKey.commonSearch),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Stack(
              children: [
                GestureDetector(
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const NotificationPage(),
                      ),
                    );
                    if (mounted) fetchUnreadNotificationsCount();
                  },
                  child: Icon(
                    Icons.notifications,
                    color: AppColors.accent,
                    size: 30,
                  ),
                ),
                if (unreadNotificationsCount > 0)
                  Positioned(
                    right: -2,
                    top: -2,
                    child: Container(
                      constraints: const BoxConstraints(
                        minWidth: 20,
                        minHeight: 20,
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                      child: Center(
                        child: Text(
                          _badgeLabel(unreadNotificationsCount),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            height: 1.1,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget sectionTitle(UiI18n i18n, String title, {VoidCallback? onSeeAll}) =>
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            if (onSeeAll != null)
              GestureDetector(
                onTap: onSeeAll,
                child: Text(
                  i18n.tr(I18nKey.commonSeeAll),
                  style: const TextStyle(color: AppColors.accent),
                ),
              ),
          ],
        ),
      );

  Widget imageCard(String title, String imagePath) => Container(
    height: 140,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(12),
      image: DecorationImage(image: AssetImage(imagePath), fit: BoxFit.cover),
    ),
    alignment: Alignment.bottomLeft,
    padding: const EdgeInsets.all(12),
    child: Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    ),
  );

  Widget activityCardFromApi(UiI18n i18n, PackageModel pkg) {
    final pdp = context.watch<PriceDisplayProvider>();
    return GestureDetector(
    onTap:
        () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PackageDetailPage(packageId: pkg.id),
          ),
        ),
    child: Container(
      width: 180,
      margin: const EdgeInsets.symmetric(horizontal: 7),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 5)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Image.network(
              pkg.mainImageUrl,
              height: 130,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder:
                  (context, error, stackTrace) => Image.asset(
                    'assets/images/default.jpg',
                    fit: BoxFit.cover,
                  ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pkg.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                if (pkg.location != null && pkg.location!.isNotEmpty)
                  Text(
                    pkg.location!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 11, color: Colors.black54),
                  ),
                if (pkg.durationDays != null)
                  Text(
                    i18n.tr(
                      I18nKey.packageDurationDaysShort,
                      params: {'days': '${pkg.durationDays}'},
                    ),
                    style: const TextStyle(fontSize: 10, color: Colors.black45),
                  ),
                Text(
                  pkg.about,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 11),
                ),
                Row(
                  children: List.generate(
                    5,
                    (index) =>
                        const Icon(Icons.star, color: Colors.amber, size: 16),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  pkg.displayPrice(pdp),
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
  }
}

/// Tappable shortcut tile used in the home page quick-action grid.
class ActionItem extends StatelessWidget {
  final IconData icon;
  final String label;

  const ActionItem({super.key, required this.icon, required this.label});

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.accentSurface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, color: AppColors.accent, size: 28),
      ),
      const SizedBox(height: 6),
      Text(
        label,
        style: const TextStyle(
          color: AppColors.accent,
          fontWeight: FontWeight.w600,
        ),
      ),
    ],
  );
}
