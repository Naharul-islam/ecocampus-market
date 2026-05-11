import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/theme/app_theme.dart';
import '../../core/routes/app_router.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _darkMode = false;
  bool _notificationsEnabled = true;
  bool _emailNotifications = true;
  bool _chatNotifications = true;
  bool _ecoAlerts = true;
  String _selectedLanguage = 'English';

  final user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text(
          'Settings',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileCard(),
            const SizedBox(height: 20),

            _sectionTitle('Account'),
            _buildCard([
              _settingsTile(
                icon: Icons.person_outline,
                title: 'Edit Profile',
                subtitle: 'Change name, photo, university',
                onTap: () => _showEditProfileDialog(),
              ),
              _divider(),
              _settingsTile(
                icon: Icons.lock_outline,
                title: 'Change Password',
                subtitle: 'Update your password',
                onTap: () => _showChangePasswordDialog(),
              ),
              _divider(),
              _settingsTile(
                icon: Icons.email_outlined,
                title: 'Email',
                subtitle: user?.email ?? 'Not set',
                onTap: null,
                trailing: const Icon(Icons.verified, color: Colors.green, size: 18),
              ),
            ]),
            const SizedBox(height: 16),

            _sectionTitle('Appearance'),
            _buildCard([
              _switchTile(
                icon: Icons.dark_mode_outlined,
                title: 'Dark Mode',
                subtitle: 'Switch to dark theme',
                value: _darkMode,
                onChanged: (v) => setState(() => _darkMode = v),
              ),
              _divider(),
              _settingsTile(
                icon: Icons.language_outlined,
                title: 'Language',
                subtitle: _selectedLanguage,
                onTap: () => _showLanguageDialog(),
              ),
            ]),
            const SizedBox(height: 16),

            _sectionTitle('Notifications'),
            _buildCard([
              _switchTile(
                icon: Icons.notifications_outlined,
                title: 'Push Notifications',
                subtitle: 'Enable all notifications',
                value: _notificationsEnabled,
                onChanged: (v) => setState(() {
                  _notificationsEnabled = v;
                  if (!v) {
                    _emailNotifications = false;
                    _chatNotifications = false;
                    _ecoAlerts = false;
                  }
                }),
              ),
              _divider(),
              _switchTile(
                icon: Icons.chat_bubble_outline,
                title: 'Chat Notifications',
                subtitle: 'New messages from buyers/sellers',
                value: _chatNotifications && _notificationsEnabled,
                onChanged: _notificationsEnabled
                    ? (v) => setState(() => _chatNotifications = v)
                    : null,
              ),
              _divider(),
              _switchTile(
                icon: Icons.eco_outlined,
                title: 'Eco Alerts',
                subtitle: 'CO₂ savings and badge updates',
                value: _ecoAlerts && _notificationsEnabled,
                onChanged: _notificationsEnabled
                    ? (v) => setState(() => _ecoAlerts = v)
                    : null,
              ),
              _divider(),
              _switchTile(
                icon: Icons.mail_outline,
                title: 'Email Notifications',
                subtitle: 'Weekly eco summary via email',
                value: _emailNotifications && _notificationsEnabled,
                onChanged: _notificationsEnabled
                    ? (v) => setState(() => _emailNotifications = v)
                    : null,
              ),
            ]),
            const SizedBox(height: 16),

            _sectionTitle('Privacy & Security'),
            _buildCard([
              _settingsTile(
                icon: Icons.security_outlined,
                title: 'Two-Factor Authentication',
                subtitle: 'Add extra security to your account',
                onTap: () => _show2FADialog(),
              ),
              _divider(),
              _settingsTile(
                icon: Icons.shield_outlined,
                title: 'Privacy Policy',
                subtitle: 'How we use your data',
                onTap: () => _showInfoDialog(
                  'Privacy Policy',
                  'EcoCampus Market only collects data necessary for marketplace functionality. Your campus email is used for verification only. We never sell your data to third parties.',
                ),
              ),
              _divider(),
              _settingsTile(
                icon: Icons.description_outlined,
                title: 'Terms of Service',
                subtitle: 'Rules and guidelines',
                onTap: () => _showInfoDialog(
                  'Terms of Service',
                  'By using EcoCampus Market, you agree to conduct fair transactions, maintain campus community standards, and promote sustainability through second-hand trading.',
                ),
              ),
            ]),
            const SizedBox(height: 16),

            _sectionTitle('About'),
            _buildCard([
              _settingsTile(
                icon: Icons.info_outline,
                title: 'App Version',
                subtitle: 'v1.0.0 (Build 1)',
                onTap: null,
              ),
              _divider(),
              _settingsTile(
                icon: Icons.star_outline,
                title: 'Rate the App',
                subtitle: 'Help us improve EcoCampus Market',
                onTap: () => _showSnack('Thank you for your support! 🌱'),
              ),
              _divider(),
              _settingsTile(
                icon: Icons.bug_report_outlined,
                title: 'Report a Bug',
                subtitle: 'Help us fix issues',
                onTap: () => _showSnack('Bug report sent! Thank you.'),
              ),
            ]),
            const SizedBox(height: 16),

            _sectionTitle('Account Actions'),
            _buildCard([
              _settingsTile(
                icon: Icons.logout,
                title: 'Log Out',
                subtitle: 'Sign out from your account',
                iconColor: Colors.orange,
                titleColor: Colors.orange,
                onTap: () => _showLogoutDialog(),
              ),
              _divider(),
              _settingsTile(
                icon: Icons.delete_outline,
                title: 'Delete Account',
                subtitle: 'Permanently delete your account',
                iconColor: Colors.red,
                titleColor: Colors.red,
                onTap: () => _showDeleteAccountDialog(),
              ),
            ]),

            const SizedBox(height: 32),
            Center(
              child: Column(children: [
                const Text('🌿', style: TextStyle(fontSize: 28)),
                const SizedBox(height: 4),
                const Text('EcoCampus Market',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary)),
                const Text(
                  'Reduce Waste · Save Money · Build Community',
                  style: TextStyle(
                      fontSize: 11, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 4),
                Text(
                  'Made with ❤️ for campus sustainability',
                  style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary.withValues(alpha: 0.7)),
                ),
              ]),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // ── Profile Card ───────────────────────────────────────────────────────────

  Widget _buildProfileCard() {
    return StreamBuilder<DocumentSnapshot>(
      stream: user != null
          ? FirebaseFirestore.instance
              .collection('users')
              .doc(user!.uid)
              .snapshots()
          : null,
      builder: (context, snapshot) {
        String name = user?.displayName ?? 'Student';
        String email = user?.email ?? '';
        double co2 = 0;
        double points = 0;
        if (snapshot.hasData && snapshot.data!.exists) {
          final data = snapshot.data!.data() as Map<String, dynamic>;
          name = data['name'] ?? name;
          co2 = (data['total_co2_saved'] ?? 0).toDouble();
          points = (data['green_points'] ?? 0).toDouble();
        }
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primary, AppColors.primaryLight],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(children: [
            CircleAvatar(
              radius: 32,
              backgroundColor: Colors.white.withValues(alpha: 0.2),
              child: Text(
                name.isNotEmpty ? name[0].toUpperCase() : 'S',
                style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.bold)),
                  Text(email,
                      style: const TextStyle(
                          color: Colors.white70, fontSize: 12)),
                  const SizedBox(height: 6),
                  Row(children: [
                    _miniStat('🌱', '${co2.toStringAsFixed(1)}kg', 'CO₂'),
                    const SizedBox(width: 12),
                    _miniStat('⭐', points.toStringAsFixed(0), 'pts'),
                  ]),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.white70, size: 20),
              onPressed: () => _showEditProfileDialog(),
            ),
          ]),
        );
      },
    );
  }

  Widget _miniStat(String icon, String value, String label) {
    return Row(children: [
      Text(icon, style: const TextStyle(fontSize: 12)),
      const SizedBox(width: 2),
      Text('$value $label',
          style: const TextStyle(color: Colors.white, fontSize: 11)),
    ]);
  }

  // ── UI Helpers ─────────────────────────────────────────────────────────────

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _buildCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _divider() => const Divider(height: 1, indent: 54);

  Widget _settingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback? onTap,
    Color? iconColor,
    Color? titleColor,
    Widget? trailing,
  }) {
    return ListTile(
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: (iconColor ?? AppColors.primary).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: iconColor ?? AppColors.primary, size: 20),
      ),
      title: Text(title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: titleColor ?? AppColors.textPrimary,
          )),
      subtitle: Text(subtitle,
          style: const TextStyle(
              fontSize: 12, color: AppColors.textSecondary)),
      trailing: trailing ??
          (onTap != null
              ? const Icon(Icons.chevron_right,
                  size: 18, color: AppColors.textSecondary)
              : null),
      onTap: onTap,
    );
  }

  Widget _switchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool>? onChanged,
  }) {
    return ListTile(
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: AppColors.primary, size: 20),
      ),
      title: Text(title,
          style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary)),
      subtitle: Text(subtitle,
          style: const TextStyle(
              fontSize: 12, color: AppColors.textSecondary)),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeTrackColor: AppColors.primary,
              activeColor: Colors.white,
      ),
    );
  }

  // ── Dialogs ────────────────────────────────────────────────────────────────

  void _showEditProfileDialog() {
    final nameController =
        TextEditingController(text: user?.displayName ?? '');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Profile'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: 'Full Name',
              prefixIcon: Icon(Icons.person_outline),
              border: OutlineInputBorder(),
            ),
          ),
        ]),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final newName = nameController.text.trim();
              if (newName.isEmpty) return;
              await user?.updateDisplayName(newName);
              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(user!.uid)
                  .update({'name': newName});
              if (!mounted) return;
              Navigator.pop(ctx);
              _showSnack('Profile updated successfully!');
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset Password'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text(
            'A password reset link will be sent to your email.',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 12),
          TextField(
            readOnly: true,
            decoration: InputDecoration(
              labelText: 'Email',
              hintText: user?.email ?? '',
              prefixIcon: const Icon(Icons.email_outlined),
              border: const OutlineInputBorder(),
            ),
          ),
        ]),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final email = user?.email ?? '';
              if (email.isEmpty) return;
              await FirebaseAuth.instance
                  .sendPasswordResetEmail(email: email);
              if (!mounted) return;
              Navigator.pop(ctx);
              _showSnack('Password reset email sent!');
            },
            child: const Text('Send Reset Link'),
          ),
        ],
      ),
    );
  }

  // ✅ groupValue deprecated fix — RadioListTile বাদ দিয়ে ListTile ব্যবহার
  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Select Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ['English', 'বাংলা'].map((lang) {
            return ListTile(
              title: Text(lang),
              leading: Icon(
                _selectedLanguage == lang
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                color: AppColors.primary,
              ),
              onTap: () {
                setState(() => _selectedLanguage = lang);
                Navigator.pop(ctx);
                _showSnack('Language changed to $lang');
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _show2FADialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Two-Factor Authentication'),
        content: const Text(
          'Two-Factor Authentication adds an extra layer of security. When enabled, you will need to verify via OTP every time you log in.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _showSnack('2FA will be available in next update!');
            },
            child: const Text('Enable 2FA'),
          ),
        ],
      ),
    );
  }

  void _showInfoDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(content,
            style: const TextStyle(
                color: AppColors.textSecondary, height: 1.5)),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style:
                ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            onPressed: () async {
              Navigator.pop(ctx);
              await FirebaseAuth.instance.signOut();
              if (!mounted) return;
              Navigator.pushNamedAndRemoveUntil(
                  context, AppRouter.login, (r) => false);
            },
            child: const Text('Log Out'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(children: [
          Icon(Icons.warning, color: Colors.red),
          SizedBox(width: 8),
          Text('Delete Account'),
        ]),
        content: const Text(
          'This will permanently delete your account and all your listings. This action cannot be undone.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(user!.uid)
                    .delete();
                await user!.delete();
                if (!mounted) return;
                Navigator.pushNamedAndRemoveUntil(
                    context, AppRouter.login, (r) => false);
              } catch (e) {
                if (!mounted) return;
                _showSnack(
                    'Please log in again before deleting account.');
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: AppColors.primary,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}