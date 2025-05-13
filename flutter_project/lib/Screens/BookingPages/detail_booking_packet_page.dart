import 'package:flutter/material.dart';
import 'package:flutter_project/Screens/PackagePages/About_tab.dart';
import 'package:flutter_project/Screens/PackagePages/PacketTab.dart';
import 'package:flutter_project/provider/Package_Detail_Provider.dart';
import 'package:flutter_project/provider/favorite_provider.dart';
import 'package:provider/provider.dart';

class DetailBookingPacketPage extends StatelessWidget {
  final int packageId;
  const DetailBookingPacketPage({super.key, required this.packageId});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create:
          (_) =>
              PackageDetailProvider()
                ..fetchPackageDetail(packageId)
                ..fetchImages(packageId),
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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PackageDetailProvider>(context);
    final package = provider.package;
    final imageUrls = provider.imageUrls;

    if (provider.isLoading || package == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            "Package Detail",
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: const Color(0xFF084886),
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
                              ? Colors.red
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
              height: 250,
              child:
                  imageUrls.isEmpty
                      ? Image.asset('assets/images/Act3.jpg', fit: BoxFit.cover)
                      : PageView.builder(
                        itemCount: imageUrls.length,
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
            ),
            TabBar(
              controller: _tabController,
              labelColor: const Color(0xFF084886),
              unselectedLabelColor: Colors.black54,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold),
              indicatorColor: const Color(0xFF084886),
              tabs: const [
                Tab(text: 'Packet'),
                Tab(text: 'About'),
                Tab(text: 'Activity'),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  PacketTab(package: package),
                  AboutTab(package: package),
                  const Center(child: Text("Activity section coming soon")),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
