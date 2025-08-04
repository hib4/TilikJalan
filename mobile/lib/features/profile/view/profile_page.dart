import 'package:flutter/material.dart';
import 'package:tilikjalan/core/core.dart';
import 'package:tilikjalan/utils/utils.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  // Mock user data - in real app this would come from user state/API
  final UserProfile _userProfile = UserProfile(
    name: 'Hibatullah Fawwaz Hana',
    email: 'hiba@garudahacks.com',
    phone: '+62 123-4567-8901',
    joinDate: DateTime(2024, 1, 15),
    totalReports: 12,
    acceptedReports: 8,
    avatarUrl: null,
  );

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final colors = context.colors;
    final textTheme = context.textTheme;

    return Scaffold(
      backgroundColor: colors.neutral[50],
      appBar: AppBar(
        title: Text(
          'Profil',
          style: textTheme.titleMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: _showSettingsModal,
            icon: Icon(
              Icons.settings,
              color: colors.neutral[800],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Profile Header Card
            _ProfileHeaderCard(
              userProfile: _userProfile,
              onEditProfile: _editProfile,
            ),

            24.vertical,

            // Statistics Cards
            _StatisticsSection(userProfile: _userProfile),

            24.vertical,

            // Menu Options
            _MenuSection(
              onAccountSettings: _showAccountSettings,
              onNotificationSettings: _showNotificationSettings,
              onPrivacySettings: _showPrivacySettings,
              onHelpSupport: _showHelpSupport,
              onAbout: _showAbout,
              onLogout: _showLogoutConfirmation,
            ),

            32.vertical,

            // App Version
            Text(
              'TilikJalan v1.0.0',
              style: textTheme.bodySmall.copyWith(
                color: colors.grey[500],
              ),
            ),

            16.vertical,
          ],
        ),
      ),
    );
  }

  void _editProfile() {
    // TODO: Navigate to edit profile page
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Fitur edit profil akan segera tersedia'),
      ),
    );
  }

  void _showSettingsModal() {
    final colors = context.colors;
    final textTheme = context.textTheme;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            16.vertical,
            Text(
              'Pengaturan Cepat',
              style: textTheme.titleMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            24.vertical,
            _QuickSettingTile(
              icon: Icons.notifications_outlined,
              title: 'Notifikasi',
              subtitle: 'Atur preferensi notifikasi',
              onTap: () {
                Navigator.pop(context);
                _showNotificationSettings();
              },
            ),
            _QuickSettingTile(
              icon: Icons.privacy_tip_outlined,
              title: 'Privasi',
              subtitle: 'Kelola pengaturan privasi',
              onTap: () {
                Navigator.pop(context);
                _showPrivacySettings();
              },
            ),
            _QuickSettingTile(
              icon: Icons.help_outline,
              title: 'Bantuan',
              subtitle: 'Dapatkan bantuan dan dukungan',
              onTap: () {
                Navigator.pop(context);
                _showHelpSupport();
              },
            ),
            16.vertical,
          ],
        ),
      ),
    );
  }

  void _showAccountSettings() {
    // TODO: Implement account settings
    _showComingSoonMessage('Pengaturan Akun');
  }

  void _showNotificationSettings() {
    // TODO: Implement notification settings
    _showComingSoonMessage('Pengaturan Notifikasi');
  }

  void _showPrivacySettings() {
    // TODO: Implement privacy settings
    _showComingSoonMessage('Pengaturan Privasi');
  }

  void _showHelpSupport() {
    // TODO: Implement help & support
    _showComingSoonMessage('Bantuan & Dukungan');
  }

  void _showAbout() {
    // TODO: Implement about page
    _showComingSoonMessage('Tentang Aplikasi');
  }

  void _showLogoutConfirmation() {
    final colors = context.colors;
    final textTheme = context.textTheme;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Keluar Akun',
          style: textTheme.titleMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'Apakah Anda yakin ingin keluar dari akun?',
          style: textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Batal',
              style: textTheme.titleSmall.copyWith(
                color: colors.grey[600],
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement logout logic
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Berhasil keluar dari akun'),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[500],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Keluar',
              style: textTheme.titleSmall.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showComingSoonMessage(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature akan segera tersedia'),
      ),
    );
  }
}

class _ProfileHeaderCard extends StatelessWidget {
  const _ProfileHeaderCard({
    required this.userProfile,
    required this.onEditProfile,
  });

