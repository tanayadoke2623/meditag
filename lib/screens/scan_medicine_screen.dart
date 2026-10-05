import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../models/medicine.dart';
import '../services/medicine_storage_service.dart';

class ScanMedicineScreen extends StatefulWidget {
  const ScanMedicineScreen({super.key});

  @override
  State<ScanMedicineScreen> createState() => _ScanMedicineScreenState();
}

class _ScanMedicineScreenState extends State<ScanMedicineScreen> {
  final ImagePicker _picker = ImagePicker();

  bool _busy = false;

  Future<void> _openScanner() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const BarcodeScannerScreen(),
      ),
    );
  }

  Future<void> _pickMedicinePhoto() async {
    try {
      final XFile? file = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 90,
      );

      if (file == null) return;

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Medicine photo selected. OCR can be connected here next.',
          ),
        ),
      );
    } catch (e) {
      _showError('Unable to select image: $e');
    }
  }

  void _showError(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade700,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1FAF8),
      appBar: AppBar(
        title: const Text(
          'Scan Medicine',
          style: TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF123B36),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Add Medicine',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: Color(0xFF123B36),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Scan the original medicine QR or barcode. '
              'If the QR contains medicine information directly, '
              'MediTag will read it and save it to your inventory.',
              style: TextStyle(
                fontSize: 15,
                height: 1.5,
                color: Color(0xFF58716C),
              ),
            ),
            const SizedBox(height: 24),

            // QR SCANNER CARD
            _ActionCard(
              icon: Icons.qr_code_scanner_rounded,
              title: 'Scan QR / Barcode',
              subtitle:
                  'Read medicine information directly from the original package.',
              buttonText: 'Scan Now',
              onPressed: _busy ? null : _openScanner,
            ),

            const SizedBox(height: 16),

            // PHOTO CARD
            _ActionCard(
              icon: Icons.photo_camera_back_rounded,
              title: 'Use Medicine Photo',
              subtitle:
                  'Use a package photo when the QR does not contain direct information.',
              buttonText: 'Choose Photo',
              onPressed: _busy ? null : _pickMedicinePhoto,
            ),

            const SizedBox(height: 28),

            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: const Color(0xFFD7ECE8),
                ),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    color: Color(0xFF159A89),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Direct QR information is saved as medicine data. '
                      'You can later generate a new self-contained MediTag QR '
                      'using the same information.',
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.45,
                        color: Color(0xFF47635E),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String buttonText;
  final VoidCallback? onPressed;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.buttonText,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 54,
            width: 54,
            decoration: BoxDecoration(
              color: const Color(0xFFE2F6F2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              icon,
              size: 28,
              color: const Color(0xFF159A89),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Color(0xFF123B36),
            ),
          ),
          const SizedBox(height: 7),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 14,
              height: 1.45,
              color: Color(0xFF66817B),
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onPressed,
              icon: Icon(
                icon,
                size: 20,
              ),
              label: Text(buttonText),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF159A89),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  vertical: 15,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// BARCODE / QR SCANNER
// ============================================================

class BarcodeScannerScreen extends StatefulWidget {
  const BarcodeScannerScreen({super.key});

