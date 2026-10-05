import 'package:supabase_flutter/supabase_flutter.dart';

class DashboardStats {
  final int medicines;
  final int batches;
  final int qrLabels;
  final int alerts;
  final int todayQrLabels;
  final int todayDispensings;

  const DashboardStats({
    required this.medicines,
    required this.batches,
    required this.qrLabels,
    required this.alerts,
    required this.todayQrLabels,
    required this.todayDispensings,
  });
}

class ExpiryAlert {
  final String medicineName;
  final String batchNumber;
  final String expiryDate;
  final bool expired;
  final int daysRemaining;

  const ExpiryAlert({
    required this.medicineName,
    required this.batchNumber,
    required this.expiryDate,
    required this.expired,
    required this.daysRemaining,
  });
}

class DashboardService {
  static final SupabaseClient _supabase =
      Supabase.instance.client;

  // ------------------------------------------------------------
  // DASHBOARD STATISTICS
  // ------------------------------------------------------------

  static Future<DashboardStats> getDashboardStats() async {
    final medicinesResponse =
        await _supabase.from('medicines').select('id');

    final batchesResponse =
        await _supabase.from('medicine_batches').select('id');

    final qrLabelsResponse =
        await _supabase.from('qr_labels').select('id');

    final expiryAlerts = await getExpiryAlerts();

    final now = DateTime.now();

    final todayStart = DateTime(
      now.year,
      now.month,
      now.day,
    );

    final tomorrowStart = todayStart.add(
      const Duration(days: 1),
    );

    final todayStartIso =
        todayStart.toIso8601String();

    final tomorrowStartIso =
        tomorrowStart.toIso8601String();

    final todayQrResponse = await _supabase
        .from('qr_labels')
        .select('id')
        .gte('created_at', todayStartIso)
        .lt('created_at', tomorrowStartIso);

    final todayDispensingResponse =
        await _supabase
            .from('dispensing_records')
            .select('id')
            .gte('created_at', todayStartIso)
            .lt('created_at', tomorrowStartIso);

    return DashboardStats(
      medicines: medicinesResponse.length,
      batches: batchesResponse.length,
      qrLabels: qrLabelsResponse.length,
      alerts: expiryAlerts.length,
      todayQrLabels: todayQrResponse.length,
      todayDispensings:
          todayDispensingResponse.length,
    );
  }

  // ------------------------------------------------------------
  // EXPIRY ALERTS
  // ------------------------------------------------------------

  static Future<List<ExpiryAlert>> getExpiryAlerts() async {
    final response = await _supabase
        .from('medicine_batches')
        .select(
          'id, medicine_id, batch_number, expiry_date',
        );

    final List<ExpiryAlert> alerts = [];

    final today = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );

    for (final row in response) {
      final expiryText =
          row['expiry_date']?.toString().trim() ?? '';

      if (expiryText.isEmpty) {
        continue;
      }

      final expiryDate =
          _parseExpiryDate(expiryText);

      if (expiryDate == null) {
        continue;
      }

      final expiryDay = DateTime(
        expiryDate.year,
        expiryDate.month,
        expiryDate.day,
      );

      final daysRemaining =
          expiryDay.difference(today).inDays;

      // Show expired medicines and medicines expiring
      // within the next 30 days.
      if (daysRemaining <= 30) {
        String medicineName = 'Unknown medicine';

        final medicineId =
            row['medicine_id']?.toString();

        if (medicineId != null &&
            medicineId.isNotEmpty) {
          final medicineResponse =
              await _supabase
                  .from('medicines')
                  .select('medicine_name')
                  .eq('id', medicineId)
                  .maybeSingle();

          if (medicineResponse != null) {
            medicineName =
                medicineResponse['medicine_name']
                        ?.toString() ??
                    'Unknown medicine';
          }
        }

        alerts.add(
          ExpiryAlert(
            medicineName: medicineName,
            batchNumber:
                row['batch_number']?.toString() ?? '',
            expiryDate: expiryText,
            expired: daysRemaining < 0,
            daysRemaining: daysRemaining,
          ),
        );
      }
    }

