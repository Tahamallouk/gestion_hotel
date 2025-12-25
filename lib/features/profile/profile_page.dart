import 'package:flutter/material.dart';
import 'package:gestion_hotel/services/auth_service.dart';
import 'package:gestion_hotel/services/firestore_service.dart';
import 'package:gestion_hotel/utils/app_theme.dart';
import 'package:gestion_hotel/widgets/app_card.dart';
import 'package:gestion_hotel/widgets/section_header.dart';
import 'package:qr_flutter/qr_flutter.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late Future<_ProfileInfo> _future;
  String _language = 'Français';

  @override
  void initState() {
    super.initState();
    _future = _loadProfile();
  }

  Future<_ProfileInfo> _loadProfile() async {
    final auth = AuthService();
    final firestore = FirestoreService();
    final user = auth.currentUser;
    final uid = user?.uid;
    final email = user?.email ?? 'Utilisateur';
    final profileData = uid != null ? await firestore.getUserProfile(uid) : null;
    final role = profileData?['role'] as String? ?? (uid != null ? 'client' : 'invite');
    final fullName = profileData?['fullName']?.toString() ?? '';
    final phone = profileData?['phone']?.toString() ?? '';

    int totalSpent = 0;
    int totalReservations = 0;
    if (uid != null) {
      final reservations = await firestore.getReservationsByUser(uid);
      totalReservations = reservations.length;
      totalSpent = reservations.fold<int>(0, (sum, r) => sum + r.totalPrice);
    }

    return _ProfileInfo(
      email: email,
      uid: uid,
      role: role,
      fullName: fullName,
      phone: phone,
      totalReservations: totalReservations,
      totalSpent: totalSpent,
    );
  }

  void _openEditModal(_ProfileInfo profile) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: AppBorderRadius.lg)),
      builder: (context) {
        String tempLang = _language;
        bool notifications = true;
        return StatefulBuilder(builder: (context, setModal) {
          return Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Préférences', style: AppTextStyles.subtitle1),
                const SizedBox(height: AppSpacing.md),
                DropdownButtonFormField<String>(
                  initialValue: tempLang,
                  decoration: const InputDecoration(labelText: 'Langue'),
                  items: const [
                    DropdownMenuItem(value: 'Français', child: Text('Français')),
                    DropdownMenuItem(value: 'English', child: Text('English')),
                  ],
                  onChanged: (v) => setModal(() => tempLang = v ?? 'Français'),
                ),
                const SizedBox(height: AppSpacing.md),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Notifications'),
                  value: notifications,
                  onChanged: (v) => setModal(() => notifications = v),
                ),
                const SizedBox(height: AppSpacing.lg),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      setState(() => _language = tempLang);
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.save_outlined),
                    label: const Text('Enregistrer'),
                  ),
                ),
              ],
            ),
          );
        });
      },
    );
  }

  Future<void> _sendPasswordReset(String email) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await AuthService().resetPassword(email);
      messenger.showSnackBar(const SnackBar(content: Text('Email de réinitialisation envoyé')));
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Erreur: $e')));
    }
  }

  void _confirmDeleteAccount() {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Supprimer le compte ?'),
          content: const Text('Cette action est définitive. Contactez le support pour finaliser la suppression.'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Suppression en attente de mise en œuvre'), backgroundColor: Colors.redAccent),
                );
              },
              child: const Text('Compris'),
            ),
          ],
        );
      },
    );
  }

  String _displayName(_ProfileInfo profile) {
    if (profile.fullName.isNotEmpty) return profile.fullName;
    final emailPrefix = profile.email.split('@').first;
    return emailPrefix;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_ProfileInfo>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Erreur profil: ${snapshot.error}'));
        }

        final profile = snapshot.data!;

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPaddingHorizontal, vertical: AppSpacing.xl),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const SectionHeader(title: 'Profil'),
            const SizedBox(height: AppSpacing.md),
            AppCard(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: AppBorderRadius.allMd),
                    child: const Icon(Icons.person_outline, color: AppColors.primary),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(profile.email, style: AppTextStyles.subtitle1),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        _displayName(profile),
                        style: AppTextStyles.body2,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(profile.role.toUpperCase(), style: AppTextStyles.body3.copyWith(color: AppColors.textSecondary)),
                      if (profile.uid != null) ...[
                        const SizedBox(height: AppSpacing.xs),
                        Text('UID: ${profile.uid}', style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
                      ],
                      const SizedBox(height: AppSpacing.sm),
                      Wrap(
                        spacing: AppSpacing.sm,
                        runSpacing: AppSpacing.xs,
                        children: [
                          if (profile.phone.isNotEmpty) _Chip(icon: Icons.phone, label: profile.phone),
                          _Chip(icon: Icons.language, label: _language),
                          _Chip(icon: Icons.brightness_6_outlined, label: 'Thème : Système'),
                          _Chip(icon: Icons.lock_clock, label: 'Sessions actives : 1'),
                        ],
                      ),
                    ]),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => _openEditModal(profile),
                    icon: const Icon(Icons.edit_outlined),
                    label: const Text('Modifier'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            AppCard(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text('Sécurité', style: AppTextStyles.subtitle1),
                    Icon(Icons.security_outlined, color: AppColors.textSecondary),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.password_outlined),
                  title: const Text('Changer / réinitialiser le mot de passe'),
                  subtitle: const Text('Envoie un email de réinitialisation'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _sendPasswordReset(profile.email),
                ),
                const Divider(),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.devices_other_outlined),
                  title: const Text('Sessions actives'),
                  subtitle: const Text('Prochainement : voir et fermer les sessions'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Gestion des sessions à venir')),);
                  },
                ),
              ]),
            ),
            const SizedBox(height: AppSpacing.lg),
            AppCard(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text('Historique', style: AppTextStyles.subtitle1),
                    Icon(Icons.bar_chart_outlined, color: AppColors.textSecondary),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    _StatTile(label: 'Réservations', value: profile.totalReservations.toString()),
                    const SizedBox(width: AppSpacing.md),
                    _StatTile(label: 'Total dépensé', value: '${profile.totalSpent} DH'),
                  ],
                ),
              ]),
            ),
            const SizedBox(height: AppSpacing.lg),
            AppCard(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text('QR Code utilisateur', style: AppTextStyles.subtitle1),
                    Icon(Icons.qr_code_2, color: AppColors.textSecondary),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                if (profile.uid == null)
                  Text('Connectez-vous pour générer votre code.', style: AppTextStyles.body3.copyWith(color: AppColors.textSecondary))
                else
                  Center(
                    child: QrImageView(
                      data: profile.uid!,
                      version: QrVersions.auto,
                      size: 200,
                      gapless: false,
                      backgroundColor: AppColors.surface,
                      eyeStyle: const QrEyeStyle(color: AppColors.textPrimary, eyeShape: QrEyeShape.square),
                      dataModuleStyle: const QrDataModuleStyle(color: AppColors.textPrimary, dataModuleShape: QrDataModuleShape.square),
                    ),
                  ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Ce code peut être scanné pour vérifier votre identité lors des check-ins.',
                  style: AppTextStyles.body3.copyWith(color: AppColors.textSecondary),
                ),
              ]),
            ),
            const SizedBox(height: AppSpacing.lg),
            AppCard(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
                Text('Préférences', style: AppTextStyles.subtitle1),
                SizedBox(height: AppSpacing.sm),
                Text('Notifications: activées'),
                SizedBox(height: AppSpacing.xs),
                Text('Langue: dynamique'),
                SizedBox(height: AppSpacing.xs),
                Text('Thème: clair / sombre (système)'),
              ]),
            ),
            const SizedBox(height: AppSpacing.lg),
            Container(
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.08),
                borderRadius: AppBorderRadius.allLg,
                border: Border.all(color: Colors.redAccent.withValues(alpha: 0.4)),
              ),
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text('Action dangereuse', style: AppTextStyles.subtitle1),
                      Icon(Icons.warning_amber_rounded, color: Colors.redAccent),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  const Text(
                    'Supprimer définitivement le compte et les données associées.',
                    style: AppTextStyles.body3,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Align(
                    alignment: Alignment.centerRight,
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
                      onPressed: _confirmDeleteAccount,
                      icon: const Icon(Icons.delete_forever),
                      label: const Text('Supprimer le compte'),
                    ),
                  ),
                ],
              ),
            ),
          ]),
        );
      },
    );
  }
}

class _ProfileInfo {
  final String email;
  final String? uid;
  final String role;
  final String fullName;
  final String phone;
  final int totalReservations;
  final int totalSpent;

  const _ProfileInfo({
    required this.email,
    required this.uid,
    required this.role,
    required this.fullName,
    required this.phone,
    required this.totalReservations,
    required this.totalSpent,
  });
}

class _Chip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _Chip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppBorderRadius.allMd,
        border: Border.all(color: AppColors.border.withValues(alpha: 0.6)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.textSecondary),
          const SizedBox(width: 6),
          Text(label, style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;

  const _StatTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppBorderRadius.allMd,
          border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
            const SizedBox(height: AppSpacing.xs),
            Text(value, style: AppTextStyles.subtitle1.copyWith(fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}
