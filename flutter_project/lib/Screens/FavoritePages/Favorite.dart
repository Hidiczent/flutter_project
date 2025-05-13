import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_project/provider/favorite_provider.dart';
import 'package:flutter_project/provider/package_provider.dart';
import 'package:flutter_project/Screens/BookingPages/detail_booking_packet_page.dart';

class FavoritePage extends StatelessWidget {
  const FavoritePage({super.key});
  @override
  Widget build(BuildContext context) {
    final favoriteProvider = Provider.of<FavoriteProvider>(
      context,
    ); // 🧠 favoriteProvider
    final packageProvider = Provider.of<PackageProvider>(
      context,
    ); // 🧠 packageProvider is a class that provides the list of packages

    // 🧠 packageProvider is a class that provides the list of packages
    final favoritePackages =
        packageProvider.packages
            .where((pkg) => favoriteProvider.isFavorited(pkg.id))
            .toList();
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Favorites"),
        backgroundColor: const Color(0xFF084886),
        centerTitle: true,
      ),
      body: Container(
        color: const Color(0xFFF9F9F9),
        child:
            // Check if the packageProvider is loading
            // If it is loading, show a loading indicator
            // If it is not loading, check if the favoritePackages list is empty
            // If it is empty, show a message indicating that there are no favorites
            // If it is not empty, show the list of favorite packages
            // The ListView.builder widget is used to create a scrollable list of items
            packageProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : favoritePackages.isEmpty
                ? const Center(
                  child: Text(
                    "You don’t have any favorites yet",
                    style: TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                )
                : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: favoritePackages.length,
                  itemBuilder: (context, index) {
                    final pkg = favoritePackages[index];
                    return Dismissible(
                      key: Key(pkg.id.toString()),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        alignment: Alignment.centerRight,
                        decoration: BoxDecoration(
                          color: Colors.redAccent,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.delete,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      onDismissed: (direction) {
                        favoriteProvider.toggleFavorite(pkg.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              "${pkg.title} has been removed from your favorite list",
                            ),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => DetailBookingPacketPage(
                                    packageId: pkg.id,
                                  ),
                            ),
                          );
                        },
                        child: Card(
                          color: const Color(0xFFF9F9F9),
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(
                                    pkg.mainImageUrl,
                                    width: 120,
                                    height: 120,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            Image.asset(
                                              'assets/images/default.jpg',
                                              width: 120,
                                              height: 120,
                                              fit: BoxFit.cover,
                                            ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        pkg.title,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: Color(0xFF084886),
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        pkg.about,
                                        maxLines: 3,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          color: Colors.black87,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(
                                  Icons.chevron_right,
                                  color: Colors.grey,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
      ),
    );
  }
}
