import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/medicine.dart';

class MedicineStorageService {
  static final SupabaseClient _supabase = Supabase.instance.client;

  // ------------------------------------------------------------
  // SAVE MEDICINE
  // ------------------------------------------------------------

  static Future<Medicine> saveMedicine(Medicine medicine) async {
    try {
      final medicineResponse = await _supabase
          .from('medicines')
          .insert({
            'medicine_name': medicine.medicineName,
            'generic_name': medicine.genericName,
            'strength': medicine.strength,
            'dosage_form': medicine.dosageForm,
            'manufacturer': medicine.manufacturer,
          })
          .select()
          .single();

      final medicineId = medicineResponse['id'].toString();

      await _supabase.from('medicine_batches').insert({
        'medicine_id': medicineId,
        'batch_number': medicine.batchNumber,
        'manufacturing_date': medicine.manufacturingDate,
        'expiry_date': medicine.expiryDate,
        'mrp': medicine.mrp,
        'original_qr_data': medicine.originalQrData,
        'barcode_data': medicine.barcodeData,
        'package_photo_url': medicine.photoData,
        'quantity_received': 0,
        'quantity_available': 0,
        'source': medicine.source,
        'is_verified': medicine.isVerified,
      });

      return Medicine(
        id: medicineId,
        medicineName: medicine.medicineName,
        genericName: medicine.genericName,
        strength: medicine.strength,
        dosageForm: medicine.dosageForm,
        manufacturer: medicine.manufacturer,
        batchNumber: medicine.batchNumber,
        manufacturingDate: medicine.manufacturingDate,
        expiryDate: medicine.expiryDate,
        mrp: medicine.mrp,
        originalQrData: medicine.originalQrData,
        barcodeData: medicine.barcodeData,
        photoData: medicine.photoData,
        source: medicine.source,
        isVerified: medicine.isVerified,
        createdAt: medicine.createdAt,
      );
    } catch (e) {
      debugPrint('saveMedicine error: $e');
      rethrow;
    }
  }

  // ------------------------------------------------------------
  // GET ALL MEDICINES
  // ------------------------------------------------------------

  static Future<List<Medicine>> getMedicines() async {
    try {
      final response = await _supabase
          .from('medicines')
          .select('''
            id,
            medicine_name,
            generic_name,
            strength,
            dosage_form,
            manufacturer,
            created_at,
            medicine_batches (
              id,
              batch_number,
              manufacturing_date,
              expiry_date,
              mrp,
              original_qr_data,
              barcode_data,
              package_photo_url,
              source,
              is_verified,
              quantity_received,
              quantity_available
            )
          ''')
          .order('created_at', ascending: false);

      return _mapMedicineRows(response);
    } catch (e) {
      debugPrint('getMedicines error: $e');
      rethrow;
    }
  }

  // ------------------------------------------------------------
  // SEARCH MEDICINES
  // ------------------------------------------------------------

  static Future<List<Medicine>> searchMedicines(String query) async {
    try {
      final search = query.trim();

      if (search.isEmpty) {
        return getMedicines();
      }

      final response = await _supabase
          .from('medicines')
          .select('''
            id,
            medicine_name,
            generic_name,
            strength,
            dosage_form,
            manufacturer,
            created_at,
            medicine_batches (
              id,
              batch_number,
              manufacturing_date,
              expiry_date,
              mrp,
              original_qr_data,
              barcode_data,
              package_photo_url,
              source,
              is_verified,
              quantity_received,
              quantity_available
            )
          ''')
          .or(
            'medicine_name.ilike.%$search%,'
            'generic_name.ilike.%$search%,'
            'manufacturer.ilike.%$search%',
          )
          .order('created_at', ascending: false);

      final results = _mapMedicineRows(response);

      // Also check batch/barcode/QR information.
      final allMedicines = await getMedicines();

      final lowerSearch = search.toLowerCase();

      final extraResults = allMedicines.where((medicine) {
        return medicine.batchNumber.toLowerCase().contains(lowerSearch) ||
            medicine.barcodeData.toLowerCase().contains(lowerSearch) ||
            medicine.originalQrData.toLowerCase().contains(lowerSearch);
      });

      final combined = <String, Medicine>{};

      for (final medicine in results) {
        combined[medicine.id] = medicine;
      }

      for (final medicine in extraResults) {
        combined[medicine.id] = medicine;
      }

      return combined.values.toList();
    } catch (e) {
      debugPrint('searchMedicines error: $e');
      rethrow;
    }
  }

  // ------------------------------------------------------------
  // GET ONE MEDICINE
  // ------------------------------------------------------------

