import 'package:flutter/material.dart';

class OcrVerificationScreen extends StatefulWidget {
  final String? imagePath;

  const OcrVerificationScreen({
    super.key,
    this.imagePath,
  });

  @override
  State<OcrVerificationScreen> createState() =>
      _OcrVerificationScreenState();
}

class _OcrVerificationScreenState
    extends State<OcrVerificationScreen> {
  final TextEditingController medicineNameController =
      TextEditingController();

  final TextEditingController batchNumberController =
      TextEditingController();

  final TextEditingController expiryDateController =
      TextEditingController();

  final TextEditingController mrpController =
      TextEditingController();

  final TextEditingController manufacturerController =
      TextEditingController();

  bool isVerified = false;

  @override
  void dispose() {
    medicineNameController.dispose();
    batchNumberController.dispose();
    expiryDateController.dispose();
    mrpController.dispose();
    manufacturerController.dispose();

    super.dispose();
  }

  void confirmMedicine() {
    setState(() {
      isVerified = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Medicine details verified successfully.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1FAF8),

      appBar: AppBar(
        backgroundColor: const Color(0xFFF1FAF8),
        elevation: 0,

        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: Color(0xFF123333),
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),

        title: const Text(
          'Verify Medicine',
          style: TextStyle(
            color: Color(0xFF123333),
            fontSize: 21,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          20,
          8,
          20,
          35,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ------------------------------------------------
            // HEADER
            // ------------------------------------------------

            const Text(
              'Review scanned details',
              style: TextStyle(
                fontSize: 27,
                fontWeight: FontWeight.w800,
                color: Color(0xFF123333),
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'MediTag has captured the medicine information. '
              'Please check the details before saving.',
              style: TextStyle(
                fontSize: 15,
                height: 1.45,
                color: Color(0xFF668080),
              ),
            ),

            const SizedBox(height: 22),

            // ------------------------------------------------
            // OCR STATUS CARD
            // ------------------------------------------------

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(17),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFFD9EFEB),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFFDDF7F2),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Icon(
                      Icons.document_scanner_rounded,
                      color: Color(0xFF0F9D8A),
                      size: 27,
                    ),
                  ),

                  const SizedBox(width: 14),

                  const Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Scan completed',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF173838),
                          ),
                        ),

                        SizedBox(height: 3),

                        Text(
                          'Please verify the information below.',
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF6C8585),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Icon(
                    Icons.check_circle_rounded,
                    color: Color(0xFF0F9D8A),
                    size: 25,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // ------------------------------------------------
            // MEDICINE DETAILS
            // ------------------------------------------------

            const Text(
              'Medicine Details',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Color(0xFF173838),
              ),
            ),

            const SizedBox(height: 15),

            _buildField(
              label: 'Medicine Name',
              hint: 'e.g. Paracetamol 500mg',
              icon: Icons.medication_rounded,
              controller: medicineNameController,
            ),

            const SizedBox(height: 14),

            _buildField(
              label: 'Batch Number',
              hint: 'e.g. BTH123456',
              icon: Icons.qr_code_2_rounded,
              controller: batchNumberController,
            ),

            const SizedBox(height: 14),

            Row(
              children: [
                Expanded(
                  child: _buildField(
                    label: 'Expiry Date',
                    hint: 'MM/YYYY',
                    icon: Icons.event_outlined,
                    controller: expiryDateController,
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: _buildField(
                    label: 'MRP',
                    hint: '₹ 00.00',
                    icon: Icons.currency_rupee_rounded,
                    controller: mrpController,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            _buildField(
              label: 'Manufacturer',
              hint: 'e.g. ABC Pharmaceuticals',
              icon: Icons.factory_outlined,
              controller: manufacturerController,
            ),

            const SizedBox(height: 25),

            // ------------------------------------------------
            // WARNING / VERIFICATION INFO
            // ------------------------------------------------

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF8E7),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: const Color(0xFFF3E0A6),
                ),
              ),
              child: const Row(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: Color(0xFFC58A00),
                    size: 24,
                  ),

                  SizedBox(width: 12),

                  Expanded(
                    child: Text(
                      'Always verify the extracted information '
                      'against the physical medicine package before '
                      'saving it.',
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.45,
                        color: Color(0xFF725B19),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // ------------------------------------------------
            // CONFIRM BUTTON
            // ------------------------------------------------

            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: confirmMedicine,

                icon: Icon(
                  isVerified
                      ? Icons.check_circle_rounded
                      : Icons.verified_rounded,
                ),

                label: Text(
                  isVerified
                      ? 'Medicine Verified'
                      : 'Confirm & Save Medicine',
                ),

                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F9D8A),
                  foregroundColor: Colors.white,
                  elevation: 4,

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(17),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // INPUT FIELD
  // ==========================================================

  Widget _buildField({
    required String label,
    required String hint,
    required IconData icon,
    required TextEditingController controller,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Color(0xFF385858),
          ),
        ),

        const SizedBox(height: 7),

        TextField(
          controller: controller,

          decoration: InputDecoration(
            hintText: hint,

            prefixIcon: Icon(
              icon,
              color: const Color(0xFF0F9D8A),
              size: 21,
            ),

            filled: true,
            fillColor: Colors.white,

            contentPadding: const EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 16,
            ),

            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(
                color: Color(0xFFD9EFEB),
              ),
            ),

            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(
                color: Color(0xFFD9EFEB),
              ),
            ),

            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(
                color: Color(0xFF0F9D8A),
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}