import 'package:flutter/material.dart';
import 'package:tilikjalan/core/core.dart';
import 'package:tilikjalan/utils/utils.dart';

enum ReportStatus { submitted, inReview, approved, rejected }

class ReportHistoryPage extends StatefulWidget {
  const ReportHistoryPage({super.key});

  @override
  State<ReportHistoryPage> createState() => _ReportHistoryPageState();
}

class _ReportHistoryPageState extends State<ReportHistoryPage> {
  final List<ReportHistoryItem> _reports = [
    ReportHistoryItem(
      id: '1',
      title: 'Jalan Berlubang di Jl. Sudirman',
      description: 'Terdapat lubang besar yang dapat membahayakan pengendara',
      status: ReportStatus.approved,
      submittedDate: DateTime.now().subtract(const Duration(days: 2)),
      location: 'Jl. Sudirman, Jakarta Pusat',
      imagePath: null,
    ),
    ReportHistoryItem(
      id: '2',
      title: 'Lampu Jalan Mati',
      description: 'Lampu jalan di area ini sudah mati selama 3 hari',
      status: ReportStatus.inReview,
      submittedDate: DateTime.now().subtract(const Duration(days: 1)),
      location: 'Jl. Gatot Subroto, Jakarta Selatan',
      imagePath: null,
    ),
    ReportHistoryItem(
      id: '3',
      title: 'Pohon Tumbang Menghalangi Jalan',
      description: 'Pohon besar tumbang dan menghalangi jalur kendaraan',
      status: ReportStatus.rejected,
      submittedDate: DateTime.now().subtract(const Duration(hours: 12)),
      location: 'Jl. Thamrin, Jakarta Pusat',
      imagePath: null,
      rejectionReason: 'Laporan duplikat, sudah ada laporan serupa sebelumnya',
    ),
    ReportHistoryItem(
      id: '4',
      title: 'Kerusakan Trotoar',
      description: 'Trotoar retak dan berbahaya untuk pejalan kaki',
      status: ReportStatus.submitted,
      submittedDate: DateTime.now().subtract(const Duration(minutes: 30)),
      location: 'Jl. Rasuna Said, Jakarta Selatan',
      imagePath: null,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = context.textTheme;

    return Scaffold(
      backgroundColor: colors.neutral[50],
      appBar: AppBar(
        title: Text(
          'Riwayat Laporan',
          style: textTheme.titleMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: _reports.isEmpty
          ? _EmptyState()
          : RefreshIndicator(
              onRefresh: _refreshReports,
              color: colors.primary[500],
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _reports.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _ReportHistoryCard(report: _reports[index]),
                  );
                },
              ),
            ),
    );
  }

  Future<void> _refreshReports() async {
    // TODO: Implement refresh logic to fetch latest reports
    await Future<void>.delayed(const Duration(seconds: 1));
    setState(() {
      // Update reports here
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
              Icons.assignment_outlined,
              size: 80,
              color: colors.grey[400],
            ),
            24.vertical,
            Text(
              'Belum Ada Laporan',
              style: textTheme.titleLarge.copyWith(
                fontWeight: FontWeight.w600,
                color: colors.neutral[800],
              ),
            ),
            8.vertical,
            Text(
              'Anda belum memiliki laporan. Buat laporan pertama Anda untuk membantu memperbaiki kondisi jalan.',
              style: textTheme.bodyMedium.copyWith(
                color: colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            32.vertical,
            ElevatedButton.icon(
              onPressed: () => context.pop(),
              icon: const Icon(Icons.add, color: Colors.white),
              label: Text(
                'Buat Laporan',
                style: textTheme.titleSmall.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.primary[500],
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReportHistoryCard extends StatelessWidget {
  const _ReportHistoryCard({required this.report});

  final ReportHistoryItem report;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = context.textTheme;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.grey[200]!),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with status and date
            Row(
              children: [
                Expanded(
                  child: Text(
                    report.title,
                    style: textTheme.titleSmall.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                8.horizontal,
                _StatusBadge(status: report.status),
              ],
            ),
            8.vertical,

            // Description
            Text(
              report.description,
              style: textTheme.bodyMedium.copyWith(
                color: colors.neutral[700],
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            12.vertical,

            // Location
            Row(
              children: [
                Icon(
                  Icons.location_on,
                  size: 16,
                  color: colors.grey[600],
                ),
                4.horizontal,
                Expanded(
                  child: Text(
                    report.location,
                    style: textTheme.bodySmall.copyWith(
                      color: colors.grey[600],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            8.vertical,

            // Submit date
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 16,
                  color: colors.grey[600],
                ),
                4.horizontal,
                Text(
                  _formatDate(report.submittedDate),
                  style: textTheme.bodySmall.copyWith(
                    color: colors.grey[600],
                  ),
                ),
              ],
            ),

            // Rejection reason if rejected
            if (report.status == ReportStatus.rejected &&
                report.rejectionReason != null) ...[
              12.vertical,
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 16,
                      color: Colors.red[600],
                    ),
                    8.horizontal,
                    Expanded(
                      child: Text(
                        'Alasan: ${report.rejectionReason}',
                        style: textTheme.bodySmall.copyWith(
                          color: Colors.red[700],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} menit yang lalu';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} jam yang lalu';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} hari yang lalu';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final ReportStatus status;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = context.textTheme;

    Color backgroundColor;
    Color textColor;
    String label;
    IconData icon;

    switch (status) {
      case ReportStatus.submitted:
        backgroundColor = colors.grey[100]!;
        textColor = colors.grey[700]!;
        label = 'Terkirim';
        icon = Icons.send;
        break;
      case ReportStatus.inReview:
        backgroundColor = colors.secondary[100]!;
        textColor = colors.secondary[700]!;
        label = 'Sedang Ditinjau';
        icon = Icons.hourglass_empty;
        break;
      case ReportStatus.approved:
        backgroundColor = colors.support[100]!;
        textColor = colors.support[700]!;
        label = 'Disetujui';
        icon = Icons.check_circle;
        break;
      case ReportStatus.rejected:
        backgroundColor = Colors.red[100]!;
        textColor = Colors.red[700]!;
        label = 'Ditolak';
        icon = Icons.cancel;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: textColor,
          ),
          4.horizontal,
          Text(
            label,
            style: textTheme.labelSmall.copyWith(
              color: textColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class ReportHistoryItem {
  const ReportHistoryItem({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.submittedDate,
    required this.location,
    this.imagePath,
    this.rejectionReason,
  });

  final String id;
  final String title;
  final String description;
  final ReportStatus status;
  final DateTime submittedDate;
  final String location;
  final String? imagePath;
  final String? rejectionReason;
}
