import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/theme/app_theme.dart';

class SeedDataScreen extends StatefulWidget {
  const SeedDataScreen({super.key});
  @override
  State<SeedDataScreen> createState() => _SeedDataScreenState();
}

class _SeedDataScreenState extends State<SeedDataScreen> {
  bool _loading = false;
  String _status = '';
  int _added = 0;

  final List<Map<String, dynamic>> _sampleData = [
    // BOOKS
    {'title': 'Data Structures & Algorithms', 'description': 'By Thomas Cormen. 3rd edition, excellent condition. Perfect for CSE students.', 'price': 450.0, 'price_display': '৳ 450', 'category': 'Books', 'condition': 'Good', 'transaction_type': 'Buy', 'emoji': '📚', 'co2': '2.1 kg', 'co2_saved': 2.1, 'green_points_earned': 21.0, 'seller_name': 'Rahim Ahmed'},
    {'title': 'Calculus by Stewart 8th Ed', 'description': 'Complete calculus textbook. Minor highlights. Great for Math/Physics students.', 'price': 600.0, 'price_display': '৳ 600', 'category': 'Books', 'condition': 'Good', 'transaction_type': 'Buy', 'emoji': '📐', 'co2': '2.5 kg', 'co2_saved': 2.5, 'green_points_earned': 25.0, 'seller_name': 'Nasrin Begum'},
    {'title': 'Introduction to Physics', 'description': 'Halliday & Resnick. Perfect for 1st year students. No markings.', 'price': 0.0, 'price_display': 'FREE', 'category': 'Books', 'condition': 'Good', 'transaction_type': 'Donate', 'emoji': '⚛️', 'co2': '2.1 kg', 'co2_saved': 2.1, 'green_points_earned': 21.0, 'seller_name': 'Karim Hossain'},
    {'title': 'Business Communication', 'description': 'BBA & MBA reference book. Used once. Like new condition.', 'price': 300.0, 'price_display': '৳ 300', 'category': 'Books', 'condition': 'New', 'transaction_type': 'Buy', 'emoji': '💼', 'co2': '2.1 kg', 'co2_saved': 2.1, 'green_points_earned': 21.0, 'seller_name': 'Farhan Islam'},
    {'title': 'Database Management Systems', 'description': 'Ramakrishnan & Gehrke. 3rd edition. Good for CSE 3rd year students.', 'price': 500.0, 'price_display': '৳ 500', 'category': 'Books', 'condition': 'Fair', 'transaction_type': 'Swap', 'emoji': '🗄️', 'co2': '2.1 kg', 'co2_saved': 2.1, 'green_points_earned': 21.0, 'seller_name': 'Sadia Akter'},
    // ELECTRONICS
    {'title': 'HP Laptop i5 8th Gen 8GB RAM', 'description': '256GB SSD, Windows 11. Battery backup 4 hours. Charger included.', 'price': 28000.0, 'price_display': '৳ 28,000', 'category': 'Electronics', 'condition': 'Good', 'transaction_type': 'Buy', 'emoji': '💻', 'co2': '18.5 kg', 'co2_saved': 18.5, 'green_points_earned': 185.0, 'seller_name': 'Jahid Hassan'},
    {'title': 'Samsung Galaxy A52', 'description': '6GB RAM, 128GB storage. Screen protector applied. Original box included.', 'price': 18000.0, 'price_display': '৳ 18,000', 'category': 'Electronics', 'condition': 'Good', 'transaction_type': 'Buy', 'emoji': '📱', 'co2': '15.2 kg', 'co2_saved': 15.2, 'green_points_earned': 152.0, 'seller_name': 'Mitu Rahman'},
    {'title': 'Scientific Calculator FX-991', 'description': 'Casio FX-991EX. Works perfectly. Essential for engineering students.', 'price': 800.0, 'price_display': '৳ 800', 'category': 'Electronics', 'condition': 'Good', 'transaction_type': 'Buy', 'emoji': '🔢', 'co2': '5.1 kg', 'co2_saved': 5.1, 'green_points_earned': 51.0, 'seller_name': 'Rony Ahmed'},
    {'title': 'Wireless Earbuds JBL Tune', 'description': 'JBL Tune 230NC. Active noise cancellation. 40hr battery. Case included.', 'price': 3500.0, 'price_display': '৳ 3,500', 'category': 'Electronics', 'condition': 'Good', 'transaction_type': 'Buy', 'emoji': '🎧', 'co2': '8.5 kg', 'co2_saved': 8.5, 'green_points_earned': 85.0, 'seller_name': 'Priya Das'},
    {'title': 'Wacom Graphics Tablet', 'description': 'Wacom Intuos Small. Perfect for design students. All accessories included.', 'price': 4500.0, 'price_display': '৳ 4,500', 'category': 'Electronics', 'condition': 'New', 'transaction_type': 'Rent', 'emoji': '🖊️', 'co2': '7.0 kg', 'co2_saved': 7.0, 'green_points_earned': 70.0, 'seller_name': 'Nadia Islam'},
    // FURNITURE
    {'title': 'Study Table with Drawer', 'description': 'Wooden study table. 120x60cm. Drawer included. Light brown color.', 'price': 2500.0, 'price_display': '৳ 2,500', 'category': 'Furniture', 'condition': 'Good', 'transaction_type': 'Buy', 'emoji': '🪑', 'co2': '8.5 kg', 'co2_saved': 8.5, 'green_points_earned': 85.0, 'seller_name': 'Tanvir Ahmed'},
    {'title': 'Bookshelf 5-Tier Wooden', 'description': '5-tier wooden bookshelf. Perfect for dorm room. Holds 200+ books.', 'price': 1800.0, 'price_display': '৳ 1,800', 'category': 'Furniture', 'condition': 'Good', 'transaction_type': 'Buy', 'emoji': '📖', 'co2': '6.8 kg', 'co2_saved': 6.8, 'green_points_earned': 68.0, 'seller_name': 'Sumaiya Khan'},
    {'title': 'Ergonomic Office Chair', 'description': 'Adjustable height. Lumbar support. Wheels included. Black color.', 'price': 3200.0, 'price_display': '৳ 3,200', 'category': 'Furniture', 'condition': 'Good', 'transaction_type': 'Buy', 'emoji': '🪑', 'co2': '9.2 kg', 'co2_saved': 9.2, 'green_points_earned': 92.0, 'seller_name': 'Arif Hossain'},
    {'title': 'Single Bed Frame Metal', 'description': 'Metal single bed frame. 90x190cm. No mattress. Easy to move.', 'price': 2000.0, 'price_display': '৳ 2,000', 'category': 'Furniture', 'condition': 'Fair', 'transaction_type': 'Buy', 'emoji': '🛏️', 'co2': '12.0 kg', 'co2_saved': 12.0, 'green_points_earned': 120.0, 'seller_name': 'Liza Parvin'},
    {'title': 'Mini Refrigerator 100L', 'description': 'Walton mini fridge. Perfect for dorm. Works perfectly. Energy efficient.', 'price': 0.0, 'price_display': 'FREE', 'category': 'Furniture', 'condition': 'Fair', 'transaction_type': 'Donate', 'emoji': '🧊', 'co2': '15.0 kg', 'co2_saved': 15.0, 'green_points_earned': 150.0, 'seller_name': 'Rafiq Islam'},
    // CLOTHES
    {'title': 'Formal Shirt Set (L size)', 'description': '3 formal shirts. Blue, white, grey. Worn few times. Perfect for presentations.', 'price': 500.0, 'price_display': '৳ 500', 'category': 'Clothes', 'condition': 'Good', 'transaction_type': 'Buy', 'emoji': '👔', 'co2': '3.2 kg', 'co2_saved': 3.2, 'green_points_earned': 32.0, 'seller_name': 'Imran Khan'},
    {'title': 'Winter Jacket (M size)', 'description': 'Thick winter jacket. Dark navy. Worn 2 seasons. Very warm. Water resistant.', 'price': 800.0, 'price_display': '৳ 800', 'category': 'Clothes', 'condition': 'Good', 'transaction_type': 'Buy', 'emoji': '🧥', 'co2': '4.5 kg', 'co2_saved': 4.5, 'green_points_earned': 45.0, 'seller_name': 'Fatema Begum'},
    {'title': 'Saree Collection 3 pieces', 'description': 'Cotton and silk sarees. Traditional designs. Perfect for cultural events.', 'price': 1200.0, 'price_display': '৳ 1,200', 'category': 'Clothes', 'condition': 'New', 'transaction_type': 'Buy', 'emoji': '👗', 'co2': '2.8 kg', 'co2_saved': 2.8, 'green_points_earned': 28.0, 'seller_name': 'Rupa Ahmed'},
    {'title': 'Nike Sports Kit', 'description': 'Nike t-shirt + shorts + socks set. Size M. Used for gym. Washed and clean.', 'price': 0.0, 'price_display': 'FREE', 'category': 'Clothes', 'condition': 'Good', 'transaction_type': 'Donate', 'emoji': '👟', 'co2': '2.5 kg', 'co2_saved': 2.5, 'green_points_earned': 25.0, 'seller_name': 'Sabbir Ahmed'},
    {'title': 'Campus Backpack 40L', 'description': 'Large 40L backpack. Laptop compartment. Many pockets. Black. Barely used.', 'price': 600.0, 'price_display': '৳ 600', 'category': 'Clothes', 'condition': 'New', 'transaction_type': 'Buy', 'emoji': '🎒', 'co2': '3.0 kg', 'co2_saved': 3.0, 'green_points_earned': 30.0, 'seller_name': 'Tania Islam'},
    // OTHERS
    {'title': 'Drawing Board A2 Size', 'description': 'Professional drawing board with T-square. Essential for Architecture students.', 'price': 1500.0, 'price_display': '৳ 1,500', 'category': 'Others', 'condition': 'Good', 'transaction_type': 'Buy', 'emoji': '✏️', 'co2': '4.2 kg', 'co2_saved': 4.2, 'green_points_earned': 42.0, 'seller_name': 'Mehedi Hassan'},
    {'title': 'Lab Coat + Goggles Set', 'description': 'White lab coat size M + safety goggles. Washed clean. For science students.', 'price': 400.0, 'price_display': '৳ 400', 'category': 'Others', 'condition': 'Good', 'transaction_type': 'Buy', 'emoji': '🥼', 'co2': '3.5 kg', 'co2_saved': 3.5, 'green_points_earned': 35.0, 'seller_name': 'Shamim Ahmed'},
    {'title': 'Complete Stationery Bundle', 'description': 'Rulers, compass set, protractor, pencils, pens, highlighters. All brand new.', 'price': 250.0, 'price_display': '৳ 250', 'category': 'Others', 'condition': 'New', 'transaction_type': 'Buy', 'emoji': '✒️', 'co2': '1.5 kg', 'co2_saved': 1.5, 'green_points_earned': 15.0, 'seller_name': 'Nusrat Jahan'},
    {'title': 'Yamaha Acoustic Guitar F280', 'description': 'Yamaha F280 acoustic guitar. Beginner friendly. Includes bag and picks.', 'price': 5000.0, 'price_display': '৳ 5,000', 'category': 'Others', 'condition': 'Good', 'transaction_type': 'Rent', 'emoji': '🎸', 'co2': '6.0 kg', 'co2_saved': 6.0, 'green_points_earned': 60.0, 'seller_name': 'Badhon Roy'},
    {'title': 'Badminton Racket Set', 'description': '2 rackets + shuttlecocks + bag. Good quality. Perfect for campus sports.', 'price': 800.0, 'price_display': '৳ 800', 'category': 'Others', 'condition': 'Good', 'transaction_type': 'Buy', 'emoji': '🏸', 'co2': '3.8 kg', 'co2_saved': 3.8, 'green_points_earned': 38.0, 'seller_name': 'Raihan Islam'},
  ];

