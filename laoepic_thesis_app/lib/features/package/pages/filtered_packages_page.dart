
import 'package:flutter/material.dart';
import 'package:laoepic_thesis_app/i18n/i18n_keys.dart';
import 'package:laoepic_thesis_app/i18n/ui_i18n.dart';
import 'package:laoepic_thesis_app/data/models/package_list_filters.dart';
import 'package:laoepic_thesis_app/data/models/package_model.dart';
import 'package:laoepic_thesis_app/data/services/packages_api.dart';
import 'package:laoepic_thesis_app/theme/app_colors.dart';
import 'package:laoepic_thesis_app/features/package/widgets/package_card.dart';
import 'package:provider/provider.dart';

/// Filtered package list — uses local state so it does not overwrite [PackageProvider]
/// (Home and Package tab keep the full catalog).
class FilteredPackagesPage extends StatefulWidget {
  final PackageListFilters initialFilters;
  final String title;

  const FilteredPackagesPage({
    super.key,
    required this.initialFilters,
    required this.title,
  });

  @override
  State<FilteredPackagesPage> createState() => _FilteredPackagesPageState();
}

class _FilteredPackagesPageState extends State<FilteredPackagesPage> {
  late PackageListFilters _filters;
  final _searchController = TextEditingController();
  List<PackageModel> _packages = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _filters = widget.initialFilters;
    _searchController.text = widget.initialFilters.search ?? '';
    _load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final list = await PackagesApi.fetchPackages(filters: _filters);
      if (!mounted) return;
      setState(() {
        _packages = list;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _packages = [];
        _loading = false;
      });
    }
  }

  void _applySearch(String value) {
    setState(() {
      _filters = _filters.copyWith(
        search: value.trim().isEmpty ? null : value.trim(),
        clearSearch: value.trim().isEmpty,
      );
    });
    _load();
  }

  void _clearFilters() {
    setState(() {
      _filters = PackageListFilters(
        search: _searchController.text.trim().isEmpty
            ? null
            : _searchController.text.trim(),
      );
    });
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final i18n = context.watch<UiI18n>();

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: AppColors.primary,
        actions: [
          if (_filters.hasServerFilter)
            TextButton(
              onPressed: _clearFilters,
              child: Text(
                i18n.tr(I18nKey.packageClearFilter),
                style: const TextStyle(color: Colors.white),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: TextField(
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
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                _error!,
                style: TextStyle(color: Colors.red.shade700, fontSize: 13),
              ),
            ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _packages.isEmpty
                ? Center(child: Text(i18n.tr(I18nKey.packageNoPackagesFound)))
                : RefreshIndicator(
                    onRefresh: _load,
                    child: ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: _packages.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        return PackageCard(pkg: _packages[index], fullWidth: true);
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
