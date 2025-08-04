import 'package:flutter/material.dart';
import 'package:tilikjalan/core/core.dart';
import 'package:tilikjalan/features/report/view/report_form_page.dart';
import 'package:tilikjalan/features/report/view/report_history_page.dart';
import 'package:tilikjalan/utils/utils.dart';

class ReportPage extends StatefulWidget {
  const ReportPage({super.key});

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final colors = context.colors;
    final textTheme = context.textTheme;

    return Scaffold(
      backgroundColor: colors.neutral[50],
      appBar: AppBar(
        title: Text(
          'Laporan',
          style: textTheme.titleMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header section
            Text(
              'Kelola Laporan Anda',
              style: textTheme.headlineSmall.copyWith(
                fontWeight: FontWeight.w700,
                color: colors.neutral[900],
              ),
            ),
            8.vertical,
            Text(
              'Laporkan masalah infrastruktur jalan dan pantau status laporan Anda',
              style: textTheme.bodyMedium.copyWith(
                color: colors.grey[600],
              ),
            ),
            32.vertical,

            // Menu options
            Expanded(
              child: Column(
                children: [
                  // Create Report Menu
                  _MenuCard(
                    icon: Icons.add_box,
                    title: 'Tambah Laporan',
                    subtitle: 'Buat laporan baru tentang kondisi jalan',
                    colors: [colors.primary[500]!, colors.primary[600]!],
                    onTap: () {
                      context.push(const ReportFormPage());
                    },
                  ),

                  20.vertical,

                  // View Reports Menu
                  _MenuCard(
                    icon: Icons.history,
                    title: 'Lihat Laporan',
                    subtitle: 'Pantau status dan riwayat laporan Anda',
                    colors: [colors.secondary[500]!, colors.secondary[600]!],
                    onTap: () {
                      context.push(const ReportHistoryPage());
                    },
                  ),

                  const Spacer(),

                  // Stats or additional info section
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: colors.grey[200]!),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: colors.primary[500],
                          size: 32,
                        ),
                        12.vertical,
                        Text(
                          'Tips Laporan Efektif',
                          style: textTheme.titleSmall.copyWith(
                            fontWeight: FontWeight.w600,
                            color: colors.neutral[800],
                          ),
                        ),
                        8.vertical,
                        Text(
                          'Sertakan foto yang jelas, deskripsi detail, dan lokasi yang tepat untuk mempercepat penanganan laporan Anda.',
                          style: textTheme.bodySmall.copyWith(
                            color: colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),

                  24.vertical,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuCard extends StatefulWidget {
  const _MenuCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.colors,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final List<Color> colors;
  final VoidCallback onTap;

  @override
  State<_MenuCard> createState() => _MenuCardState();
}

class _MenuCardState extends State<_MenuCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation =
        Tween<double>(
          begin: 1.0,
          end: 0.95,
        ).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeInOut,
          ),
        );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;

    return GestureDetector(
      onTapDown: (_) {
        setState(() => _isPressed = true);
        _animationController.forward();
      },
      onTapUp: (_) {
        setState(() => _isPressed = false);
        _animationController.reverse();
        widget.onTap();
      },
      onTapCancel: () {
        setState(() => _isPressed = false);
        _animationController.reverse();
      },
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: widget.colors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: widget.colors[0].withOpacity(0.3),
                    blurRadius: _isPressed ? 8 : 12,
                    offset: Offset(0, _isPressed ? 2 : 6),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        widget.icon,
                        size: 32,
                        color: Colors.white,
                      ),
                    ),
                    20.horizontal,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.title,
                            style: textTheme.titleMedium.copyWith(
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          4.vertical,
                          Text(
                            widget.subtitle,
                            style: textTheme.bodyMedium.copyWith(
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.white.withOpacity(0.8),
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
