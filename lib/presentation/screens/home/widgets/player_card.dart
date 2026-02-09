import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/constants/colors.dart';
import '../../../../data/models/match.dart';
import 'package:intl/intl.dart';

class PlayerCard extends StatelessWidget {
  final String userName;
  final String photoUrl;
  final Match? upcomingMatch;

  const PlayerCard({
    Key? key,
    required this.userName,
    required this.photoUrl,
    this.upcomingMatch,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.kDarkCard,
            AppColors.kDarkSurface,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.kYellowAccent.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.kYellowAccent,
                    width: 2,
                  ),
                ),
                child: ClipOval(
                  child: photoUrl.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: photoUrl,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => const Icon(
                            Icons.person,
                            color: AppColors.kGrey,
                            size: 30,
                          ),
                          errorWidget: (context, url, error) => const Icon(
                            Icons.person,
                            color: AppColors.kGrey,
                            size: 30,
                          ),
                        )
                      : const Icon(
                          Icons.person,
                          color: AppColors.kGrey,
                          size: 30,
                        ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.kWhite,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Jugador Activo',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.kGrey,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.kYellowAccent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  '7.5',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.kBlack,
                  ),
                ),
              ),
            ],
          ),
          if (upcomingMatch != null) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.kDarkBackground.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.event_rounded,
                    color: AppColors.kYellowAccent,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Próximo Partido',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.kGrey,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          upcomingMatch!.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.kWhite,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          DateFormat('dd MMM, HH:mm', 'es').format(upcomingMatch!.dateTime),
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.kGrey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
