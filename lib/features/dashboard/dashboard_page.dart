import 'package:flutter/material.dart';
import 'package:gestion_hotel/models/reservation.dart';
import 'package:gestion_hotel/services/auth_service.dart';
import 'package:gestion_hotel/services/firestore_service.dart';
import 'package:gestion_hotel/utils/app_theme.dart';
import 'package:gestion_hotel/widgets/app_card.dart';
import 'package:gestion_hotel/widgets/section_header.dart';
import 'package:gestion_hotel/widgets/weather_widget.dart';
import 'package:gestion_hotel/widgets/world_time_widget.dart';


class DashboardPage extends StatefulWidget {
  final void Function(int index)? onNavigate;
  const DashboardPage({super.key, this.onNavigate});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final _auth = AuthService();
  final _firestore = FirestoreService();
  late Future<_DashboardSummary> _summaryFuture;

  @override
  void initState() {
    super.initState();
    _summaryFuture = _loadSummary();
  }

  Future<_DashboardSummary> _loadSummary() async {
    final user = _auth.currentUser;
    final uid = user?.uid;
    final email = user?.email ?? 'Utilisateur';
    final stats = await Future.wait([
      _firestore.getHotelsCount(),
      _firestore.getRoomsCount(),
      _firestore.getReservationsCount(),
      _firestore.getOccupancyRate(),
    ]);
    final role = uid != null ? await _firestore.getUserRole(uid) ?? 'client' : 'client';
    return _DashboardSummary(
      email: email,
      uid: uid,
      role: role,
      hotels: stats[0] as int,
      rooms: stats[1] as int,
      reservations: stats[2] as int,
      occupancy: stats[3] as double,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_DashboardSummary>(
      future: _summaryFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Erreur: ${snapshot.error}'));
        }

        final summary = snapshot.data!;
        final isMobile = ResponsiveHelper.isMobile(context);

        return RefreshIndicator(
          onRefresh: () async {
            setState(() {
              _summaryFuture = _loadSummary();
            });
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.screenPaddingHorizontal,
              vertical: AppSpacing.xl,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome Header (more compact)
                _buildWelcomeHeader(summary),
                const SizedBox(height: AppSpacing.lg),

                // Quick Stats
                _buildQuickStats(summary),
                const SizedBox(height: AppSpacing.lg),

                // API Features Section (more compact, side by side)
                const SectionHeader(
                  title: '🌟 Informations Utiles',
                  subtitle: 'Météo, devises, support international',
                ),
                const SizedBox(height: AppSpacing.sm),
                _buildApiFeatures(isMobile),
                const SizedBox(height: AppSpacing.lg),

                // Quick Actions (more compact)
                const SectionHeader(
                  title: '⚡ Actions Rapides',
                  subtitle: 'Accès rapide aux fonctionnalités',
                ),
                const SizedBox(height: AppSpacing.sm),
                if (summary.role == 'admin') ...[
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text('Actions rapides', style: TextStyle(fontSize: 16)),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],
                _buildQuickActions(summary.role),
                
                // Recent Activity (only if there's space)
                if (!isMobile) ...[
                  const SizedBox(height: AppSpacing.lg),
                  _buildRecentActivity(summary),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildWelcomeHeader(_DashboardSummary summary) {
    return AppCard(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
              child: Icon(
                summary.role == 'admin' ? Icons.admin_panel_settings : Icons.person,
                size: 30,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bienvenue !',
                    style: AppTextStyles.subtitle1.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    summary.email,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    summary.role == 'admin' ? 'Administrateur' : 'Client',
                    style: AppTextStyles.body3.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.dashboard,
              size: 32,
              color: AppColors.primary.withValues(alpha: 0.7),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStats(_DashboardSummary summary) {
    return _KpiGrid(
      items: [
        _KpiData(
          'Hôtels',
          summary.hotels.toString(),
          Icons.domain_outlined,
          Colors.blue,
        ),
        _KpiData(
          'Chambres',
          summary.rooms.toString(),
          Icons.meeting_room_outlined,
          Colors.green,
        ),
        _KpiData(
          'Réservations',
          summary.reservations.toString(),
          Icons.calendar_month_outlined,
          Colors.orange,
        ),
        _KpiData(
          'Taux d\'occupation',
          '${summary.occupancy.toStringAsFixed(1)}%',
          Icons.pie_chart_outline,
          Colors.purple,
        ),
      ],
    );
  }

  Widget _buildApiFeatures(bool isMobile) {
    if (isMobile) {
      return Column(
        children: [
          const WeatherWidget(city: 'Paris', isCompact: true),
          const SizedBox(height: AppSpacing.md),
          const WorldTimeWidget(isCompact: true),
          const SizedBox(height: AppSpacing.md),
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Tarification intelligente: 180,00 EUR (Deluxe)',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ),
          ),
        ],
      );
    } else {
      return Column(
        children: [
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Expanded(
                  child: WeatherWidget(city: 'Paris'),
                ),
                const SizedBox(width: AppSpacing.md),
                const Expanded(
                  child: WorldTimeWidget(),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Tarification intelligente: 180,00 EUR (Deluxe)',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ),
          ),
        ],
      );
    }
  }

  Widget _buildCurrencyShowcase() {
    return AppCard(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(Icons.attach_money, color: AppColors.primary, size: 18),
                const SizedBox(width: 8),
                const Text(
                  'Tarification Multi-Devises',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'Chambre Deluxe (exemple)',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
            ),
            const SizedBox(height: 8),
            const Card(
              child: Padding(
                padding: EdgeInsets.all(12.0),
                child: Text(
                  'Prix: 180,00 EUR (Deluxe)',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(String role) {
    final actions = role == 'admin'
        ? [
            _ManagementCardData(
              'Gérer les Hôtels',
              'Ajouter, modifier, consulter',
              Icons.apartment,
              () => widget.onNavigate?.call(1),
            ),
            _ManagementCardData(
              'Gérer les Chambres',
              'Types, disponibilités, prix',
              Icons.king_bed_outlined,
              () => widget.onNavigate?.call(2),
            ),
            _ManagementCardData(
              'Réservations',
              'Suivre et traiter',
              Icons.assignment_turned_in_outlined,
              () => widget.onNavigate?.call(3),
            ),
          ]
        : [
            _ManagementCardData(
              'Rechercher Hôtels',
              'Parcourir et réserver',
              Icons.search,
              () => widget.onNavigate?.call(1),
            ),
            _ManagementCardData(
              'Mes Réservations',
              'Gérer vos séjours',
              Icons.calendar_today,
              () => widget.onNavigate?.call(2),
            ),
            _ManagementCardData(
              'Mon Profil',
              'Paramètres et infos',
              Icons.person,
              () => widget.onNavigate?.call(3),
            ),
          ];

    return _ManagementGrid(items: actions);
  }

  Widget _buildRecentActivity(_DashboardSummary summary) {
    final stream = summary.role == 'admin'
        ? _firestore.getAllReservations()
        : (summary.uid != null
            ? _firestore.getReservationsByUserStream(summary.uid!)
            : const Stream<List<Reservation>>.empty());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          title: '📊 Activité Récente',
          subtitle: 'Dernières réservations',
        ),
        const SizedBox(height: AppSpacing.md),
        StreamBuilder<List<Reservation>>(
          stream: stream,
          builder: (context, resSnap) {
            if (resSnap.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (resSnap.hasError) {
              return Text('Erreur chargement activité: ${resSnap.error}');
            }
            final items = (resSnap.data ?? [])
                .where((r) => r.startDate.isAfter(DateTime.now().subtract(const Duration(days: 60))))
                .toList()
              ..sort((a, b) => b.startDate.compareTo(a.startDate));
            return _RecentActivity(items: items.take(6).toList());
          },
        ),
      ],
    );
  }
}

class _KpiGrid extends StatelessWidget {
  final List<_KpiData> items;
  const _KpiGrid({required this.items});

  @override
  Widget build(BuildContext context) {
    final columns = ResponsiveHelper.getGridColumns(context).clamp(1, 4);
    return GridView.count(
      crossAxisCount: columns,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: AppSpacing.md,
      crossAxisSpacing: AppSpacing.md,
      childAspectRatio: 1.6,
      children: items.map((item) => _KpiCard(item: item)).toList(),
    );
  }
}

class _KpiCard extends StatelessWidget {
  final _KpiData item;
  const _KpiCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: item.color.withValues(alpha: 0.1),
              borderRadius: AppBorderRadius.allMd,
            ),
            child: Icon(item.icon, color: item.color, size: 24),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.label, style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
                const SizedBox(height: AppSpacing.xs),
                Text(item.value, style: AppTextStyles.headline4.copyWith(color: item.color)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ManagementGrid extends StatelessWidget {
  final List<_ManagementCardData> items;
  const _ManagementGrid({required this.items});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.md,
      runSpacing: AppSpacing.md,
      children: items
          .map(
            (item) => SizedBox(
              width: ResponsiveHelper.isMobile(context) ? double.infinity : 280,
              child: _ManagementCard(item: item),
            ),
          )
          .toList(),
    );
  }
}

class _ManagementCard extends StatelessWidget {
  final _ManagementCardData item;
  const _ManagementCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: item.onTap,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: AppBorderRadius.allMd,
            ),
            child: Icon(item.icon, color: AppColors.primary),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title, style: AppTextStyles.subtitle1),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  item.description,
                  style: AppTextStyles.body3.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.textSecondary),
        ],
      ),
    );
  }
}

class _RecentActivity extends StatelessWidget {
  final List<Reservation> items;
  const _RecentActivity({required this.items});

  String _formatDateRange(Reservation r) {
    final start = '${r.startDate.day.toString().padLeft(2, '0')}/${r.startDate.month.toString().padLeft(2, '0')}';
    final end = '${r.endDate.day.toString().padLeft(2, '0')}/${r.endDate.month.toString().padLeft(2, '0')}';
    return '$start -> $end';
  }

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return AppCard(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          children: [
            Icon(Icons.inbox_outlined, color: AppColors.textSecondary),
            const SizedBox(width: AppSpacing.md),
            Text('Aucune activite recente', style: AppTextStyles.body3.copyWith(color: AppColors.textSecondary)),
          ],
        ),
      );
    }

