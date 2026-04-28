import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/routes/app_router.dart';

class ProductDetailScreen extends StatelessWidget {
  final Map<String, dynamic> productData;
  const ProductDetailScreen({super.key, required this.productData});

  @override
  Widget build(BuildContext context) {
    final title = productData['title'] ?? 'Item';
    final price = productData['price'] ?? '৳ 0';
    final condition = productData['condition'] ?? 'Good';
    final category = productData['category'] ?? 'Others';
    final type = productData['type'] ?? productData['transaction_type'] ?? 'Buy';
    final co2 = productData['co2'] ?? productData['co2_saved']?.toString() ?? '0';
    final seller = productData['seller'] ?? productData['seller_name'] ?? 'Anonymous';
    final desc = productData['description'] ?? 'No description provided.';
    final emoji = productData['emoji'] ?? '📦';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 240,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: AppColors.ecoGreen,
                child: Center(
                  child: Text(emoji, style: const TextStyle(fontSize: 90)),
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.favorite_outline),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.share_outlined),
                onPressed: () {},
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Type badge + Category
                  Row(children: [
                    _typeBadge(type),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.divider),
                      ),
                      child: Text(category,
                          style: const TextStyle(
                              fontSize: 12, color: AppColors.textSecondary)),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.divider),
                      ),
                      child: Text('Condition: $condition',
                          style: const TextStyle(
                              fontSize: 12, color: AppColors.textSecondary)),
                    ),
                  ]),
                  const SizedBox(height: 12),
                  Text(title,
                      style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary)),
                  const SizedBox(height: 8),
                  Text(
                    type == 'Donate' ? 'FREE (Donation)' : price,
                    style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary),
                  ),
                  const SizedBox(height: 16),
                  // Eco Impact Card
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.ecoGreen,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(children: [
                      const Text('🌍', style: TextStyle(fontSize: 28)),
                      const SizedBox(width: 12),
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Eco Impact of this transaction',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primaryDark,
                                    fontSize: 13)),
                            Text('CO₂ Saved: $co2 kg',
                                style: const TextStyle(
                                    color: AppColors.primary, fontSize: 12)),
                          ]),
                    ]),
                  ),
                  const SizedBox(height: 16),
                  const Text('Description',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary)),
                  const SizedBox(height: 6),
                  Text(desc,
                      style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                          height: 1.5)),
                  const SizedBox(height: 16),
                  // Seller info
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.divider),
                    ),
                    child: Row(children: [
                      CircleAvatar(
                        backgroundColor: AppColors.ecoGreen,
                        child: Text(
                          seller.isNotEmpty ? seller[0].toUpperCase() : 'S',
                          style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(seller,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary)),
                            const Row(children: [
                              Icon(Icons.star, color: Colors.amber, size: 14),
                              Text(' 4.8 · Campus Verified',
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textSecondary)),
                            ]),
                          ]),
                      const Spacer(),
                      TextButton(
                          onPressed: () {},
                          child: const Text('View Profile')),
                    ]),
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 10,
                offset: const Offset(0, -2))
          ],
        ),
        child: Row(children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => Navigator.pushNamed(context, AppRouter.chat,
                  arguments: productData),
              icon: const Icon(Icons.chat_outlined),
              label: const Text('Chat'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: const BorderSide(color: AppColors.primary),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: () {},
              child: Text(type == 'Donate'
                  ? 'Request Item'
                  : type == 'Rent'
                      ? 'Rent Now'
                      : 'Buy Now'),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _typeBadge(String type) {
    final colors = {
      'Buy': Colors.blue,
      'Rent': Colors.orange,
      'Swap': Colors.purple,
      'Donate': Colors.green,
      'Auction': Colors.red,
    };
    final color = colors[type] ?? Colors.blue;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(type,
          style: TextStyle(
              fontSize: 12, color: color, fontWeight: FontWeight.w600)),
    );
  }
}
