
import 'package:flutter/material.dart';
import 'package:laoepic_thesis_app/features/package/pages/package_detail_page.dart';
import 'package:laoepic_thesis_app/i18n/i18n_keys.dart';
import 'package:laoepic_thesis_app/i18n/ui_i18n.dart';
import 'package:laoepic_thesis_app/data/models/package_model.dart';
import 'package:laoepic_thesis_app/theme/app_colors.dart';
import 'package:provider/provider.dart';
import 'package:laoepic_thesis_app/shared/utils/responsive_layout.dart';

/// Full-width hero banner with search and promotional messaging on the home page.
class HomeHeroSection extends StatefulWidget {
  final List<PackageModel> packages;

  const HomeHeroSection({super.key, required this.packages});

  @override
  State<HomeHeroSection> createState() => _HomeHeroSectionState();
}

class _HomeHeroSectionState extends State<HomeHeroSection> {
  final _controller = PageController();
  int _index = 0;

  List<PackageModel> get _slides =>
      widget.packages
          .where((p) => p.mainImageUrl.isNotEmpty)
          .take(5)
          .toList();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final i18n = context.watch<UiI18n>();
    final slides = _slides;
    final carouselH = ResponsiveLayout.carouselHeight(context);
    if (slides.isEmpty) {
      return Container(
        height: carouselH,
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [AppColors.primary, AppColors.primary.withOpacity(0.75)],
          ),
        ),
        alignment: Alignment.center,
        padding: const EdgeInsets.all(24),
        child: Text(
          i18n.tr(I18nKey.homeHeroTagline),
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
        ),
      );
    }

    return Column(
      children: [
        SizedBox(
          height: carouselH,
          child: PageView.builder(
            controller: _controller,
            itemCount: slides.length,
            onPageChanged: (i) => setState(() => _index = i),
            itemBuilder: (context, i) {
              final pkg = slides[i];
              return GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PackageDetailPage(packageId: pkg.id),
                  ),
                ),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    image: DecorationImage(
                      image: NetworkImage(pkg.mainImageUrl),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.65),
                        ],
                      ),
                    ),
                    alignment: Alignment.bottomLeft,
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      pkg.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            slides.length,
            (i) => Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: i == _index ? AppColors.primary : Colors.grey.shade300,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
