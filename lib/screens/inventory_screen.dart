import 'package:flutter/material.dart';

import '../models/medicine.dart';
import '../services/medicine_storage_service.dart';
import 'dispense_medicine_screen.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  final TextEditingController _searchController = TextEditingController();

  List<Medicine> _medicines = [];
  List<Medicine> _filteredMedicines = [];

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMedicines();
    _searchController.addListener(_filterMedicines);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadMedicines() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final medicines = await MedicineStorageService.getMedicines();

      if (!mounted) return;

      setState(() {
        _medicines = medicines;
        _filteredMedicines = medicines;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not load medicines: $e'),
        ),
      );
    }
  }

  void _filterMedicines() {
    final query = _searchController.text.trim().toLowerCase();

    setState(() {
      if (query.isEmpty) {
        _filteredMedicines = List.from(_medicines);
      } else {
        _filteredMedicines = _medicines.where((medicine) {
          return medicine.medicineName.toLowerCase().contains(query) ||
              medicine.genericName.toLowerCase().contains(query) ||
              medicine.strength.toLowerCase().contains(query) ||
              medicine.manufacturer.toLowerCase().contains(query) ||
              medicine.batchNumber.toLowerCase().contains(query) ||
              medicine.barcodeData.toLowerCase().contains(query) ||
              medicine.originalQrData.toLowerCase().contains(query);
        }).toList();
      }
    });
  }

  Future<void> _deleteMedicine(Medicine medicine) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete medicine?'),
          content: Text(
            'This will remove ${medicine.medicineName} from the inventory.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) return;

    try {
      await MedicineStorageService.deleteMedicine(medicine.id);

      await _loadMedicines();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Medicine deleted.'),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not delete medicine: $e'),
        ),
      );
    }
  }

  Future<void> _verifyMedicine(Medicine medicine) async {
    final verified = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(
                Icons.verified_rounded,
                color: Color(0xFF0F9D8A),
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text('Verify Medicine'),
              ),
            ],
          ),
          content: const Text(
            'After verification, the official medicine information is treated as locked. '
            'The pharmacist can still add dispensing instructions later, but the official '
            'medicine details should not be changed casually.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF0F9D8A),
              ),
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Verify & Lock'),
            ),
          ],
        );
      },
    );

    if (verified != true) return;

    try {
      await MedicineStorageService.updateMedicine(
        medicine.copyWithVerified(true),
      );

      await _loadMedicines();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Medicine verified and locked successfully.',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Verification failed: $e'),
        ),
      );
    }
  }

  void _openDispenseScreen(Medicine medicine) {
    if (!medicine.isVerified) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please verify and lock this medicine before dispensing.',
          ),
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DispenseMedicineScreen(
          medicine: medicine,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final verifiedCount =
        _medicines.where((medicine) => medicine.isVerified).length;

    final pendingCount =
        _medicines.where((medicine) => !medicine.isVerified).length;

    return Scaffold(
      backgroundColor: const Color(0xFFF1FAF8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Medicine Inventory',
          style: TextStyle(
            color: Color(0xFF173B36),
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(
          color: Color(0xFF173B36),
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: _loadMedicines,
            icon: const Icon(
              Icons.refresh_rounded,
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadMedicines,
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF0F9D8A),
                ),
              )
            : SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _InventorySummary(
                      total: _medicines.length,
                      verified: verifiedCount,
                      pending: pendingCount,
                    ),

                    const SizedBox(height: 18),

                    _SearchBox(
                      controller: _searchController,
                    ),

                    const SizedBox(height: 20),

                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Saved Medicines',
                            style: TextStyle(
                              fontSize: 21,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF173B36),
                            ),
                          ),
                        ),
                        Text(
                          '${_filteredMedicines.length} found',
                          style: const TextStyle(
                            color: Colors.black54,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    if (_filteredMedicines.isEmpty)
                      const _EmptyInventory()
                    else
                      ..._filteredMedicines.map(
                        (medicine) => Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: _MedicineCard(
                            medicine: medicine,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      MedicineDetailsScreen(
                                    medicine: medicine,
                                    onRefresh: _loadMedicines,
                                  ),
                                ),
                              );
                            },
                            onVerify: () => _verifyMedicine(medicine),
                            onDispense: () =>
                                _openDispenseScreen(medicine),
                            onDelete: () =>
                                _deleteMedicine(medicine),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
      ),
    );
  }
}

class _InventorySummary extends StatelessWidget {
  final int total;
  final int verified;
  final int pending;