  static Future<Medicine?> getMedicineById(String id) async {
    try {
      final response = await _supabase
          .from('medicines')
          .select('''
            id,
            medicine_name,
            generic_name,
            strength,
            dosage_form,
            manufacturer,
            created_at,
            medicine_batches (
              id,
              batch_number,
              manufacturing_date,
              expiry_date,
              mrp,
              original_qr_data,
              barcode_data,
              package_photo_url,
              source,
              is_verified,
              quantity_received,
              quantity_available
            )
          ''')
          .eq('id', id)
          .maybeSingle();

      if (response == null) {
        return null;
      }

      final medicines = _mapMedicineRows([response]);

      if (medicines.isEmpty) {
        return null;
      }

      return medicines.first;
    } catch (e) {
      debugPrint('getMedicineById error: $e');
      rethrow;
    }
  }

  // ------------------------------------------------------------
  // UPDATE MEDICINE
  // ------------------------------------------------------------

  static Future<void> updateMedicine(Medicine medicine) async {
    try {
      // Update the main medicine information.
      await _supabase
          .from('medicines')
          .update({
            'medicine_name': medicine.medicineName,
            'generic_name': medicine.genericName,
            'strength': medicine.strength,
            'dosage_form': medicine.dosageForm,
            'manufacturer': medicine.manufacturer,
          })
          .eq('id', medicine.id);

      // IMPORTANT:
      // Verification is stored in medicine_batches.
      //
      // The previous implementation could leave the batch as
      // unverified. We now explicitly update ALL batches belonging
      // to this medicine.
      await _supabase
          .from('medicine_batches')
          .update({
            'batch_number': medicine.batchNumber,
            'manufacturing_date': medicine.manufacturingDate,
            'expiry_date': medicine.expiryDate,
            'mrp': medicine.mrp,
            'original_qr_data': medicine.originalQrData,
            'barcode_data': medicine.barcodeData,
            'package_photo_url': medicine.photoData,
            'source': medicine.source,
            'is_verified': medicine.isVerified,
          })
          .eq('medicine_id', medicine.id);

      debugPrint(
        'Medicine updated successfully. '
        'ID=${medicine.id}, '
        'verified=${medicine.isVerified}',
      );
    } catch (e) {
      debugPrint('updateMedicine error: $e');
      rethrow;
    }
  }

  // ------------------------------------------------------------
  // DELETE MEDICINE
  // ------------------------------------------------------------

  static Future<void> deleteMedicine(String id) async {
    try {
      await _supabase
          .from('medicines')
          .delete()
          .eq('id', id);
    } catch (e) {
      debugPrint('deleteMedicine error: $e');
      rethrow;
    }
  }

  // ------------------------------------------------------------
  // CLEAR ALL MEDICINES
  // ------------------------------------------------------------

  static Future<void> clearAllMedicines() async {
    try {
      await _supabase
          .from('medicines')
          .delete()
          .neq('id', '00000000-0000-0000-0000-000000000000');
    } catch (e) {
      debugPrint('clearAllMedicines error: $e');
      rethrow;
    }
  }

  // ------------------------------------------------------------
  // MAP SUPABASE ROWS TO MEDICINE OBJECTS
  // ------------------------------------------------------------

  static List<Medicine> _mapMedicineRows(
    List<dynamic> rows,
  ) {
    final medicines = <Medicine>[];

    for (final rawRow in rows) {
      final row = Map<String, dynamic>.from(rawRow as Map);

      final batchesRaw = row['medicine_batches'];

      List<dynamic> batches = [];

      if (batchesRaw is List) {
        batches = batchesRaw;
      } else if (batchesRaw is Map) {
        batches = [batchesRaw];
      }

      // Use the first batch for displaying batch information.
      Map<String, dynamic> firstBatch = {};

      if (batches.isNotEmpty && batches.first is Map) {
        firstBatch = Map<String, dynamic>.from(
          batches.first as Map,
        );
      }

      // A medicine is considered verified if at least one
      // associated batch has been verified.
      final isVerified = batches.any((batch) {
        if (batch is Map) {
          return batch['is_verified'] == true;
        }

        return false;
      });

      medicines.add(
        Medicine(
          id: row['id']?.toString() ?? '',
          medicineName:
              row['medicine_name']?.toString() ?? '',
          genericName:
              row['generic_name']?.toString() ?? '',
          strength:
              row['strength']?.toString() ?? '',
          dosageForm:
              row['dosage_form']?.toString() ?? '',
          manufacturer:
              row['manufacturer']?.toString() ?? '',

          batchNumber:
              firstBatch['batch_number']?.toString() ?? '',

          manufacturingDate:
              firstBatch['manufacturing_date']?.toString() ?? '',

          expiryDate:
              firstBatch['expiry_date']?.toString() ?? '',

          mrp:
              firstBatch['mrp']?.toString() ?? '',

          originalQrData:
              firstBatch['original_qr_data']?.toString() ?? '',

          barcodeData:
              firstBatch['barcode_data']?.toString() ?? '',

          photoData:
              firstBatch['package_photo_url']?.toString(),

          source:
              firstBatch['source']?.toString() ?? '',

          isVerified: isVerified,

          createdAt: DateTime.tryParse(
                row['created_at']?.toString() ?? '',
              ) ??
              DateTime.now(),
        ),
      );
    }

    return medicines;
  }
}