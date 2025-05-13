import 'package:flutter/material.dart';
import 'package:flutter_project/provider/package_provider.dart';
import 'package:flutter_project/widget/Package_Card.dart';
import 'package:provider/provider.dart';

class PackagePage extends StatefulWidget {
  const PackagePage({super.key});

  @override
  State<PackagePage> createState() => _PackagePageState();
}

class _PackagePageState extends State<PackagePage> {
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final packageProvider = Provider.of<PackageProvider>(context);
    final allPackages = packageProvider.packages;

    // ✅ กรองรายการตามคำค้นหา
    final filteredPackages =
        allPackages
            .where(
              (pkg) =>
                  pkg.title.toLowerCase().contains(searchQuery.toLowerCase()),
            )
            .toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        title: const Text('All Packages'),
        backgroundColor: const Color(0xFF084886),
        elevation: 2,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child:
            allPackages.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : Column(
                  children: [
                    TextField(
                      onChanged: (val) {
                        setState(() => searchQuery = val);
                      },
                      decoration: InputDecoration(
                        hintText: 'Search package...',
                        prefixIcon: const Icon(
                          Icons.search,
                          color: Colors.grey,
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

                    // ✅ รายการแพ็คเกจ
                    Expanded(
                      child:
                          filteredPackages.isEmpty
                              ? const Center(child: Text('No packages found.'))
                              : ListView.separated(
                                itemCount: filteredPackages.length,
                                separatorBuilder:
                                    (context, index) =>
                                        const SizedBox(height: 12),
                                itemBuilder: (context, index) {
                                  final pkg = filteredPackages[index];
                                  return PackageCard(pkg: pkg);
                                },
                              ),
                    ),
                  ],
                ),
      ),
    );
  }
}
