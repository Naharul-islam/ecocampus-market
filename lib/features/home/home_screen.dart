import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/theme/app_theme.dart';
import '../../core/routes/app_router.dart';
import '../search/search_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Map<String, dynamic>> _sampleItems = [
    {'title': 'Data Structures Textbook', 'price_display': '৳ 450', 'category': 'Books', 'condition': 'Good', 'co2': '2.1 kg', 'seller': 'Rahim Ahmed', 'emoji': '📚', 'transaction_type': 'Buy'},
    {'title': 'HP Laptop i5 8th Gen', 'price_display': '৳ 28,000', 'category': 'Electronics', 'condition': 'Fair', 'co2': '18.5 kg', 'seller': 'Karim Hossain', 'emoji': '💻', 'transaction_type': 'Buy'},
    {'title': 'Study Chair', 'price_display': '৳ 1,200', 'category': 'Furniture', 'condition': 'Good', 'co2': '5.3 kg', 'seller': 'Nasrin Begum', 'emoji': '🪑', 'transaction_type': 'Rent'},
    {'title': 'Calculus by Stewart', 'price_display': 'FREE', 'category': 'Books', 'condition': 'Good', 'co2': '1.8 kg', 'seller': 'Farhan Islam', 'emoji': '📖', 'transaction_type': 'Donate'},
  ];

  String _selectedCategory = 'All';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildHomeTab(),
          const SearchScreen(),
          const SizedBox(),
          _buildWishlistTab(),
          _buildProfileTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, AppRouter.addProduct),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 6,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(0, Icons.home_outlined, Icons.home, 'Home'),
            _buildNavItem(1, Icons.search_outlined, Icons.search, 'Search'),
            const SizedBox(width: 40),
            _buildNavItem(3, Icons.favorite_outline, Icons.favorite, 'Wishlist'),
            _buildNavItem(4, Icons.person_outline, Icons.person, 'Profile'),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, IconData activeIcon, String label) {
    final isSelected = _currentIndex == index;
    return InkWell(
      onTap: () => setState(() => _currentIndex = index),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(isSelected ? activeIcon : icon, color: isSelected ? AppColors.primary : AppColors.textSecondary, size: 24),
            Text(label, style: TextStyle(fontSize: 10, color: isSelected ? AppColors.primary : AppColors.textSecondary, fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal)),
          ],
        ),
      ),
    );
  }

  Widget _buildHomeTab() {
    final user = FirebaseAuth.instance.currentUser;
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 130,
          floating: true,
          snap: true,
          backgroundColor: AppColors.primary,
          actions: [
            IconButton(
              icon: const Icon(Icons.chat_bubble_outline, color: Colors.white),
              onPressed: () => Navigator.pushNamed(context, AppRouter.chatList),
            ),
            IconButton(
              icon: const Icon(Icons.notifications_outlined, color: Colors.white),
              onPressed: () => Navigator.pushNamed(context, AppRouter.notifications),
            ),
          ],
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              color: AppColors.primary,
              padding: const EdgeInsets.fromLTRB(20, 50, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text('Hi, ${user?.displayName ?? 'Student'} 👋',
                      style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                  const Text('Find eco-friendly deals on campus!',
                      style: TextStyle(color: Colors.white70, fontSize: 13)),
                ],
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildEcoStatsCard(),
                const SizedBox(height: 20),
                _buildQuickActions(),
                const SizedBox(height: 20),
                const Text('Categories', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                const SizedBox(height: 12),
                _buildCategories(),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Recent Listings', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                    TextButton(onPressed: () {}, child: const Text('See all', style: TextStyle(color: AppColors.primary))),
                  ],
                ),
                const SizedBox(height: 8),
                _buildListingsGrid(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEcoStatsCard() {
    final user = FirebaseAuth.instance.currentUser;
    return StreamBuilder<DocumentSnapshot>(
      stream: user != null ? FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots() : null,
      builder: (context, snapshot) {
        double co2 = 0, points = 0, trees = 0;
        if (snapshot.hasData && snapshot.data!.exists) {
          final data = snapshot.data!.data() as Map<String, dynamic>;
          co2 = (data['total_co2_saved'] ?? 0).toDouble();
          points = (data['green_points'] ?? 0).toDouble();
          trees = co2 / 21.7;
        }
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [AppColors.primary, AppColors.primaryLight], begin: Alignment.topLeft, end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(children: [
            const Row(children: [
              Text('🌍', style: TextStyle(fontSize: 18)),
              SizedBox(width: 8),
              Text('Your Eco Impact', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
            ]),
            const SizedBox(height: 12),
            Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
              _statItem('${co2.toStringAsFixed(1)} kg', 'CO₂ Saved'),
              _statItem(points.toStringAsFixed(0), 'Green Points'),
              _statItem(trees.toStringAsFixed(1), 'Trees Saved'),
            ]),
          ]),
        );
      },
    );
  }

  Widget _statItem(String value, String label) {
    return Column(children: [
      Text(value, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
      Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
    ]);
  }

  Widget _buildQuickActions() {
    final actions = [
      {'icon': '🗺️', 'label': 'Meetup\nZones', 'route': AppRouter.meetupMap},
      {'icon': '🏆', 'label': 'Leaderboard', 'route': AppRouter.leaderboard},
      {'icon': '💬', 'label': 'My\nChats', 'route': AppRouter.chatList},
      {'icon': '📋', 'label': 'My\nListings', 'route': AppRouter.myListings},
    ];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: actions.map((a) => GestureDetector(
        onTap: () { if (a['route'] != null) Navigator.pushNamed(context, a['route'] as String); },
        child: Column(children: [
          Container(
            width: 54, height: 54,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.07), blurRadius: 8, offset: const Offset(0, 2))],
            ),
            child: Center(child: Text(a['icon'] as String, style: const TextStyle(fontSize: 24))),
          ),
          const SizedBox(height: 6),
          Text(a['label'] as String, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary, height: 1.3), textAlign: TextAlign.center),
        ]),
      )).toList(),
    );
  }

  Widget _buildCategories() {
    final categories = ['All', '📚 Books', '💻 Electronics', '🪑 Furniture', '👕 Clothes', '🔧 Others'];
    return SizedBox(
      height: 38,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: categories.map((c) {
          final isSelected = _selectedCategory == c;
          return GestureDetector(
            onTap: () => setState(() => _selectedCategory = c),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: isSelected ? AppColors.primary : AppColors.divider),
              ),
              child: Text(c, style: TextStyle(fontSize: 13, color: isSelected ? Colors.white : AppColors.textSecondary, fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal)),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildListingsGrid() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('listings').where('is_available', isEqualTo: true).orderBy('created_at', descending: true).limit(10).snapshots(),
      builder: (context, snapshot) {
        List<Map<String, dynamic>> items = [];
        if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
          items = snapshot.data!.docs.map((d) => d.data() as Map<String, dynamic>).toList();
        } else {
          items = _sampleItems;
        }
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 0.75, crossAxisSpacing: 12, mainAxisSpacing: 12),
          itemCount: items.length,
          itemBuilder: (context, i) => _productCard(items[i]),
        );
      },
    );
  }

  Widget _productCard(Map<String, dynamic> data) {
    final imageUrls = data['image_urls'] as List?;
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
            child: Container(
              height: 110, color: AppColors.ecoGreen,
              child: imageUrls != null && imageUrls.isNotEmpty
                  ? Image.network(imageUrls[0], fit: BoxFit.cover, width: double.infinity,
                      errorBuilder: (_, __, ___) => Center(child: Text(data['emoji'] ?? '📦', style: const TextStyle(fontSize: 44))))
                  : Center(child: Text(data['emoji'] ?? '📦', style: const TextStyle(fontSize: 44))),
            ),
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

  Widget _buildWishlistTab() {
    return Scaffold(
      appBar: AppBar(title: const Text('Wishlist'), automaticallyImplyLeading: false),
      body: const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text('❤️', style: TextStyle(fontSize: 60)),
        SizedBox(height: 16),
        Text('Your wishlist is empty', style: TextStyle(fontSize: 18, color: AppColors.textSecondary)),
        SizedBox(height: 8),
        Text('Save items you love to find them later', style: TextStyle(color: AppColors.textSecondary)),
      ])),
    );
  }

  Widget _buildProfileTab() {
    final user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (mounted) Navigator.pushReplacementNamed(context, AppRouter.login);
            },
          ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: user != null ? FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots() : null,
        builder: (context, snapshot) {
          double co2 = 0, points = 0;
          if (snapshot.hasData && snapshot.data!.exists) {
            final data = snapshot.data!.data() as Map<String, dynamic>;
            co2 = (data['total_co2_saved'] ?? 0).toDouble();
            points = (data['green_points'] ?? 0).toDouble();
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(children: [
              const SizedBox(height: 8),
              CircleAvatar(
                radius: 44,
                backgroundColor: AppColors.ecoGreen,
                child: Text(
                  user?.displayName?.isNotEmpty == true ? user!.displayName![0].toUpperCase() : 'S',
                  style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: AppColors.primary),
                ),
              ),
              const SizedBox(height: 12),
              Text(user?.displayName ?? 'Student', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              Text(user?.email ?? '', style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: AppColors.ecoGreen, borderRadius: BorderRadius.circular(16)),
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                  Column(children: [
                    Text(points.toStringAsFixed(0), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primary)),
                    const Text('Green Points', style: TextStyle(fontSize: 11, color: AppColors.primaryDark)),
                  ]),
                  Column(children: [
                    Text('${co2.toStringAsFixed(1)} kg', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary)),
                    const Text('CO₂ Saved', style: TextStyle(fontSize: 11, color: AppColors.primaryDark)),
                  ]),
                  Column(children: [
                    Text((co2 / 21.7).toStringAsFixed(1), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primary)),
                    const Text('Trees Saved', style: TextStyle(fontSize: 11, color: AppColors.primaryDark)),
                  ]),
                ]),
              ),
              const SizedBox(height: 16),
              ...[
                {'icon': Icons.list_alt, 'title': 'My Listings', 'route': AppRouter.myListings},
                {'icon': Icons.chat_bubble_outline, 'title': 'My Chats', 'route': AppRouter.chatList},
                {'icon': Icons.notifications_outlined, 'title': 'Notifications', 'route': AppRouter.notifications},
                {'icon': Icons.map_outlined, 'title': 'Safe Meetup Zones', 'route': AppRouter.meetupMap},
                {'icon': Icons.leaderboard_outlined, 'title': 'Eco Leaderboard', 'route': AppRouter.leaderboard},
                {'icon': Icons.favorite_outline, 'title': 'My Wishlist', 'route': AppRouter.wishlist},
                {'icon': Icons.settings_outlined, 'title': 'Settings', 'route': null},
              ].map((item) => ListTile(
                leading: Icon(item['icon'] as IconData, color: AppColors.primary),
                title: Text(item['title'] as String),
                trailing: const Icon(Icons.chevron_right),
                onTap: () { if (item['route'] != null) Navigator.pushNamed(context, item['route'] as String); },
              )),
            ]),
          );
        },
      ),
    );
  }
}