    alerts.sort(
      (a, b) =>
          a.daysRemaining.compareTo(
        b.daysRemaining,
      ),
    );

    return alerts;
  }

  // ------------------------------------------------------------
  // EXPIRY DATE PARSER
  // ------------------------------------------------------------

  static DateTime? _parseExpiryDate(String value) {
    final text = value.trim();

    // ISO date
    final iso = DateTime.tryParse(text);

    if (iso != null) {
      return iso;
    }

    // MM/YYYY or MM-YYYY
    final mmYear = RegExp(
      r'^(\d{1,2})[\/\-](\d{4})$',
    ).firstMatch(text);

    if (mmYear != null) {
      final month =
          int.tryParse(mmYear.group(1)!);

      final year =
          int.tryParse(mmYear.group(2)!);

      if (month != null &&
          year != null &&
          month >= 1 &&
          month <= 12) {
        return DateTime(
          year,
          month + 1,
          0,
        );
      }
    }

    // YYYY/MM or YYYY-MM
    final yearMonth = RegExp(
      r'^(\d{4})[\/\-](\d{1,2})$',
    ).firstMatch(text);

    if (yearMonth != null) {
      final year =
          int.tryParse(yearMonth.group(1)!);

      final month =
          int.tryParse(yearMonth.group(2)!);

      if (year != null &&
          month != null &&
          month >= 1 &&
          month <= 12) {
        return DateTime(
          year,
          month + 1,
          0,
        );
      }
    }

    // DD/MM/YYYY
    final ddMmYyyy = RegExp(
      r'^(\d{1,2})[\/\-](\d{1,2})[\/\-](\d{4})$',
    ).firstMatch(text);

    if (ddMmYyyy != null) {
      final day =
          int.tryParse(ddMmYyyy.group(1)!);

      final month =
          int.tryParse(ddMmYyyy.group(2)!);

      final year =
          int.tryParse(ddMmYyyy.group(3)!);

      if (day != null &&
          month != null &&
          year != null) {
        return DateTime(
          year,
          month,
          day,
        );
      }
    }

    return null;
  }

  // ------------------------------------------------------------
  // QR LABEL HISTORY
  // ------------------------------------------------------------

  static Future<List<Map<String, dynamic>>>
      getQrLabels() async {
    /*
     * We intentionally do this in separate queries.
     *
     * This is more reliable for the current Supabase
     * demo schema than depending on nested PostgREST
     * response structures.
     */

    final qrResponse = await _supabase
        .from('qr_labels')
        .select(
          'id, dispensing_id, qr_token, qr_data, created_at, is_active',
        )
        .order(
          'created_at',
          ascending: false,
        );

    final List<Map<String, dynamic>> result = [];

    for (final qrRow in qrResponse) {
      final item =
          Map<String, dynamic>.from(qrRow);

      final dispensingId =
          qrRow['dispensing_id']?.toString();

      if (dispensingId == null ||
          dispensingId.isEmpty) {
        item['dispensing_records'] = null;
        result.add(item);
        continue;
      }

      final dispensingResponse =
          await _supabase
              .from('dispensing_records')
              .select(
                'id, quantity_dispensed, pharmacy_instructions, dispensing_date, medicine_id',
              )
              .eq('id', dispensingId)
              .maybeSingle();

      if (dispensingResponse == null) {
        item['dispensing_records'] = null;
        result.add(item);
        continue;
      }

      final dispensing =
          Map<String, dynamic>.from(
        dispensingResponse,
      );

      final medicineId =
          dispensing['medicine_id']?.toString();

      if (medicineId != null &&
          medicineId.isNotEmpty) {
        final medicineResponse =
            await _supabase
                .from('medicines')
                .select(
                  'medicine_name, generic_name, strength',
                )
                .eq('id', medicineId)
                .maybeSingle();

        if (medicineResponse != null) {
          dispensing['medicines'] =
              Map<String, dynamic>.from(
            medicineResponse,
          );
        }
      }

      item['dispensing_records'] = dispensing;

      result.add(item);
    }

    return result;
  }
}