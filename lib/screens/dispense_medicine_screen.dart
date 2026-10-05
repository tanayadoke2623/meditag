import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/medicine.dart';

class DispenseMedicineScreen extends StatefulWidget {
  final Medicine medicine;

  const DispenseMedicineScreen({
    super.key,
    required this.medicine,
  });

  @override
  State<DispenseMedicineScreen> createState() =>
      _DispenseMedicineScreenState();
}

class _DispenseMedicineScreenState
    extends State<DispenseMedicineScreen> {
  final SupabaseClient _supabase =
      Supabase.instance.client;

  final TextEditingController quantityController =
      TextEditingController(text: '5');

  final TextEditingController doseController =
      TextEditingController(text: '1 tablet');

  final TextEditingController frequencyController =
      TextEditingController(text: 'Twice daily');

  final TextEditingController durationController =
      TextEditingController(text: '3 days');

  final TextEditingController instructionsController =
      TextEditingController();

  String timing = 'After food';

  String? qrData;

  bool generating = false;
  bool saving = false;

  @override
  void dispose() {
    quantityController.dispose();
    doseController.dispose();
    frequencyController.dispose();
    durationController.dispose();
    instructionsController.dispose();
    super.dispose();
  }

  int? _getQuantity() {
    final value =
        int.tryParse(quantityController.text.trim());

    if (value == null || value <= 0) {
      return null;
    }

    return value;
  }

  String _buildQrText() {
    final medicine = widget.medicine;

    final quantity =
        quantityController.text.trim();

    final dose =
        doseController.text.trim();

    final frequency =
        frequencyController.text.trim();

    final duration =
        durationController.text.trim();

    final pharmacyInstructions =
        instructionsController.text.trim();

    return '''
MEDItag

Medicine: ${medicine.medicineName}
Generic: ${medicine.genericName}
Strength: ${medicine.strength}
Form: ${medicine.dosageForm}
Manufacturer: ${medicine.manufacturer}

Batch: ${medicine.batchNumber}
MFG: ${medicine.manufacturingDate}
EXP: ${medicine.expiryDate}
MRP: ${medicine.mrp.isEmpty ? 'Not available' : 'Rs ${medicine.mrp}'}

Quantity: $quantity tablets

Dose: $dose
Timing: $timing
Frequency: $frequency
Duration: $duration

Pharmacy Instructions:
${pharmacyInstructions.isEmpty ? 'None' : pharmacyInstructions}
'''.trim();
  }

  Future<void> _generateQr() async {
    final quantity = _getQuantity();

    if (quantity == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please enter a valid quantity.',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (!widget.medicine.isVerified) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Only verified medicines can be dispensed.',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      generating = true;
    });

    try {
      final generatedData = _buildQrText();

      setState(() {
        qrData = generatedData;
        generating = false;
      });

      await _saveDispensingAndQr(
        quantity: quantity,
        qrText: generatedData,
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        generating = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Could not generate QR: $e',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _saveDispensingAndQr({
    required int quantity,
    required String qrText,
  }) async {
    if (saving) return;

    setState(() {
      saving = true;
    });

    try {
      final medicineId = widget.medicine.id;

      /*
       * Find the medicine batch.
       *
       * We use the first batch belonging to the
       * verified medicine for this demo.
       */
      final batchResponse = await _supabase
          .from('medicine_batches')
          .select('id')
          .eq('medicine_id', medicineId)
          .eq('is_verified', true)
          .limit(1)
          .maybeSingle();

      if (batchResponse == null) {
        throw Exception(
          'No verified batch found for this medicine.',
        );
      }

      final batchId =
          batchResponse['id']?.toString();

      if (batchId == null || batchId.isEmpty) {
        throw Exception(
          'The verified batch ID is missing.',
        );
      }

      /*
       * 1. Create dispensing record.
       */
      final dispensingResponse = await _supabase
          .from('dispensing_records')
          .insert({
            'medicine_id': medicineId,
            'batch_id': batchId,
            'quantity_dispensed': quantity,
            'pharmacy_instructions':
                _buildPharmacyInstructions(),
            'dispensing_date':
                DateTime.now().toIso8601String(),
          })
          .select('id')
          .single();

      final dispensingId =
          dispensingResponse['id']?.toString();

      if (dispensingId == null ||
          dispensingId.isEmpty) {
        throw Exception(
          'Could not create dispensing record.',
        );
      }

      /*
       * 2. Create QR label history.
       *
       * qr_data contains the actual self-contained
       * QR information.
       *
       * qr_token is only a database identifier.
       * The customer QR does NOT depend on it.
       */
      final qrToken =
          'MEDI-${DateTime.now().millisecondsSinceEpoch}';

      await _supabase
          .from('qr_labels')
          .insert({
        'dispensing_id': dispensingId,
        'qr_token': qrToken,
        'qr_data': qrText,
        'is_active': true,
      });

      if (!mounted) return;

      setState(() {
        saving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Dispensing record and QR label saved successfully.',
          ),
          backgroundColor: Color(0xFF0F766E),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        saving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'QR generated, but database save failed: $e',
          ),
          backgroundColor: Colors.orange.shade800,
        ),
      );
    }
  }

  String _buildPharmacyInstructions() {
    final parts = <String>[];

    final dose =
        doseController.text.trim();

    final frequency =
        frequencyController.text.trim();

    final duration =
        durationController.text.trim();

    final additional =
        instructionsController.text.trim();

    if (dose.isNotEmpty) {
      parts.add('Dose: $dose');
    }

    if (timing.isNotEmpty) {
      parts.add('Timing: $timing');
    }

    if (frequency.isNotEmpty) {
      parts.add('Frequency: $frequency');
    }

    if (duration.isNotEmpty) {
      parts.add('Duration: $duration');
    }

    if (additional.isNotEmpty) {
      parts.add('Additional: $additional');
    }

    return parts.join('\n');
  }

  Future<void> _printQr() async {
    if (qrData == null || qrData!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Generate a QR first.',
          ),
        ),
      );
      return;
    }

    /*
     * For now the demo uses the browser's normal
     * print dialog.
     *
     * We intentionally keep this simple for the
     * Chrome-based hackathon demo.
     */
    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Print QR Label',
          ),
          content: const Text(
            'The MediTag QR is ready. You can use the browser print option to print the label.',
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
    final medicine = widget.medicine;

    return Scaffold(
      backgroundColor: const Color(0xFFF7FAF9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: const Color(0xFF17332F),
        title: const Text(
          'Create MediTag',
          style: TextStyle(
            fontSize: 21,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            _buildMedicineHeader(medicine),

            const SizedBox(height: 20),

            _buildSectionTitle(
              'Dispensing details',
              'Enter the quantity being given to the customer.',
            ),

            const SizedBox(height: 12),

            _buildTextField(
              controller: quantityController,
              label: 'Quantity',
              hint: 'Example: 5',
              icon: Icons.medication_rounded,
              keyboardType: TextInputType.number,
            ),

            const SizedBox(height: 20),

            _buildSectionTitle(
              'Pharmacy instructions',
              'Enter the instructions that should stay with this dispensed medicine.',
            ),

            const SizedBox(height: 12),

            _buildTextField(
              controller: doseController,
              label: 'Dose',
              hint: 'Example: 1 tablet',
              icon: Icons.medication_liquid_rounded,
            ),

            const SizedBox(height: 12),

            _buildTimingDropdown(),

            const SizedBox(height: 12),

            _buildTextField(
              controller: frequencyController,
              label: 'Frequency',
              hint: 'Example: Twice daily',
              icon: Icons.repeat_rounded,
            ),

            const SizedBox(height: 12),

            _buildTextField(
              controller: durationController,
              label: 'Duration',
              hint: 'Example: 3 days',
              icon: Icons.calendar_month_rounded,
            ),

            const SizedBox(height: 12),

            _buildTextField(
              controller: instructionsController,
              label: 'Additional instructions',
              hint:
                  'Example: Take with sufficient water',
              icon: Icons.notes_rounded,
              maxLines: 4,
            ),

            const SizedBox(height: 12),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF9F6),
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Row(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    color: Color(0xFF0F766E),
                    size: 20,
                  ),
                  SizedBox(width: 9),
                  Expanded(
                    child: Text(
                      'Pharmacy instructions are stored separately from the verified medicine information.',
                      style: TextStyle(
                        fontSize: 12,
                        height: 1.45,
                        color: Color(0xFF315E58),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed:
                    generating || saving
                        ? null
                        : _generateQr,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      const Color(0xFF0F766E),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor:
                      Colors.grey.shade300,
                  padding:
                      const EdgeInsets.symmetric(
                    vertical: 17,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(16),
                  ),
                ),
                icon: generating || saving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child:
                            CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(
                        Icons.qr_code_2_rounded,
                      ),
                label: Text(
                  saving
                      ? 'Saving QR...'
                      : generating
                          ? 'Generating...'
                          : 'Generate MediTag QR',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),

            if (qrData != null) ...[
              const SizedBox(height: 28),
              _buildQrPreview(),
            ],

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildMedicineHeader(Medicine medicine) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFF0F766E)
              .withOpacity(0.12),
        ),
      ),
      child: Row(
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
              Icons.verified_rounded,
              color: Color(0xFF0F766E),
              size: 31,
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
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  medicine.genericName.isEmpty
                      ? 'Verified medicine'
                      : medicine.genericName,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 7),
                const Row(
                  children: [
                    Icon(
                      Icons.lock_rounded,
                      size: 14,
                      color: Color(0xFF0F766E),
                    ),
                    SizedBox(width: 5),
                    Text(
                      'Verified & locked',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F766E),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(
    String title,
    String subtitle,
  ) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w800,
            color: Color(0xFF17201F),
          ),
        ),
        const SizedBox(height: 5),
        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 12.5,
            color: Color(0xFF64748B),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Padding(
          padding: const EdgeInsets.only(
            left: 4,
            right: 4,
          ),
          child: Icon(
            icon,
            color: const Color(0xFF0F766E),
          ),
        ),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: Colors.black.withOpacity(0.05),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: Color(0xFF0F766E),
            width: 1.5,
          ),
        ),
      ),
    );
  }

  Widget _buildTimingDropdown() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.black.withOpacity(0.05),
        ),
      ),
      child: DropdownButtonFormField<String>(
        initialValue: timing,
        decoration: const InputDecoration(
          labelText: 'Timing',
          prefixIcon: Icon(
            Icons.schedule_rounded,
            color: Color(0xFF0F766E),
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 5,
          ),
        ),
        items: const [
          DropdownMenuItem(
            value: 'Before food',
            child: Text('Before food'),
          ),
          DropdownMenuItem(
            value: 'After food',
            child: Text('After food'),
          ),
          DropdownMenuItem(
            value: 'With food',
            child: Text('With food'),
          ),
          DropdownMenuItem(
            value: 'Any time',
            child: Text('Any time'),
          ),
        ],
        onChanged: (value) {
          if (value == null) return;

          setState(() {
            timing = value;
          });
        },
      ),
    );
  }

  Widget _buildQrPreview() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'MediTag QR Ready',
            style: TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.w800,
              color: Color(0xFF17201F),
            ),
          ),

          const SizedBox(height: 7),

          const Text(
            'This QR contains the medicine information directly.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12.5,
              color: Color(0xFF64748B),
            ),
          ),

          const SizedBox(height: 20),

          QrImageView(
            data: qrData!,
            version: QrVersions.auto,
            size: 250,
            backgroundColor: Colors.white,
            errorCorrectionLevel:
                QrErrorCorrectLevel.M,
          ),

          const SizedBox(height: 18),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF7FAF9),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              '${widget.medicine.medicineName} • ${quantityController.text.trim()} tablets',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFF17332F),
              ),
            ),
          ),

          const SizedBox(height: 15),

          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: saving ? null : _printQr,
              style: OutlinedButton.styleFrom(
                foregroundColor:
                    const Color(0xFF0F766E),
                padding:
                    const EdgeInsets.symmetric(
                  vertical: 15,
                ),
                side: const BorderSide(
                  color: Color(0xFF0F766E),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(15),
                ),
              ),
              icon: const Icon(
                Icons.print_rounded,
              ),
              label: const Text(
                'Print QR Label',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          const Row(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.wifi_off_rounded,
                size: 18,
                color: Color(0xFF0F766E),
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'The printed QR can be scanned by a normal QR scanner. MediTag or internet access is not required to read its embedded text.',
                  style: TextStyle(
                    fontSize: 11.5,
                    height: 1.45,
                    color: Color(0xFF64748B),
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