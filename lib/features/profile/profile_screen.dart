import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/theme/app_theme.dart';
import '../../core/routes/app_router.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (context.mounted) {
                Navigator.pushReplacementNamed(context, AppRouter.login);
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 16),
            CircleAvatar(
              radius: 44,
              backgroundColor: AppColors.ecoGreen,
              child: Text(
                user?.displayName?.isNotEmpty == true
                    ? user!.displayName![0].toUpperCase()
                    : 'S',
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              user?.displayName ?? 'Student',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              user?.email ?? '',
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.ecoGreen,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(children: [
                    Text('0',
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary)),
                    Text('Listings',
                        style: TextStyle(
                            fontSize: 11, color: AppColors.primaryDark)),
                  ]),
                  Column(children: [
                    Text('0',
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary)),
                    Text('Transactions',
                        style: TextStyle(
                            fontSize: 11, color: AppColors.primaryDark)),
                  ]),
                  Column(children: [
                    Text('0.0',
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary)),
                    Text('CO₂ Saved',
                        style: TextStyle(
                            fontSize: 11, color: AppColors.primaryDark)),
                  ]),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _menuItem(context, Icons.list_alt, 'My Listings', null),
            _menuItem(context, Icons.map_outlined, 'Safe Meetup Zones',
                AppRouter.meetupMap),
            _menuItem(context, Icons.leaderboard_outlined, 'Eco Leaderboard',
                AppRouter.leaderboard),
            _menuItem(context, Icons.favorite_outline, 'My Wishlist',
                AppRouter.wishlist),
            _menuItem(context, Icons.settings_outlined, 'Settings', null),
          ],
        ),
      ),
    );
  }

  Widget _menuItem(
      BuildContext context, IconData icon, String title, String? route) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        if (route != null) Navigator.pushNamed(context, route);
      },
    );
  }
}