import 'package:flutter/material.dart';

import '../services/dashboard_service.dart';
import 'about_meditag_screen.dart';
import 'expiry_alerts_screen.dart';
import 'inventory_screen.dart';
import 'pharmacy_profile_screen.dart';
import 'qr_labels_screen.dart';
import 'scan_medicine_screen.dart';
import 'search_medicine_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DashboardStats? stats;

  bool loadingStats = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    if (mounted) {
      setState(() {
        loadingStats = true;
      });
    }

    try {
      final result =
          await DashboardService.getDashboardStats();

      if (!mounted) return;

      setState(() {
        stats = result;
        loadingStats = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loadingStats = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Could not load dashboard: $e',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _openScan() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ScanMedicineScreen(),
      ),
    );
  }

  void _openInventory() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const InventoryScreen(),
      ),
    );
  }

  void _openSearch() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const SearchMedicineScreen(),
      ),
    );
  }

  void _openQrLabels() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const QrLabelsScreen(),
      ),
    );
  }

  void _openAlerts() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ExpiryAlertsScreen(),
      ),
    );
  }

  // ============================================================
  // PHARMACY PROFILE
  // ============================================================

  void _openPharmacyProfile() {
    Navigator.pop(context);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const PharmacyProfileScreen(),
      ),
    );
  }

  // ============================================================
  // ABOUT MEDITAG
  // ============================================================

  void _openAboutMediTag() {
    Navigator.pop(context);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AboutMediTagScreen(),
      ),
    );
  }

  // ============================================================
  // SETTINGS
  // ============================================================

  void _showSettings() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) {
        return Container(
          padding: const EdgeInsets.fromLTRB(
            20,
            12,
            20,
            30,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(28),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 45,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.black12,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),

              const SizedBox(height: 22),

              const Row(
                children: [
                  Icon(
                    Icons.settings_rounded,
                    color: Color(0xFF0F766E),
                    size: 28,
                  ),
                  SizedBox(width: 12),
                  Text(
                    'MediTag Settings',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 22),

              // ------------------------------------------------
              // PHARMACY PROFILE
              // ------------------------------------------------

              _SettingsRow(
                icon: Icons.person_outline_rounded,
                title: 'Pharmacy Profile',
                subtitle: 'Manage pharmacy information',
                onTap: _openPharmacyProfile,
              ),

              // ------------------------------------------------
              // NOTIFICATIONS
              // ------------------------------------------------

              _SettingsRow(
                icon: Icons.notifications_none_rounded,
                title: 'Notifications',
                subtitle: 'Expiry and medicine alerts',
                onTap: () {
                  Navigator.pop(context);
                  _openAlerts();
                },
              ),

              // ------------------------------------------------
              // ABOUT MEDITAG
              // ------------------------------------------------

              _SettingsRow(
                icon: Icons.info_outline_rounded,
                title: 'About MediTag',
                subtitle:
                    'Medicine verification and QR system',
                onTap: _openAboutMediTag,
              ),
            ],
          ),
        );
      },
    );
  }

  // ============================================================
  // TODAY OVERVIEW
  // ============================================================

  void _showTodayOverview() {
    if (stats == null) return;

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          title: const Row(
            children: [
              Icon(
                Icons.today_rounded,
                color: Color(0xFF0F766E),
              ),
              SizedBox(width: 10),
              Text(
                "Today's Overview",
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _OverviewDialogRow(
                icon: Icons.qr_code_2_rounded,
                label: 'QR labels created today',
                value: '${stats!.todayQrLabels}',
              ),
              const SizedBox(height: 14),
              _OverviewDialogRow(
                icon: Icons.medication_rounded,
                label: 'Dispensings today',
                value: '${stats!.todayDispensings}',
              ),
              const SizedBox(height: 14),
              _OverviewDialogRow(
                icon: Icons.inventory_2_outlined,
                label: 'Total medicines',
                value: '${stats!.medicines}',
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentStats = stats;

    return Scaffold(
      backgroundColor: const Color(0xFFF1FAF8),

      // ========================================================
      // APP BAR
      // ========================================================

      appBar: AppBar(
        backgroundColor: const Color(0xFFF1FAF8),
        elevation: 0,
        titleSpacing: 20,
        title: const Row(
          children: [
            Icon(
              Icons.local_pharmacy_rounded,
              color: Color(0xFF0F766E),
              size: 27,
            ),
            SizedBox(width: 9),
            Text(
              'MediTag',
              style: TextStyle(
                color: Color(0xFF17332F),
                fontSize: 21,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _openAlerts,
            tooltip: 'Alerts',
            icon: const Icon(
              Icons.notifications_none_rounded,
              color: Color(0xFF17332F),
            ),
          ),
          IconButton(
            onPressed: _showSettings,
            tooltip: 'Settings',
            icon: const Icon(
              Icons.settings_outlined,
              color: Color(0xFF17332F),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),

      // ========================================================
      // BODY
      // ========================================================

      body: RefreshIndicator(
        onRefresh: _loadStats,
        color: const Color(0xFF0F766E),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(
            20,
            8,
            20,
            30,
          ),
          children: [
            const Text(
              'Good day 👋',
              style: TextStyle(
                fontSize: 15,
                color: Color(0xFF64748B),
              ),
            ),

            const SizedBox(height: 4),

            const Text(
              'Pharmacy Dashboard',
              style: TextStyle(
                fontSize: 27,
                fontWeight: FontWeight.w900,
                color: Color(0xFF17201F),
              ),
            ),

            const SizedBox(height: 20),

            // ==================================================
            // SCAN HERO
            // ==================================================

            GestureDetector(
              onTap: _openScan,
              child: Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF0F766E),
                      Color(0xFF159A8A),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(
                        0xFF0F766E,
                      ).withOpacity(0.20),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 65,
                      height: 65,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.16),
                        borderRadius:
                            BorderRadius.circular(19),
                      ),
                      child: const Icon(
                        Icons.qr_code_scanner_rounded,
                        color: Colors.white,
                        size: 35,
                      ),
                    ),

                    const SizedBox(width: 16),

                    const Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Scan Medicine',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 21,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            'Scan QR, barcode or capture medicine information',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12.5,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 25),

            // ==================================================
            // QUICK ACTIONS
            // ==================================================

            const Text(
              'Quick Actions',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w800,
                color: Color(0xFF17201F),
              ),
            ),

            const SizedBox(height: 13),

            Row(
              children: [
                Expanded(
                  child: _ActionCard(
                    icon: Icons.inventory_2_outlined,
                    title: 'Inventory',
                    subtitle: 'Medicines',
                    onTap: _openInventory,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ActionCard(
                    icon: Icons.search_rounded,
                    title: 'Search',
                    subtitle: 'Find medicine',
                    onTap: _openSearch,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _ActionCard(
                    icon: Icons.qr_code_2_rounded,
                    title: 'QR Labels',
                    subtitle: 'Generated labels',
                    onTap: _openQrLabels,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ActionCard(
                    icon: Icons.warning_amber_rounded,
                    title: 'Alerts',
                    subtitle: 'Expiry alerts',
                    onTap: _openAlerts,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 25),

            // ==================================================
            // TODAY'S OVERVIEW
            // ==================================================

            Row(
              children: [
                const Expanded(
                  child: Text(
                    "Today's Overview",
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF17201F),
                    ),
                  ),
                ),

                IconButton(
                  onPressed: _loadStats,
                  tooltip: 'Refresh',
                  icon: const Icon(
                    Icons.refresh_rounded,
                    color: Color(0xFF0F766E),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            if (loadingStats)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(25),
                  child: CircularProgressIndicator(
                    color: Color(0xFF0F766E),
                  ),
                ),
              )
            else
              GestureDetector(
                onTap: _showTodayOverview,
                child: Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        icon: Icons.medication_outlined,
                        number:
                            '${currentStats?.medicines ?? 0}',
                        label: 'Medicines',
                      ),
                    ),

                    const SizedBox(width: 10),

                    Expanded(
                      child: _StatCard(
                        icon: Icons.inventory_2_outlined,
                        number:
                            '${currentStats?.batches ?? 0}',
                        label: 'Batches',
                      ),
                    ),

                    const SizedBox(width: 10),

                    Expanded(
                      child: _StatCard(
                        icon: Icons.qr_code_2_rounded,
                        number:
                            '${currentStats?.qrLabels ?? 0}',
                        label: 'QR Labels',
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 25),

            // ==================================================
            // TODAY ACTIVITY
            // ==================================================

            GestureDetector(
              onTap: _showTodayOverview,
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: const Color(
                          0xFF0F766E,
                        ).withOpacity(0.09),
                        borderRadius:
                            BorderRadius.circular(15),
                      ),
                      child: const Icon(
                        Icons.today_rounded,
                        color: Color(0xFF0F766E),
                        size: 27,
                      ),
                    ),

                    const SizedBox(width: 13),

                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Today's activity",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${currentStats?.todayDispensings ?? 0} dispensings • ${currentStats?.todayQrLabels ?? 0} QR labels created',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Icon(
                      Icons.chevron_right_rounded,
                      color: Color(0xFF94A3A0),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 14),

            // ==================================================
            // VERIFICATION INFO
            // ==================================================

            Container(
              padding: const EdgeInsets.all(17),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF9F6),
                borderRadius:
                    BorderRadius.circular(18),
              ),
              child: const Row(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.verified_rounded,
                    color: Color(0xFF0F766E),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'MediTag keeps verified medicine information separate from pharmacy-added dispensing instructions.',
                      style: TextStyle(
                        fontSize: 12,
                        height: 1.5,
                        color: Color(0xFF315E58),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      // ========================================================
      // BOTTOM NAVIGATION
      // ========================================================

      bottomNavigationBar: NavigationBar(
        backgroundColor: Colors.white,
        selectedIndex: 0,
        onDestinationSelected: (index) {
          if (index == 0) {
            return;
          }

          if (index == 1) {
            _openInventory();
            return;
          }

          if (index == 2) {
            _openSearch();
            return;
          }

          if (index == 3) {
            _showSettings();
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.inventory_2_outlined),
            selectedIcon:
                Icon(Icons.inventory_2_rounded),
            label: 'Inventory',
          ),
          NavigationDestination(
            icon: Icon(Icons.search_outlined),
            selectedIcon:
                Icon(Icons.search_rounded),
            label: 'Search',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon:
                Icon(Icons.settings_rounded),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

// ============================================================
// ACTION CARD
// ============================================================

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(19),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(19),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(
                    0xFF0F766E,
                  ).withOpacity(0.09),
                  borderRadius:
                      BorderRadius.circular(13),
                ),
                child: Icon(
                  icon,
                  color: const Color(0xFF0F766E),
                  size: 24,
                ),
              ),

              const SizedBox(height: 12),

              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 3),

              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// STAT CARD
// ============================================================

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String number;
  final String label;

  const _StatCard({
    required this.icon,
    required this.number,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: const Color(0xFF0F766E),
            size: 25,
          ),

          const SizedBox(height: 8),

          Text(
            number,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),

          const SizedBox(height: 2),

          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 10.5,
              color: Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// SETTINGS ROW
// ============================================================

class _SettingsRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SettingsRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 5,
          ),
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(
              horizontal: 0,
              vertical: 4,
            ),
            leading: Container(
              width: 45,
              height: 45,
              decoration: BoxDecoration(
                color: const Color(
                  0xFF0F766E,
                ).withOpacity(0.08),
                borderRadius:
                    BorderRadius.circular(13),
              ),
              child: Icon(
                icon,
                color: const Color(0xFF0F766E),
              ),
            ),
            title: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
              ),
            ),
            subtitle: Text(
              subtitle,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF64748B),
              ),
            ),
            trailing: const Icon(
              Icons.chevron_right_rounded,
              color: Color(0xFF94A3A0),
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// OVERVIEW DIALOG ROW
// ============================================================

class _OverviewDialogRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _OverviewDialogRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: const Color(
              0xFF0F766E,
            ).withOpacity(0.09),
            borderRadius:
                BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: const Color(0xFF0F766E),
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF64748B),
            ),
          ),
        ),

        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}