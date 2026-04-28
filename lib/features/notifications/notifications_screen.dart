import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/theme/app_theme.dart';
import '../../core/routes/app_router.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          TextButton(
            onPressed: () => _markAllRead(user?.uid ?? ''),
            child: const Text('Mark all read', style: TextStyle(color: Colors.white, fontSize: 12)),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('notifications')
            .where('user_id', isEqualTo: user?.uid)
            .orderBy('created_at', descending: true)
            .limit(50)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return _buildEmptyState(context, user?.uid ?? '');
          }
          final notifications = snapshot.data!.docs;
          final unread = notifications.where((d) => (d.data() as Map)['is_read'] == false).length;
          return Column(children: [
            if (unread > 0)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                color: AppColors.ecoGreen,
                child: Text(
                  'You have $unread unread notification${unread > 1 ? 's' : ''}',
                  style: const TextStyle(color: AppColors.primaryDark, fontSize: 13, fontWeight: FontWeight.w600),
                ),
              ),
            Expanded(
              child: ListView.builder(
                itemCount: notifications.length,
                itemBuilder: (context, i) {
                  final data = notifications[i].data() as Map<String, dynamic>;
                  final docId = notifications[i].id;
                  return _notificationTile(context, data, docId);
                },
              ),
            ),
          ]);
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addSampleNotification(user?.uid ?? ''),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_alert_outlined, color: Colors.white),
        label: const Text('Test Notify', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, String userId) {
    return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Text('🔔', style: TextStyle(fontSize: 64)),
        const SizedBox(height: 16),
        const Text('No notifications yet',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        const SizedBox(height: 8),
        const Text('You\'ll see alerts for messages,\noffers, and eco achievements here!',
            style: TextStyle(color: AppColors.textSecondary), textAlign: TextAlign.center),
        const SizedBox(height: 24),
        ElevatedButton.icon(
          onPressed: () => _addSampleNotification(userId),
          icon: const Icon(Icons.add_alert_outlined),
          label: const Text('Add Test Notification'),
        ),
      ]),
    );
  }

  Widget _notificationTile(BuildContext context, Map<String, dynamic> data, String docId) {
    final isRead = data['is_read'] ?? false;
    final type = data['type'] ?? 'general';
    final title = data['title'] ?? 'Notification';
    final body = data['body'] ?? '';
    final timestamp = data['created_at'] as Timestamp?;

    String timeStr = '';
    if (timestamp != null) {
      final dt = timestamp.toDate();
      final now = DateTime.now();
      final diff = now.difference(dt);
      if (diff.inMinutes < 1) {
        timeStr = 'Just now';
      } else if (diff.inHours < 1) timeStr = '${diff.inMinutes}m ago';
      else if (diff.inDays < 1) timeStr = '${diff.inHours}h ago';
      else timeStr = '${diff.inDays}d ago';
    }

    final typeConfig = _getTypeConfig(type);

    return Dismissible(
      key: Key(docId),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete_outline, color: Colors.white, size: 28),
      ),
      onDismissed: (_) => FirebaseFirestore.instance.collection('notifications').doc(docId).delete(),
      child: InkWell(
        onTap: () {
          FirebaseFirestore.instance.collection('notifications').doc(docId).update({'is_read': true});
          _handleNotificationTap(context, data);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isRead ? Colors.white : AppColors.ecoGreen.withOpacity(0.4),
            border: const Border(bottom: BorderSide(color: AppColors.divider, width: 0.5)),
          ),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              width: 46, height: 46,
              decoration: BoxDecoration(
                color: (typeConfig['color'] as Color).withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Center(child: Text(typeConfig['emoji'] as String, style: const TextStyle(fontSize: 22))),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Expanded(
                    child: Text(title,
                        style: TextStyle(fontSize: 14, fontWeight: isRead ? FontWeight.normal : FontWeight.bold, color: AppColors.textPrimary),
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                  ),
                  Text(timeStr, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                ]),
                const SizedBox(height: 4),
                Text(body,
                    style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                    maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: (typeConfig['color'] as Color).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(typeConfig['label'] as String,
                      style: TextStyle(fontSize: 10, color: typeConfig['color'] as Color, fontWeight: FontWeight.w600)),
                ),
              ]),
            ),
            if (!isRead)
              Container(
                width: 8, height: 8,
                margin: const EdgeInsets.only(left: 8, top: 4),
                decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
              ),
          ]),
        ),
      ),
    );
  }

  Map<String, dynamic> _getTypeConfig(String type) {
    switch (type) {
      case 'message': return {'emoji': '💬', 'color': Colors.blue, 'label': 'Message'};
      case 'offer': return {'emoji': '💰', 'color': Colors.orange, 'label': 'Offer'};
      case 'eco': return {'emoji': '🌱', 'color': AppColors.primary, 'label': 'Eco Achievement'};
      case 'badge': return {'emoji': '🏆', 'color': Colors.amber, 'label': 'Badge Earned'};
      case 'sold': return {'emoji': '✅', 'color': Colors.green, 'label': 'Item Sold'};
      case 'system': return {'emoji': '📢', 'color': Colors.purple, 'label': 'System'};
      default: return {'emoji': '🔔', 'color': AppColors.primary, 'label': 'General'};
    }
  }

  void _handleNotificationTap(BuildContext context, Map<String, dynamic> data) {
    switch (data['type'] ?? '') {
      case 'message': Navigator.pushNamed(context, AppRouter.chatList); break;
      case 'offer': case 'sold': Navigator.pushNamed(context, AppRouter.myListings); break;
      case 'eco': case 'badge': Navigator.pushNamed(context, AppRouter.leaderboard); break;
    }
  }

  Future<void> _markAllRead(String userId) async {
    final batch = FirebaseFirestore.instance.batch();
    final unread = await FirebaseFirestore.instance
        .collection('notifications')
        .where('user_id', isEqualTo: userId)
        .where('is_read', isEqualTo: false)
        .get();
    for (final doc in unread.docs) {
      batch.update(doc.reference, {'is_read': true});
    }
    await batch.commit();
  }

  Future<void> _addSampleNotification(String userId) async {
    if (userId.isEmpty) return;
    final samples = [
      {'type': 'message', 'title': 'New message from Rahim', 'body': 'Is the laptop still available?'},
      {'type': 'eco', 'title': '🌱 Eco Milestone!', 'body': 'You\'ve saved 10kg of CO₂! Keep it up!'},
      {'type': 'offer', 'title': 'New offer on your listing', 'body': 'Someone made an offer on your item'},
      {'type': 'badge', 'title': '🏆 Badge Earned!', 'body': 'You earned the "Green Hero" badge!'},
      {'type': 'sold', 'title': 'Item Sold!', 'body': 'Your listing has been marked as sold'},
    ];
    final sample = samples[DateTime.now().second % samples.length];
    await FirebaseFirestore.instance.collection('notifications').add({
      'user_id': userId,
      'type': sample['type'],
      'title': sample['title'],
      'body': sample['body'],
      'is_read': false,
      'created_at': FieldValue.serverTimestamp(),
    });
  }
}
