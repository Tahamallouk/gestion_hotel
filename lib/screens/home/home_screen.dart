import 'package:flutter/material.dart';
import 'package:gestion_hotel/models/reservation.dart';
import 'package:gestion_hotel/services/auth_service.dart';
import 'package:gestion_hotel/services/firestore_service.dart';
import 'package:gestion_hotel/utils/app_theme.dart';
import 'package:gestion_hotel/widgets/app_card.dart';
import 'package:gestion_hotel/widgets/section_header.dart';

class HomeScreen extends StatefulWidget {
  final Function(ThemeMode)? onThemeModeChanged;
  final ThemeMode? currentThemeMode;
  const HomeScreen({super.key, this.onThemeModeChanged, this.currentThemeMode});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _auth = AuthService();
  final _firestore = FirestoreService();
  late Future<_HomeData> _homeFuture;

  @override
  void initState() {
    super.initState();
    _homeFuture = _loadHomeData();
  }

  Future<_HomeData> _loadHomeData() async {
    final uid = _auth.currentUser?.uid;
    final stats = Future.wait([
      _firestore.getHotelsCount(),
      _firestore.getRoomsCount(),
      _firestore.getReservationsCount(),
      _firestore.getOccupancyRate(),
    ]);
    final role = uid != null ? _firestore.getUserRole(uid) : Future.value(null);
    final res = uid != null ? _firestore.getReservationsByUser(uid) : Future.value(<Reservation>[]);
    final results = await Future.wait([stats, _firestore.getHotels(), role, res]);
    final s = results[0] as List<dynamic>;
    final r = results[3] as List<Reservation>;
    final now = DateTime.now();
    final upcoming = r.where((x) => x.startDate.isAfter(now) && x.status != 'cancelled').toList()
      ..sort((a, b) => a.startDate.compareTo(b.startDate));
    return _HomeData(
      hotelsCount: s[0] as int,
      roomsCount: s[1] as int,
      reservationsCount: s[2] as int,
      occupancyRate: s[3] as double,
      upcomingReservations: upcoming.take(5).toList(),
      role: results[2] as String?,
    );
  }

  Future<void> _refresh() async {
    setState(() => _homeFuture = _loadHomeData());
    await _homeFuture;
  }

  @override
  Widget build(BuildContext context) {
    final email = _auth.currentUser?.email ?? 'Utilisateur';
    return FutureBuilder<_HomeData>(
      future: _homeFuture,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (snap.hasError) {
          return Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 40),
                  const SizedBox(height: AppSpacing.sm),
                  Text('Erreur: ${snap.error}', textAlign: TextAlign.center),
                  const SizedBox(height: AppSpacing.md),
                  ElevatedButton.icon(onPressed: _refresh, icon: const Icon(Icons.refresh), label: const Text('Reessayer')),
                ]),
              ),
            ),
          );
        }

        final data = snap.data!;
        final role = data.role ?? 'client';

        return Scaffold(
          appBar: AppBar(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Dashboard'),
                Text('$email • $role', style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
              ],
            ),
            elevation: 0,
            actions: [
              IconButton(
                icon: const Icon(Icons.currency_exchange_outlined),
                tooltip: 'Convertisseur de devises',
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => Scaffold(
                      appBar: AppBar(title: const Text('Convertisseur de Devises')),
                      body: const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Center(
                          child: Text('Convertisseur de devises indisponible', 
                            style: TextStyle(fontSize: 16)),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              IconButton(icon: const Icon(Icons.person_outline), tooltip: 'Profil', onPressed: () {}),
              IconButton(icon: const Icon(Icons.logout), tooltip: 'Se deconnecter', onPressed: () async => _auth.signOut()),
              if (widget.onThemeModeChanged != null)
                IconButton(
                  icon: Icon(widget.currentThemeMode == ThemeMode.dark ? Icons.light_mode : Icons.dark_mode),
                  tooltip: 'Changer de theme',
                  onPressed: () {
                    final next = widget.currentThemeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
                    widget.onThemeModeChanged?.call(next);
                  },
                ),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: _refresh,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPaddingHorizontal, vertical: AppSpacing.xl),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const SectionHeader(title: 'Vue d ensemble'),
                const SizedBox(height: AppSpacing.md),
                _DashboardHeader(email: email, role: role),
                const SizedBox(height: AppSpacing.xl),
                if (role == 'admin') ...[
                  _KpiGrid(data: data),
                  const SizedBox(height: AppSpacing.xl),
                ],
                const SectionHeader(title: 'Gestion'),
                const SizedBox(height: AppSpacing.md),
                const _ManagementGrid(),
                const SizedBox(height: AppSpacing.xl),
                const SectionHeader(title: 'Activite recente'),
                const SizedBox(height: AppSpacing.md),
                _RecentActivity(reservations: data.upcomingReservations),
              ]),
            ),
          ),
        );
      },
    );
  }
}

class _DashboardHeader extends StatelessWidget {
  final String email; final String role;
  const _DashboardHeader({required this.email, required this.role});
  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Dashboard', style: AppTextStyles.headline3),
          const SizedBox(height: AppSpacing.xs),
          Text('$email • $role', style: AppTextStyles.body3.copyWith(color: AppColors.textSecondary)),
        ])),
        Wrap(spacing: AppSpacing.sm, children: [
          OutlinedButton.icon(icon: const Icon(Icons.person_outline), label: const Text('Profil'), onPressed: () {}),
          ElevatedButton.icon(icon: const Icon(Icons.logout), label: const Text('Deconnexion'), onPressed: () {}),
        ]),
      ]),
    );
  }
}

