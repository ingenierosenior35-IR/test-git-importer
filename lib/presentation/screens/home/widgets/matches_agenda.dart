import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/strings.dart';
import '../../../../data/models/match.dart';
import 'package:intl/intl.dart';

class MatchesAgenda extends StatelessWidget {
  final List<Match> upcomingMatches;
  final Function(String) onMatchTap;

  const MatchesAgenda({
    Key? key,
    required this.upcomingMatches,
    required this.onMatchTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppStrings.yourMatches,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.kWhite,
              ),
            ),
            TextButton(
              onPressed: () {},
              child: Text(
                'Ver todos',
                style: TextStyle(
                  color: AppColors.kYellowAccent,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (upcomingMatches.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: AppColors.kDarkCard,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.event_busy_rounded,
                  color: AppColors.kGrey,
                  size: 48,
                ),
                const SizedBox(height: 12),
                Text(
                  'No tienes partidos próximos',
                  style: TextStyle(
                    color: AppColors.kGrey,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: upcomingMatches.length > 3 ? 3 : upcomingMatches.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final match = upcomingMatches[index];
              return _buildMatchCard(match);
            },
          ),
      ],
    );
  }

  Widget _buildMatchCard(Match match) {
    return InkWell(
      onTap: () => onMatchTap(match.id),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.kDarkCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.kDarkSurface,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.kYellowAccent.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.sports_soccer_rounded,
                color: AppColors.kYellowAccent,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    match.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.kWhite,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_rounded,
                        color: AppColors.kGrey,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        match.venue,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.kGrey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('dd MMM yyyy, HH:mm', 'es').format(match.dateTime),
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.kGrey,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: AppColors.kGrey,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
