import 'package:supabase_flutter/supabase_flutter.dart';

class PharmacyProfile {
  final String id;
  final String pharmacyName;
  final String pharmacistName;
  final String phone;
  final String email;
  final String address;
  final String licenseNumber;

  const PharmacyProfile({
    required this.id,
    required this.pharmacyName,
    required this.pharmacistName,
    required this.phone,
    required this.email,
    required this.address,
    required this.licenseNumber,
  });

  factory PharmacyProfile.fromMap(
    Map<String, dynamic> map,
  ) {
    return PharmacyProfile(
      id: map['id']?.toString() ?? '',
      pharmacyName:
          map['pharmacy_name']?.toString() ?? '',
      pharmacistName:
          map['pharmacist_name']?.toString() ?? '',
      phone:
          map['phone']?.toString() ?? '',
      email:
          map['email']?.toString() ?? '',
      address:
          map['address']?.toString() ?? '',
      licenseNumber:
          map['license_number']?.toString() ?? '',
    );
  }
}

class PharmacyProfileService {
  static final SupabaseClient _supabase =
      Supabase.instance.client;

  static Future<PharmacyProfile?> getProfile() async {
    final response = await _supabase
        .from('pharmacy_profiles')
        .select()
        .order(
          'created_at',
          ascending: true,
        )
        .limit(1)
        .maybeSingle();

    if (response == null) {
      return null;
    }

    return PharmacyProfile.fromMap(response);
  }

  static Future<PharmacyProfile> saveProfile({
    required String pharmacyName,
    required String pharmacistName,
    required String phone,
    required String email,
    required String address,
    required String licenseNumber,
  }) async {
    final existing = await getProfile();

    final data = {
      'pharmacy_name': pharmacyName.trim(),
      'pharmacist_name': pharmacistName.trim(),
      'phone': phone.trim(),
      'email': email.trim(),
      'address': address.trim(),
      'license_number': licenseNumber.trim(),
      'updated_at':
          DateTime.now().toIso8601String(),
    };

    Map<String, dynamic> response;

    if (existing == null) {
      final inserted = await _supabase
          .from('pharmacy_profiles')
          .insert(data)
          .select()
          .single();

      response =
          Map<String, dynamic>.from(inserted);
    } else {
      final updated = await _supabase
          .from('pharmacy_profiles')
          .update(data)
          .eq('id', existing.id)
          .select()
          .single();

      response =
          Map<String, dynamic>.from(updated);
    }

    return PharmacyProfile.fromMap(response);
  }
}