  final UserProfile userProfile;
  final VoidCallback onEditProfile;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = context.textTheme;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colors.primary[500]!, colors.primary[600]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: colors.primary[500]!.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Avatar and Edit Button
            Stack(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: userProfile.avatarUrl != null
                      ? ClipOval(
                          child: Image.network(
                            userProfile.avatarUrl!,
                            fit: BoxFit.cover,
                          ),
                        )
                      : Icon(
                          Icons.person,
                          size: 40,
                          color: Colors.white.withOpacity(0.9),
                        ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: onEditProfile,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: colors.primary[500]!,
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        Icons.edit,
                        size: 16,
                        color: colors.primary[600],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            16.vertical,

            // User Name
            Text(
              userProfile.name,
              style: textTheme.titleLarge.copyWith(
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),

            4.vertical,

            // User Email
            Text(
              userProfile.email,
              style: textTheme.bodyMedium.copyWith(
                color: Colors.white.withOpacity(0.9),
              ),
            ),

            16.vertical,

            // Join Date
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Bergabung ${_formatJoinDate(userProfile.joinDate)}',
                style: textTheme.bodySmall.copyWith(
                  color: Colors.white.withOpacity(0.9),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatJoinDate(DateTime date) {
    const months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    return '${months[date.month - 1]} ${date.year}';
  }
}

class _StatisticsSection extends StatelessWidget {
  const _StatisticsSection({required this.userProfile});

  final UserProfile userProfile;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = context.textTheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Statistik Laporan',
            style: textTheme.titleMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: colors.neutral[900],
            ),
          ),
          16.vertical,
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 140,
                  child: _StatCard(
                    icon: Icons.assignment,
                    value: userProfile.totalReports.toString(),
                    label: 'Total Laporan',
                    color: colors.primary[500]!,
                  ),
                ),
              ),
              16.horizontal,
              Expanded(
                child: SizedBox(
                  height: 140,
                  child: _StatCard(
                    icon: Icons.check_circle,
                    value: userProfile.acceptedReports.toString(),
                    label: 'Diterima',
                    color: colors.support[500]!,
                  ),
                ),
              ),
            ],
          ),
          12.vertical,
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 140,
                  child: _StatCard(
                    icon: Icons.trending_up,
                    value:
                        '${((userProfile.acceptedReports / userProfile.totalReports) * 100).round()}%',
                    label: 'Tingkat Penerimaan',
                    color: colors.secondary[500]!,
                  ),
                ),
              ),
              16.horizontal,
              Expanded(
                child: SizedBox(
                  height: 140,
                  child: _StatCard(
                    icon: Icons.schedule,
                    value:
                        '${userProfile.totalReports - userProfile.acceptedReports}',
                    label: 'Dalam Proses',
                    color: colors.darkAccent[500]!,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = context.textTheme;

    return Container(
      width: double.infinity,
      height: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),
          8.vertical,
          Text(
            value,
            style: textTheme.titleLarge.copyWith(
              fontWeight: FontWeight.w700,
              color: colors.neutral[900],
            ),
          ),
          4.vertical,
          Text(
            label,
            style: textTheme.bodySmall.copyWith(
              color: colors.neutral[700],
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _MenuSection extends StatelessWidget {
  const _MenuSection({
    required this.onAccountSettings,
    required this.onNotificationSettings,
    required this.onPrivacySettings,
    required this.onHelpSupport,
    required this.onAbout,
    required this.onLogout,
  });

  final VoidCallback onAccountSettings;
  final VoidCallback onNotificationSettings;
  final VoidCallback onPrivacySettings;
  final VoidCallback onHelpSupport;
  final VoidCallback onAbout;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.grey[200]!),
      ),
      child: Column(
        children: [
          _MenuTile(
            icon: Icons.account_circle_outlined,
            title: 'Pengaturan Akun',
            subtitle: 'Kelola informasi pribadi',
            onTap: onAccountSettings,
          ),
          _MenuDivider(),
          _MenuTile(
            icon: Icons.notifications_outlined,
            title: 'Notifikasi',
            subtitle: 'Atur preferensi notifikasi',
            onTap: onNotificationSettings,
          ),
          _MenuDivider(),
          _MenuTile(
            icon: Icons.privacy_tip_outlined,
            title: 'Privasi & Keamanan',
            subtitle: 'Kelola pengaturan privasi',
            onTap: onPrivacySettings,
          ),
          _MenuDivider(),
          _MenuTile(
            icon: Icons.help_outline,
            title: 'Bantuan & Dukungan',
            subtitle: 'FAQ dan hubungi kami',
            onTap: onHelpSupport,
          ),
          _MenuDivider(),
          _MenuTile(
            icon: Icons.info_outline,
            title: 'Tentang TilikJalan',
            subtitle: 'Versi app dan informasi lainnya',
            onTap: onAbout,
          ),
          _MenuDivider(),
          _MenuTile(
            icon: Icons.logout,
            title: 'Keluar',
            subtitle: 'Keluar dari akun Anda',
            onTap: onLogout,
            isDestructive: true,
          ),
        ],
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.isDestructive = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = context.textTheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDestructive ? Colors.red[100] : colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                size: 20,
                color: isDestructive ? Colors.red[600] : colors.neutral[900],
              ),
            ),
            16.horizontal,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: textTheme.titleSmall.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isDestructive
                          ? Colors.red[700]
                          : colors.neutral[900],
                    ),
                  ),
                  2.vertical,
                  Text(
                    subtitle,
                    style: textTheme.bodySmall.copyWith(
                      color: colors.neutral[700],
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: colors.grey[500],
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      height: 1,
      margin: const EdgeInsets.only(left: 60),
      color: colors.grey[200],
    );
  }
}

class _QuickSettingTile extends StatelessWidget {
  const _QuickSettingTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = context.textTheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(
              icon,
              size: 24,
              color: colors.primary[600],
            ),
            16.horizontal,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: textTheme.titleSmall.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  2.vertical,
                  Text(
                    subtitle,
                    style: textTheme.bodySmall.copyWith(
                      color: colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: colors.grey[500],
            ),
          ],
        ),
      ),
    );
  }
}

class UserProfile {
  const UserProfile({
    required this.name,
    required this.email,
    required this.phone,
    required this.joinDate,
    required this.totalReports,
    required this.acceptedReports,
    this.avatarUrl,
  });

  final String name;
  final String email;
  final String phone;
  final DateTime joinDate;
  final int totalReports;
  final int acceptedReports;
  final String? avatarUrl;
}