    return Column(
      children: items
          .map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: AppCard(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.08),
                        borderRadius: AppBorderRadius.allMd,
                      ),
                      child: const Icon(Icons.timeline, color: AppColors.primary),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.roomType.isNotEmpty ? item.roomType : 'Reservation', style: AppTextStyles.subtitle1),
                          const SizedBox(height: AppSpacing.xs),
                          Text(_formatDateRange(item), style: AppTextStyles.body3.copyWith(color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: AppColors.border.withValues(alpha: 0.5),
                        borderRadius: AppBorderRadius.allMd,
                      ),
                      child: Text(item.status, style: AppTextStyles.caption),
                    ),
                  ],
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _KpiData {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  const _KpiData(this.label, this.value, this.icon, this.color);
}

class _ActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const _ActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: AppBorderRadius.allMd,
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const Spacer(),
              Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            title,
            style: AppTextStyles.subtitle1.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            subtitle,
            style: AppTextStyles.body3.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _ManagementCardData {
  final String title;
  final String description;
  final IconData icon;
  final VoidCallback? onTap;
  const _ManagementCardData(this.title, this.description, this.icon, this.onTap);
}

class _DashboardSummary {
  final String email;
  final String? uid;
  final String role;
  final int hotels;
  final int rooms;
  final int reservations;
  final double occupancy;

  const _DashboardSummary({
    required this.email,
    required this.uid,
    required this.role,
    required this.hotels,
    required this.rooms,
    required this.reservations,
    required this.occupancy,
  });
}
