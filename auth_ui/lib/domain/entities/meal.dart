class Meal {
  final String id;
  final String name;
  final double carbs;
  final String? restaurantName;
  final String? notes;
  final String? imageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String userId;
  final bool isFavorite;

  const Meal({
    required this.id,
    required this.name,
    required this.carbs,
    this.restaurantName,
    this.notes,
    this.imageUrl,
    required this.createdAt,
    required this.updatedAt,
    required this.userId,
    this.isFavorite = false,
  });

  Meal copyWith({
    String? id,
    String? name,
    double? carbs,
    String? restaurantName,
    String? notes,
    String? imageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? userId,
    bool? isFavorite,
  }) {
    return Meal(
      id: id ?? this.id,
      name: name ?? this.name,
      carbs: carbs ?? this.carbs,
      restaurantName: restaurantName ?? this.restaurantName,
      notes: notes ?? this.notes,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      userId: userId ?? this.userId,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Meal &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          carbs == other.carbs &&
          restaurantName == other.restaurantName &&
          notes == other.notes &&
          imageUrl == other.imageUrl &&
          createdAt == other.createdAt &&
          updatedAt == other.updatedAt &&
          userId == other.userId &&
          isFavorite == other.isFavorite;

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      carbs.hashCode ^
      restaurantName.hashCode ^
      notes.hashCode ^
      imageUrl.hashCode ^
      createdAt.hashCode ^
      updatedAt.hashCode ^
      userId.hashCode ^
      isFavorite.hashCode;

  @override
  String toString() {
    return 'Meal{id: $id, name: $name, carbs: $carbs, restaurantName: $restaurantName, '
        'notes: $notes, imageUrl: $imageUrl, createdAt: $createdAt, '
        'updatedAt: $updatedAt, userId: $userId, isFavorite: $isFavorite}';
  }
}
