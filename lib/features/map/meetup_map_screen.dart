import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class MeetupMapScreen extends StatelessWidget {
  const MeetupMapScreen({super.key});

  final List<Map<String, dynamic>> _zones = const [
    {'name': 'Library Main Entrance', 'desc': 'Open 8AM–9PM', 'emoji': '📚', 'safe': true},
    {'name': 'Student Center Lobby', 'desc': 'Open 7AM–11PM', 'emoji': '🏫', 'safe': true},
    {'name': 'Cafeteria Ground Floor', 'desc': 'Open 7AM–10PM', 'emoji': '🍽️', 'safe': true},
    {'name': 'Admin Building Front', 'desc': 'Open 9AM–5PM', 'emoji': '🏢', 'safe': true},
    {'name': 'Sports Complex Gate', 'desc': 'Open 6AM–8PM', 'emoji': '⚽', 'safe': true},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('🗺️ Safe Meetup Zones')),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            color: AppColors.ecoGreen,
            child: const Row(children: [
              Icon(Icons.shield_outlined, color: AppColors.primary, size: 18),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'These are campus-verified safe locations for item handover',
                  style: TextStyle(
                      fontSize: 12,
                      color: AppColors.primaryDark),
                ),
              ),
            ]),
          ),
          // Map placeholder
          Container(
            height: 200,
            width: double.infinity,
            color: const Color(0xFFD5E8D4),
            child: const Stack(
              children: [
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('🗺️', style: TextStyle(fontSize: 48)),
                      Text('Campus Map',
                          style: TextStyle(
                              color: AppColors.primaryDark,
                              fontWeight: FontWeight.bold)),
                      Text('(Add Google Maps API key to enable)',
                          style: TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('Safe Meetup Locations',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary)),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _zones.length,
              itemBuilder: (context, i) {
                final zone = _zones[i];
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border:
                        Border.all(color: AppColors.divider),
                  ),
                  child: Row(children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: AppColors.ecoGreen,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                          child: Text(zone['emoji'] as String,
                              style: const TextStyle(fontSize: 22))),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(zone['name'] as String,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                    fontSize: 14)),
                            Text(zone['desc'] as String,
                                style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary)),
                          ]),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.ecoGreen,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(children: [
                        Icon(Icons.shield, color: AppColors.primary, size: 12),
                        SizedBox(width: 3),
                        Text('Safe',
                            style: TextStyle(
                                fontSize: 11,
                                color: AppColors.primaryDark,
                                fontWeight: FontWeight.w600)),
                      ]),
                    ),
                  ]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
