class Animal {
  final String id;
  final String commonName;
  final String scientificName;
  final String habitat;
  final String dangerLevel;
  final String description;
  final String imageUrl;
  final List<String> safetyTips;
  final List<String> firstAidSteps;

  Animal({
    required this.id,
    required this.commonName,
    required this.scientificName,
    required this.habitat,
    required this.dangerLevel,
    required this.description,
    required this.imageUrl,
    required this.safetyTips,
    required this.firstAidSteps,
  });

  factory Animal.fromJson(Map<String, dynamic> json) {
    return Animal(
      id: json['id'] as String,
      commonName: json['commonName'] as String,
      scientificName: json['scientificName'] as String,
      habitat: json['habitat'] as String,
      dangerLevel: json['dangerLevel'] as String,
      description: json['description'] as String,
      imageUrl: json['imageUrl'] as String,
      safetyTips: List<String>.from(json['safetyTips']),
      firstAidSteps: List<String>.from(json['firstAidSteps']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'commonName': commonName,
      'scientificName': scientificName,
      'habitat': habitat,
      'dangerLevel': dangerLevel,
      'description': description,
      'imageUrl': imageUrl,
      'safetyTips': safetyTips,
      'firstAidSteps': firstAidSteps,
    };
  }
}
