import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:monex/theme/app_theme.dart';

class MonexEmptyState extends StatelessWidget {
  const MonexEmptyState({
    super.key,
    required this.title,
    this.subtitle,
    this.compact = false,
  });

  final String title;
  final String? subtitle;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: compact ? 96 : 132,
          height: compact ? 96 : 132,
          child: Lottie.asset('lib/assets/lottie/finance_pulse.json'),
        ),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: MonexColors.ink,
            fontWeight: FontWeight.w800,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 6),
          Text(
            subtitle!,
            textAlign: TextAlign.center,
            style: const TextStyle(color: MonexColors.muted, fontSize: 12),
          ),
        ],
      ],
    );
  }
}
