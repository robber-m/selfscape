// selfscape_app/lib/features/inventory/models/acquisition_model.dart

class Acquisition {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final DateTime dateAcquired;
  final String source;
  final List<String> tags;

  Acquisition({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.dateAcquired,
    required this.source,
    required this.tags,
  });

  factory Acquisition.fromJson(Map<String, dynamic> json) {
    return Acquisition(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      imageUrl: json['imageUrl'] as String,
      // Ensure dateAcquired from backend is a string that DateTime.parse can handle (ISO 8601)
      dateAcquired: DateTime.parse(json['dateAcquired'] as String),
      source: json['source'] as String,
      // Ensure tags are properly cast from List<dynamic> if necessary
      tags: (json['tags'] as List<dynamic>).map((tag) => tag as String).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    // For sending data TO the backend.
    return {
      'id': id, // Included for completeness, backend might ignore for new entries or use for updates
      'name': name,
      'description': description,
      'imageUrl': imageUrl, // Usually set by backend after upload, or if updating metadata of existing image
      'dateAcquired': dateAcquired.toIso8601String(),
      'source': source,
      'tags': tags,
    };
  }

  // Optional: A method for creating/updating that doesn't include id or imageUrl
  // if they are managed by the backend. This is useful for POST/PUT requests
  // where the body only contains fields the client can set.
  Map<String, dynamic> toJsonForUpsert() {
    return {
      'name': name,
      'description': description,
      // 'imageUrl' is typically handled via a separate file upload mechanism 
      // and its URL is set by the backend. It's usually not sent in the JSON body for creation/update.
      'dateAcquired': dateAcquired.toIso8601String(),
      'source': source,
      'tags': tags,
    };
  }
}
