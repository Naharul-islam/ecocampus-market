import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/theme/app_theme.dart';
import '../../core/routes/app_router.dart';

class MyListingsScreen extends StatelessWidget {
  const MyListingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Listings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: () => Navigator.pushNamed(context, AppRouter.addProduct),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('listings')
            .where('seller_id', isEqualTo: user?.uid)
            .orderBy('created_at', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('📋', style: TextStyle(fontSize: 64)),
                  const SizedBox(height: 16),
                  const Text('No listings yet', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                  const SizedBox(height: 8),
                  const Text('Post your first item to get started!', style: TextStyle(color: AppColors.textSecondary)),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.pushNamed(context, AppRouter.addProduct),
                    icon: const Icon(Icons.add),
                    label: const Text('Add Listing'),
                  ),
                ],
              ),
            );
          }

          final listings = snapshot.data!.docs;

          return Column(
            children: [
              // Stats bar
              Container(
                padding: const EdgeInsets.all(16),
                color: AppColors.ecoGreen,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _statChip('📦', '${listings.length}', 'Total'),
                    _statChip('✅', '${listings.where((d) => (d.data() as Map)['is_available'] == true).length}', 'Active'),
                    _statChip('🌱', '${listings.fold<double>(0, (sum, d) { final data = d.data() as Map<String, dynamic>; return sum + ((data['co2_saved'] ?? 0) as num).toDouble(); }).toStringAsFixed(1)} kg', 'CO₂ Saved'),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: listings.length,
                  itemBuilder: (context, i) {
                    final data = listings[i].data() as Map<String, dynamic>;
                    final docId = listings[i].id;
                    return _listingCard(context, data, docId);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _statChip(String emoji, String value, String label) {
    return Column(children: [
      Text(emoji, style: const TextStyle(fontSize: 20)),
      Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primaryDark)),
      Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
    ]);
  }

  Widget _listingCard(BuildContext context, Map<String, dynamic> data, String docId) {
    final isAvailable = data['is_available'] ?? true;
    final imageUrls = data['image_urls'] as List?;
    final type = data['transaction_type'] ?? 'Buy';

    final typeColors = {
      'Buy': Colors.blue,
      'Rent': Colors.orange,
      'Swap': Colors.purple,
      'Donate': Colors.green,
    };
    final typeColor = typeColors[type] ?? Colors.blue;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Image
              ClipRRect(
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), bottomLeft: Radius.circular(16)),
                child: Container(
                  width: 90, height: 90,
                  color: AppColors.ecoGreen,
                  child: imageUrls != null && imageUrls.isNotEmpty
                      ? Image.network(imageUrls[0], fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Center(child: Text(data['emoji'] ?? '📦', style: const TextStyle(fontSize: 36))))
                      : Center(child: Text(data['emoji'] ?? '📦', style: const TextStyle(fontSize: 36))),
                ),
              ),
              // Info
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(color: typeColor.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                          child: Text(type, style: TextStyle(fontSize: 10, color: typeColor, fontWeight: FontWeight.w600)),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: isAvailable ? AppColors.ecoGreen : Colors.grey[100],
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            isAvailable ? '● Active' : '● Sold',
                            style: TextStyle(fontSize: 10, color: isAvailable ? AppColors.primary : Colors.grey, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ]),
                      const SizedBox(height: 6),
                      Text(data['title'] ?? 'Item', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary), maxLines: 1, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 4),
                      Text(
                        data['price_display'] ?? (data['price'] != null ? '৳ ${data['price']}' : 'FREE'),
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.primary),
                      ),
                      const SizedBox(height: 4),
                      Text('🌱 ${data['co2'] ?? '0 kg'} CO₂ saved', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          // Action buttons
          Container(
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: AppColors.divider)),
              borderRadius: BorderRadius.only(bottomLeft: Radius.circular(16), bottomRight: Radius.circular(16)),
            ),
            child: Row(children: [
              // View
              Expanded(child: TextButton.icon(
                onPressed: () => Navigator.pushNamed(context, AppRouter.productDetail, arguments: data),
                icon: const Icon(Icons.visibility_outlined, size: 16, color: AppColors.primary),
                label: const Text('View', style: TextStyle(fontSize: 12, color: AppColors.primary)),
              )),
              Container(width: 1, height: 36, color: AppColors.divider),
              // Mark Sold / Available
              Expanded(child: TextButton.icon(
                onPressed: () async {
                  await FirebaseFirestore.instance.collection('listings').doc(docId).update({'is_available': !isAvailable});
                },
                icon: Icon(isAvailable ? Icons.check_circle_outline : Icons.refresh, size: 16, color: Colors.orange),
                label: Text(isAvailable ? 'Mark Sold' : 'Relist', style: const TextStyle(fontSize: 12, color: Colors.orange)),
              )),
              Container(width: 1, height: 36, color: AppColors.divider),
              // Delete
              Expanded(child: TextButton.icon(
                onPressed: () => _confirmDelete(context, docId, data['title'] ?? 'this item'),
                icon: const Icon(Icons.delete_outline, size: 16, color: Colors.red),
                label: const Text('Delete', style: TextStyle(fontSize: 12, color: Colors.red)),
              )),
            ]),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, String docId, String title) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Listing?', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text('Are you sure you want to delete "$title"? This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              await FirebaseFirestore.instance.collection('listings').doc(docId).delete();
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Listing deleted'), backgroundColor: Colors.red),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
