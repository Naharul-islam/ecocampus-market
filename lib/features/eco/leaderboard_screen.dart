import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final mockLeaders = [
      {'name': 'Rahim Ahmed', 'co2': 48.5, 'points': 485, 'rank': 1},
      {'name': 'Nasrin Begum', 'co2': 35.2, 'points': 352, 'rank': 2},
      {'name': 'Karim Hossain', 'co2': 28.7, 'points': 287, 'rank': 3},
      {'name': 'Farhan Islam', 'co2': 21.0, 'points': 210, 'rank': 4},
      {'name': 'Sadia Akter', 'co2': 15.3, 'points': 153, 'rank': 5},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('🏆 Eco Leaderboard')),
      body: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: AppColors.primary,
            child: const Column(
              children: [
                Text('Campus CO₂ Savings',
                    style: TextStyle(
                        color: Colors.white70, fontSize: 13)),
                Text('Total: 148.7 kg saved this month 🌍',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          // Top 3 podium
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _podiumItem(mockLeaders[1], 2, 80),
                _podiumItem(mockLeaders[0], 1, 110),
                _podiumItem(mockLeaders[2], 3, 60),
              ],
            ),
          ),
          // Full list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: mockLeaders.length,
              itemBuilder: (context, i) {
                final leader = mockLeaders[i];
                final rank = leader['rank'] as int;
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: rank <= 3
                        ? Border.all(color: AppColors.accent.withOpacity(0.4))
                        : null,
                  ),
                  child: Row(children: [
                    Text(
                      rank == 1
                          ? '🥇'
                          : rank == 2
                              ? '🥈'
                              : rank == 3
                                  ? '🥉'
                                  : '#$rank',
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 12),
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: AppColors.ecoGreen,
                      child: Text(
                          (leader['name'] as String)[0],
                          style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(leader['name'] as String,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14)),
                            Text(
                                '${(leader['co2'] as double).toStringAsFixed(1)} kg CO₂ saved',
                                style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textSecondary)),
                          ]),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.ecoGreen,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '🌿 ${leader['points']} pts',
                        style: const TextStyle(
                            color: AppColors.primaryDark,
                            fontSize: 12,
                            fontWeight: FontWeight.bold),
                      ),
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

  Widget _podiumItem(Map<String, dynamic> leader, int rank, double height) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          rank == 1 ? '👑' : rank == 2 ? '🥈' : '🥉',
          style: const TextStyle(fontSize: 24),
        ),
        const SizedBox(height: 4),
        Text((leader['name'] as String).split(' ')[0],
            style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary)),
        Text('${(leader['co2'] as double).toStringAsFixed(1)}kg',
            style: const TextStyle(
                fontSize: 10, color: AppColors.textSecondary)),
        const SizedBox(height: 4),
        Container(
          width: 72,
          height: height,
          decoration: BoxDecoration(
            color: rank == 1
                ? AppColors.accent
                : rank == 2
                    ? Colors.grey[400]!
                    : const Color(0xFFCD7F32),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
          ),
          child: Center(
            child: Text('#$rank',
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }
}
