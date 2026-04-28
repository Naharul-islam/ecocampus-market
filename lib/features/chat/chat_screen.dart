import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../../core/theme/app_theme.dart';

class ChatScreen extends StatefulWidget {
  final Map<String, dynamic> chatData;
  const ChatScreen({super.key, required this.chatData});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _msgCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  final _user = FirebaseAuth.instance.currentUser!;
  late String _conversationId;

  @override
  void initState() {
    super.initState();
    _conversationId = widget.chatData['conversation_id'] ??
        'conv_${widget.chatData['listing_id'] ?? const Uuid().v4()}';
    _initConversation();
  }

  Future<void> _initConversation() async {
    final convRef = FirebaseFirestore.instance.collection('conversations').doc(_conversationId);
    final doc = await convRef.get();
    if (!doc.exists) {
      await convRef.set({
        'conversation_id': _conversationId,
        'listing_id': widget.chatData['listing_id'] ?? '',
        'listing_title': widget.chatData['title'] ?? '',
        'listing_emoji': widget.chatData['emoji'] ?? '📦',
        'listing_price': widget.chatData['price_display'] ?? '',
        'seller_id': widget.chatData['seller_id'] ?? '',
        'seller_name': widget.chatData['seller'] ?? 'Seller',
        'buyer_id': _user.uid,
        'buyer_name': _user.displayName ?? 'Buyer',
        'participants': [_user.uid, widget.chatData['seller_id'] ?? ''],
        'last_message': '',
        'last_message_time': FieldValue.serverTimestamp(),
        'created_at': FieldValue.serverTimestamp(),
      });
    }
  }

  Future<void> _sendMessage() async {
    final text = _msgCtrl.text.trim();
    if (text.isEmpty) return;
    _msgCtrl.clear();

    final msgId = const Uuid().v4();
    final batch = FirebaseFirestore.instance.batch();

    // Add message
    final msgRef = FirebaseFirestore.instance
        .collection('conversations')
        .doc(_conversationId)
        .collection('messages')
        .doc(msgId);

    batch.set(msgRef, {
      'message_id': msgId,
      'sender_id': _user.uid,
      'sender_name': _user.displayName ?? 'Me',
      'content': text,
      'is_read': false,
      'sent_at': FieldValue.serverTimestamp(),
    });

    // Update conversation last message
    final convRef = FirebaseFirestore.instance.collection('conversations').doc(_conversationId);
    batch.update(convRef, {
      'last_message': text,
      'last_message_time': FieldValue.serverTimestamp(),
    });

    await batch.commit();

    // Auto scroll to bottom
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(_scrollCtrl.position.maxScrollExtent, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final seller = widget.chatData['seller'] ?? 'Seller';
    final title = widget.chatData['title'] ?? 'Item';
    final emoji = widget.chatData['emoji'] ?? '📦';
    final price = widget.chatData['price_display'] ?? '';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Row(children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: Colors.white.withOpacity(0.3),
            child: Text(seller.isNotEmpty ? seller[0].toUpperCase() : 'S',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
          ),
          const SizedBox(width: 10),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(seller, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            const Text('Online', style: TextStyle(fontSize: 10, color: Colors.white70)),
          ]),
        ]),
        actions: [
          IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          // Item preview
          Container(
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: AppColors.ecoGreen, borderRadius: BorderRadius.circular(10)),
            child: Row(children: [
              Text(emoji, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 8),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryDark, fontSize: 13)),
                if (price.isNotEmpty) Text(price, style: const TextStyle(color: AppColors.primary, fontSize: 12)),
              ])),
              const Icon(Icons.chevron_right, color: AppColors.primary, size: 18),
            ]),
          ),
          // Messages
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('conversations')
                  .doc(_conversationId)
                  .collection('messages')
                  .orderBy('sent_at')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      const Text('👋', style: TextStyle(fontSize: 48)),
                      const SizedBox(height: 8),
                      Text('Say hi to $seller!', style: const TextStyle(color: AppColors.textSecondary, fontSize: 15)),
                      const SizedBox(height: 4),
                      const Text('Messages are end-to-end secured', style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                    ]),
                  );
                }
                return ListView.builder(
                  controller: _scrollCtrl,
                  padding: const EdgeInsets.all(12),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, i) {
                    final msg = snapshot.data!.docs[i].data() as Map<String, dynamic>;
                    final isMe = msg['sender_id'] == _user.uid;
                    return _buildBubble(msg['content'] ?? '', isMe, msg['sent_at'] as Timestamp?);
                  },
                );
              },
            ),
          ),
          // Quick replies
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(8, 6, 8, 0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ['Is this available? 🙋', 'Can we meet on campus? 🗺️', 'Final price? 💰', 'Still available?']
                    .map((q) => Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: ActionChip(
                            label: Text(q, style: const TextStyle(fontSize: 11)),
                            onPressed: () => _msgCtrl.text = q,
                            backgroundColor: AppColors.ecoGreen,
                            padding: EdgeInsets.zero,
                          ),
                        ))
                    .toList(),
              ),
            ),
          ),
          const SizedBox(height: 4),
          // Input
          Container(
            padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
            color: Colors.white,
            child: Row(children: [
              Expanded(
                child: TextField(
                  controller: _msgCtrl,
                  maxLines: null,
                  decoration: InputDecoration(
                    hintText: 'Type a message...',
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: const BorderSide(color: AppColors.divider)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: const BorderSide(color: AppColors.divider)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: const BorderSide(color: AppColors.primary)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: _sendMessage,
                child: Container(
                  width: 46, height: 46,
                  decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                  child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _buildBubble(String text, bool isMe, Timestamp? timestamp) {
    String timeStr = '';
    if (timestamp != null) {
      final dt = timestamp.toDate();
      final hour = dt.hour.toString().padLeft(2, '0');
      final min = dt.minute.toString().padLeft(2, '0');
      timeStr = '$hour:$min';
    }

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.72),
        decoration: BoxDecoration(
          color: isMe ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMe ? 16 : 4),
            bottomRight: Radius.circular(isMe ? 4 : 16),
          ),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 4, offset: const Offset(0, 1))],
        ),
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(text, style: TextStyle(color: isMe ? Colors.white : AppColors.textPrimary, fontSize: 14)),
            if (timeStr.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(timeStr, style: TextStyle(color: isMe ? Colors.white60 : AppColors.textSecondary, fontSize: 10)),
            ],
          ],
        ),
      ),
    );
  }
}