  Future<void> _addSampleData() async {
    setState(() { _loading = true; _added = 0; _status = 'Starting...'; });
    try {
      for (int i = 0; i < _sampleData.length; i++) {
        final item = Map<String, dynamic>.from(_sampleData[i]);
        setState(() => _status = 'Adding: ${item['title']}');
        await FirebaseFirestore.instance.collection('listings').add({
          ...item,
          'seller_id': 'sample_seller_$i',
          'image_urls': [],
          'is_available': true,
          'created_at': FieldValue.serverTimestamp(),
        });
        setState(() => _added = i + 1);
        await Future.delayed(const Duration(milliseconds: 300));
      }
      setState(() { _status = '✅ সম্পন্ন! $_added টি product যোগ হয়েছে!'; _loading = false; });
    } catch (e) {
      setState(() { _status = '❌ Error: $e'; _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Add Sample Data')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🌿', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 16),
            const Text('Sample Products যোগ করো', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            const SizedBox(height: 8),
            const Text('প্রতি category-তে ৫টা করে\nমোট ২৫টা product যোগ হবে', style: TextStyle(color: AppColors.textSecondary), textAlign: TextAlign.center),
            const SizedBox(height: 32),
            if (_added > 0) ...[
              LinearProgressIndicator(value: _added / 25, backgroundColor: AppColors.ecoGreen, color: AppColors.primary, minHeight: 8),
              const SizedBox(height: 8),
              Text('$_added / 25 টি যোগ হয়েছে', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 16),
            ],
            if (_status.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: AppColors.ecoGreen, borderRadius: BorderRadius.circular(12)),
                child: Text(_status, style: const TextStyle(color: AppColors.primaryDark, fontSize: 13), textAlign: TextAlign.center),
              ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _loading ? null : _addSampleData,
                icon: _loading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Icon(Icons.cloud_upload_outlined),
                label: Text(_loading ? '$_added/25 যোগ হচ্ছে...' : '২৫টি Sample Product যোগ করো'),
              ),
            ),
            if (_status.contains('✅')) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.home_outlined, color: AppColors.primary),
                  label: const Text('Home-এ যাও', style: TextStyle(color: AppColors.primary)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