  const _InventorySummary({
    required this.total,
    required this.verified,
    required this.pending,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF173B36),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Expanded(
            child: _SummaryItem(
              value: '$total',
              label: 'Total',
              icon: Icons.inventory_2_rounded,
            ),
          ),
          Container(
            width: 1,
            height: 45,
            color: Colors.white24,
          ),
          Expanded(
            child: _SummaryItem(
              value: '$verified',
              label: 'Verified',
              icon: Icons.verified_rounded,
            ),
          ),
          Container(
            width: 1,
            height: 45,
            color: Colors.white24,
          ),
          Expanded(
            child: _SummaryItem(
              value: '$pending',
              label: 'Pending',
              icon: Icons.pending_actions_rounded,
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;

  const _SummaryItem({
    required this.value,
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          icon,
          color: Colors.white,
          size: 22,
        ),
        const SizedBox(height: 5),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class _SearchBox extends StatelessWidget {
  final TextEditingController controller;

  const _SearchBox({
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: 'Search medicine, batch, barcode...',
        prefixIcon: const Icon(
          Icons.search_rounded,
          color: Color(0xFF0F9D8A),
        ),
        suffixIcon: controller.text.isNotEmpty
            ? IconButton(
                onPressed: controller.clear,
                icon: const Icon(Icons.clear_rounded),
              )
            : null,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(17),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(17),
          borderSide: const BorderSide(
            color: Color(0xFFDDEEEA),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(17),
          borderSide: const BorderSide(
            color: Color(0xFF0F9D8A),
            width: 1.5,
          ),
        ),
      ),
    );
  }
}

class _MedicineCard extends StatelessWidget {
  final Medicine medicine;
  final VoidCallback onTap;
  final VoidCallback onVerify;
  final VoidCallback onDispense;
  final VoidCallback onDelete;

  const _MedicineCard({
    required this.medicine,
    required this.onTap,
    required this.onVerify,
    required this.onDispense,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(21),
        border: Border.all(
          color: const Color(0xFFDDEEEA),
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(21),
        child: Padding(
          padding: const EdgeInsets.all(17),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE5F7F3),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Icon(
                      Icons.medication_rounded,
                      color: Color(0xFF0F9D8A),
                      size: 29,
                    ),
                  ),
                  const SizedBox(width: 13),
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
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF173B36),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${medicine.genericName} • ${medicine.strength}',
                          style: const TextStyle(
                            color: Colors.black54,
                          ),
                        ),
                        if (medicine.manufacturer.isNotEmpty) ...[
                          const SizedBox(height: 3),
                          Text(
                            medicine.manufacturer,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black45,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  _StatusBadge(
                    verified: medicine.isVerified,
                  ),
                ],
              ),

              const SizedBox(height: 15),

              Wrap(
                spacing: 7,
                runSpacing: 7,
                children: [
                  if (medicine.source.isNotEmpty)
                    _SmallTag(
                      icon: medicine.source.toLowerCase() == 'qr'
                          ? Icons.qr_code_2_rounded
                          : medicine.source.toLowerCase() ==
                                  'barcode'
                              ? Icons.qr_code_scanner_rounded
                              : Icons.photo_camera_rounded,
                      text: medicine.source,
                    ),
                  if (medicine.batchNumber.isNotEmpty)
                    _SmallTag(
                      icon: Icons.inventory_2_outlined,
                      text: 'Batch ${medicine.batchNumber}',
                    ),
                  if (medicine.expiryDate.isNotEmpty)
                    _SmallTag(
                      icon: Icons.event_outlined,
                      text: 'EXP ${medicine.expiryDate}',
                    ),
                ],
              ),

              const SizedBox(height: 15),

              if (!medicine.isVerified)
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: OutlinedButton.icon(
                    onPressed: onVerify,
                    icon: const Icon(
                      Icons.verified_outlined,
                      size: 19,
                    ),
                    label: const Text(
                      'Review & Verify Medicine',
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor:
                          const Color(0xFF0F9D8A),
                      side: const BorderSide(
                        color: Color(0xFF0F9D8A),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(13),
                      ),
                    ),
                  ),
                ),

              if (medicine.isVerified)
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: FilledButton.icon(
                    onPressed: onDispense,
                    icon: const Icon(
                      Icons.qr_code_2_rounded,
                    ),
                    label: const Text(
                      'Dispense & Create MediTag QR',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor:
                          const Color(0xFF0F9D8A),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(13),
                      ),
                    ),
                  ),
                ),

              const SizedBox(height: 8),

              Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                children: [
                  TextButton.icon(
                    onPressed: onTap,
                    icon: const Icon(
                      Icons.visibility_outlined,
                      size: 18,
                    ),
                    label: const Text('View details'),
                  ),
                  IconButton(
                    tooltip: 'Delete',
                    onPressed: onDelete,
                    icon: const Icon(
                      Icons.delete_outline_rounded,
                      color: Colors.redAccent,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final bool verified;

  const _StatusBadge({
    required this.verified,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: verified
            ? const Color(0xFFE5F7F3)
            : const Color(0xFFFFF4DD),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            verified
                ? Icons.verified_rounded
                : Icons.warning_amber_rounded,
            size: 15,
            color: verified
                ? const Color(0xFF0F9D8A)
                : const Color(0xFFB87900),
          ),
          const SizedBox(width: 4),
          Text(
            verified ? 'Verified' : 'Needs verification',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: verified
                  ? const Color(0xFF0F9D8A)
                  : const Color(0xFFB87900),
            ),
          ),
        ],
      ),
    );
  }
}

