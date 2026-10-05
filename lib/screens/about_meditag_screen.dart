import 'package:flutter/material.dart';

class AboutMediTagScreen extends StatelessWidget {
  const AboutMediTagScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFF1FAF8),
      appBar: AppBar(
        backgroundColor:
            const Color(0xFFF1FAF8),
        elevation: 0,
        foregroundColor:
            const Color(0xFF17332F),
        title: const Text(
          'About MediTag',
          style: TextStyle(
            fontSize: 21,
            fontWeight:
                FontWeight.w800,
          ),
        ),
      ),
      body: ListView(
        padding:
            const EdgeInsets.all(20),
        children: [
          // LOGO
          Container(
            padding:
                const EdgeInsets.all(25),
            decoration:
                BoxDecoration(
              gradient:
                  const LinearGradient(
                colors: [
                  Color(0xFF0F766E),
                  Color(0xFF159A8A),
                ],
                begin:
                    Alignment.topLeft,
                end:
                    Alignment.bottomRight,
              ),
              borderRadius:
                  BorderRadius.circular(26),
            ),
            child: Column(
              children: [
                Container(
                  width: 76,
                  height: 76,
                  decoration:
                      BoxDecoration(
                    color: Colors.white
                        .withOpacity(0.15),
                    borderRadius:
                        BorderRadius.circular(
                      23,
                    ),
                  ),
                  child: const Icon(
                    Icons
                        .local_pharmacy_rounded,
                    color:
                        Colors.white,
                    size: 42,
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                const Text(
                  'MediTag',
                  style:
                      TextStyle(
                    color:
                        Colors.white,
                    fontSize: 29,
                    fontWeight:
                        FontWeight.w900,
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                const Text(
                  'Verified medicine information, wherever you need it.',
                  textAlign:
                      TextAlign.center,
                  style:
                      TextStyle(
                    color:
                        Colors.white70,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(
            height: 22,
          ),

          _AboutCard(
            icon:
                Icons.help_outline_rounded,
            title:
                'What is MediTag?',
            child:
                const Text(
              'MediTag is a pharmacy-focused medicine information and QR labeling system. It helps preserve important medicine information when tablets or strips are separated from their original packaging.',
              style:
                  TextStyle(
                fontSize: 13,
                height: 1.55,
                color:
                    Color(0xFF475569),
              ),
            ),
          ),

          const SizedBox(
            height: 14,
          ),

          _AboutCard(
            icon:
                Icons.account_tree_outlined,
            title:
                'How it works',
            child:
                Column(
              children: [
                _StepRow(
                  number: '1',
                  title:
                      'Capture medicine information',
                  description:
                      'Scan an existing QR code or barcode, or use the medicine information workflow.',
                ),
                _StepRow(
                  number: '2',
                  title:
                      'Verify and lock',
                  description:
                      'The pharmacist reviews the official medicine information before it becomes a verified record.',
                ),
                _StepRow(
                  number: '3',
                  title:
                      'Dispense',
                  description:
                      'Select the quantity and enter appropriate pharmacy dispensing instructions.',
                ),
                _StepRow(
                  number: '4',
                  title:
                      'Generate MediTag',
                  description:
                      'Create a new QR label containing the relevant medicine and dispensing information.',
                ),
                _StepRow(
                  number: '5',
                  title:
                      'Scan anywhere',
                  description:
                      'The generated QR contains its information directly, so a normal QR scanner can read it.',
                  last: true,
                ),
              ],
            ),
          ),

          const SizedBox(
            height: 14,
          ),

          _AboutCard(
            icon:
                Icons.qr_code_2_rounded,
            title:
                'Self-contained QR',
            child:
                Container(
              padding:
                  const EdgeInsets.all(14),
              decoration:
                  BoxDecoration(
                color:
                    const Color(0xFFEFF9F6),
                borderRadius:
                    BorderRadius.circular(
                  14,
                ),
              ),
              child:
                  const Row(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons
                        .wifi_off_rounded,
                    color:
                        Color(0xFF0F766E),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child:
                        Text(
                      'MediTag QR labels are designed to contain the information directly. Reading the QR does not require the MediTag app, a database lookup, or internet access.',
                      style:
                          TextStyle(
                        fontSize: 12,
                        height: 1.5,
                        color:
                            Color(0xFF315E58),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(
            height: 14,
          ),

          _AboutCard(
            icon:
                Icons.verified_user_outlined,
            title:
                'Verification & safety',
            child:
                const Text(
              'Official medicine information and pharmacy-added dispensing instructions are kept conceptually separate. Pharmacy instructions should be based on the appropriate prescription or professional direction and should not be treated as manufacturer or doctor claims.',
              style:
                  TextStyle(
                fontSize: 13,
                height: 1.55,
                color:
                    Color(0xFF475569),
              ),
            ),
          ),

          const SizedBox(
            height: 14,
          ),

          _AboutCard(
            icon:
                Icons.storage_outlined,
            title:
                'Data & history',
            child:
                const Text(
              'MediTag stores medicine records, batch information, dispensing history and generated QR label history in the connected pharmacy database.',
              style:
                  TextStyle(
                fontSize: 13,
                height: 1.55,
                color:
                    Color(0xFF475569),
              ),
            ),
          ),

          const SizedBox(
            height: 22,
          ),

          Center(
            child:
                Column(
              children: [
                Text(
                  'MediTag',
                  style:
                      TextStyle(
                    fontSize: 18,
                    fontWeight:
                        FontWeight.w900,
                    color:
                        const Color(
                      0xFF0F766E,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 4,
                ),
                const Text(
                  'Hackathon Demo',
                  style:
                      TextStyle(
                    fontSize: 12,
                    color:
                        Color(0xFF64748B),
                  ),
                ),
                const SizedBox(
                  height: 3,
                ),
                const Text(
                  'Version 1.0.0',
                  style:
                      TextStyle(
                    fontSize: 11,
                    color:
                        Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(
            height: 30,
          ),
        ],
      ),
    );
  }
}

class _AboutCard
    extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget child;

  const _AboutCard({
    required this.icon,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(18),
      decoration:
          BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 43,
                height: 43,
                decoration:
                    BoxDecoration(
                  color:
                      const Color(
                    0xFF0F766E,
                  ).withOpacity(
                    0.09,
                  ),
                  borderRadius:
                      BorderRadius.circular(
                    12,
                  ),
                ),
                child: Icon(
                  icon,
                  color:
                      const Color(
                    0xFF0F766E,
                  ),
                ),
              ),
              const SizedBox(
                width: 11,
              ),
              Expanded(
                child: Text(
                  title,
                  style:
                      const TextStyle(
                    fontSize: 16,
                    fontWeight:
                        FontWeight.w800,
                    color:
                        Color(0xFF17201F),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 14,
          ),
          child,
        ],
      ),
    );
  }
}

class _StepRow
    extends StatelessWidget {
  final String number;
  final String title;
  final String description;
  final bool last;

  const _StepRow({
    required this.number,
    required this.title,
    required this.description,
    this.last = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration:
                  const BoxDecoration(
                color:
                    Color(0xFF0F766E),
                shape:
                    BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  number,
                  style:
                      const TextStyle(
                    color:
                        Colors.white,
                    fontWeight:
                        FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
            if (!last)
              Container(
                width: 2,
                height: 47,
                color:
                    const Color(
                  0xFFD6E9E5,
                ),
              ),
          ],
        ),
        const SizedBox(
          width: 12,
        ),
        Expanded(
          child: Padding(
            padding:
                const EdgeInsets.only(
              bottom: 16,
            ),
            child:
                Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style:
                      const TextStyle(
                    fontSize: 13.5,
                    fontWeight:
                        FontWeight.w800,
                  ),
                ),
                const SizedBox(
                  height: 3,
                ),
                Text(
                  description,
                  style:
                      const TextStyle(
                    fontSize: 11.5,
                    height: 1.45,
                    color:
                        Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}