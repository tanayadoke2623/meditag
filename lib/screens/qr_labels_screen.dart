import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../services/dashboard_service.dart';

class QrLabelsScreen extends StatefulWidget {
  const QrLabelsScreen({super.key});

  @override
  State<QrLabelsScreen> createState() =>
      _QrLabelsScreenState();
}

class _QrLabelsScreenState
    extends State<QrLabelsScreen> {
  List<Map<String, dynamic>> qrLabels = [];

  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadQrLabels();
  }

  Future<void> _loadQrLabels() async {
    setState(() {
      loading = true;
    });

    try {
      final result =
          await DashboardService.getQrLabels();

      if (!mounted) return;

      setState(() {
        qrLabels = result;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Could not load QR labels: $e',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Map<String, dynamic>? _getDispensing(
    Map<String, dynamic> item,
  ) {
    final value =
        item['dispensing_records'];

    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }

    return null;
  }

  Map<String, dynamic>? _getMedicine(
    Map<String, dynamic> item,
  ) {
    final dispensing =
        _getDispensing(item);

    if (dispensing == null) {
      return null;
    }

    final value =
        dispensing['medicines'];

    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }

    return null;
  }

  String _medicineName(
    Map<String, dynamic> item,
  ) {
    final medicine =
        _getMedicine(item);

    return medicine?['medicine_name']
            ?.toString() ??
        'Unknown medicine';
  }

  String _strength(
    Map<String, dynamic> item,
  ) {
    final medicine =
        _getMedicine(item);

    return medicine?['strength']
            ?.toString() ??
        '';
  }

  String _quantity(
    Map<String, dynamic> item,
  ) {
    final dispensing =
        _getDispensing(item);

    return dispensing?['quantity_dispensed']
            ?.toString() ??
        '0';
  }

  String _instructions(
    Map<String, dynamic> item,
  ) {
    final dispensing =
        _getDispensing(item);

    return dispensing?[
            'pharmacy_instructions']
        ?.toString() ??
        '';
  }

  String _qrData(
    Map<String, dynamic> item,
  ) {
    final data =
        item['qr_data']?.toString() ?? '';

    if (data.isNotEmpty) {
      return data;
    }

    return item['qr_token']?.toString() ?? '';
  }

  String _formatDate(String value) {
    if (value.isEmpty) {
      return '';
    }

    final date =
        DateTime.tryParse(value);

    if (date == null) {
      return value;
    }

    final day =
        date.day.toString().padLeft(2, '0');

    final month =
        date.month.toString().padLeft(2, '0');

    return '$day/$month/${date.year}';
  }

  void _showQrDetails(
    Map<String, dynamic> item,
  ) {
    final medicineName =
        _medicineName(item);

    final strength =
        _strength(item);

    final quantity =
        _quantity(item);

    final instructions =
        _instructions(item);

    final qrData =
        _qrData(item);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return Container(
          height:
              MediaQuery.of(context).size.height *
                  0.88,
          decoration:
              const BoxDecoration(
            color: Color(0xFFF7FAF9),
            borderRadius:
                BorderRadius.vertical(
              top: Radius.circular(28),
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 12),

                Container(
                  width: 45,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.black12,
                    borderRadius:
                        BorderRadius.circular(10),
                  ),
                ),

                const SizedBox(height: 18),

                Padding(
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 20,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration:
                            BoxDecoration(
                          color: const Color(
                            0xFF0F766E,
                          ).withOpacity(0.10),
                          borderRadius:
                              BorderRadius.circular(
                            14,
                          ),
                        ),
                        child: const Icon(
                          Icons.qr_code_2_rounded,
                          color:
                              Color(0xFF0F766E),
                          size: 29,
                        ),
                      ),
                      const SizedBox(width: 13),
                      const Expanded(
                        child: Text(
                          'MediTag QR Label',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight:
                                FontWeight.w800,
                            color:
                                Color(0xFF17332F),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                Expanded(
                  child:
                      SingleChildScrollView(
                    padding:
                        const EdgeInsets.fromLTRB(
                      20,
                      0,
                      20,
                      30,
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: double.infinity,
                          padding:
                              const EdgeInsets.all(
                            22,
                          ),
                          decoration:
                              BoxDecoration(
                            color: Colors.white,
                            borderRadius:
                                BorderRadius.circular(
                              22,
                            ),
                          ),
                          child: Column(
                            children: [
                              if (qrData
                                  .isNotEmpty)
                                QrImageView(
                                  data: qrData,
                                  version:
                                      QrVersions.auto,
                                  size: 230,
                                  backgroundColor:
                                      Colors.white,
                                  errorCorrectionLevel:
                                      QrErrorCorrectLevel
                                          .M,
                                ),

                              const SizedBox(
                                height: 18,
                              ),

                              Text(
                                medicineName,
                                textAlign:
                                    TextAlign.center,
                                style:
                                    const TextStyle(
                                  fontSize: 22,
                                  fontWeight:
                                      FontWeight.w800,
                                  color:
                                      Color(0xFF17201F),
                                ),
                              ),

                              if (strength
                                  .isNotEmpty) ...[
                                const SizedBox(
                                  height: 5,
                                ),
                                Text(
                                  strength,
                                  style:
                                      const TextStyle(
                                    color:
                                        Color(0xFF64748B),
                                  ),
                                ),
                              ],

                              const SizedBox(
                                height: 15,
                              ),

                              Container(
                                padding:
                                    const EdgeInsets
                                        .symmetric(
                                  horizontal: 14,
                                  vertical: 8,
                                ),
                                decoration:
                                    BoxDecoration(
                                  color:
                                      const Color(
                                    0xFFEFF9F6,
                                  ),
                                  borderRadius:
                                      BorderRadius
                                          .circular(
                                    12,
                                  ),
                                ),
                                child: Text(
                                  '$quantity tablets',
                                  style:
                                      const TextStyle(
                                    color:
                                        Color(0xFF0F766E),
                                    fontWeight:
                                        FontWeight.w800,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(
                          height: 15,
                        ),

                        _DetailsCard(
                          title:
                              'Label information',
                          children: [
                            _DetailRow(
                              label: 'Quantity',
                              value:
                                  '$quantity tablets',
                            ),
                            _DetailRow(
                              label: 'Created',
                              value:
                                  _formatDate(
                                item['created_at']
                                        ?.toString() ??
                                    '',
                              ),
                            ),
                            _DetailRow(
                              label: 'Status',
                              value:
                                  item['is_active'] ==
                                          true
                                      ? 'Active'
                                      : 'Inactive',
                            ),
                          ],
                        ),

                        if (instructions
                            .isNotEmpty) ...[
                          const SizedBox(
                            height: 15,
                          ),
                          _DetailsCard(
                            title:
                                'Pharmacy instructions',
                            children: [
                              Text(
                                instructions,
                                style:
                                    const TextStyle(
                                  fontSize: 14,
                                  height: 1.5,
                                  color:
                                      Color(0xFF334155),
                                ),
                              ),
                            ],
                          ),
                        ],

                        const SizedBox(
                          height: 15,
                        ),

                        _DetailsCard(
                          title: 'QR data',
                          children: [
                            SelectableText(
                              qrData.isEmpty
                                  ? 'No QR data stored'
                                  : qrData,
                              style:
                                  const TextStyle(
                                fontSize: 12,
                                height: 1.5,
                                color:
                                    Color(0xFF475569),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(
                          height: 18,
                        ),

                        Container(
                          width: double.infinity,
                          padding:
                              const EdgeInsets.all(
                            15,
                          ),
                          decoration:
                              BoxDecoration(
                            color:
                                const Color(
                              0xFFEFF9F6,
                            ),
                            borderRadius:
                                BorderRadius.circular(
                              16,
                            ),
                          ),
                          child: const Row(
                            crossAxisAlignment:
                                CrossAxisAlignment
                                    .start,
                            children: [
                              Icon(
                                Icons
                                    .wifi_off_rounded,
                                color:
                                    Color(0xFF0F766E),
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'This QR contains the medicine information directly. MediTag or internet access is not required to read it.',
                                  style:
                                      TextStyle(
                                    fontSize: 12,
                                    height: 1.45,
                                    color:
                                        Color(0xFF315E58),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFF7FAF9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor:
            const Color(0xFF17332F),
        title: const Text(
          'QR Labels',
          style: TextStyle(
            fontSize: 21,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          IconButton(
            onPressed:
                loading ? null : _loadQrLabels,
            icon: const Icon(
              Icons.refresh_rounded,
            ),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadQrLabels,
        color: const Color(0xFF0F766E),
        child: loading
            ? const Center(
                child:
                    CircularProgressIndicator(
                  color:
                      Color(0xFF0F766E),
                ),
              )
            : ListView(
                physics:
                    const AlwaysScrollableScrollPhysics(),
                padding:
                    const EdgeInsets.all(20),
                children: [
                  _buildHeader(),

                  const SizedBox(
                    height: 20,
                  ),

                  if (qrLabels.isEmpty)
                    _buildEmptyState()
                  else
                    ...qrLabels.map(
                      (item) => Padding(
                        padding:
                            const EdgeInsets.only(
                          bottom: 12,
                        ),
                        child: _QrLabelCard(
                          medicineName:
                              _medicineName(item),
                          strength:
                              _strength(item),
                          quantity:
                              _quantity(item),
                          createdAt:
                              _formatDate(
                            item['created_at']
                                    ?.toString() ??
                                '',
                          ),
                          onTap: () =>
                              _showQrDetails(
                            item,
                          ),
                        ),
                      ),
                    ),

                  const SizedBox(
                    height: 25,
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding:
          const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient:
            const LinearGradient(
          colors: [
            Color(0xFF0F766E),
            Color(0xFF159A8A),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius:
            BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration:
                BoxDecoration(
              color: Colors.white
                  .withOpacity(0.15),
              borderRadius:
                  BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.qr_code_2_rounded,
              color: Colors.white,
              size: 30,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const Text(
                  'Generated MediTags',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight:
                        FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '${qrLabels.length} QR label${qrLabels.length == 1 ? '' : 's'} created',
                  style:
                      const TextStyle(
                    color:
                        Colors.white70,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 25,
        vertical: 55,
      ),
      decoration:
          BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(22),
      ),
      child: Column(
        children: [
          Container(
            width: 78,
            height: 78,
            decoration:
                BoxDecoration(
              color:
                  const Color(0xFF0F766E)
                      .withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.qr_code_rounded,
              color:
                  Color(0xFF0F766E),
              size: 42,
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'No QR labels yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight:
                  FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Generate a MediTag QR after dispensing a verified medicine and it will appear here.',
            textAlign:
                TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              height: 1.5,
              color:
                  Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }
}

class _QrLabelCard
    extends StatelessWidget {
  final String medicineName;
  final String strength;
  final String quantity;
  final String createdAt;
  final VoidCallback onTap;

  const _QrLabelCard({
    required this.medicineName,
    required this.strength,
    required this.quantity,
    required this.createdAt,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape:
          RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(20),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius:
            BorderRadius.circular(20),
        child: Padding(
          padding:
              const EdgeInsets.all(17),
          child: Row(
            children: [
              Container(
                width: 58,
                height: 58,
                decoration:
                    BoxDecoration(
                  color:
                      const Color(0xFF0F766E)
                          .withOpacity(0.08),
                  borderRadius:
                      BorderRadius.circular(
                    15,
                  ),
                ),
                child: const Icon(
                  Icons.qr_code_2_rounded,
                  color:
                      Color(0xFF0F766E),
                  size: 32,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      medicineName,
                      style:
                          const TextStyle(
                        fontSize: 17,
                        fontWeight:
                            FontWeight.w800,
                        color:
                            Color(0xFF17201F),
                      ),
                    ),
                    if (strength.isNotEmpty) ...[
                      const SizedBox(
                        height: 4,
                      ),
                      Text(
                        strength,
                        style:
                            const TextStyle(
                          fontSize: 13,
                          color:
                              Color(0xFF64748B),
                        ),
                      ),
                    ],
                    const SizedBox(
                      height: 8,
                    ),
                    Row(
                      children: [
                        Container(
                          padding:
                              const EdgeInsets
                                  .symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration:
                              BoxDecoration(
                            color:
                                const Color(
                              0xFFEFF9F6,
                            ),
                            borderRadius:
                                BorderRadius.circular(
                              8,
                            ),
                          ),
                          child: Text(
                            '$quantity tablets',
                            style:
                                const TextStyle(
                              fontSize: 11,
                              color:
                                  Color(0xFF0F766E),
                              fontWeight:
                                  FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 8,
                        ),
                        if (createdAt
                            .isNotEmpty)
                          Text(
                            createdAt,
                            style:
                                const TextStyle(
                              fontSize: 11,
                              color:
                                  Color(0xFF94A3B8),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color:
                    Color(0xFF9AA8A5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailsCard
    extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _DetailsCard({
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(17),
      decoration:
          BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style:
                const TextStyle(
              fontSize: 14,
              fontWeight:
                  FontWeight.w800,
              color:
                  Color(0xFF17332F),
            ),
          ),
          const SizedBox(
            height: 12,
          ),
          ...children,
        ],
      ),
    );
  }
}

class _DetailRow
    extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          const EdgeInsets.only(
        bottom: 9,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 95,
            child: Text(
              label,
              style:
                  const TextStyle(
                fontSize: 13,
                color:
                    Color(0xFF64748B),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style:
                  const TextStyle(
                fontSize: 13,
                fontWeight:
                    FontWeight.w600,
                color:
                    Color(0xFF17201F),
              ),
            ),
          ),
        ],
      ),
    );
  }
}