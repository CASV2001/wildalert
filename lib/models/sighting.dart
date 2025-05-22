class Sighting {
  final String id;
  final String animalId;
  final double latitude;
  final double longitude;
  final DateTime timestamp;
  final String reportedBy;
  final String? imageUrl;
  final String? notes;

  Sighting({
    required this.id,
    required this.animalId,
    required this.latitude,
    required this.longitude,
    required this.timestamp,
    required this.reportedBy,
    this.imageUrl,
    this.notes,
  });

  factory Sighting.fromJson(Map<String, dynamic> json) {
    return Sighting(
      id: json['id'] as String,
      animalId: json['animalId'] as String,
      latitude: json['latitude'] as double,
      longitude: json['longitude'] as double,
      timestamp: DateTime.parse(json['timestamp'] as String),
      reportedBy: json['reportedBy'] as String,
      imageUrl: json['imageUrl'] as String?,
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'animalId': animalId,
      'latitude': latitude,
      'longitude': longitude,
      'timestamp': timestamp.toIso8601String(),
      'reportedBy': reportedBy,
      'imageUrl': imageUrl,
      'notes': notes,
    };
  }
}
