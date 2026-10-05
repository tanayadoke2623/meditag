class Medicine {
  final String id;

  // Official medicine information
  String medicineName;
  String genericName;
  String strength;
  String dosageForm;
  String manufacturer;

  // Batch information
  String batchNumber;
  String manufacturingDate;
  String expiryDate;
  String mrp;

  // Original package information
  String originalQrData;
  String barcodeData;

  // Photo of the medicine package
  String? photoData;

  // How the medicine was added
  String source;

  // Verification
  bool isVerified;

  // Storage timestamp
  final DateTime createdAt;

  Medicine({
    required this.id,
    this.medicineName = '',
    this.genericName = '',
    this.strength = '',
    this.dosageForm = '',
    this.manufacturer = '',
    this.batchNumber = '',
    this.manufacturingDate = '',
    this.expiryDate = '',
    this.mrp = '',
    this.originalQrData = '',
    this.barcodeData = '',
    this.photoData,
    this.source = '',
    this.isVerified = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Convert Medicine object into JSON.
  ///
  /// Later, the same structure can be sent to Supabase.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'medicineName': medicineName,
      'genericName': genericName,
      'strength': strength,
      'dosageForm': dosageForm,
      'manufacturer': manufacturer,
      'batchNumber': batchNumber,
      'manufacturingDate': manufacturingDate,
      'expiryDate': expiryDate,
      'mrp': mrp,
      'originalQrData': originalQrData,
      'barcodeData': barcodeData,
      'photoData': photoData,
      'source': source,
      'isVerified': isVerified,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Convert JSON back into a Medicine object.
  factory Medicine.fromJson(Map<String, dynamic> json) {
    return Medicine(
      id: json['id']?.toString() ?? '',
      medicineName: json['medicineName']?.toString() ?? '',
      genericName: json['genericName']?.toString() ?? '',
      strength: json['strength']?.toString() ?? '',
      dosageForm: json['dosageForm']?.toString() ?? '',
      manufacturer: json['manufacturer']?.toString() ?? '',
      batchNumber: json['batchNumber']?.toString() ?? '',
      manufacturingDate: json['manufacturingDate']?.toString() ?? '',
      expiryDate: json['expiryDate']?.toString() ?? '',
      mrp: json['mrp']?.toString() ?? '',
      originalQrData: json['originalQrData']?.toString() ?? '',
      barcodeData: json['barcodeData']?.toString() ?? '',
      photoData: json['photoData']?.toString(),
      source: json['source']?.toString() ?? '',
      isVerified: json['isVerified'] == true,
      createdAt: DateTime.tryParse(
            json['createdAt']?.toString() ?? '',
          ) ??
          DateTime.now(),
    );
  }
}