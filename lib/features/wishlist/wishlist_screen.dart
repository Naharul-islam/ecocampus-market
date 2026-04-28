import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Wishlist')),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('❤️', style: TextStyle(fontSize: 60)),
            SizedBox(height: 16),
            Text('Wishlist is empty',
                style: TextStyle(fontSize: 18, color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}
