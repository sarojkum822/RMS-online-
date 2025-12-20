class VaultDoc {
  final String id;
  final String title;
  final String storagePath;
  final DateTime uploadedAt;
  final String mimeType;

  VaultDoc({
    required this.id,
    required this.title,
    required this.storagePath,
    required this.uploadedAt,
    this.mimeType = 'image/jpeg',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'storagePath': storagePath,
      'uploadedAt': uploadedAt.toIso8601String(),
      'mimeType': mimeType,
    };
  }

  factory VaultDoc.fromMap(Map<String, dynamic> map, String id) {
    return VaultDoc(
      id: id,
      title: map['title'] ?? 'Untitled Doc',
      storagePath: map['storagePath'] ?? '',
      uploadedAt: DateTime.tryParse(map['uploadedAt'] ?? '') ?? DateTime.now(),
      mimeType: map['mimeType'] ?? 'image/jpeg',
    );
  }
}
