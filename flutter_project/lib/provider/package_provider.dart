import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_project/models/package_model.dart';
import 'package:flutter_project/config.dart';
import 'package:http/http.dart' as http;

class PackageProvider with ChangeNotifier {
  List<PackageModel> _packages = [];
  bool _isLoading = true;

  List<PackageModel> get packages => _packages;
  bool get isLoading => _isLoading;

  PackageProvider() {
    fetchPackages(); // Call provider when the app starts
  }

// Function to fetch packages
  // This function fetches the list of packages from the API
  Future<void> fetchPackages() async {
    final url = Uri.parse('${AppConfig.baseUrl}/packages/packages');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        _packages = data.map((json) => PackageModel.fromJson(json)).toList();
      } else {
        print("❌ Failed to load packages: ${response.statusCode}");
      }
    } catch (e) {
      print("❌ Error fetching packages: $e");
    }
    _isLoading = false;
    notifyListeners();
  }
}