class _KpiGrid extends StatelessWidget {
  final _HomeData data; const _KpiGrid({required this.data});
  @override
  Widget build(BuildContext context) {
    final cols = ResponsiveHelper.getGridColumns(context).clamp(1, 4);
    final items = [
      _KpiItem('Hotels', data.hotelsCount.toString(), Icons.domain),
      _KpiItem('Chambres', data.roomsCount.toString(), Icons.meeting_room_outlined),
      _KpiItem('Reservations', data.reservationsCount.toString(), Icons.calendar_month),
      _KpiItem('Taux d occupation', '${data.occupancyRate.toStringAsFixed(1)}%', Icons.pie_chart),
    ];
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const SectionHeader(title: 'KPIs'),
      const SizedBox(height: AppSpacing.md),
      GridView.count(
        crossAxisCount: cols,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: AppSpacing.md,
        crossAxisSpacing: AppSpacing.md,
        childAspectRatio: 1.6,
        children: items.map((i) => _KpiCard(item: i)).toList(),
      ),
    ]);
  }
}

class _KpiItem {final String label,value; final IconData icon; const _KpiItem(this.label,this.value,this.icon);} 
class _KpiCard extends StatelessWidget {
  final _KpiItem item; const _KpiCard({required this.item});
  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(children: [
        Container(padding: const EdgeInsets.all(AppSpacing.md), decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: AppBorderRadius.allMd), child: Icon(item.icon, color: AppColors.primary)),
        const SizedBox(width: AppSpacing.md),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(item.label, style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: AppSpacing.xs),
          Text(item.value, style: AppTextStyles.headline4),
        ])),
      ]),
    );
  }
}

class _ManagementGrid extends StatelessWidget {
  const _ManagementGrid();
  @override
  Widget build(BuildContext context) {
    final items = [
      _NavItem('Gerer hotels', 'Liste, fiches, mises a jour.', Icons.hotel_outlined),
      _NavItem('Gerer chambres', 'Types, tarifs, dispo.', Icons.meeting_room_outlined),
      _NavItem('Gerer reservations', 'Suivi et statut.', Icons.book_online),
      _NavItem('Statistiques', 'Vue globale et KPIs.', Icons.query_stats),
    ];
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const SectionHeader(title: 'Gestion'),
      const SizedBox(height: AppSpacing.md),
      Wrap(
        spacing: AppSpacing.md,
        runSpacing: AppSpacing.md,
        children: items
            .map((i) => SizedBox(
                  width: ResponsiveHelper.isMobile(context) ? double.infinity : 280,
                  child: _NavCard(item: i),
                ))
            .toList(),
      ),
    ]);
  }
}

class _NavItem {final String title, subtitle; final IconData icon; const _NavItem(this.title,this.subtitle,this.icon);} 
class _NavCard extends StatelessWidget {
  final _NavItem item; const _NavCard({required this.item});
  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg), onTap: () {},
      child: Row(children: [
        Container(padding: const EdgeInsets.all(AppSpacing.md), decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: AppBorderRadius.allMd), child: Icon(item.icon, color: AppColors.primary)),
        const SizedBox(width: AppSpacing.md),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(item.title, style: AppTextStyles.subtitle1),
          const SizedBox(height: AppSpacing.xs),
          Text(item.subtitle, style: AppTextStyles.body3.copyWith(color: AppColors.textSecondary)),
        ])),
        const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.textSecondary),
      ]),
    );
  }
}

class _RecentActivity extends StatelessWidget {
  final List<Reservation> reservations; const _RecentActivity({required this.reservations});
  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const SectionHeader(title: 'Activite recente'),
      const SizedBox(height: AppSpacing.md),
      if (reservations.isEmpty)
        AppCard(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(children: [
            Icon(Icons.inbox_outlined, color: AppColors.textSecondary),
            const SizedBox(width: AppSpacing.md),
            Text('Aucune reservation recente', style: AppTextStyles.body3.copyWith(color: AppColors.textSecondary)),
          ]),
        )
      else
        Column(
          children: reservations
                .map((r) => AppCard(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Row(children: [
                      Container(padding: const EdgeInsets.all(AppSpacing.md), decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: AppBorderRadius.allMd), child: const Icon(Icons.calendar_month, color: AppColors.primary)),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(r.roomType.isNotEmpty ? r.roomType : 'Reservation', style: AppTextStyles.subtitle1),
                        const SizedBox(height: AppSpacing.xs),
                        Text('${r.startDate} -> ${r.endDate}', style: AppTextStyles.body3.copyWith(color: AppColors.textSecondary)),
                      ])),
                      Container(padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm), decoration: BoxDecoration(color: AppColors.border.withValues(alpha: 0.4), borderRadius: AppBorderRadius.allMd), child: Text(r.status, style: AppTextStyles.caption)),
                    ]),
                  ))
              .toList(),
        ),
    ]);
  }
}

class _HomeData {
  final int hotelsCount, roomsCount, reservationsCount; final double occupancyRate; final List<Reservation> upcomingReservations; final String? role;
  _HomeData({required this.hotelsCount, required this.roomsCount, required this.reservationsCount, required this.occupancyRate, required this.upcomingReservations, required this.role});
}
