
import 'package:flutter/material.dart';
import 'package:laoepic_thesis_app/features/package/pages/filtered_packages_page.dart';
import 'package:laoepic_thesis_app/data/models/package_list_filters.dart';
import 'package:laoepic_thesis_app/providers/package_provider.dart';
import 'package:provider/provider.dart';

/// Opens filtered list (local fetch) then restores full catalog for Home/Package tab.
Future<void> openFilteredPackagesPage(
  BuildContext context, {
  required PackageListFilters initialFilters,
  required String title,
}) async {
  await Navigator.push<void>(
    context,
    MaterialPageRoute<void>(
      builder: (_) => FilteredPackagesPage(
        initialFilters: initialFilters,
        title: title,
      ),
    ),
  );
  if (!context.mounted) return;
  await context.read<PackageProvider>().fetchPackages(
    filters: const PackageListFilters(),
  );
}
