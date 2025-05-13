// ✅ STEP 1: Create a PackageDetailProvider
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_project/models/package_model.dart';
import 'package:flutter_project/config.dart';

class PackageDetailProvider with ChangeNotifier {
  PackageModel? _package;
  List<String> _imageUrls = [];
  bool _isLoading = true;

  // packageModel is a class that represents the package details
  // It contains properties like packageId, packageName, packageDescription, etc.
  PackageModel? get package => _package; 
  List<String> get imageUrls => _imageUrls;
  bool get isLoading => _isLoading;
 /// Function to fetch package details
  // This function takes a packageId as an argument and fetches the package details from the API
  Future<void> fetchPackageDetail(int packageId) async {
    _isLoading = true;
    notifyListeners(); // Notify listeners to update the UI
    // Fetch package details from the API
    // It uses the http package to make a GET request to the API
    // It uses the AppConfig class to get the base URL of the API

    try {
      final res = await http.get(
        Uri.parse('${AppConfig.baseUrl}/packages/package/$packageId'),
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        _package = PackageModel.fromJson(data);
      }
    } catch (e) {
      print("❌ Error fetching package detail: $e");
    }

    _isLoading = false;
    notifyListeners();
  }


// Function to fetch package images
  // This function takes a packageId as an argument and fetches the package images from the API
  Future<void> fetchImages(int packageId) async {
    try {
      final res = await http.get(
        Uri.parse('${AppConfig.baseUrl}/packageImage/package-images/$packageId'),
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        _imageUrls = (data as List).map((e) => e['image_url'].toString()).toList();
      }
    } catch (e) {
      print("❌ Error fetching images: $e");
    }
    notifyListeners();
  }

  void clear() {
    _package = null;
    _imageUrls = [];
    _isLoading = true;
    notifyListeners();
  }
}
