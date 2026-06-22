
import 'package:flutter/material.dart';
import 'package:laoepic_thesis_app/features/package/pages/about_tab.dart';
import 'package:laoepic_thesis_app/features/package/pages/package_tab.dart';
import 'package:laoepic_thesis_app/features/package/pages/package_activity_tab.dart';
import 'package:laoepic_thesis_app/providers/package_detail_provider.dart';
import 'package:laoepic_thesis_app/providers/favorite_provider.dart';
import 'package:laoepic_thesis_app/i18n/i18n_keys.dart';
import 'package:laoepic_thesis_app/i18n/ui_i18n.dart';
import 'package:laoepic_thesis_app/theme/app_colors.dart';
import 'package:provider/provider.dart';
import 'package:laoepic_thesis_app/shared/utils/responsive_layout.dart';

/// Detail host that loads a single tour package and renders tabbed content.
class PackageDetailPage extends StatelessWidget {
  final int packageId;
  const PackageDetailPage({super.key, required this.packageId});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PackageDetailProvider()..loadPackage(packageId),
      child: _PackageDetailView(packageId: packageId),
    );
  }
}

class _PackageDetailView extends StatefulWidget {
  final int packageId;
  const _PackageDetailView({required this.packageId});

  @override
  State<_PackageDetailView> createState() => _PackageDetailViewState();
}

class _PackageDetailViewState extends State<_PackageDetailView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late PageController _heroPageController;
  int _heroIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _heroPageController = PageController();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _heroPageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PackageDetailProvider>(context);
    final i18n = context.watch<UiI18n>();
    final package = provider.package;
    final imageUrls = provider.imageUrls;

    if (provider.isLoading || package == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          i18n.tr(I18nKey.packageDetailTitle),
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: AppColors.primary,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          Consumer<FavoriteProvider>(
            builder:
                (context, fav, _) => IconButton(
                  icon: Icon(
                    fav.isFavorited(widget.packageId)
                        ? Icons.favorite
                        : Icons.favorite_border,
                    color:
                        fav.isFavorited(widget.packageId)
                            ? Colors.redAccent
                            : Colors.white,
                  ),
                  onPressed: () => fav.toggleFavorite(widget.packageId),
                ),
          ),
        ],
      ),
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          SizedBox(
            height: ResponsiveLayout.carouselHeight(context),
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (imageUrls.isEmpty)
                    Image.asset('assets/images/Act3.jpg', fit: BoxFit.cover)
                  else
                    PageView.builder(
                      controller: _heroPageController,
                      itemCount: imageUrls.length,
                      onPageChanged: (i) => setState(() => _heroIndex = i),
                      itemBuilder:
                          (context, index) => Image.network(
                            imageUrls[index],
                            fit: BoxFit.cover,
                            errorBuilder:
                                (_, __, ___) => Image.asset(
                                  'assets/images/Act3.jpg',
                                  fit: BoxFit.cover,
                                ),
                          ),
                    ),
                  if (imageUrls.length > 1)
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 10,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          imageUrls.length,
                          (i) => AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            width: i == _heroIndex ? 18 : 7,
                            height: 7,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              color:
                                  i == _heroIndex
                                      ? Colors.white
                                      : Colors.white.withOpacity(0.45),
                              boxShadow: [
                                if (i == _heroIndex)
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.25),
                                    blurRadius: 4,
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  if (imageUrls.length > 1)
                    Positioned(
                      top: 10,
                      right: 10,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.45),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          child: Text(
                            '${_heroIndex + 1} / ${imageUrls.length}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          TabBar(
            controller: _tabController,
            labelColor: AppColors.primary,
            unselectedLabelColor: Colors.black54,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold),
            indicatorColor: AppColors.primary,
            tabs: [
              Tab(text: i18n.tr(I18nKey.packageTabPackage)),
              Tab(text: i18n.tr(I18nKey.packageTabAbout)),
              Tab(text: i18n.tr(I18nKey.packageTabDepartures)),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                PackageTab(package: package),
                AboutTab(package: package),
                PackageActivityTab(package: package),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
