import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/theme/app_theme.dart';
import '../../core/routes/app_router.dart';

class ProductDetailScreen extends StatefulWidget {
  final Map<String, dynamic> productData;
  const ProductDetailScreen({super.key, required this.productData});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  bool _isWishlisted = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkWishlist();
  }

  Future<void> _checkWishlist() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final docId = widget.productData['doc_id'] ?? '';
    if (docId.isEmpty) return;
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('wishlist')
        .doc(docId)
        .get();
    if (mounted) setState(() => _isWishlisted = doc.exists);
  }

  Future<void> _toggleWishlist() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final docId = widget.productData['doc_id'] ?? '';
    if (docId.isEmpty) return;

    final ref = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('wishlist')
        .doc(docId);

    if (_isWishlisted) {
      await ref.delete();
    } else {
      await ref.set(widget.productData);
    }
    setState(() => _isWishlisted = !_isWishlisted);
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.productData;

    // ── সব field safely read করো ────────────────────────────────────────────
    final title = data['title'] ?? 'Item';
    final priceDisplay =
        data['price_display'] ?? data['price']?.toString() ?? '৳ 0';
    final condition = data['condition'] ?? 'Good';
    final category = data['category'] ?? 'Others';
    final type = data['transaction_type'] ?? data['type'] ?? 'Buy';
    final co2 = data['co2'] ??
        data['co2_saved_kg']?.toString() ??
        data['co2_saved']?.toString() ??
        '0';
    final seller = data['seller'] ?? data['seller_name'] ?? 'Anonymous';
    final sellerId = data['seller_id'] ?? '';
    final desc =
        data['description'] ?? 'No description provided.';
    final emoji = data['emoji'] ?? '📦';
    final imageUrls = data['image_urls'] as List?;

    // Green points calculation
    final co2Double = double.tryParse(co2.toString()) ?? 0.0;
    final greenPoints = (co2Double * 10).toStringAsFixed(0);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // ── App Bar with Image ─────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 260,
            pinned: true,
            backgroundColor: AppColors.primary,
            flexibleSpace: FlexibleSpaceBar(
              background: imageUrls != null && imageUrls.isNotEmpty
                  ? Image.network(
                      imageUrls[0],
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: AppColors.ecoGreen,
                        child: Center(
                          child: Text(emoji,
                              style: const TextStyle(fontSize: 90)),
                        ),
                      ),
                    )
                  : Container(
                      color: AppColors.ecoGreen,
                      child: Center(
                        child: Text(emoji,
                            style: const TextStyle(fontSize: 90)),
                      ),
                    ),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  _isWishlisted ? Icons.favorite : Icons.favorite_outline,
                  color: _isWishlisted ? Colors.red : Colors.white,
                ),
                onPressed: _toggleWishlist,
              ),
              IconButton(
                icon: const Icon(Icons.share_outlined, color: Colors.white),
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
                  // ── Badges Row ──────────────────────────────────────────────
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      _typeBadge(type),
                      _infoBadge(category),
                      _infoBadge('Condition: $condition'),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // ── Title ───────────────────────────────────────────────────
                  Text(
                    title,
                    style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 8),

                  // ── Price ───────────────────────────────────────────────────
                  Text(
                    type == 'Donate' ? 'FREE (Donation)' : priceDisplay,
                    style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary),
                  ),
                  const SizedBox(height: 16),

                  // ── Eco Impact Card ─────────────────────────────────────────
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.ecoGreen,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(children: [
                      const Text('🌍', style: TextStyle(fontSize: 32)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Eco Impact of this transaction',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryDark,
                                  fontSize: 13),
                            ),
                            const SizedBox(height: 6),
                            Row(children: [
                              _ecoStat('🌿', '$co2 kg', 'CO₂ Saved'),
                              const SizedBox(width: 16),
                              _ecoStat('⭐', greenPoints, 'Green Points'),
                              const SizedBox(width: 16),
                              _ecoStat('🌳',
                                  (co2Double / 21.0).toStringAsFixed(2),
                                  'Trees'),
                            ]),
                          ],
                        ),
                      ),
                    ]),
                  ),
                  const SizedBox(height: 16),

                  // ── Description ─────────────────────────────────────────────
                  const Text(
                    'Description',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    desc,
                    style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                        height: 1.6),
                  ),
                  const SizedBox(height: 16),

                  // ── Image Gallery ───────────────────────────────────────────
                  if (imageUrls != null && imageUrls.length > 1) ...[
                    const Text(
                      'Photos',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 80,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: imageUrls.length,
                        itemBuilder: (context, i) => Container(
                          margin: const EdgeInsets.only(right: 8),
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border:
                                Border.all(color: AppColors.divider),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              imageUrls[i],
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // ── Seller Info ─────────────────────────────────────────────
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.divider),
                    ),
                    child: Row(children: [
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: AppColors.ecoGreen,
                        child: Text(
                          seller.isNotEmpty
                              ? seller[0].toUpperCase()
                              : 'S',
                          style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 18),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              seller,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                  fontSize: 15),
                            ),
                            const Row(children: [
                              Icon(Icons.star,
                                  color: Colors.amber, size: 14),
                              Text(
                                ' 4.8 · Campus Verified',
                                style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary),
                              ),
                            ]),
                          ],
                        ),
                      ),
                      if (sellerId.isNotEmpty)
                        TextButton(
                          onPressed: () {},
                          child: const Text('View Profile'),
                        ),
                    ]),
                  ),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),

      // ── Bottom Action Bar ──────────────────────────────────────────────────
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, -2),
            )
          ],
        ),
        child: Row(children: [
          // Chat button
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => Navigator.pushNamed(
                context,
                AppRouter.chat,
                arguments: widget.productData,
              ),
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
          // Main action button
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _handleMainAction,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2),
                    )
                  : Text(
                      type == 'Donate'
                          ? '🎁 Request Item'
                          : type == 'Rent'
                              ? '🔑 Rent Now'
                              : type == 'Swap'
                                  ? '🔄 Swap Now'
                                  : '🛒 Buy Now',
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.bold),
                    ),
            ),
          ),
        ]),
      ),
    );
  }

  Future<void> _handleMainAction() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() => _isLoading = false);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Chat with seller to complete transaction!'),
        backgroundColor: AppColors.primary,
        action: SnackBarAction(
          label: 'Chat Now',
          textColor: Colors.white,
          onPressed: () => Navigator.pushNamed(
            context,
            AppRouter.chat,
            arguments: widget.productData,
          ),
        ),
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
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        type,
        style: TextStyle(
            fontSize: 12, color: color, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _infoBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.divider),
      ),
      child: Text(
        text,
        style:
            const TextStyle(fontSize: 12, color: AppColors.textSecondary),
      ),
    );
  }

  Widget _ecoStat(String icon, String value, String label) {
    return Column(children: [
      Text(icon, style: const TextStyle(fontSize: 16)),
      Text(value,
          style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryDark)),
      Text(label,
          style: const TextStyle(
              fontSize: 10, color: AppColors.primaryDark)),
    ]);
  }
}