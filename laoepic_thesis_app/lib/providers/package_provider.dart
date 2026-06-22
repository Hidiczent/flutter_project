
import 'package:flutter/material.dart';
import 'package:laoepic_thesis_app/data/models/package_list_filters.dart';
import 'package:laoepic_thesis_app/data/models/package_model.dart';
import 'package:laoepic_thesis_app/data/services/packages_api.dart';

/// Holds the searchable package catalog list and active filter state for browsing.
class PackageProvider with ChangeNotifier {
  List<PackageModel> _packages = [];
  bool _isLoading = true;
  String? _error;
  PackageListFilters _filters = const PackageListFilters();

  List<PackageModel> get packages => _packages;
  bool get isLoading => _isLoading;
  String? get error => _error;
  PackageListFilters get filters => _filters;

  PackageProvider() {
    fetchPackages();
  }
  /// Fetches packages from the Lao Epic API.
  Future<void> fetchPackages({PackageListFilters? filters}) async {
    if (filters != null) _filters = filters;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _packages = await PackagesApi.fetchPackages(filters: _filters);
    } catch (e) {
      _error = e.toString();
      _packages = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Clear filters for this module.
  void clearFilters() {
    fetchPackages(filters: const PackageListFilters());
  }
}
