
import 'package:flutter/material.dart';
import 'package:laoepic_thesis_app/data/models/package_list_filters.dart';
import 'package:laoepic_thesis_app/providers/package_provider.dart';
import 'package:laoepic_thesis_app/i18n/i18n_keys.dart';
import 'package:laoepic_thesis_app/i18n/ui_i18n.dart';
import 'package:laoepic_thesis_app/features/package/widgets/package_card.dart';
import 'package:provider/provider.dart';

/// Browse-all-packages tab with search and scrollable package cards.
class MainPackagePage extends StatefulWidget {
  const MainPackagePage({super.key});

  @override
  State<MainPackagePage> createState() => _MainPackagePageState();
}

class _MainPackagePageState extends State<MainPackagePage> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PackageProvider>().fetchPackages(
        filters: const PackageListFilters(),
      );
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _applySearch(String value) {
    context.read<PackageProvider>().fetchPackages(
      filters: PackageListFilters(
        search: value.trim().isEmpty ? null : value.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final i18n = context.watch<UiI18n>();
    final packageProvider = context.watch<PackageProvider>();
    final packages = packageProvider.packages;

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        title: Text(i18n.tr(I18nKey.packageAllPackages)),
        backgroundColor: const Color(0xFF084887),
        elevation: 2,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              onSubmitted: _applySearch,
              decoration: InputDecoration(
                hintText: i18n.tr(I18nKey.commonSearch),
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () => _applySearch(_searchController.text),
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: packageProvider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : packages.isEmpty
                  ? Center(child: Text(i18n.tr(I18nKey.packageNoPackagesFound)))
                  : RefreshIndicator(
                      onRefresh: () => packageProvider.fetchPackages(),
                      child: ListView.separated(
                        itemCount: packages.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          return PackageCard(
                            pkg: packages[index],
                            fullWidth: true,
                          );
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
