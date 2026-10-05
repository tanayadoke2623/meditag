import 'package:flutter/material.dart';

import '../services/pharmacy_profile_service.dart';

class PharmacyProfileScreen extends StatefulWidget {
  const PharmacyProfileScreen({super.key});

  @override
  State<PharmacyProfileScreen> createState() =>
      _PharmacyProfileScreenState();
}

class _PharmacyProfileScreenState
    extends State<PharmacyProfileScreen> {
  final pharmacyNameController =
      TextEditingController();

  final pharmacistNameController =
      TextEditingController();

  final phoneController =
      TextEditingController();

  final emailController =
      TextEditingController();

  final addressController =
      TextEditingController();

  final licenseController =
      TextEditingController();

  bool loading = true;
  bool saving = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    pharmacyNameController.dispose();
    pharmacistNameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    addressController.dispose();
    licenseController.dispose();

    super.dispose();
  }

  Future<void> _loadProfile() async {
    try {
      final profile =
          await PharmacyProfileService
              .getProfile();

      if (!mounted) return;

      if (profile != null) {
        pharmacyNameController.text =
            profile.pharmacyName;

        pharmacistNameController.text =
            profile.pharmacistName;

        phoneController.text =
            profile.phone;

        emailController.text =
            profile.email;

        addressController.text =
            profile.address;

        licenseController.text =
            profile.licenseNumber;
      }

      setState(() {
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loading = false;
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            'Could not load pharmacy profile: $e',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _saveProfile() async {
    if (pharmacyNameController.text
        .trim()
        .isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Please enter the pharmacy name.',
          ),
        ),
      );

      return;
    }

    setState(() {
      saving = true;
    });

    try {
      await PharmacyProfileService.saveProfile(
        pharmacyName:
            pharmacyNameController.text,
        pharmacistName:
            pharmacistNameController.text,
        phone:
            phoneController.text,
        email:
            emailController.text,
        address:
            addressController.text,
        licenseNumber:
            licenseController.text,
      );

      if (!mounted) return;

      setState(() {
        saving = false;
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Pharmacy profile saved successfully.',
          ),
          backgroundColor:
              Color(0xFF0F766E),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        saving = false;
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            'Could not save profile: $e',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

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
          'Pharmacy Profile',
          style: TextStyle(
            fontSize: 21,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: loading
          ? const Center(
              child:
                  CircularProgressIndicator(
                color:
                    Color(0xFF0F766E),
              ),
            )
          : ListView(
              padding:
                  const EdgeInsets.all(20),
              children: [
                // PROFILE HEADER
                Container(
                  padding:
                      const EdgeInsets.all(20),
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
                        BorderRadius.circular(24),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 62,
                        height: 62,
                        decoration:
                            BoxDecoration(
                          color: Colors.white
                              .withOpacity(
                            0.15,
                          ),
                          borderRadius:
                              BorderRadius.circular(
                            18,
                          ),
                        ),
                        child: const Icon(
                          Icons
                              .local_pharmacy_rounded,
                          color:
                              Colors.white,
                          size: 34,
                        ),
                      ),
                      const SizedBox(
                        width: 15,
                      ),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,
                          children: [
                            Text(
                              'Pharmacy Profile',
                              style:
                                  TextStyle(
                                color:
                                    Colors.white,
                                fontSize: 20,
                                fontWeight:
                                    FontWeight.w800,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              'Information shown for your pharmacy',
                              style:
                                  TextStyle(
                                color:
                                    Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 22),

                const Text(
                  'Pharmacy Information',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight:
                        FontWeight.w800,
                    color:
                        Color(0xFF17201F),
                  ),
                ),

                const SizedBox(height: 12),

                _ProfileField(
                  controller:
                      pharmacyNameController,
                  label:
                      'Pharmacy Name',
                  hint:
                      'e.g. MediCare Pharmacy',
                  icon:
                      Icons.local_pharmacy_outlined,
                  requiredField: true,
                ),

                const SizedBox(height: 13),

                _ProfileField(
                  controller:
                      pharmacistNameController,
                  label:
                      'Pharmacist / Owner Name',
                  hint:
                      'Enter pharmacist name',
                  icon:
                      Icons.person_outline_rounded,
                ),

                const SizedBox(height: 13),

                _ProfileField(
                  controller:
                      phoneController,
                  label:
                      'Phone Number',
                  hint:
                      'Enter pharmacy phone number',
                  icon:
                      Icons.phone_outlined,
                  keyboardType:
                      TextInputType.phone,
                ),

                const SizedBox(height: 13),

                _ProfileField(
                  controller:
                      emailController,
                  label:
                      'Email',
                  hint:
                      'Enter pharmacy email',
                  icon:
                      Icons.email_outlined,
                  keyboardType:
                      TextInputType.emailAddress,
                ),

                const SizedBox(height: 13),

                _ProfileField(
                  controller:
                      addressController,
                  label:
                      'Pharmacy Address',
                  hint:
                      'Enter complete pharmacy address',
                  icon:
                      Icons.location_on_outlined,
                  maxLines: 3,
                ),

                const SizedBox(height: 13),

                _ProfileField(
                  controller:
                      licenseController,
                  label:
                      'License Number',
                  hint:
                      'Enter pharmacy license number',
                  icon:
                      Icons.badge_outlined,
                ),

                const SizedBox(height: 25),

                // SAVE BUTTON
                SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed:
                        saving
                            ? null
                            : _saveProfile,
                    style:
                        ElevatedButton.styleFrom(
                      backgroundColor:
                          const Color(
                        0xFF0F766E,
                      ),
                      foregroundColor:
                          Colors.white,
                      elevation: 0,
                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(
                          17,
                        ),
                      ),
                    ),
                    child: saving
                        ? const SizedBox(
                            width: 23,
                            height: 23,
                            child:
                                CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color:
                                  Colors.white,
                            ),
                          )
                        : const Row(
                            mainAxisAlignment:
                                MainAxisAlignment
                                    .center,
                            children: [
                              Icon(
                                Icons
                                    .save_rounded,
                              ),
                              SizedBox(
                                width: 9,
                              ),
                              Text(
                                'Save Pharmacy Profile',
                                style:
                                    TextStyle(
                                  fontSize: 15,
                                  fontWeight:
                                      FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),

                const SizedBox(height: 18),

                Container(
                  padding:
                      const EdgeInsets.all(15),
                  decoration:
                      BoxDecoration(
                    color:
                        const Color(0xFFEFF9F6),
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
                        Icons.info_outline_rounded,
                        color:
                            Color(0xFF0F766E),
                        size: 21,
                      ),
                      SizedBox(width: 9),
                      Expanded(
                        child: Text(
                          'Keep your pharmacy information accurate. This information can later be associated with your authenticated pharmacy account.',
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

                const SizedBox(height: 30),
              ],
            ),
    );
  }
}

class _ProfileField
    extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final TextInputType? keyboardType;
  final int maxLines;
  final bool requiredField;

  const _ProfileField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.keyboardType,
    this.maxLines = 1,
    this.requiredField = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration:
          BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(17),
      ),
      child: TextField(
        controller: controller,
        keyboardType:
            keyboardType,
        maxLines: maxLines,
        decoration:
            InputDecoration(
          labelText:
              requiredField
                  ? '$label *'
                  : label,
          hintText: hint,
          prefixIcon: Icon(
            icon,
            color:
                const Color(0xFF0F766E),
          ),
          border:
              OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(17),
            borderSide:
                BorderSide.none,
          ),
          enabledBorder:
              OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(17),
            borderSide:
                BorderSide.none,
          ),
          focusedBorder:
              OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(17),
            borderSide:
                const BorderSide(
              color:
                  Color(0xFF0F766E),
              width: 1.5,
            ),
          ),
          filled: true,
          fillColor:
              Colors.white,
          contentPadding:
              const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }
}