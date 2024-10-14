import 'package:flutter/material.dart';

import '../utils/constants.dart';

Widget buildChallengeCard(
  int id,
  String challenge,
  List<String> forbiddenWords,
) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
    child: Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            PictConstants.PictSurface,
            PictConstants.PictSurfaceVariant,
          ],
        ),
        border: Border.all(
          color: PictConstants.PictPrimary.withOpacity(0.25),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: PictConstants.PictPrimary.withOpacity(0.25),
            blurRadius: 20,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: PictConstants.PictPrimary.withOpacity(0.2),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.auto_awesome,
                        size: 16, color: PictConstants.PictAccent),
                    const SizedBox(width: 6),
                    Text(
                      'Challenge #$id',
                      style: const TextStyle(
                        color: PictConstants.PictSecondary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.bolt,
                  color: PictConstants.PictAccent, size: 22),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            challenge,
            style: const TextStyle(
              fontSize: 22,
              height: 1.3,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: forbiddenWords
                .map(
                  (word) => Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [PictConstants.PictRed, PictConstants.PictOrange],
                      ),
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: PictConstants.PictRed.withOpacity(0.25),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.block,
                            size: 14, color: PictConstants.PictSecondary),
                        const SizedBox(width: 6),
                        Text(
                          word,
                          style: const TextStyle(
                            color: PictConstants.PictSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    ),
  );
}
