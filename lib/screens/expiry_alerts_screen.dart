import 'package:flutter/material.dart';

import '../services/dashboard_service.dart';

class ExpiryAlertsScreen extends StatefulWidget {
  const ExpiryAlertsScreen({super.key});

  @override
  State<ExpiryAlertsScreen> createState() => _ExpiryAlertsScreenState();
}

class _ExpiryAlertsScreenState extends State<ExpiryAlertsScreen> {
  List<ExpiryAlert> alerts = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadAlerts();
  }

  Future<void> _loadAlerts() async {
    setState(() {
      loading = true;
    });

    try {
      final result = await DashboardService.getExpiryAlerts();

      if (!mounted) return;

      setState(() {
        alerts = result;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not load expiry alerts: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _statusText(ExpiryAlert alert) {
    if (alert.expired) {
      return 'EXPIRED';
    }

    if (alert.daysRemaining == 0) {
      return 'EXPIRES TODAY';
    }

    if (alert.daysRemaining == 1) {
      return '1 DAY LEFT';
    }

    return '${alert.daysRemaining} DAYS LEFT';
  }

  Color _statusColor(ExpiryAlert alert) {
    if (alert.expired) {
      return const Color(0xFFD92D20);
    }

    if (alert.daysRemaining <= 7) {
      return const Color(0xFFE67E22);
    }

    return const Color(0xFFD69E2E);
  }

  IconData _statusIcon(ExpiryAlert alert) {
    if (alert.expired) {
      return Icons.error_rounded;
    }

    if (alert.daysRemaining <= 7) {
      return Icons.warning_amber_rounded;
    }

    return Icons.schedule_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final expiredCount =
        alerts.where((alert) => alert.expired).length;

    final soonCount =
        alerts.where((alert) => !alert.expired).length;

    return Scaffold(
      backgroundColor: const Color(0xFFF7FAF9),

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: const Color(0xFF17332F),
        title: const Text(
          'Expiry Alerts',
          style: TextStyle(
            fontSize: 21,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          IconButton(
            onPressed: loading ? null : _loadAlerts,
            tooltip: 'Refresh',
            icon: const Icon(
              Icons.refresh_rounded,
            ),
          ),
          const SizedBox(width: 6),
        ],
      ),

      body: RefreshIndicator(
        onRefresh: _loadAlerts,
        color: const Color(0xFF0F766E),
        child: loading
            ? const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF0F766E),
                ),
              )
            : ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                children: [
                  _buildHeader(
                    expiredCount,
                    soonCount,
                  ),

                  const SizedBox(height: 20),

                  if (alerts.isEmpty)
                    _buildNoAlerts()
                  else
                    ...alerts.map(
                      (alert) => Padding(
                        padding:
                            const EdgeInsets.only(bottom: 12),
                        child: _buildAlertCard(alert),
                      ),
                    ),

                  const SizedBox(height: 25),

                  _buildInformationCard(),
                ],
              ),
      ),
    );
  }

  Widget _buildHeader(
    int expiredCount,
    int soonCount,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF0F766E),
            Color(0xFF159A8A),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.16),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Icon(
                  Icons.notifications_active_rounded,
                  color: Colors.white,
                  size: 27,
                ),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Text(
                  'Medicine Expiry Monitor',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          const Text(
            'MediTag checks medicine batches and highlights products that have expired or are approaching expiry.',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 13,
              height: 1.45,
            ),
          ),

          const SizedBox(height: 18),

          Row(
            children: [
              Expanded(
                child: _SummaryBox(
                  number: '$expiredCount',
                  label: 'Expired',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _SummaryBox(
                  number: '$soonCount',
                  label: 'Expiring Soon',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAlertCard(ExpiryAlert alert) {
    final statusColor = _statusColor(alert);

    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: statusColor.withOpacity(0.18),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.035),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.10),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(
              _statusIcon(alert),
              color: statusColor,
              size: 27,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  alert.medicineName.isEmpty
                      ? 'Unknown medicine'
                      : alert.medicineName,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF17201F),
                  ),
                ),

                const SizedBox(height: 6),

                if (alert.batchNumber.isNotEmpty)
                  Text(
                    'Batch: ${alert.batchNumber}',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF64748B),
                    ),
                  ),

                const SizedBox(height: 5),

                Text(
                  'Expiry: ${alert.expiryDate}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF64748B),
                  ),
                ),

                const SizedBox(height: 11),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    _statusText(alert),
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoAlerts() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 25,
        vertical: 55,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        children: [
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              color: const Color(0xFF0F9D8A)
                  .withOpacity(0.10),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle_outline_rounded,
              color: Color(0xFF0F9D8A),
              size: 42,
            ),
          ),

          const SizedBox(height: 18),

          const Text(
            'No expiry alerts',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 8),

          const Text(
            'Great! No medicine batches are currently expired or approaching their expiry date.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              height: 1.5,
              color: Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInformationCard() {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF9F6),
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: Color(0xFF0F766E),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'MediTag shows batches expiring within 30 days as alerts. Expired batches are highlighted separately.',
              style: TextStyle(
                fontSize: 12.5,
                height: 1.5,
                color: Color(0xFF315E58),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryBox extends StatelessWidget {
  final String number;
  final String label;

  const _SummaryBox({
    required this.number,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.14),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Text(
            number,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}