  @override
  State<BarcodeScannerScreen> createState() =>
      _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState
    extends State<BarcodeScannerScreen> {
  bool _alreadyScanned = false;

  void _handleBarcode(BarcodeCapture capture) {
    if (_alreadyScanned) return;

    if (capture.barcodes.isEmpty) return;

    final Barcode barcode = capture.barcodes.first;

    final String? rawValue = barcode.rawValue;

    if (rawValue == null || rawValue.trim().isEmpty) {
      return;
    }

    _alreadyScanned = true;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ScannedCodeResultScreen(
          scannedData: rawValue.trim(),
          format: barcode.format.name,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Scan Medicine QR'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          MobileScanner(
            onDetect: _handleBarcode,
          ),

          Center(
            child: Container(
              width: 270,
              height: 270,
              decoration: BoxDecoration(
                border: Border.all(
                  color: const Color(0xFF52D5C3),
                  width: 3,
                ),
                borderRadius: BorderRadius.circular(22),
              ),
            ),
          ),

          Positioned(
            left: 24,
            right: 24,
            bottom: 40,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.72),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Text(
                'Place the medicine QR or barcode inside the box.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// SCANNED RESULT
// ============================================================

class ScannedCodeResultScreen extends StatefulWidget {
  final String scannedData;
  final String format;

  const ScannedCodeResultScreen({
    super.key,
    required this.scannedData,
    required this.format,
  });

  @override
  State<ScannedCodeResultScreen> createState() =>
      _ScannedCodeResultScreenState();
}

class _ScannedCodeResultScreenState
    extends State<ScannedCodeResultScreen> {
  bool _saving = false;

  late Map<String, String> _details;

  @override
  void initState() {
    super.initState();

    _details = _parseMedicineData(widget.scannedData);
  }

  // ==========================================================
  // MAIN QR PARSER
  // ==========================================================

  Map<String, String> _parseMedicineData(String raw) {
    final Map<String, String> data = {};

    final String text = raw.trim();

    // --------------------------------------------------------
    // CASE 1: JSON QR
    // --------------------------------------------------------

    try {
      final dynamic decoded = jsonDecode(text);

      if (decoded is Map) {
        decoded.forEach((key, value) {
          if (value != null) {
            data[key.toString().toLowerCase()] =
                value.toString().trim();
          }
        });

        return _normaliseFields(data);
      }
    } catch (_) {
      // Not JSON. Continue.
    }

    // --------------------------------------------------------
    // CASE 2: KEY : VALUE
    // CASE 3: KEY = VALUE
    // CASE 4: KEY - VALUE
    // --------------------------------------------------------

    final List<String> lines = text.split(
      RegExp(r'[\r\n]+'),
    );

    for (final line in lines) {
      String current = line.trim();

      if (current.isEmpty) continue;

      final Match? match = RegExp(
        r'^([A-Za-z][A-Za-z0-9 _\/-]{1,40})\s*[:=]\s*(.+)$',
      ).firstMatch(current);

      if (match != null) {
        final String key = match.group(1)!
            .trim()
            .toLowerCase();

        final String value = match.group(2)!
            .trim();

        data[key] = value;
      }
    }

    // --------------------------------------------------------
    // Try common GS1-like labels
    // --------------------------------------------------------

    final String upper = text.toUpperCase();

    if (!data.containsKey('batch') &&
        !data.containsKey('batch number')) {
      final Match? batch = RegExp(
        r'(?:LOT|BATCH)\s*[:#-]?\s*([A-Z0-9./_-]+)',
        caseSensitive: false,
      ).firstMatch(text);

      if (batch != null) {
        data['batch'] = batch.group(1)!.trim();
      }
    }

    if (!data.containsKey('expiry') &&
        !data.containsKey('expiry date')) {
      final Match? expiry = RegExp(
        r'(?:EXP|EXPIRY)\s*[:#-]?\s*([A-Z0-9./_-]+)',
        caseSensitive: false,
      ).firstMatch(text);

      if (expiry != null) {
        data['expiry'] = expiry.group(1)!.trim();
      }
    }

    if (!data.containsKey('mrp')) {
      final Match? mrp = RegExp(
        r'MRP\s*[:₹Rs.\-]*\s*([0-9]+(?:\.[0-9]+)?)',
        caseSensitive: false,
      ).firstMatch(text);

      if (mrp != null) {
        data['mrp'] = mrp.group(1)!.trim();
      }
    }

    // --------------------------------------------------------
    // If QR contains a simple medicine sentence
    // --------------------------------------------------------

    if (data.isEmpty) {
      data['raw information'] = text;
    }

    // Avoid unused variable warning.
    if (upper.isEmpty) {
      data['raw information'] = text;
    }

    return _normaliseFields(data);
  }

  // ==========================================================
  // NORMALISE FIELD NAMES
  // ==========================================================

  Map<String, String> _normaliseFields(
    Map<String, String> input,
  ) {
    final Map<String, String> output = {};

    String findValue(List<String> possibleKeys) {
      for (final key in possibleKeys) {
        final value = input[key.toLowerCase()];

        if (value != null && value.trim().isNotEmpty) {
          return value.trim();
        }
      }

      return '';
    }

    final String medicineName = findValue([
      'medicine',
      'medicine name',
      'name',
      'product',
      'product name',
      'drug',
      'drug name',
    ]);

    final String genericName = findValue([
      'generic',
      'generic name',
      'composition',
      'salt',
      'active ingredient',
    ]);

    final String strength = findValue([
      'strength',
      'dose strength',
      'dosage strength',
    ]);

    final String dosageForm = findValue([
      'form',
      'dosage form',
      'type',
      'medicine type',
    ]);

    final String manufacturer = findValue([
      'manufacturer',
      'company',
      'maker',
      'manufactured by',
    ]);

    final String batch = findValue([
      'batch',
      'batch number',
      'lot',
      'lot number',
    ]);

    final String mfg = findValue([
      'mfg',
      'mfg date',
      'manufacturing date',
      'manufactured',
    ]);

    final String exp = findValue([
      'exp',
      'expiry',
      'expiry date',
      'expiration',
    ]);

    final String mrp = findValue([
      'mrp',
      'price',
      'maximum retail price',
    ]);

    if (medicineName.isNotEmpty) {
      output['medicine'] = medicineName;
    }

    if (genericName.isNotEmpty) {
      output['generic'] = genericName;
    }

    if (strength.isNotEmpty) {
      output['strength'] = strength;
    }

    if (dosageForm.isNotEmpty) {
      output['form'] = dosageForm;
    }

    if (manufacturer.isNotEmpty) {
      output['manufacturer'] = manufacturer;
    }

    if (batch.isNotEmpty) {
      output['batch'] = batch;
    }

    if (mfg.isNotEmpty) {
      output['mfg'] = mfg;
    }

    if (exp.isNotEmpty) {
      output['exp'] = exp;
    }

    if (mrp.isNotEmpty) {
      output['mrp'] = mrp;
    }

    // Preserve any other useful values.
    input.forEach((key, value) {
      if (value.trim().isEmpty) return;

      if (!output.containsKey(key)) {
        output[key] = value;
      }
    });

    return output;
  }

  bool get _hasMedicineInformation {
    final String medicine =
        _details['medicine']?.trim() ?? '';

    return medicine.isNotEmpty &&
        _details.length >= 1;
  }

  // ==========================================================
  // SAVE TO INVENTORY
  // ==========================================================

  Future<void> _addToInventory() async {
    if (_saving) return;

    final String medicineName =
        _details['medicine']?.trim() ?? '';

    if (medicineName.isEmpty) {
      _showError(
        'Medicine name was not found in this QR.',
      );
      return;
    }

    setState(() {
      _saving = true;
    });

    try {
      final Medicine medicine = Medicine(
        id: '',
        medicineName: medicineName,
        genericName: _details['generic'] ?? '',
        strength: _details['strength'] ?? '',
        dosageForm: _details['form'] ?? '',
        manufacturer: _details['manufacturer'] ?? '',
        batchNumber: _details['batch'] ?? '',
        manufacturingDate: _details['mfg'] ?? '',
        expiryDate: _details['exp'] ?? '',
        mrp: _details['mrp'] ?? '',

        // IMPORTANT:
        // Save the ORIGINAL QR information.
        originalQrData: widget.scannedData,

        barcodeData: widget.scannedData,

        source: 'direct_qr_scan',

        // Pharmacist can verify this later.
        isVerified: false,
      );

      final Medicine saved =
          await MedicineStorageService.saveMedicine(
        medicine,
      );

      if (!mounted) return;

      setState(() {
        _saving = false;
      });

      await Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => MedicineSavedScreen(
            medicine: saved,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _saving = false;
      });

      _showError(
        'Could not save medicine: $e',
      );
    }
  }

  void _showError(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade700,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool hasData = _hasMedicineInformation;

    return Scaffold(
      backgroundColor: const Color(0xFFF1FAF8),
      appBar: AppBar(
        title: const Text(
          'Medicine Information',
          style: TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF123B36),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // SUCCESS HEADER
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Row(
                children: [
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      color: hasData
                          ? const Color(0xFFE2F6F2)
                          : const Color(0xFFFFF0D9),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      hasData
                          ? Icons.check_circle_rounded
                          : Icons.warning_amber_rounded,
                      color: hasData
                          ? const Color(0xFF159A89)
                          : Colors.orange,
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      hasData
                          ? 'Medicine information found'
                          : 'Information needs verification',
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                        color: hasData
                            ? const Color(0xFF123B36)
                            : Colors.orange.shade900,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            if (hasData)
              _buildMedicineDetails()
            else
              _buildRawInformation(),

            const SizedBox(height: 22),

            if (hasData)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _saving
                      ? null
                      : _addToInventory,
                  icon: _saving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(
                          Icons.inventory_2_rounded,
                        ),
                  label: Text(
                    _saving
                        ? 'Saving...'
                        : 'Add to Inventory',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        const Color(0xFF159A89),
                    foregroundColor: Colors.white,
                    padding:
                        const EdgeInsets.symmetric(
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(15),
                    ),
                  ),
                ),
              ),

            const SizedBox(height: 12),

            if (!hasData)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(
                    Icons.camera_alt_outlined,
                  ),
                  label: const Text(
                    'Use Package Photo Instead',
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor:
                        const Color(0xFF159A89),
                    padding:
                        const EdgeInsets.symmetric(
                      vertical: 15,
                    ),
                    side: const BorderSide(
                      color: Color(0xFF159A89),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(15),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMedicineDetails() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Scanned Details',
            style: TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.w800,
              color: Color(0xFF123B36),
            ),
          ),
          const SizedBox(height: 18),

          _detailRow(
            'Medicine',
            _details['medicine'],
            Icons.medication_rounded,
          ),

          _detailRow(
            'Generic',
            _details['generic'],
            Icons.science_outlined,
          ),

          _detailRow(
            'Strength',
            _details['strength'],
            Icons.bolt_outlined,
          ),

          _detailRow(
            'Form',
            _details['form'],
            Icons.category_outlined,
          ),

          _detailRow(
            'Manufacturer',
            _details['manufacturer'],
            Icons.factory_outlined,
          ),

          _detailRow(
            'Batch',
            _details['batch'],
            Icons.confirmation_number_outlined,
          ),

          _detailRow(
            'Manufacturing Date',
            _details['mfg'],
            Icons.calendar_today_outlined,
          ),

          _detailRow(
            'Expiry Date',
            _details['exp'],
            Icons.event_outlined,
          ),

          _detailRow(
            'MRP',
            _details['mrp'],
            Icons.currency_rupee_rounded,
          ),
        ],
      ),
    );
  }

  Widget _buildRawInformation() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'QR Content',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Color(0xFF123B36),
            ),
          ),
          const SizedBox(height: 14),
          SelectableText(
            widget.scannedData,
            style: const TextStyle(
              fontSize: 14,
              height: 1.5,
              color: Color(0xFF526D67),
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'This QR does not appear to contain enough structured medicine information. '
            'Use the package photo/OCR option instead.',
            style: TextStyle(
              fontSize: 14,
              height: 1.45,
              color: Colors.orange,
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(
    String title,
    String? value,
    IconData icon,
  ) {
    if (value == null || value.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: const Color(0xFFF5FBF9),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 21,
            color: const Color(0xFF159A89),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF78908B),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF183D37),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// SAVED SUCCESS SCREEN
// ============================================================

class MedicineSavedScreen extends StatelessWidget {
  final Medicine medicine;

  const MedicineSavedScreen({
    super.key,
    required this.medicine,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1FAF8),
      appBar: AppBar(
        title: const Text('Added to Inventory'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF123B36),
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: const BoxDecoration(
                  color: Color(0xFFE2F6F2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  size: 55,
                  color: Color(0xFF159A89),
                ),
              ),
              const SizedBox(height: 22),
              const Text(
                'Medicine Saved!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF123B36),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                medicine.medicineName,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF52706A),
                ),
              ),
              const SizedBox(height: 28),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.qr_code_2_rounded,
                      size: 50,
                      color: Color(0xFF159A89),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'The medicine information is now in your inventory.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        height: 1.45,
                        color: Color(0xFF58716C),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'You can select this medicine later and generate a MediTag QR containing the same information.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.45,
                        color: Color(0xFF78908B),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.popUntil(
                      context,
                      (route) => route.isFirst,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        const Color(0xFF159A89),
                    foregroundColor: Colors.white,
                    padding:
                        const EdgeInsets.symmetric(
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(15),
                    ),
                  ),
                  child: const Text(
                    'Back to Dashboard',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                    ),
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