class _SmallTag extends StatelessWidget {
  final IconData icon;
  final String text;

  const _SmallTag({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F8F7),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: Colors.black54,
          ),
          const SizedBox(width: 5),
          Text(
            text,
            style: const TextStyle(
              fontSize: 11,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyInventory extends StatelessWidget {
  const _EmptyInventory();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 25,
        vertical: 45,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFFDDEEEA),
        ),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 58,
            color: Color(0xFF0F9D8A),
          ),
          SizedBox(height: 15),
          Text(
            'No medicines found',
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
              color: Color(0xFF173B36),
            ),
          ),
          SizedBox(height: 7),
          Text(
            'Scan or add a medicine to see it here.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}

class MedicineDetailsScreen extends StatelessWidget {
  final Medicine medicine;
  final Future<void> Function() onRefresh;

  const MedicineDetailsScreen({
    super.key,
    required this.medicine,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1FAF8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Medicine Details',
          style: TextStyle(
            color: Color(0xFF173B36),
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(
          color: Color(0xFF173B36),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
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
                      color: const Color(0xFFE5F7F3),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.medication_rounded,
                      size: 38,
                      color: Color(0xFF0F9D8A),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    medicine.medicineName,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF173B36),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '${medicine.genericName} • ${medicine.strength}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _StatusBadge(
                    verified: medicine.isVerified,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            const Text(
              'Official Medicine Information',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
                color: Color(0xFF173B36),
              ),
            ),

            const SizedBox(height: 10),

            _DetailsSection(
              children: [
                _DetailItem(
                  label: 'Medicine',
                  value: medicine.medicineName,
                ),
                _DetailItem(
                  label: 'Generic',
                  value: medicine.genericName,
                ),
                _DetailItem(
                  label: 'Strength',
                  value: medicine.strength,
                ),
                _DetailItem(
                  label: 'Dosage form',
                  value: medicine.dosageForm,
                ),
                _DetailItem(
                  label: 'Manufacturer',
                  value: medicine.manufacturer,
                ),
              ],
            ),

            const SizedBox(height: 18),

            const Text(
              'Batch Information',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
                color: Color(0xFF173B36),
              ),
            ),

            const SizedBox(height: 10),

            _DetailsSection(
              children: [
                _DetailItem(
                  label: 'Batch',
                  value: medicine.batchNumber,
                ),
                _DetailItem(
                  label: 'Manufacturing date',
                  value: medicine.manufacturingDate,
                ),
                _DetailItem(
                  label: 'Expiry date',
                  value: medicine.expiryDate,
                ),
                _DetailItem(
                  label: 'MRP',
                  value: medicine.mrp.isEmpty
                      ? ''
                      : 'Rs ${medicine.mrp}',
                ),
              ],
            ),

            const SizedBox(height: 20),

            if (medicine.isVerified)
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            DispenseMedicineScreen(
                          medicine: medicine,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons.qr_code_2_rounded,
                  ),
                  label: const Text(
                    'Dispense & Create MediTag QR',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor:
                        const Color(0xFF0F9D8A),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
              )
            else
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF4DD),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.lock_outline_rounded,
                      color: Color(0xFFB87900),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Verify this medicine before creating a MediTag QR.',
                        style: TextStyle(
                          color: Color(0xFF805700),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _DetailsSection extends StatelessWidget {
  final List<Widget> children;

  const _DetailsSection({
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(
          color: const Color(0xFFDDEEEA),
        ),
      ),
      child: Column(
        children: children,
      ),
    );
  }
}

class _DetailItem extends StatelessWidget {
  final String label;
  final String value;

  const _DetailItem({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 145,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.black54,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? 'Not available' : value,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF173B36),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

extension _MedicineVerification on Medicine {
  Medicine copyWithVerified(bool verified) {
    return Medicine(
      id: id,
      medicineName: medicineName,
      genericName: genericName,
      strength: strength,
      dosageForm: dosageForm,
      manufacturer: manufacturer,
      batchNumber: batchNumber,
      manufacturingDate: manufacturingDate,
      expiryDate: expiryDate,
      mrp: mrp,
      originalQrData: originalQrData,
      barcodeData: barcodeData,
      photoData: photoData,
      source: source,
      isVerified: verified,
      createdAt: createdAt,
    );
  }
}