import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/theme/app_theme.dart';
import '../../core/routes/app_router.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Messages')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('conversations')
            .where('participants', arrayContains: user?.uid)
            .orderBy('last_message_time', descending: true)
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
                  const Text('💬', style: TextStyle(fontSize: 64)),
                  const SizedBox(height: 16),
                  const Text('No messages yet', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                  const SizedBox(height: 8),
                  const Text('Browse listings and start a conversation!', style: TextStyle(color: AppColors.textSecondary)),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.pushReplacementNamed(context, AppRouter.home),
                    icon: const Icon(Icons.explore_outlined),
                    label: const Text('Browse Listings'),
                  ),
                ],
              ),
            );
          }

          final conversations = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: conversations.length,
            itemBuilder: (context, i) {
              final data = conversations[i].data() as Map<String, dynamic>;
              return _chatTile(context, data, user?.uid ?? '');
            },
          );
        },
      ),
    );
  }

  Widget _chatTile(BuildContext context, Map<String, dynamic> data, String myUid) {
    final otherName = data['buyer_id'] == myUid
        ? (data['seller_name'] ?? 'Seller')
        : (data['buyer_name'] ?? 'Buyer');

    final otherInitial = otherName.isNotEmpty ? otherName[0].toUpperCase() : 'U';
    final lastMsg = data['last_message'] ?? 'No messages yet';
    final itemTitle = data['listing_title'] ?? 'Item';
    final itemEmoji = data['listing_emoji'] ?? '📦';
    final unreadCount = data['unread_count_$myUid'] ?? 0;
    final timestamp = data['last_message_time'] as Timestamp?;

    String timeStr = '';
    if (timestamp != null) {
      final dt = timestamp.toDate();
      final now = DateTime.now();
      final diff = now.difference(dt);
      if (diff.inMinutes < 1) {
        timeStr = 'Just now';
      } else if (diff.inHours < 1) {
        timeStr = '${diff.inMinutes}m ago';
      } else if (diff.inDays < 1) {
        timeStr = '${diff.inHours}h ago';
      } else {
        timeStr = '${diff.inDays}d ago';
      }
    }

    return InkWell(
      onTap: () => Navigator.pushNamed(context, AppRouter.chat, arguments: {
        'listing_id': data['listing_id'] ?? '',
        'title': itemTitle,
        'emoji': itemEmoji,
        'seller': otherName,
        'price_display': data['listing_price'] ?? '',
        'conversation_id': data['conversation_id'] ?? '',
      }),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.divider, width: 0.5)),
          color: Colors.white,
        ),
        child: Row(children: [
          // Avatar
          Stack(children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: AppColors.ecoGreen,
              child: Text(otherInitial, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primary)),
            ),
            Positioned(
              bottom: 0, right: 0,
              child: Container(
                width: 12, height: 12,
                decoration: BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ),
          ]),
          const SizedBox(width: 12),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(otherName, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                    Text(timeStr, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                  ],
                ),
                const SizedBox(height: 2),
                Row(children: [
                  Text('$itemEmoji ', style: const TextStyle(fontSize: 12)),
                  Expanded(
                    child: Text(itemTitle, style: const TextStyle(fontSize: 11, color: AppColors.primary), maxLines: 1, overflow: TextOverflow.ellipsis),
                  ),
                ]),
                const SizedBox(height: 2),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(lastMsg, style: TextStyle(fontSize: 13, color: unreadCount > 0 ? AppColors.textPrimary : AppColors.textSecondary, fontWeight: unreadCount > 0 ? FontWeight.w600 : FontWeight.normal), maxLines: 1, overflow: TextOverflow.ellipsis),
                    ),
                    if (unreadCount > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                        child: Text('$unreadCount', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ]),
      ),
    );
  }
}
