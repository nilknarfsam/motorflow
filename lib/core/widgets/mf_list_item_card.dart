import 'package:flutter/material.dart';
import 'package:motorflow/core/theme/motorflow_spacing.dart';

class MfListItemCard extends StatelessWidget {
  const MfListItemCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
    this.trailing,
    this.footer,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final Widget? trailing;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(MotorflowSpacing.md),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor: scheme.secondaryContainer,
                child: Icon(icon, color: scheme.onSecondaryContainer),
              ),
              const SizedBox(width: MotorflowSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: MotorflowSpacing.xxs),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyMedium,
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (footer != null) ...[
                      const SizedBox(height: MotorflowSpacing.xs),
                      footer!,
                    ],
                  ],
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: MotorflowSpacing.xs),
                trailing!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}
