import 'package:flutter/material.dart';

import '../models/medicine.dart';
import '../services/medicine_storage_service.dart';

class SearchMedicineScreen extends StatefulWidget {
  const SearchMedicineScreen({super.key});

  @override
  State<SearchMedicineScreen> createState() => _SearchMedicineScreenState();
}

class _SearchMedicineScreenState extends State<SearchMedicineScreen> {
  final TextEditingController searchController = TextEditingController();

  List<Medicine> medicines = [];
  List<Medicine> filteredMedicines = [];

  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadMedicines();
    searchController.addListener(_search);
  }

  @override
  void dispose() {
    searchController.removeListener(_search);
    searchController.dispose();
    super.dispose();
  }

  Future<void> _loadMedicines() async {
    setState(() {
      loading = true;
    });

    try {
      final result = await MedicineStorageService.getMedicines();

      if (!mounted) return;

      setState(() {
        medicines = result;
        filteredMedicines = result;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not load medicines: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _search() {
    final query = searchController.text.trim().toLowerCase();

    setState(() {
      if (query.isEmpty) {
        filteredMedicines = medicines;
        return;
      }

      filteredMedicines = medicines.where((medicine) {
        return medicine.medicineName.toLowerCase().contains(query) ||
            medicine.genericName.toLowerCase().contains(query) ||
            medicine.manufacturer.toLowerCase().contains(query) ||
            medicine.batchNumber.toLowerCase().contains(query) ||
            medicine.strength.toLowerCase().contains(query) ||
            medicine.barcodeData.toLowerCase().contains(query) ||
            medicine.originalQrData.toLowerCase().contains(query);
      }).toList();
    });
  }

  void _showMedicineDetails(Medicine medicine) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.78,
          decoration: const BoxDecoration(
            color: Color(0xFFF7FAF9),
            borderRadius: BorderRadius.vertical(
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
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 20),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(
                      20,
                      0,
                      20,
                      30,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 58,
                              height: 58,
                              decoration: BoxDecoration(
                                color: const Color(0xFF0F766E)
                                    .withOpacity(0.10),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(
                                Icons.medication_rounded,
                                color: Color(0xFF0F766E),
                                size: 30,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    medicine.medicineName.isEmpty
                                        ? 'Unnamed medicine'
                                        : medicine.medicineName,
                                    style: const TextStyle(
                                      fontSize: 23,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF17201F),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    medicine.genericName.isEmpty
                                        ? 'Generic name not available'
                                        : medicine.genericName,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFF64748B),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        _InfoCard(
                          title: 'Verification',
                          child: Row(
                            children: [
                              Icon(
                                medicine.isVerified
                                    ? Icons.verified_rounded
                                    : Icons.warning_amber_rounded,
                                color: medicine.isVerified
                                    ? const Color(0xFF0F9D8A)
                                    : Colors.orange,
                                size: 25,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                medicine.isVerified
                                    ? 'Verified & locked'
                                    : 'Needs verification',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: medicine.isVerified
                                      ? const Color(0xFF087F70)
                                      : Colors.orange.shade800,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 14),

                        _InfoCard(
                          title: 'Medicine information',
                          child: Column(
                            children: [
                              _InfoRow(
                                label: 'Strength',
                                value: medicine.strength,
                              ),
                              _InfoRow(
                                label: 'Dosage form',
                                value: medicine.dosageForm,
                              ),
                              _InfoRow(
                                label: 'Manufacturer',
                                value: medicine.manufacturer,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 14),

                        _InfoCard(
                          title: 'Batch information',
                          child: Column(
                            children: [
                              _InfoRow(
                                label: 'Batch',
                                value: medicine.batchNumber,
                              ),
                              _InfoRow(
                                label: 'Manufacturing',
                                value: medicine.manufacturingDate,
                              ),
                              _InfoRow(
                                label: 'Expiry',
                                value: medicine.expiryDate,
                              ),
                              _InfoRow(
                                label: 'MRP',
                                value: medicine.mrp.isEmpty
                                    ? ''
                                    : '₹ ${medicine.mrp}',
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 14),

                        if (medicine.barcodeData.isNotEmpty)
                          _InfoCard(
                            title: 'Barcode',
                            child: SelectableText(
                              medicine.barcodeData,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),

                        if (medicine.originalQrData.isNotEmpty) ...[
                          const SizedBox(height: 14),
                          _InfoCard(
                            title: 'Original QR data',
                            child: SelectableText(
                              medicine.originalQrData,
                              style: const TextStyle(
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
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
      backgroundColor: const Color(0xFFF7FAF9),

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: const Color(0xFF17332F),
        title: const Text(
          'Search Medicine',
          style: TextStyle(
            fontSize: 21,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      body: RefreshIndicator(
        onRefresh: _loadMedicines,
        child: loading
            ? const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF0F766E),
                ),
              )
            : ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 14,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: searchController,
                      decoration: InputDecoration(
                        hintText:
                            'Search medicine, batch, barcode...',
                        prefixIcon: const Icon(
                          Icons.search_rounded,
                          color: Color(0xFF0F766E),
                        ),
                        suffixIcon: searchController.text.isNotEmpty
                            ? IconButton(
                                onPressed: () {
                                  searchController.clear();
                                },
                                icon: const Icon(Icons.close),
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding:
                            const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 18,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 22),

                  Row(
                    children: [
                      const Text(
                        'Medicines',
                        style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${filteredMedicines.length} found',
                        style: const TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  if (filteredMedicines.isEmpty)
                    _EmptySearchState(
                      query: searchController.text,
                    )
                  else
                    ...filteredMedicines.map(
                      (medicine) => Padding(
                        padding:
                            const EdgeInsets.only(bottom: 12),
                        child: _MedicineSearchCard(
                          medicine: medicine,
                          onTap: () =>
                              _showMedicineDetails(medicine),
                        ),
                      ),
                    ),

                  const SizedBox(height: 30),
                ],
              ),
      ),
    );
  }
}

class _MedicineSearchCard extends StatelessWidget {
  final Medicine medicine;
  final VoidCallback onTap;

  const _MedicineSearchCard({
    required this.medicine,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(17),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: const Color(0xFF0F766E).withOpacity(0.10),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Icon(
                  Icons.medication_outlined,
                  color: Color(0xFF0F766E),
                  size: 28,
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      medicine.medicineName.isEmpty
                          ? 'Unnamed medicine'
                          : medicine.medicineName,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      [
                        if (medicine.genericName.isNotEmpty)
                          medicine.genericName,
                        if (medicine.strength.isNotEmpty)
                          medicine.strength,
                      ].join(' • '),
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF64748B),
                      ),
                    ),

                    const SizedBox(height: 8),

                    Row(
                      children: [
                        Icon(
                          medicine.isVerified
                              ? Icons.verified_rounded
                              : Icons.warning_amber_rounded,
                          size: 16,
                          color: medicine.isVerified
                              ? const Color(0xFF0F9D8A)
                              : Colors.orange,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          medicine.isVerified
                              ? 'Verified'
                              : 'Needs verification',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: medicine.isVerified
                                ? const Color(0xFF087F70)
                                : Colors.orange.shade800,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const Icon(
                Icons.chevron_right_rounded,
                color: Color(0xFF9AA8A5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _InfoCard({
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: Color(0xFF17332F),
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    if (value.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 115,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF64748B),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptySearchState extends StatelessWidget {
  final String query;

  const _EmptySearchState({
    required this.query,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 50,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: const Color(0xFF0F766E).withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.search_off_rounded,
              size: 36,
              color: Color(0xFF0F766E),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            query.isEmpty
                ? 'No medicines found'
                : 'No matching medicine',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            query.isEmpty
                ? 'Add a medicine first and it will appear here.'
                : 'Try another medicine name, batch number or barcode.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }
}