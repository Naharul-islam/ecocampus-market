import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/theme/app_theme.dart';
import '../../core/routes/app_router.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = 'All';
  String _selectedType = 'All';
  String _selectedCondition = 'All';
  String _sortBy = 'newest';
  double _minPrice = 0;
  double _maxPrice = 50000;
  bool _showFilters = false;

  final _categories = ['All', 'Books', 'Electronics', 'Furniture', 'Clothes', 'Others'];
  final _types = ['All', 'Buy', 'Rent', 'Swap', 'Donate'];
  final _conditions = ['All', 'New', 'Good', 'Fair', 'Poor'];
  final _sortOptions = [
    {'value': 'newest', 'label': '🕐 Newest'},
    {'value': 'price_low', 'label': '💰 Low-High'},
    {'value': 'price_high', 'label': '💰 High-Low'},
    {'value': 'co2', 'label': '🌱 Most Eco'},
  ];

  int get _activeFilterCount {
    int count = 0;
    if (_selectedCategory != 'All') count++;
    if (_selectedType != 'All') count++;
    if (_selectedCondition != 'All') count++;
    if (_minPrice > 0 || _maxPrice < 50000) count++;
    return count;
  }

  void _resetFilters() {
    setState(() {
      _selectedCategory = 'All';
      _selectedType = 'All';
      _selectedCondition = 'All';
      _minPrice = 0;
      _maxPrice = 50000;
      _sortBy = 'newest';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Search'), automaticallyImplyLeading: false),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Row(children: [
              Expanded(
                child: TextField(
                  controller: _searchCtrl,
                  onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
                  decoration: InputDecoration(
                    hintText: 'Search items...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(icon: const Icon(Icons.clear), onPressed: () { _searchCtrl.clear(); setState(() => _searchQuery = ''); })
                        : null,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => setState(() => _showFilters = !_showFilters),
                child: Container(
                  width: 48, height: 48,
                  decoration: BoxDecoration(
                    color: _activeFilterCount > 0 ? AppColors.primary : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _activeFilterCount > 0 ? AppColors.primary : AppColors.divider),
                  ),
                  child: Stack(alignment: Alignment.center, children: [
                    Icon(Icons.tune, color: _activeFilterCount > 0 ? Colors.white : AppColors.textSecondary),
                    if (_activeFilterCount > 0)
                      Positioned(
                        top: 6, right: 6,
                        child: Container(
                          width: 16, height: 16,
                          decoration: const BoxDecoration(color: Colors.orange, shape: BoxShape.circle),
                          child: Center(child: Text('$_activeFilterCount', style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold))),
                        ),
                      ),
                  ]),
                ),
              ),
            ]),
          ),

          // Filter Panel
          if (_showFilters)
            Container(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10)],
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  const Text('Filters', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                  TextButton(onPressed: _resetFilters, child: const Text('Reset all', style: TextStyle(color: Colors.red, fontSize: 12))),
                ]),
                const Divider(),
                // Transaction Type
                const Text('Transaction Type', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                const SizedBox(height: 8),
                Wrap(spacing: 8, runSpacing: 6, children: _types.map((t) {
                  final colors = {'All': Colors.grey, 'Buy': Colors.blue, 'Rent': Colors.orange, 'Swap': Colors.purple, 'Donate': Colors.green};
                  final isSelected = _selectedType == t;
                  final color = colors[t] ?? Colors.grey;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedType = t),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isSelected ? color.withOpacity(0.15) : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: isSelected ? color : AppColors.divider),
                      ),
                      child: Text(t, style: TextStyle(fontSize: 12, color: isSelected ? color : AppColors.textSecondary, fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal)),
                    ),
                  );
                }).toList()),
                const SizedBox(height: 12),
                // Condition
                const Text('Condition', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                const SizedBox(height: 8),
                Wrap(spacing: 8, runSpacing: 6, children: _conditions.map((c) {
                  final isSelected = _selectedCondition == c;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedCondition = c),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.ecoGreen : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: isSelected ? AppColors.primary : AppColors.divider),
                      ),
                      child: Text(c, style: TextStyle(fontSize: 12, color: isSelected ? AppColors.primaryDark : AppColors.textSecondary, fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal)),
                    ),
                  );
                }).toList()),
                const SizedBox(height: 12),
                // Price Range
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  const Text('Price Range', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                  Text('৳${_minPrice.toInt()} — ৳${_maxPrice.toInt()}', style: const TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.bold)),
                ]),
                RangeSlider(
                  values: RangeValues(_minPrice, _maxPrice),
                  min: 0, max: 50000, divisions: 100,
                  activeColor: AppColors.primary,
                  onChanged: (v) => setState(() { _minPrice = v.start; _maxPrice = v.end; }),
                ),
                const Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text('৳0', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                  Text('৳50,000', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                ]),
              ]),
            ),

          // Sort Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(children: [
              const Text('Sort:', style: TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
              const SizedBox(width: 8),
              Expanded(
                child: SizedBox(
                  height: 30,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _sortOptions.length,
                    itemBuilder: (context, i) {
                      final opt = _sortOptions[i];
                      final isSelected = _sortBy == opt['value'];
                      return GestureDetector(
                        onTap: () => setState(() => _sortBy = opt['value']!),
                        child: Container(
                          margin: const EdgeInsets.only(right: 6),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.primary : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: isSelected ? AppColors.primary : AppColors.divider),
                          ),
                          child: Text(opt['label']!, style: TextStyle(fontSize: 11, color: isSelected ? Colors.white : AppColors.textSecondary, fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal)),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ]),
          ),

          // Category Chips
          if (!_showFilters)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                height: 30,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: _categories.map((c) {
                    final isSelected = _selectedCategory == c;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedCategory = c),
                      child: Container(
                        margin: const EdgeInsets.only(right: 6),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primary : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: isSelected ? AppColors.primary : AppColors.divider),
                        ),
                        child: Text(c, style: TextStyle(fontSize: 11, color: isSelected ? Colors.white : AppColors.textSecondary, fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal)),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

          const SizedBox(height: 8),

          // Results
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('listings').where('is_available', isEqualTo: true).snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator(color: AppColors.primary));

                var results = snapshot.data!.docs.map((d) => d.data() as Map<String, dynamic>).toList();

                // Search
                if (_searchQuery.isNotEmpty) {
                  results = results.where((data) {
                    final title = (data['title'] ?? '').toString().toLowerCase();
                    final category = (data['category'] ?? '').toString().toLowerCase();
                    final desc = (data['description'] ?? '').toString().toLowerCase();
                    return title.contains(_searchQuery) || category.contains(_searchQuery) || desc.contains(_searchQuery);
                  }).toList();
                }

                // Category
                if (_selectedCategory != 'All') {
                  results = results.where((d) => d['category'] == _selectedCategory).toList();
                }

                // Type
                if (_selectedType != 'All') {
                  results = results.where((d) => d['transaction_type'] == _selectedType).toList();
                }

                // Condition
                if (_selectedCondition != 'All') {
                  results = results.where((d) => d['condition'] == _selectedCondition).toList();
                }

                // Price
                results = results.where((d) {
                  if (d['transaction_type'] == 'Donate') return true;
                  final price = (d['price'] ?? 0).toDouble();
                  return price >= _minPrice && price <= _maxPrice;
                }).toList();

                // Sort
                switch (_sortBy) {
                  case 'price_low':
                    results.sort((a, b) => ((a['price'] ?? 0) as num).compareTo((b['price'] ?? 0) as num));
                    break;
                  case 'price_high':
                    results.sort((a, b) => ((b['price'] ?? 0) as num).compareTo((a['price'] ?? 0) as num));
                    break;
                  case 'co2':
                    results.sort((a, b) => ((b['co2_saved'] ?? 0) as num).compareTo((a['co2_saved'] ?? 0) as num));
                    break;
                }

                if (results.isEmpty) {
                  return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    const Text('😕', style: TextStyle(fontSize: 48)),
                    const SizedBox(height: 12),
                    const Text('No items found', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                    const SizedBox(height: 6),
                    const Text('Try different filters or search terms', style: TextStyle(color: AppColors.textSecondary)),
                    if (_activeFilterCount > 0) ...[
                      const SizedBox(height: 16),
                      ElevatedButton(onPressed: _resetFilters, child: const Text('Clear all filters')),
                    ],
                  ]));
                }

                return Column(children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Text('${results.length} item${results.length > 1 ? 's' : ''} found',
                          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                      if (_activeFilterCount > 0)
                        TextButton(onPressed: _resetFilters, child: const Text('Clear filters', style: TextStyle(color: Colors.red, fontSize: 12))),
                    ]),
                  ),
                  Expanded(
                    child: GridView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 0.75, crossAxisSpacing: 12, mainAxisSpacing: 12),
                      itemCount: results.length,
                      itemBuilder: (context, i) => _productCard(context, results[i]),
                    ),
                  ),
                ]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _productCard(BuildContext context, Map<String, dynamic> data) {
    final imageUrls = data['image_urls'] as List?;
    final type = data['transaction_type'] ?? 'Buy';
    final typeColors = {'Buy': Colors.blue, 'Rent': Colors.orange, 'Swap': Colors.purple, 'Donate': Colors.green};
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, AppRouter.productDetail, arguments: data),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Stack(children: [
              Container(
                height: 110, color: AppColors.ecoGreen, width: double.infinity,
                child: imageUrls != null && imageUrls.isNotEmpty
                    ? Image.network(imageUrls[0], fit: BoxFit.cover, width: double.infinity,
                        errorBuilder: (_, __, ___) => Center(child: Text(data['emoji'] ?? '📦', style: const TextStyle(fontSize: 44))))
                    : Center(child: Text(data['emoji'] ?? '📦', style: const TextStyle(fontSize: 44))),
              ),
              Positioned(top: 6, left: 6, child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: (typeColors[type] ?? Colors.blue).withOpacity(0.9), borderRadius: BorderRadius.circular(6)),
                child: Text(type, style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
              )),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(data['title'] ?? 'Item', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary), maxLines: 2, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 4),
              Text(data['price_display'] ?? '৳ 0', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.primary)),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: AppColors.ecoGreen, borderRadius: BorderRadius.circular(6)),
                child: Text('🌱 ${data['co2'] ?? '0 kg'} CO₂', style: const TextStyle(fontSize: 9, color: AppColors.primaryDark)),
              ),
            ]),
          ),
        ]),
      ),
    );
  }
}
