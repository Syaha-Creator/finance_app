import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';

class QuickActionsWidget extends StatelessWidget {
  const QuickActionsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Text(
            'Quick Actions',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
        SizedBox(
          height: 130,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              _buildQuickActionCard(
                context,
                icon: Icons.account_balance_wallet_outlined,
                title: 'Aset',
                subtitle: 'Kelola aset',
                color: AppColors.success,
                onTap: () => context.push('/assets'),
              ),
              const SizedBox(width: 12),
              _buildQuickActionCard(
                context,
                icon: Icons.flag_outlined,
                title: 'Tujuan',
                subtitle: 'Kelola goals',
                color: AppColors.accent,
                onTap: () => context.push('/goals'),
              ),
              const SizedBox(width: 12),
              _buildQuickActionCard(
                context,
                icon: Icons.credit_card_outlined,
                title: 'Hutang',
                subtitle: 'Kelola hutang',
                color: AppColors.primary,
                onTap: () => context.push('/debt'),
              ),
              const SizedBox(width: 12),
              _buildQuickActionCard(
                context,
                icon: Icons.account_balance_wallet_outlined,
                title: 'Anggaran',
                subtitle: 'Kelola budget',
                color: AppColors.warning,
                onTap: () => context.push('/budget'),
              ),
              const SizedBox(width: 12),
              _buildQuickActionCard(
                context,
                icon: Icons.receipt_long_outlined,
                title: 'Tagihan',
                subtitle: 'Kelola tagihan',
                color: AppColors.error,
                onTap: () => context.push('/bills'),
              ),
              const SizedBox(width: 12),
              _buildQuickActionCard(
                context,
                icon: Icons.photo_library_outlined,
                title: 'Struk',
                subtitle: 'Kelola struk',
                color: AppColors.accent,
                onTap: () => context.push('/receipts'),
              ),
              const SizedBox(width: 12),
              _buildQuickActionCard(
                context,
                icon: Icons.trending_up_outlined,
                title: 'Portfolio',
                subtitle: 'Kelola investasi',
                color: AppColors.income,
                onTap: () => context.push('/investments'),
              ),
              const SizedBox(width: 12),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 150,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
