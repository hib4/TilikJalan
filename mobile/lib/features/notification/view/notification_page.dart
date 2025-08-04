import 'package:flutter/material.dart';
import 'package:tilikjalan/core/core.dart';
import 'package:tilikjalan/utils/utils.dart';

enum NotificationType { reportUpdate, systemAlert, reminder, announcement }

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final List<NotificationItem> _notifications = [
    NotificationItem(
      id: '1',
      title: 'Laporan Anda Disetujui',
      message:
          'Laporan "Jalan Berlubang di Jl. Sudirman" telah disetujui dan akan segera ditindaklanjuti.',
      type: NotificationType.reportUpdate,
      timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
      isRead: false,
    ),
    NotificationItem(
      id: '2',
      title: 'Pembaruan Sistem',
      message:
          'TilikJalan telah diperbarui dengan fitur baru untuk meningkatkan pengalaman pengguna.',
      type: NotificationType.systemAlert,
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      isRead: false,
    ),
    NotificationItem(
      id: '3',
      title: 'Laporan Dalam Peninjauan',
      message:
          'Laporan "Lampu Jalan Mati" sedang dalam proses peninjauan oleh tim terkait.',
      type: NotificationType.reportUpdate,
      timestamp: DateTime.now().subtract(const Duration(hours: 6)),
      isRead: true,
    ),
    NotificationItem(
      id: '4',
      title: 'Pengingat Laporan Bulanan',
      message:
          'Jangan lupa untuk melaporkan kondisi jalan di sekitar Anda bulan ini.',
      type: NotificationType.reminder,
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      isRead: true,
    ),
    NotificationItem(
      id: '5',
      title: 'Pengumuman Penting',
      message:
          'Maintenance sistem akan dilakukan pada tanggal 15 Agustus 2025 pukul 01:00 - 03:00 WIB.',
      type: NotificationType.announcement,
      timestamp: DateTime.now().subtract(const Duration(days: 2)),
      isRead: true,
    ),
  ];

  int get _unreadCount => _notifications.where((n) => !n.isRead).length;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final colors = context.colors;
    final textTheme = context.textTheme;

    return Scaffold(
      backgroundColor: colors.neutral[50],
      appBar: AppBar(
        title: Text(
          'Notifikasi',
          style: textTheme.titleMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        actions: [
          if (_unreadCount > 0)
            TextButton(
              onPressed: _markAllAsRead,
              child: Text(
                'Tandai Semua',
                style: textTheme.labelMedium.copyWith(
                  color: colors.primary[600],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
      body: _notifications.isEmpty
          ? _EmptyState()
          : RefreshIndicator(
              onRefresh: _refreshNotifications,
              color: colors.primary[500],
              child: Column(
                children: [
                  // Unread count header
                  if (_unreadCount > 0)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      color: colors.primary[50],
                      child: Text(
                        '$_unreadCount notifikasi belum dibaca',
                        style: textTheme.bodySmall.copyWith(
                          color: colors.primary[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),

                  // Notifications list
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      itemCount: _notifications.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: _NotificationCard(
                            notification: _notifications[index],
                            onTap: () => _markAsRead(_notifications[index]),
                            onDismiss: () =>
                                _dismissNotification(_notifications[index]),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Future<void> _refreshNotifications() async {
    // TODO: Implement refresh logic to fetch latest notifications
    await Future<void>.delayed(const Duration(seconds: 1));
    setState(() {
      // Update notifications here
    });
  }

  void _markAsRead(NotificationItem notification) {
    setState(() {
      notification.isRead = true;
    });
  }

  void _markAllAsRead() {
    setState(() {
      for (final notification in _notifications) {
        notification.isRead = true;
      }
    });
  }

  void _dismissNotification(NotificationItem notification) {
    setState(() {
      _notifications.remove(notification);
    });
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = context.textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_none,
              size: 80,
              color: colors.grey[400],
            ),
            24.vertical,
            Text(
              'Tidak Ada Notifikasi',
              style: textTheme.titleLarge.copyWith(
                fontWeight: FontWeight.w600,
                color: colors.neutral[800],
              ),
            ),
            8.vertical,
            Text(
              'Semua notifikasi akan muncul di sini. Anda akan mendapatkan update tentang laporan dan informasi penting.',
              style: textTheme.bodyMedium.copyWith(
                color: colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({
    required this.notification,
    required this.onTap,
    required this.onDismiss,
  });

  final NotificationItem notification;
  final VoidCallback onTap;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = context.textTheme;

    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDismiss(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red[400],
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
          size: 24,
        ),
      ),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: notification.isRead ? Colors.white : colors.primary[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: notification.isRead
                  ? colors.grey[200]!
                  : colors.primary[200]!,
            ),
            boxShadow: [
              BoxShadow(
                color: colors.grey[300]!.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Notification icon
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _getTypeColor(
                      notification.type,
                      colors,
                    ).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getTypeIcon(notification.type),
                    size: 20,
                    color: _getTypeColor(notification.type, colors),
                  ),
                ),

                12.horizontal,

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              notification.title,
                              style: textTheme.titleSmall.copyWith(
                                fontWeight: notification.isRead
                                    ? FontWeight.w500
                                    : FontWeight.w600,
                                color: colors.neutral[900],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (!notification.isRead) ...[
                            4.horizontal,
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: colors.primary[500],
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ],
                      ),
                      4.vertical,
                      Text(
                        notification.message,
                        style: textTheme.bodyMedium.copyWith(
                          color: colors.neutral[700],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      8.vertical,
                      Text(
                        _formatTimestamp(notification.timestamp),
                        style: textTheme.bodySmall.copyWith(
                          color: colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getTypeIcon(NotificationType type) {
    switch (type) {
      case NotificationType.reportUpdate:
        return Icons.assignment_turned_in;
      case NotificationType.systemAlert:
        return Icons.system_update_alt;
      case NotificationType.reminder:
        return Icons.schedule;
      case NotificationType.announcement:
        return Icons.campaign;
    }
  }

  Color _getTypeColor(NotificationType type, AppColors colors) {
    switch (type) {
      case NotificationType.reportUpdate:
        return colors.support[500]!;
      case NotificationType.systemAlert:
        return colors.primary[500]!;
      case NotificationType.reminder:
        return colors.secondary[500]!;
      case NotificationType.announcement:
        return colors.darkAccent[500]!;
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} menit yang lalu';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} jam yang lalu';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} hari yang lalu';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }
}

class NotificationItem {
  NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.timestamp,
    required this.isRead,
  });

  final String id;
  final String title;
  final String message;
  final NotificationType type;
  final DateTime timestamp;
  bool isRead;
}
